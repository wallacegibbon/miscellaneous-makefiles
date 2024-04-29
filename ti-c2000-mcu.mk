OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(C_SOURCE_FILES:.c=.c.obj)))
OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(ASM_SOURCE_FILES:.asm=.asm.obj)))

C_INCLUDES += $(C2000_TOOL_ROOT)/include

C_FLAGS += $(ARCH) -Ooff --preproc_with_compile --abi=coffabi \
--diag_warning=225 --diag_wrap=off --display_error_number \
--printf_support=full \
--preproc_dependency="$(@:%.obj=%.d)" \
$(addprefix -I, $(C_INCLUDES)) \

LINKER_FLAGS += $(ARCH) --diag_warning=225 --diag_wrap=off \
--display_error_number --reread_libs \
-i$(C2000_TOOL_ROOT)/lib -i$(C2000_TOOL_ROOT)/include \
--heap_size=0x400 --stack_size=0x400 \
--warn_sections -m"$@.map" --rom_model -llibc.a \

BUILD_DIR ?= build
TARGET ?= target

CL2000 = "$(C2000_TOOL_ROOT)/bin/cl2000"
HEX2000 = "$(C2000_TOOL_ROOT)/bin/hex2000"

vpath %.c $(sort $(dir $(C_SOURCE_FILES)))
vpath %.asm $(sort $(dir $(ASM_SOURCE_FILES)))

.PHONY: all clean dependents

all: $(BUILD_DIR)/$(TARGET).hex

$(BUILD_DIR)/%.c.obj: %.c | $(BUILD_DIR)
	$(CL2000) -c --output_file $@ $< $(C_FLAGS)

$(BUILD_DIR)/%.asm.obj: %.asm | $(BUILD_DIR)
	$(CL2000) -c --output_file $@ $< $(C_FLAGS)

$(BUILD_DIR)/$(TARGET).out: $(OBJECTS) $(LINKER_SCRIPTS)
	$(CL2000) --abi=coffabi --printf_support=full \
		--run_linker \
		--output_file $@ $^ $(LINKER_FLAGS)

$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).out
	$(HEX2000) --memwidth 16 --romwidth 16 --intel -o $@ $<
	rm $(TARGET).i*

$(BUILD_DIR):
	mkdir $@

clean:
	rm -rf $(BUILD_DIR)

-include $(OBJECTS:.obj=.d)

