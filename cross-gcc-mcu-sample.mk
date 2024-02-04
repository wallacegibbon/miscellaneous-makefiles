CROSS_COMPILER_PREFIX = C:/MounRiver/MounRiver_Studio/toolchain/RISC-V Embedded GCC/bin/riscv-none-embed-
#CROSS_COMPILER_PREFIX = $(HOME)/MRS_Toolchain_Linux_x64_V1.80/RISC-V Embedded GCC/bin/riscv-none-embed-

OPENOCD = C:/MounRiver/MounRiver_Studio/toolchain/OpenOCD/bin/openocd.exe
OPENOCD_ARGS = -f C:/MounRiver/MounRiver_Studio/toolchain/OpenOCD/bin/wch-riscv.cfg
#OPENOCD = $(HOME)/MRS_Toolchain_Linux_x64_V1.80/OpenOCD/bin/openocd
#OPENOCD_ARGS = -f $(HOME)/MRS_Toolchain_Linux_x64_V1.80/OpenOCD/bin/wch-riscv.cfg
#OPENOCD = /usr/local/bin/openocd
#OPENOCD_ARGS = -f interface/wlink.cfg -f target/wch-riscv.cfg

ARCH = -march=rv32imafc -mabi=ilp32f
#ARCH = -march=rv32imac -mabi=ilp32
#ARCH = -march=rv32ec -mabi=ilp32e

CH32_STD_LIB_DIR = ../ch32-standard-library/ch32v30x
#CH32_STD_LIB_DIR = $(HOME)/playground/ch32-standard-library/ch32v30x

CROSS_C_SOURCE_FILES += $(wildcard $(CH32_STD_LIB_DIR)/peripheral/src/*.c)
CROSS_C_SOURCE_FILES += $(wildcard $(CH32_STD_LIB_DIR)/core/*.c)
CROSS_C_SOURCE_FILES += $(wildcard ./src/*.c)

CROSS_ASM_SOURCE_FILES += $(CH32_STD_LIB_DIR)/sample/startup.S

CROSS_C_FLAGS += -fno-common -fno-builtin -Os
CROSS_C_FLAGS += -DCHIP_CH32V30X

CROSS_LD_FLAGS += -Wl,--no-relax -specs=nosys.specs -specs=nano.specs -nostartfiles \
-T$(CH32_STD_LIB_DIR)/sample/default.ld

#CROSS_LD_FLAGS += -lm

CROSS_C_INCLUDES = $(CH32_STD_LIB_DIR)/peripheral/inc $(CH32_STD_LIB_DIR)/core \
./screen-library-mcu/ch32v ./screen-library-mcu ./src \

OPENOCD_FLASH_COMMANDS = -c "program $< verify" -c wlink_reset_resume -c exit

include ../miscellaneous-makefiles/cross-gcc-mcu.mk

