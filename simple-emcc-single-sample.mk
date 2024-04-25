C_SOURCE_FILES += $(wildcard ./screen-library-mcu/*.c)
C_SOURCE_FILES += $(wildcard ./screen-library-mcu/sdlv1/*.c)
C_SOURCE_FILES += $(wildcard ./src/*.c)

C_INCLUDES += ./src ./screen-library-mcu ./screen-library-mcu/sdlv1

TARGET = serialport-demo-sdlv1

C_FLAGS += $(shell sdl-config --cflags)
LD_FLAGS += $(shell sdl-config --libs)

include ./simple-emcc-single.mk

