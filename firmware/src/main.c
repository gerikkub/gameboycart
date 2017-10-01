
#include <stdio.h>
#include <string.h>

#include "stm32f4xx_hal_conf.h"

#include "SEGGER_RTT.h"

#include "rtt.h"
#include "rcc.h"
#include "bsp.h"
#include "exti.h"

#include "spi_gpio.h"

#include "ff_gen_drv.h"
#include "sd_diskio.h"

struct log_data_t {
    uint32_t write_addr;
    uint32_t raw_data;
    uint32_t fixed_addr;
}__attribute__((packed));

struct log_data_t log_data[2048];

struct log_data_t* log_ptr = log_data;

uint8_t game_ram[0x8192] = {};

void run_cycle();

FATFS SDFatFs;
FIL MyFile;
DIR my_dir;
FILINFO my_finfo;
char SDPath[4];

SD_HandleTypeDef sd_handle;

int main() {

    uint8_t sdio_rx_buf[512];
    memset(sdio_rx_buf, 0, 512);

    HAL_Init();

    HAL_NVIC_EnableIRQ(SysTick_IRQn);
    __enable_irq();
    //while (1) {
    //}
    //*(uint32_t*)0xE000E100 = 0xFFFFFFFF;

    //HAL_SYSTICK_Config(180000);
    //HAL_SYSTICK_CLKSourceConfig(SYSTICK_CLKSOURCE_HCLK);

    enable_perf_clocks();
    //setup_clocks();

    // Disable WWDG
    RCC->APB1ENR &= ~(1 << 11);

    // Enable RTT (JLink) communication
    init_rtt();

    //sdio_init();

    //sd_handle.Instance = SDIO;
    //sd_handle.Init.ClockEdge = SDIO_CLOCK_EDGE_RISING;
    //sd_handle.Init.ClockBypass = SDIO_CLOCK_BYPASS_ENABLE;
    //sd_handle.Init.ClockPowerSave = SDIO_CLOCK_POWER_SAVE_DISABLE;
    //sd_handle.Init.BusWide = SDIO_BUS_WIDE_1B;
    //sd_handle.Init.HardwareFlowControl = SDIO_HARDWARE_FLOW_CONTROL_ENABLE;
    //sd_handle.Init.ClockDiv = 0;
    //sd_handle.State = HAL_SD_STATE_RESET;

    //if (HAL_SD_Init(&sd_handle) != HAL_OK) {
        //printf("Failed to init SD\r\n");
        //while (1);
    //}

    //if (HAL_SD_ReadBlocks(&sd_handle, sdio_rx_buf, 0, 1, 10000) != HAL_OK) {
        //printf("Failed to read block\r\n");
        //while (1);
    //}

    
    init_spi_gpio();

    SDPath[0] = '/';
    SDPath[1] = '\0';

    if (1) {

        if (f_mount(&SDFatFs, (const char*)SDPath, 0) != FR_OK) {
            printf("Failed to mount SD card\r\n");
        } else {

            if (f_opendir(&my_dir, (const char*)SDPath) != FR_OK) {
                printf("Failed to open directory\r\n");
            } else {

                printf("Reading %s\r\n", SDPath);
                while (1) {
                    FRESULT res;
                    if ((res = f_readdir(&my_dir, &my_finfo)) != FR_OK) {
                        printf("f_readdir failed %u\r\n", res);
                        break;
                    }

                    if (my_finfo.fname[0] == 0) {
                        break;
                    }

                    printf("%s\r\n", my_finfo.fname);

                }

                printf("Done reading files\r\n");

            }

        }
    } else {
        printf("Failed to link driver\r\n");
    }
            

    while (1);


    int resp = init_sd_card();

    printf("Resp: %.8x\r\n", resp);

    while (1) {
    }

    init_all_pins();

    GPIOB->OSPEEDR = 0xFFFFFFFF;
    GPIOC->OSPEEDR = 0xFFFFFFFF;

    //enable_gb_clock_exti();

    printf("Printf test %X\r\n", 0xDEADBEEF);
    printf("Sysclk: %lu\r\n", HAL_RCC_GetSysClockFreq());

    __disable_irq();

    run_cycle();

    printf("Timeout\r\n");

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

void UsageFault_Handler() {

    volatile uint8_t cont = 0;

    while (cont == 0);
}

void SysTick_Handler(void) {
    HAL_IncTick();
}

