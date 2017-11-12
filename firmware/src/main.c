
#include <stdio.h>
#include <string.h>

#include "stm32f4xx_hal_conf.h"

#include "SEGGER_RTT.h"

#include "rtt.h"
#include "rcc.h"
#include "bsp.h"
#include "exti.h"
#include "flash.h"

#include "spi_gpio.h"

#include "ff_gen_drv.h"
#include "sd_diskio.h"

#include "gb.h"

uint8_t game_ram[0x8000] = {};

int main() {

    enable_perf_clocks();
    setup_clocks();

    // Disable WWDG
    RCC->APB1ENR &= ~(1 << 11);

    // Enable RTT (JLink) communication
    init_rtt();

    init_spi_gpio();

    load_game_list();
            
    init_all_pins();
    //enable_gb_rst_exti();

    GPIOB->OSPEEDR = 0xFFFFFFFF;
    GPIOC->OSPEEDR = 0xFFFFFFFF;

    printf("Printf test %X\r\n", 0xDEADBEEF);

    //__enable_irq();
    __disable_irq();

    // Should never return!!!!
    run_game();

    while(1);

    return 0;
}

void print_data(uint8_t data_shift, uint8_t data, uint32_t addr) {
    SEGGER_RTT_printf(0, "Data: %.2X Shift: %.8X\r\n", data, data_shift);
}

void log_time(uint8_t inst_data, uint32_t end_time, uint32_t start_time) {

    uint32_t cycle_diff = end_time - start_time;

    SEGGER_RTT_printf(0, "Data: %.2X Diff: %lu\r\n", inst_data, cycle_diff);
}

void print_value_hex(uint16_t value) {
    char* hex_arr = "0123456789ABCDEF";
    char buf[6];
    buf[0] = hex_arr[(value >> 12) & 0xF];
    buf[1] = hex_arr[(value >> 8) & 0xF];
    buf[2] = hex_arr[(value >> 4) & 0xF];
    buf[3] = hex_arr[value & 0xF];
    buf[4] = '\r';
    buf[5] = '\n';

    SEGGER_RTT_WriteSkipNoLock(0, buf, 6);
}

void WWDG_IRQHandler() {

}

void _init() {

}

void HardFault_Handler(void) {
    asm("BKPT #01");

    while (1);
}

void UsageFault_Handler() {

    volatile uint8_t cont = 0;

    asm("BKPT #01");

    while (cont == 0);
}

void SysTick_Handler(void) {
    HAL_IncTick();
}

