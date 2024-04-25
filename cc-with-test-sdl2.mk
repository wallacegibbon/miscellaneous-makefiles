C_SOURCE_FILES += $(wildcard ./src/*.c)
C_INCLUDES += ./src ./include

## `sdl2-config --cflags`
COMMON_C_FLAGS += -IC:/lib/SDL2-2.30.2/x86_64-w64-mingw32/include/SDL2
COMMON_C_FLAGS += -IC:/lib/SDL2_image-2.8.2/x86_64-w64-mingw32/include/SDL2
COMMON_C_FLAGS += -Dmain=SDL_main

## `sdl2-config --libs`
COMMON_LD_FLAGS += -LC:/lib/SDL2-2.30.2/x86_64-w64-mingw32/lib
COMMON_LD_FLAGS += -LC:/lib/SDL2_image-2.8.2/x86_64-w64-mingw32/lib
COMMON_LD_FLAGS += -lmingw32 -lSDL2main -lSDL2 -lSDL2_image -mwindows

include ./cc-with-test.mk

