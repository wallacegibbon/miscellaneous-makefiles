OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(C_SOURCE_FILES:.c=.c.o)))

C_FLAGS += -Wall -Wextra -g \
-Wp,-MMD,-MT"$@",-MF"$(@:.o=.d)",-MP \
$(addprefix -I, $(C_INCLUDES))

LD_FLAGS +=

CC = cc
AR = ar

BUILD_DIR ?= build
TARGET ?= target

vpath %.c $(sort $(dir $(C_SOURCE_FILES)))

.PHONY: all clean install

all: $(BUILD_DIR)/lib$(TARGET).a

$(BUILD_DIR)/%.c.o: %.c | $(BUILD_DIR)
	$(CC) -o $@ -c $< $(C_FLAGS)

$(BUILD_DIR)/lib$(TARGET).a: $(OBJECTS)
	$(AR) crs $@ $^

$(BUILD_DIR):
	mkdir $@

clean:
	rm -rf build

install:
	cp include/* /usr/local/include/
	cp $(BUILD_DIR)/lib$(TARGET).a /usr/local/lib/

-include $(OBJECTS:.o=.d)

