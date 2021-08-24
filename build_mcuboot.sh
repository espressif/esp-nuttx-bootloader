#!/usr/bin/env bash
#
#  Copyright (c) 2021 Espressif Systems (Shanghai) Co., Ltd.
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

targets="esp32"
mcuboot_config="${PWD}/mcuboot.conf"
output_dir="${PWD}/out"

mkdir -p "${output_dir}"

git submodule update --init mcuboot
pushd mcuboot &>/dev/null

git submodule update --init --recursive ext/mbedtls
cd boot/espressif

for target in ${targets}; do
    cmake -DCMAKE_TOOLCHAIN_FILE=tools/toolchain-"${target}".cmake -DMCUBOOT_TARGET="${target}" -DMCUBOOT_CONFIG_FILE="${mcuboot_config}" -DIDF_PATH="${IDF_PATH}" -B build -GNinja
    cmake --build build/
    "${IDF_PATH}"/components/esptool_py/esptool/esptool.py --chip "${target}" elf2image --flash_mode dio --flash_freq 40m -o build/mcuboot-"${target}".bin build/mcuboot_"${target}".elf
    cp build/mcuboot-"${target}".bin "${output_dir}"/mcuboot-"${target}".bin
done

popd &>/dev/null
