#!/usr/bin/env bash

set -euo pipefail

targets="esp32 esp32s2 esp32c3"

mkdir -p out

for target in ${targets}; do
    idf.py set-target ${target}
    idf.py bootloader partition_table
    cp build/bootloader/bootloader.bin out/bootloader-${target}.bin
    cp build/partition_table/partition-table.bin out/partition-table-${target}.bin
    cp sdkconfig out/sdkconfig
done
