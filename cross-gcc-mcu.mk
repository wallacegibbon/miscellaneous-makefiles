CROSS_OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(CROSS_C_SOURCE_FILES:.c=.c.o)))
CROSS_OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(CROSS_ASM_SOURCE_FILES:.S=.S.o)))

CROSS_C_FLAGS += $(ARCH) -Wall -Wextra -Wno-unused -g -ffunction-sections -fdata-sections \
-Wp,-MMD,-MT"$@",-MF"$(@:.o=.d)",-MP \
$(addprefix -I, $(CROSS_C_INCLUDES))

CROSS_LD_FLAGS += $(ARCH) -Wl,--gc-sections,-Map=$@.map,--cref

CROSS_CC = "$(CROSS_COMPILER_PREFIX)gcc"
CROSS_OBJCOPY = "$(CROSS_COMPILER_PREFIX)objcopy"
CROSS_OBJDUMP = "$(CROSS_COMPILER_PREFIX)objdump"
CROSS_SIZE = "$(CROSS_COMPILER_PREFIX)size"
CROSS_GDB ?= "$(CROSS_COMPILER_PREFIX)gdb"

OPENOCD_FLASH_COMMANDS ?= -c "program $< verify reset exit"
GDB_INIT_COMMANDS ?= target extended-remote localhost:3333

BUILD_DIR ?= build
TARGET ?= target

vpath %.c $(sort $(dir $(CROSS_C_SOURCE_FILES)))
vpath %.S $(sort $(dir $(CROSS_ASM_SOURCE_FILES)))

.PHONY: all target_detail clean debug flash openocd

all: $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin target_detail

$(BUILD_DIR)/%.c.o: %.c | $(BUILD_DIR)
	@echo -e "\tcompiling $< ..."
	@$(CROSS_CC) -c -o $@ $< $(CROSS_C_FLAGS)

$(BUILD_DIR)/%.S.o: %.S | $(BUILD_DIR)
	@echo -e "\tcompiling $< ..."
	@$(CROSS_CC) -c -o $@ $< $(CROSS_C_FLAGS)

$(BUILD_DIR)/$(TARGET).elf: $(CROSS_OBJECTS)
	@echo -e "\tlinking $@ ..."
	@$(CROSS_CC) -o $@ $^ $(CROSS_LD_FLAGS)

$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
	@echo -e "\tgenerating $@ ..."
	@$(CROSS_OBJCOPY) -Oihex $< $@

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	@echo -e "\tgenerating $@ ..."
	@$(CROSS_OBJCOPY) -Obinary $< $@

$(BUILD_DIR):
	mkdir $@

target_detail: $(BUILD_DIR)/$(TARGET).elf
	@echo -e "\n\tsize of the target\n"
	@$(CROSS_OBJDUMP) -S -D $< > $<.lss
	@#$(CROSS_SIZE) --radix=16 --format=BSD $<
	@$(CROSS_SIZE) --radix=16 --format=SysV $<
	@echo -e "\n\tdone."

clean:
	@rm -rf $(BUILD_DIR)

debug: $(BUILD_DIR)/$(TARGET).elf
	$(CROSS_GDB) $< --eval-command="$(GDB_INIT_COMMANDS)"

flash: $(BUILD_DIR)/$(TARGET).hex
	$(OPENOCD) $(OPENOCD_ARGS) $(OPENOCD_FLASH_COMMANDS)

openocd:
	$(OPENOCD) $(OPENOCD_ARGS)

-include $(CROSS_OBJECTS:.o=.d)

