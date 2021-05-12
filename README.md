[![Build Status](https://github.com/espressif/esp-nuttx-bootloader/workflows/build/badge.svg)](https://github.com/espressif/esp-nuttx-bootloader/actions?query=branch%3Amain)

# Bootloader and partition table for NuttX

This repository contains a minimal ESP-IDF project and build scripts used to produce 2nd stage bootloader and partition table binaries. Users of NuttX RTOS can download the binaries from release artifacts in this repository.

# Obtaining the binaries

## Downloading the latest version from Github

Binaries built from the tip of the default branch or this repository can be obtained here:

Chip | Bootloader | Partition table
-----|------------|-----------------
ESP32 | [bootloader-esp32.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/bootloader-esp32.bin) | [partition-table-esp32.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/partition-table-esp32.bin)
ESP32-S2 | [bootloader-esp32s2.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/bootloader-esp32s2.bin) | [partition-table-esp32s2.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/partition-table-esp32s2.bin)
ESP32-C3 | [bootloader-esp32c3.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/bootloader-esp32c3.bin) | [partition-table-esp32c3.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/partition-table-esp32c3.bin)

## Building locally

To build the binaries locally, it is recommended to run [build.sh](build.sh) script inside `espressif/idf` Docker image:

```bash
git clone https://github.com/espressif/esp-nuttx-bootloader.git
cd esp-nuttx-bootloader
docker run --rm -v $PWD:/work -w /work espressif/idf:release-v4.3 ./build.sh
```

The binaries will be inside `out` directory.

## Modifying sdkconfig or the partition table

When building locally, you can customize bootloader configuration and the partition table by editing [sdkconfig.defaults](sdkconfig.defaults) and [partitions.csv](partitions.csv) files.

For more information about these files, refer to the following chapters of IDF Programming Guide:

* [Partition Tables](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/partition-tables.html) 
* [Bootloader](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/bootloader.html)
* [Configuration Options Reference](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/kconfig.html#configuration-options-reference)

# License

This repository and the binaries on the Releases page are distributed under Apache 2.0, the same as the license of ESP-IDF.
