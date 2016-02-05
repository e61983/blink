CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
SIZE = arm-none-eabi-size
GDB = arm-none-eabi-gdb

CFLAGS = -ggdb3 --std=c99
CFLAGS += -mcpu=cortex-m4 -mthumb -nostartfiles 
CFLAGS += -Tsimple.ld
SRC = blink.c
OBJS := $(addprefix $(OUTDIR)/,$(patsubst %s,%.o,$(SRC:.c=.o)) )
TARGET = blink
OUTDIR = build

.PHONY: all clean flash openocd gdb

DUMPTYPE ?= .text

OBJS = $(SRC:.c=.o)

all: $(OUTDIR)/$(TARGET).bin

$(OUTDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo " CC " $@
	@$(CC) $(CFLAGS) -o $@ -c $< 

$(OUTDIR)/$(TARGET).elf: $(OUTDIR)/$(OBJS)
	@echo " LD "$@
	@$(CC) $(CFLAGS) -Wl,-Map=$(OUTDIR)/$(TARGET).map -o $@ $^

$(OUTDIR)/$(TARGET).bin: $(OUTDIR)/$(TARGET).elf
	@echo " OBJCOPY "$@
	@$(OBJCOPY) -I ihex -O binary $< $@
	$(SIZE) $<

clean:
	rm -rf $(OUTDIR)

flash:
	st-flash write $(OUTDIR)/$(TARGET).bin 0x8000000

dump:
	$(OBJDUMP) -d -j $(DUMPTYPE)  $(OUTDIR)/$(TARGET).elf


gdb:
	$(GDB) -q -x .gdbinit $(OUTDIR)/$(TARGET).elf

openocd:
	openocd -f board/stm32f4discovery.cfg
