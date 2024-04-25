OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(C_SOURCE_FILES:.c=.c.o)))

C_FLAGS += -Wall -Wextra -g \
-Wp,-MMD,-MT"$@",-MF"$(@:.o=.d)",-MP \
$(addprefix -I, $(C_INCLUDES))

LD_FLAGS +=

CC = gcc

BUILD_DIR ?= build
TARGET ?= target

vpath %.c $(sort $(dir $(C_SOURCE_FILES)))

.PHONY: all clean

all: $(BUILD_DIR)/$(TARGET)

$(BUILD_DIR)/%.c.o: %.c | $(BUILD_DIR)
	$(CC) -o $@ -c $< $(C_FLAGS)

$(BUILD_DIR)/$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^ $(LD_FLAGS)

$(BUILD_DIR):
	mkdir $@

clean:
	rm -rf build

-include $(OBJECTS:.o=.d)

