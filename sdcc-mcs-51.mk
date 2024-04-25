CROSS_OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(CROSS_C_SOURCE_FILES:.c=.c.rel)))
CROSS_OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(CROSS_ASM_SOURCE_FILES:.asm=.asm.rel)))

CROSS_C_FLAGS += -mmcs51 --disable-warning 283 \
-Wp,-MMD,-MT"$@",-MF"$(@:%.rel=%.d)",-MP \
$(addprefix -I, $(CROSS_C_INCLUDES))

CROSS_LD_FLAGS += -mmcs51

CROSS_CC = "$(CROSS_COMPILER_PREFIX)sdcc"
CROSS_AS = "$(CROSS_COMPILER_PREFIX)sdas8051"
PACKIHX = "$(CROSS_COMPILER_PREFIX)packihx"

BUILD_DIR ?= build
TARGET ?= target

vpath %.c $(sort $(dir $(CROSS_C_SOURCE_FILES)))
vpath %.asm $(sort $(dir $(CROSS_ASM_SOURCE_FILES)))

.PHONY: all clean

all: $(BUILD_DIR)/$(TARGET).hex

$(BUILD_DIR)/%.c.rel: %.c | $(BUILD_DIR)
	@echo -e "\tcompiling $< ..."
	@$(CROSS_CC) -c -o $@ $< $(CROSS_C_FLAGS)

$(BUILD_DIR)/%.asm.rel: %.asm | $(BUILD_DIR)
	@echo -e "\tcompiling $< ..."
	@$(CROSS_AS) -l -s -o $@ $<

$(BUILD_DIR)/$(TARGET).ihx: $(CROSS_OBJECTS)
	@echo -e "\tlinking $@ ..."
	@$(CROSS_CC) -o $@ $^ $(CROSS_LD_FLAGS)

$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).ihx
	@echo -e "\tgenerating $@ ..."
	@$(PACKIHX) $< > $@ 2> /dev/null
	@echo -e "\n\tdone."

$(BUILD_DIR):
	mkdir $@

clean:
	@rm -rf $(BUILD_DIR)

-include $(CROSS_OBJECTS:.rel=.d)

