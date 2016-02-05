#define GPIOG_CRH   (* ( ( volatile unsigned long* )( 0x40021800 + 0x00 ) ) )
#define GPIOG_ODR   (* ( ( volatile unsigned long* )( 0x40021800 + 0x14 ) ) )
#define GPIOG_BSRR  (* ( ( volatile unsigned long* )( 0x40021800 + 0x18 ) ) )
#define RCC_AHB1ENR (* ( ( volatile unsigned long* )( 0x40023800 + 0x30 ) ) )

typedef void (*pfnISR)(void);

extern unsigned long _etext;
extern unsigned long _data;
extern unsigned long _edata;
extern unsigned long _bss;
extern unsigned long _ebss;

__asm__(".word 0x20001000");
__asm__(".word main");

void   ResetISR(void);
void   NMIException(void);
void   HardFaultException(void);

__attribute__((section(".isr_vector")))
pfnISR VectorTable[] = {
    (pfnISR)(0x20010000),
      ResetISR,
      NMIException,
      HardFaultException
};

void   ResetISR(void){
    unsigned long *src;
    unsigned long *dst; 
    src = &_etext;
    dst = &_data;
    while(dst < &_edata) 
        *dst++=*src++;
    for (dst = &_bss; dst < &_ebss; dst++) *dst = 0;
    main();
}
__attribute__((section(".isr")))
void   NMIException(void){}

__attribute__((section(".isr")))
void   HardFaultException(void){}

int main(void){
    RCC_AHB1ENR = (1<<6);    /* GPIOG ON  */
    GPIOG_CRH = 0x14000000;
    while(1){
        for (int c = 0; c < 100000; c++) {
            GPIOG_BSRR = (11<<29); 
        }
        for (int c = 0; c < 100000; c++) {
            GPIOG_BSRR = (11<<13); 
        }
    }
}

