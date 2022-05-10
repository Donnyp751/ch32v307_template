# -----------------------------------------------------------------------------
# File:        project.mk
# Description: Configuration makefile that sets up the generic Makefile
# -----------------------------------------------------------------------------
EXECUTABLE   := template_app
BUILD_DIR    := ./bin
SDK_LOCATION := ./sdk
SRC_DIRS     := ./src $(SDK_LOCATION)/src 
INC_DIRS     := ./inc $(SDK_LOCATION)/inc
STARTUP_FILE := $(SDK_LOCATION)/Startup/startup_ch32v30x_D8C.S
LIB_DIRS     := 
LIBS         := 
ADDL_SOURCES := 
CFLAGS       :=
CXXFLAGS     :=
CFLAGS       := -g -Wall -nostartfiles  -msmall-data-limit=8 -msave-restore -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common -w -Xlinker --gc-sections 
LDFLAGS      := -static
TOOLCHAIN_PREFIX := riscv64-unknown-elf-
AS := $(TOOLCHAIN_PREFIX)as
CC := $(TOOLCHAIN_PREFIX)gcc
OBJCOPY := $(TOOLCHAIN_PREFIX)objcopy
OBJDUMP := $(TOOLCHAIN_PREFIX)objdump
ARCH := rv32imafc
ABI  := ilp32f


LINKER_DIRECTORY := $(SDK_LOCATION)/Ld

DOCKER_CONTAINER_URI := ghcr.io/donnyp751/risc-v_ch32v307_build_env
DOCKER_CONTAINER_VERSION := 0.1
DOCKER_CONTAINER_SRC := /dmpi/src
DOCKER_COMMAND_PREFIX := docker run -it --rm -v $(CURDIR):$(DOCKER_CONTAINER_SRC) $(DOCKER_CONTAINER_URI):$(DOCKER_CONTAINER_VERSION)

TARGET = bare_metal