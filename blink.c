#define GPIOG_CRH   (* ( ( volatile unsigned long* )( 0x40021800 + 0x00 ) ) )
#define GPIOG_ODR   (* ( ( volatile unsigned long* )( 0x40021800 + 0x14 ) ) )
#define GPIOG_BSRR  (* ( ( volatile unsigned long* )( 0x40021800 + 0x18 ) ) )
#define RCC_AHB1ENR (* ( ( volatile unsigned long* )( 0x40023800 + 0x30 ) ) )

__asm__(".word 0x20001000");
__asm__(".word main");

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

