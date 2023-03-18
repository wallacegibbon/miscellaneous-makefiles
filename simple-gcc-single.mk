OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(C_SOURCE_FILES:.c=.c.o)))

CC = gcc

BUILD_DIR ?= build
TARGET ?= target

C_FLAGS += $(addprefix -I, $(C_INCLUDES)) -MMD -MP -MF"$(@:%.o=%.d)"
LD_FLAGS +=

vpath %.c $(sort $(dir $(C_SOURCE_FILES)))

.PHONY: all install clean

all: $(BUILD_DIR)/$(TARGET)

$(BUILD_DIR)/%.c.o: %.c | $(BUILD_DIR)
	$(CC) $(C_FLAGS) -o $@ -c $<

$(BUILD_DIR)/$(TARGET): $(OBJECTS)
	$(CC) $(LD_FLAGS) -o $@ $^

$(BUILD_DIR):
	mkdir $@

clean:
	rm -rf build

-include $(OBJECTS:.o=.d)

