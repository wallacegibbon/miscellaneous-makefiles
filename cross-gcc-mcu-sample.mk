CROSS_COMPILER_PREFIX = $(HOME)/MRS_Toolchain_Linux_x64_V1.60/RISC-V Embedded GCC/bin/riscv-none-embed-
OPENOCD = /usr/local/bin/openocd
OPENOCD_ARGS = -f interface/wlink.cfg -f target/wch-riscv.cfg

ARCH = -march=rv32imac -mabi=ilp32
#ARCH = -march=rv32ec -mabi=ilp32e

CH32_STD_LIB_DIR = $(HOME)/playground/ch32-standard-library/ch32v20x

CROSS_C_SOURCE_FILES += $(wildcard $(CH32_STD_LIB_DIR)/peripheral/src/*.c)
CROSS_C_SOURCE_FILES += $(wildcard $(CH32_STD_LIB_DIR)/core/*.c)
CROSS_C_SOURCE_FILES += $(wildcard ./screen-library-mcu/*.c)
CROSS_C_SOURCE_FILES += $(wildcard ./screen-library-mcu/ch32v/*.c)
CROSS_C_SOURCE_FILES += $(wildcard ./src/*.c)

CROSS_ASM_SOURCE_FILES += $(CH32_STD_LIB_DIR)/sample/startup.S

CROSS_LINKER_SCRIPT = $(CH32_STD_LIB_DIR)/sample/default.ld

CROSS_C_INCLUDES = \
$(CH32_STD_LIB_DIR)/peripheral/inc $(CH32_STD_LIB_DIR)/core \
./screen-library-mcu/ch32v ./screen-library-mcu ./src \

OPENOCD_FLASH_COMMANDS = \
-c "program $< verify" -c wlink_reset_resume -c exit

include ../miscellaneous-makefiles/cross-gcc-mcu.mk

