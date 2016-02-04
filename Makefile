CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

CFLAGS = -g --std=c99
CFLAGS += -mcpu=cortex-m4 -mthumb -nostartfiles 
CFLAGS += -Tsimple.ld
SRC = blink.c
OBJS := $(addprefix $(OUTDIR)/,$(patsubst %s,%.o,$(SRC:.c=.o)) )
TARGET = blink
OUTDIR = build

.PHONY: all

OBJS = $(SRC:.c=.o)

all: $(OUTDIR)/$(TARGET).bin

$(OUTDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo " CC " $@
	@$(CC) $(CFLAGS) -o $@ -c $< 

$(OUTDIR)/$(TARGET).elf: $(OUTDIR)/$(OBJS)
	@echo " LD "$@
	@$(CC) $(CFLAGS) -o $@ $^ 

$(OUTDIR)/$(TARGET).bin: $(OUTDIR)/$(TARGET).elf
	@echo " OBJCOPY "$@
	@$(OBJCOPY) -I ihex -O binary $< $@
	$(SIZE) $<

clean:
	rm -rf $(OUTDIR)
