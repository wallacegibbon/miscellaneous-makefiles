C_SOURCE_FILES += $(wildcard ./lib/*.c)
C_SOURCE_FILES += ./src/main.c

C_INCLUDES += ./lib ./src

TARGET = serialport-demo

LD_FLAGS += -lserialport

include ./simple-gcc-single.mk

