## Variables you have to define before including this makefile:
## CROSS_COMPILER_PREFIX, OPENOCD, OPENOCD_ARGS, TARGET, BUILD_DIR, ARCH,
## CROSS_C_SOURCE_FILES, CROSS_ASM_SOURCE_FILES, CROSS_C_ASM_INCLUDES, CROSS_LINKER_SCRIPT
##
## Variables you can define if you need:
## CUSTOM_C_ASM_FLAGS CUSTOM_LD_FLAGS

CROSS_OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(CROSS_C_SOURCE_FILES:.c=.c.o)))
CROSS_OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(CROSS_ASM_SOURCE_FILES:.S=.S.o)))

CROSS_C_ASM_FLAGS = $(ARCH) -W -g -Os -ffunction-sections -fdata-sections \
-fno-common -fno-builtin $(CROSS_C_ASM_INCLUDES) $(CUSTOM_C_ASM_FLAGS) \

CROSS_LD_FLAGS = $(ARCH) -T$(CROSS_LINKER_SCRIPT) -nostartfiles \
-specs=nosys.specs -specs=nano.specs $(CUSTOM_LD_FLAGS) \
-Wl,--gc-sections -Wl,--no-relax -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref \

CROSS_CC = "$(CROSS_COMPILER_PREFIX)gcc"
CROSS_OBJCOPY = "$(CROSS_COMPILER_PREFIX)objcopy"
CROSS_OBJDUMP = "$(CROSS_COMPILER_PREFIX)objdump"
CROSS_SIZE = "$(CROSS_COMPILER_PREFIX)size"
CROSS_GDB = "$(CROSS_COMPILER_PREFIX)gdb"

vpath %.c $(sort $(dir $(CROSS_C_SOURCE_FILES)))
vpath %.S $(sort $(dir $(CROSS_ASM_SOURCE_FILES)))

define show-size
@echo "\n\tMemory Usage of the target:"
@$(CROSS_SIZE) --format=SysV $(1)
@echo
endef

.PHONY: all flash openocd debug clean

all: $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/%.c.o: %.c | $(BUILD_DIR)
	@echo "\tCC $< ..."
	@$(CROSS_CC) $(CROSS_C_ASM_FLAGS) -MMD -MF"$(@:%.o=%.d)" -c -o $@ $<

$(BUILD_DIR)/%.S.o: %.S | $(BUILD_DIR)
	@echo "\tAS $< ..."
	@$(CROSS_CC) $(CROSS_C_ASM_FLAGS) -MMD -MF"$(@:%.o=%.d)" -c -o $@ $<

$(BUILD_DIR)/$(TARGET).elf: $(CROSS_OBJECTS)
	@echo "\tLD $@ ..."
	@$(CROSS_CC) $(CROSS_LD_FLAGS) -o $@ $^
	@$(CROSS_OBJDUMP) -S -D $@ > $@.lss
	$(call show-size, $@)

$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
	@echo "\tGenerating HEX file ..."
	@$(CROSS_OBJCOPY) -Oihex $< $@

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	@echo "\tGenerating BIN file ..."
	@$(CROSS_OBJCOPY) -Obinary $< $@

$(BUILD_DIR):
	@mkdir $@

flash:
	@$(OPENOCD) $(OPENOCD_ARGS) \
		-c "program $(BUILD_DIR)/$(TARGET).hex verify reset exit"

openocd:
	@$(OPENOCD) $(OPENOCD_ARGS)

debug:
	@$(CROSS_GDB) $(BUILD_DIR)/$(TARGET).elf \
		--eval-command="target extended-remote localhost:3333"

clean:
	@rm -rf $(BUILD_DIR)

-include $(wildcard $(BUILD_DIR)/*.d)

