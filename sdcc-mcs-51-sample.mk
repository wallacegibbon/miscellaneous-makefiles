CROSS_COMPILER_PREFIX = C:/Program Files/SDCC/bin/

CROSS_C_SOURCE_FILES += $(wildcard ./src/*.c)

CROSS_ASM_SOURCE_FILES +=

CROSS_C_FLAGS += --model-small --xram-size 0x0100 --xram-loc 0x0100 --code-size 0x2800

CROSS_LD_FLAGS +=
#CROSS_LD_FLAGS += -lm

CROSS_C_INCLUDES = ./src

include ./sdcc-mcs-51.mk

