

#OpenOCD GDB server, enable semihosting, program the flash, and wait for command
target extended localhost:3333
monitor reset halt
load
monitor reset init



