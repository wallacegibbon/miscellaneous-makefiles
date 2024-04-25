C2000_TOOL_ROOT := $(HOME)/ti/ccs1220/ccs/tools/compiler/ti-cgt-c2000_22.6.0.LTS

ARCH = -v28 -ml -mt --float_support=fpu32

C_SOURCE_FILES += $(wildcard ./src/*.c)

ASM_SOURCE_FILES += $(wildcard ./src/*.asm)

C_INCLUDES = src lib/include

LINKER_SCRIPTS = ./cmd/F28335_APP_FLASH.cmd ./cmd/newcmd.cmd

include ./ti-c2000-mcu.mk

