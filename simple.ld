MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 512k
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 64k
}

SECTIONS{
    .text :
    {
        KEEP(*(.isr_vector))
        *(.text)
        *(.rodata)
        . = ALIGN(4);
        _etext = .;
    } > FLASH

    .data : AT (_etext)
    {
        _data = .;
        *(.data)
        *(.isr)
        . = ALIGN(4);
        _edata = .;
    } > SRAM

    .bss (NOLOAD) :
    {
        _bss = .;
        *(.bss)
        . = ALIGN(4);
        _ebss = .;
    } > SRAM
    _end = .;
}

