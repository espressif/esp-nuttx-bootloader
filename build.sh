#!/usr/bin/env bash

set -eo pipefail

targets="esp32 esp32c3"
suffix=""

while [ -n "${1}" ]; do
   case "${1}" in
   -m )
       shift
       mode=${1}
       ;;
   * )
       echo "Unknown option"
       exit 1
       ;;
   esac
   shift
done

mkdir -p out

echo "Building bootloader and partition table with mode=${mode}"
for target in ${targets}; do
    idf.py set-target ${target}
    if [ ${mode} = "DOUT" ]; then
        echo "CONFIG_ESPTOOLPY_FLASHMODE_DOUT=y" >> sdkconfig
        suffix="-qemu"
    fi
    idf.py bootloader partition_table
    cp build/bootloader/bootloader.bin out/bootloader-${target}${suffix}.bin
    cp build/partition_table/partition-table.bin out/partition-table-${target}${suffix}.bin
    cp sdkconfig out/sdkconfig-${target}${suffix}
done
