CROSS_COMPILE ?= arm-none-eabi-

CFLAGS = -DSTM32F429_439xx -DUSE_STDPERIPH_DRIVER -DUSE_FULL_ASSERT
CFLAGS += -ggdb3 --std=c99 -Wall -Werror
CFLAGS += -mcpu=cortex-m4 -mthumb 
CFLAGS += -fdata-sections -ffunction-sections
CFLAGS += -TSTM32F439NIHx_FLASH.ld -Wl,--gc-sections

TARGET = blink
OUTDIR = build

VENDOR = ST
PLAT = STM32F4xx

STM32_LIB = Libraries/STM32F4xx_StdPeriph_Driver
CMSIS_PLAT_SRC = $(CMSIS_LIB)/DeviceSupport/$(VENDOR)/$(PLAT)
CMSIS_LIB = Libraries/CMSIS

SRC = src/blink.c
SRC += $(CMSIS_PLAT_SRC)/system_stm32f4xx.c
SRC += $(CMSIS_PLAT_SRC)/startup/gcc_ride7/startup_stm32f429_439xx.s
SRC += $(STM32_LIB)/src/misc.c
SRC += $(STM32_LIB)/src/stm32f4xx_gpio.c
SRC += $(STM32_LIB)/src/stm32f4xx_rcc.c
OBJ := $(addprefix $(OUTDIR)/,$(patsubst %.s,%.o,$(SRC:.c=.o)))

INCDIR = inc
INCDIR += $(STM32_LIB)/inc
INCDIR += $(CMSIS_PLAT_SRC)
INCDIR += $(CMSIS_LIB)/CoreSupport
INCLUDES = $(addprefix -I,$(INCDIR))

SEMIHOSTING_FLAGS = --specs=rdimon.specs -lc -lrdimon 
.PHONY: all clean flash openocd gdb

DUMPTYPE ?= .text

OBJS = $(SRC:.c=.o)

all: $(OUTDIR)/$(TARGET).bin $(OUTDIR)/$(TARGET).lst

$(OUTDIR)/$(TARGET).bin: $(OUTDIR)/$(TARGET).elf
	@echo "    OBJCOPY "$@
	@$(CROSS_COMPILE)objcopy -Obinary $< $@
	@$(CROSS_COMPILE)size $<

$(OUTDIR)/$(TARGET).lst: $(OUTDIR)/$(TARGET).elf
	@echo "    LIST    "$@
	@$(CROSS_COMPILE)objdump -S $< > $@

$(OUTDIR)/$(TARGET).elf: $(OBJ)
	@echo "    LD      "$@
	@echo "    MAP     "$(OUTDIR)/$(TARGET).map
	@$(CROSS_COMPILE)gcc $(CFLAGS) -Wl,-Map=$(OUTDIR)/$(TARGET).map -o $@ $^

$(OUTDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "    CC      "$@
	@$(CROSS_COMPILE)gcc $(CFLAGS) $(SEMIHOSTING_FLAGS) -o $@ -c $(INCLUDES) $<

$(OUTDIR)/%.o: %.s
	@mkdir -p $(dir $@)
	@echo "    CC      "$@
	@$(CROSS_COMPILE)gcc $(CFLAGS) $(SEMIHOSTING_FLAGS) -o $@ -c $(INCLUDES) $<

clean:
	rm -rf $(OUTDIR)

flash:
	st-flash write $(OUTDIR)/$(TARGET).bin 0x8000000

dump:
	@$(CROSS_COMPILE)objdump -d -j $(DUMPTYPE)  $(OUTDIR)/$(TARGET).elf


gdb:
	@$(CROSS_COMPILE)gdb -q -x .gdbinit $(OUTDIR)/$(TARGET).elf

openocd:
	openocd -f board/stm32f4discovery.cfg
