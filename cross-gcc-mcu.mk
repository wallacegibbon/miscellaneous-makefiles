## Variables you have to define before including this makefile:
## CROSS_COMPILER_PREFIX, ARCH, OPENOCD, OPENOCD_ARGS, CROSS_LINKER_SCRIPT
## CROSS_C_SOURCE_FILES, CROSS_ASM_SOURCE_FILES, CROSS_C_ASM_INCLUDES,

CROSS_OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(CROSS_C_SOURCE_FILES:.c=.c.o)))
CROSS_OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(CROSS_ASM_SOURCE_FILES:.S=.S.o)))

vpath %.c $(sort $(dir $(CROSS_C_SOURCE_FILES)))
vpath %.S $(sort $(dir $(CROSS_ASM_SOURCE_FILES)))

OPENOCD_FLASH_COMMANDS ?= verify reset exit
GDB_INIT_COMMANDS ?= target extended-remote localhost:3333

CROSS_CC = "$(CROSS_COMPILER_PREFIX)gcc"
CROSS_OBJCOPY = "$(CROSS_COMPILER_PREFIX)objcopy"
CROSS_OBJDUMP = "$(CROSS_COMPILER_PREFIX)objdump"
CROSS_SIZE = "$(CROSS_COMPILER_PREFIX)size"
CROSS_GDB ?= "$(CROSS_COMPILER_PREFIX)gdb"

BUILD_DIR ?= build
TARGET ?= target

CROSS_C_ASM_FLAGS += $(ARCH) -W -g -Os -ffunction-sections -fdata-sections \
-fno-common -fno-builtin $(CROSS_C_ASM_INCLUDES) \

CROSS_LD_FLAGS += $(ARCH) -T$(CROSS_LINKER_SCRIPT) -nostartfiles \
-Wl,--gc-sections -Wl,--no-relax -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref \
-specs=nosys.specs -specs=nano.specs \

define show-size
@echo "\n\tMemory Usage of the target:\n"
@$(CROSS_SIZE) --radix=16 --format=SysV $(1) | sed -e 's/\(.*\)/\t\1/'
endef

define openocd-flash
@$(OPENOCD) $(OPENOCD_ARGS) -c "program $(1) $(OPENOCD_FLASH_COMMANDS)"
endef

define gdb-connect
@$(CROSS_GDB) $(1) --eval-command="$(GDB_INIT_COMMANDS)"
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
	$(call openocd-flash, $(BUILD_DIR)/$(TARGET).hex)

openocd:
	@$(OPENOCD) $(OPENOCD_ARGS)

debug:
	$(call gdb-connect, $(BUILD_DIR)/$(TARGET).elf)

clean:
	@rm -rf $(BUILD_DIR)

-include $(wildcard $(BUILD_DIR)/*.d)

