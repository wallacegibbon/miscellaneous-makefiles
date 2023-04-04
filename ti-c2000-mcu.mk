OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(C_SOURCE_FILES:.c=.c.obj)))
OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(ASM_SOURCE_FILES:.asm=.asm.obj)))

CL2000 = "$(C2000_TOOL_ROOT)/bin/cl2000"
HEX2000 = "$(C2000_TOOL_ROOT)/bin/hex2000"

BUILD_DIR ?= build
TARGET ?= target

C_FLAGS += $(ARCH) -Ooff -g --preproc_with_compile \
--diag_warning=225 --display_error_number --diag_wrap=off \
--preproc_dependency="$(@:%.obj=%.d)" \
$(addprefix -I, $(C_INCLUDES)) \

LINK_MODEL ?= --rom_model

LINKER_FLAGS += $(ARCH) --run_linker $(LINK_MODEL) \
--stack_size=0x300 --warn_sections -m"$@.map" \

vpath %.c $(sort $(dir $(C_SOURCE_FILES)))
vpath %.asm $(sort $(dir $(ASM_SOURCE_FILES)))

.PHONY: all clean dependents

all: $(BUILD_DIR)/$(TARGET).hex

$(BUILD_DIR)/%.c.obj: %.c | $(BUILD_DIR)
	$(CL2000) -c --output_file $@ $< $(C_FLAGS)

$(BUILD_DIR)/%.asm.obj: %.asm | $(BUILD_DIR)
	$(CL2000) -c --output_file $@ $< $(C_FLAGS)

$(BUILD_DIR)/$(TARGET).out: $(OBJECTS) $(LINKER_SCRIPTS)
	$(CL2000) -o $@ $^ $(LINKER_FLAGS)

$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).out
	$(HEX2000) -o $@ @< --memwidth=16 --romwidth=16 --intel

$(BUILD_DIR):
	mkdir $@

clean:
	rm -rf $(BUILD_DIR)

-include $(OBJECTS:.obj=.d)

