CROSS_COMPILER_PREFIX = C:/Program Files/SDCC/bin/

CROSS_C_SOURCE_FILES += $(wildcard ./src/*.c)

CROSS_ASM_SOURCE_FILES += $(wildcard ./src/*.asm)

CROSS_C_FLAGS += --model-small

CROSS_LD_FLAGS += --iram-size 0x80 --xram-size 0x2000 --xram-loc 0x0100 --code-size 0x10000
#CROSS_LD_FLAGS += -lm

CROSS_C_INCLUDES = ./src

include ./sdcc-mcs-51.mk

