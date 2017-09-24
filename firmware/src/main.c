
#include <stdio.h>

#include "stm32f4xx_hal_conf.h"

#include "SEGGER_RTT.h"

#include "rtt.h"
#include "rcc.h"
#include "bsp.h"
#include "exti.h"

struct log_data_t {
    uint32_t write_addr;
    uint32_t raw_data;
    uint32_t fixed_addr;
}__attribute__((packed));

struct log_data_t log_data[2048];

struct log_data_t* log_ptr = log_data;

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

    run_cycle();

    printf("Exited\r\n");

    while(1);

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
