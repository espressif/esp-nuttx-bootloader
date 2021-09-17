[![Build Status](https://github.com/espressif/esp-nuttx-bootloader/workflows/build/badge.svg)](https://github.com/espressif/esp-nuttx-bootloader/actions?query=branch%3Amain)

# Bootloader for NuttX

This repository contains build scripts for producing the binaries for the 2nd stage bootloader. There are two bootloader options:
- [IDF bootloader](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/startup.html#second-stage-bootloader) (**default** option for NuttX images)
- [MCUboot bootloader](https://github.com/mcu-tools/mcuboot/blob/main/docs/readme-espressif.md) (for loading NuttX images built with `CONFIG_ESP32_APP_FORMAT_MCUBOOT` option)

Users of NuttX RTOS can download the binaries from release artifacts in this repository.

# Downloading the latest version from Github

Binaries built from the tip of the default branch of this repository can be obtained here:

## IDF bootloader

Chip | Bootloader | Partition table
-----|------------|-----------------
ESP32 | [bootloader-esp32.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/bootloader-esp32.bin) | [partition-table-esp32.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/partition-table-esp32.bin)
ESP32-S2 | [bootloader-esp32s2.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/bootloader-esp32s2.bin) | [partition-table-esp32s2.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/partition-table-esp32s2.bin)
ESP32-C3 | [bootloader-esp32c3.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/bootloader-esp32c3.bin) | [partition-table-esp32c3.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/partition-table-esp32c3.bin)

## MCUboot bootloader

Chip | Bootloader
-----|------------
ESP32 | [mcuboot-esp32.bin](https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/mcuboot-esp32.bin)

The prebuilt bootloader image considers the following default partitioning of the chip's SPI Flash for the application slots:

Attribute | Value
----------|-------
Application Primary slot offset | 0x10000
Application Secondary slot offset | 0x110000
Application slot size | 0x100000 (1 MiB)
Scratch slot offset | 0x210000
Scratch slot size | 0x40000 (256 KiB)

# Building locally

Clone this repository and change to the newly created directory:

```bash
git clone https://github.com/espressif/esp-nuttx-bootloader.git
cd esp-nuttx-bootloader
```

Next, follow the instructions according to the bootloader choice.

## IDF bootloader

It is recommended to build the binaries inside the `espressif/idf` Docker image.

```bash
docker run --rm --user $(id -u):$(id -g) -v $PWD:/work -w /work espressif/idf:release-v4.3 ./build_idfboot.sh -c <chip>
```

The binaries will be inside `out` directory.

### Modifying sdkconfig or the partition table

When building locally, you can customize bootloader configuration and the partition table by editing [sdkconfig.defaults](sdkconfig.defaults) and [partitions.csv](partitions.csv) files.

For more information about these files, refer to the following chapters of IDF Programming Guide:

* [Partition Tables](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/partition-tables.html)
* [Bootloader](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/bootloader.html)
* [Configuration Options Reference](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/kconfig.html#configuration-options-reference)


## MCUboot bootloader

First of all, make sure the MCUboot repository and its dependencies are up-to-date:

```bash
git submodule update --init mcuboot
cd mcuboot
git submodule update --init --recursive ext/mbedtls
```

It is recommended to build the binaries inside the `espressif/idf` Docker image.

```bash
docker run --rm --user $(id -u):$(id -g) -v $PWD:/work -w /work espressif/idf:release-v4.3 ./build_mcuboot.sh -c <chip>
```

The binaries will be inside `out` directory.

### Modifying the application slots attributes

When building locally, you may customize the bootloader default attributes by editing [mcuboot.conf](mcuboot.conf) file.
Remember to mirror the customized configuration on the application firmware image.

# License

This repository and the binaries on the Releases page are distributed under Apache 2.0, the same as the license of ESP-IDF.
