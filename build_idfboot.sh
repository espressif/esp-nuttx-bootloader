#!/usr/bin/env bash
#
#  Copyright (c) 2021 Espressif Systems (Shanghai) Co., Ltd.
#
# SPDX-License-Identifier: Apache-2.0
#

SCRIPT_ROOTDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")

set -eo pipefail

supported_targets=("esp32" "esp32s2" "esp32c3")

usage() {
  echo ""
  echo "USAGE: ${SCRIPT_NAME} [-h] -c <chip>"
  echo ""
  echo "Where:"
  echo "  -c <chip> Target chip (options: ${supported_targets[*]})"
  echo "  -h Show usage and terminate"
  echo ""
}

build_idfboot() {
  local target=${1}
  local build_dir=".build-${target}"
  local output_dir="${SCRIPT_ROOTDIR}/out"

  pushd "${SCRIPT_ROOTDIR}" &>/dev/null
  mkdir -p "${output_dir}" &>/dev/null

  # Build bootloader for selected target

  idf.py -B "${build_dir}" set-target "${target}"
  idf.py -B "${build_dir}" bootloader partition_table

  # Copy bootloader binary file to output directory

  cp "${build_dir}"/bootloader/bootloader.bin "${output_dir}"/bootloader-"${target}".bin
  cp "${build_dir}"/partition_table/partition-table.bin "${output_dir}"/partition-table-"${target}".bin
  mv sdkconfig "${output_dir}"/sdkconfig-"${target}"

  # Remove build directory

  rm -rf "${build_dir}" &>/dev/null

  popd &>/dev/null
}

while getopts ":hc:" arg; do
  case "${arg}" in
    c)
      chip=${OPTARG}
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

if [[ ! "${supported_targets[*]}" =~ "${chip}" ]]; then
  printf "ERROR: Target \"%s\" is not supported!\n" "${chip}"
  usage
  exit 1
fi

build_idfboot "${chip}"
