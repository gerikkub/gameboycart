
#include <stdio.h>

#include "stm32f4xx_hal_conf.h"

#include "SEGGER_RTT.h"

#include "rtt.h"
#include "rcc.h"
#include "bsp.h"
#include "exti.h"

#include "Tetris.gb.h"

void run_cycle();

int main() {

    enable_perf_clocks();
    setup_clocks();

    // Disable WWDG
    RCC->APB1ENR &= ~(1 << 11);

    // Enable RTT (JLink) communication
    init_rtt();

    init_all_pins();

    GPIOB->OSPEEDR = 0xFFFFFFFF;
    GPIOC->OSPEEDR = 0xFFFFFFFF;

    //enable_gb_clock_exti();

    printf("Printf test %X\r\n", 0xDEADBEEF);
    printf("Sysclk: %lu\r\n", HAL_RCC_GetSysClockFreq());

    __disable_irq();
    //__enable_irq();

    //EXTI->SWIER = 0x20;

    uint32_t cycle_diff;
    volatile uint8_t out_data;

    //while (1) {
    //}

    run_cycle();

    printf("Exited\r\n");

    while(1);

    while (1) {
    
        uint32_t cycle_start = DWT->CYCCNT;
        //uint32_t addr_pins = get_addr_pins();
        //uint32_t data_pins = get_data_pins();
        //uint32_t ctrl_pins = get_ctrl_pins();
        uint32_t addr_pins = GET_ADDR_LOWER_PINS;
        uint32_t data_pins = GET_ADDR_PINS;
        uint32_t ctrl_pins = GET_ADDR_PINS;


        if ((ctrl_pins & GB_RD_MASK) == 0) {
            out_data = gameData[addr_pins];

            //write_data_pins(out_data);
            WRITE_DATA_PINS_1(out_data);
            WRITE_DATA_PINS_2(out_data);
        }

        (void)out_data;

        uint32_t cycle_end = DWT->CYCCNT;

        (void)addr_pins;
        (void)data_pins;
        (void)ctrl_pins;

        cycle_diff = cycle_end - cycle_start;

        //printf("Addr: %.4lX Data: %.2lX Ctrl: %.2lX\r\n", addr_pins, data_pins, ctrl_pins);
        printf("Diff: %lu\r\n", cycle_diff);

        //volatile int i;
        //for (i = 0; i < 10000; i++) {
        //}
    
    }

    return 0;
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
