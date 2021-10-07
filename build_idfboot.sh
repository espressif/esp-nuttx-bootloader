#!/usr/bin/env bash
#
#  Copyright (c) 2021 Espressif Systems (Shanghai) Co., Ltd.
#
# SPDX-License-Identifier: Apache-2.0
#

SCRIPT_ROOTDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
IDF_PATH="${IDF_PATH:-${SCRIPT_ROOTDIR}/esp-idf}"

set -eo pipefail

supported_targets=("esp32" "esp32s2" "esp32c3")

usage() {
  echo ""
  echo "USAGE: ${SCRIPT_NAME} [-h] [-s] -c <chip> -f <config> -p <partinfo>"
  echo ""
  echo "Where:"
  echo "  -c <chip> Target chip (options: ${supported_targets[*]})"
  echo "  -f <config> Path to file containing bootloader configuration options"
  echo "  -p <partinfo> Path to file containing partition table information"
  echo "  -s Setup environment"
  echo "  -h Show usage and terminate"
  echo ""
}

setup() {
  if [ "${IDF_PATH}" == "${SCRIPT_ROOTDIR}/esp-idf" ]; then
    git -C "${SCRIPT_ROOTDIR}" submodule update --init esp-idf
  fi
}

build_idfboot() {
  local target=${1}
  local config=${2}
  local partinfo=${3}
  local build_dir=".build-${target}"
  local source_dir="${IDF_PATH}/components/bootloader/subproject"
  local output_dir="${SCRIPT_ROOTDIR}/out"
  local toolchain_file="${IDF_PATH}/tools/cmake/toolchain-${target}.cmake"
  local idfboot_config
  local idfboot_partinfo
  local idfboot_partoffset
  local idfboot_flashsize
  local make_generator

  idfboot_config=$(realpath "${config:-${SCRIPT_ROOTDIR}/sdkconfig.defaults}")
  idfboot_partinfo=$(realpath "${partinfo:-${SCRIPT_ROOTDIR}/partitions.csv}")

  # Try parsing Flash Size and Partition Table offset values from the sdkconfig
  # file.
  # If found, pass them to the Partition Table generator script. Otherwise, the
  # script will assume default values.

  idfboot_partoffset=$(sed -n 's/^CONFIG_PARTITION_TABLE_OFFSET=//p' "${idfboot_config}")
  if [ -n "${idfboot_partoffset}" ]; then
    idfboot_partoffset="--offset ${idfboot_partoffset}"
  fi

  idfboot_flashsize=$(sed -n 's/^CONFIG_ESPTOOLPY_FLASHSIZE_\(.*\)MB=y/\1MB/p' "${idfboot_config}")
  if [ -n "${idfboot_flashsize}" ]; then
    idfboot_flashsize="--flash-size ${idfboot_flashsize}"
  fi

  pushd "${SCRIPT_ROOTDIR}" &>/dev/null
  mkdir -p "${output_dir}" &>/dev/null

  # Build with Ninja if installed

  if command -v ninja &>/dev/null; then
    make_generator="-GNinja"
  fi

  # Build bootloader for selected target

  export IDF_PATH=${IDF_PATH}
  cmake -DCMAKE_TOOLCHAIN_FILE="${toolchain_file}"      \
        -DSDKCONFIG_DEFAULTS="${idfboot_config}"        \
        -DSDKCONFIG="${output_dir}/sdkconfig-${target}" \
        -DIDF_PATH="${IDF_PATH}"                        \
        -DIDF_TARGET="${target}"                        \
        -DPYTHON_DEPS_CHECKED=1                         \
        -B "${build_dir}"                               \
        "${make_generator}"                             \
        "${source_dir}"
  cmake --build "${build_dir}"/

  # Copy bootloader binary file to output directory

  cp "${build_dir}"/bootloader.bin "${output_dir}"/bootloader-"${target}".bin

  # Generate partition table binary file
  # shellcheck disable=SC2086 # Intentionally split words from variables

  python "${IDF_PATH}"/components/partition_table/gen_esp32part.py \
         ${idfboot_partoffset}                                     \
         ${idfboot_flashsize}                                      \
         "${idfboot_partinfo}"                                     \
         "${output_dir}"/partition-table-"${target}".bin

  # Remove build directory

  rm -rf "${build_dir}" &>/dev/null

  popd &>/dev/null
}

while getopts ":hc:f:p:s" arg; do
  case "${arg}" in
    c)
      chip=${OPTARG}
      ;;
    f)
      config=${OPTARG}
      ;;
    p)
      partinfo=${OPTARG}
      ;;
    s)
      setup
      ;;
    h)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [ -z "${chip}" ]; then
  printf "ERROR: Missing target chip.\n"
  usage
  exit 1
fi

if [ -n "${config}" ] && [ ! -f "${config}" ]; then
  printf "ERROR: Bootloader configuration file %s not found.\n" "${config}"
  usage
  exit 1
fi

if [ -n "${partinfo}" ] && [ ! -f "${partinfo}" ]; then
  printf "ERROR: Partition table file %s not found.\n" "${partinfo}"
  usage
  exit 1
fi

if [[ ! "${supported_targets[*]}" =~ "${chip}" ]]; then
  printf "ERROR: Target \"%s\" is not supported!\n" "${chip}"
  usage
  exit 1
fi

build_idfboot "${chip}" "${config}" "${partinfo}"
