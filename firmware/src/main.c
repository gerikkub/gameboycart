
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

struct log_data_t {
    uint32_t raw_data;
    uint32_t fixed_addr;
}__attribute__((packed));

struct log_data_t log_data[2048];

struct log_data_t* log_ptr = log_data;

struct game_entry_t {
    char name[16];
    uint32_t index;
};

uint8_t game_ram[0x8000] = {};

extern uint8_t* const  _game_rom_data;

void selection_cart();
void mbc1_cart();

FATFS SDFatFs;
FIL MyFile;
DIR my_dir;
FILINFO my_finfo;
char SDPath[64];

SD_HandleTypeDef sd_handle;

int main() {

    int ram_idx = 0;
    struct game_entry_t game_table[32] = {};
    uint32_t num_games = 0;

    enable_perf_clocks();
    setup_clocks();

    // Disable WWDG
    RCC->APB1ENR &= ~(1 << 11);

    // Enable RTT (JLink) communication
    init_rtt();

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

                    if (my_finfo.fname[0] == '_') {
                        continue;
                    }

                    printf("%s\r\n", my_finfo.fname);

                    char* name_end = strstr(my_finfo.fname, ".GB");
                    if (name_end != NULL) {
                        
                        // Add game to external RAM
                        uint32_t name_len = name_end - my_finfo.fname;

                        memcpy(&game_ram[ram_idx], my_finfo.fname, name_len);
                        game_ram[ram_idx + name_len] = 0;
                        ram_idx += name_len + 1;

                        // Add game to game table
                        memcpy(game_table[num_games].name, my_finfo.fname, name_len);
                        game_table[num_games].name[name_len] = '\0';

                        game_table[num_games].index = num_games;
                        
                        num_games++;
                    }

                }

                game_ram[ram_idx] = 0;

                printf("Done reading files\r\n");

            }

        }
    } else {
        printf("Failed to link driver\r\n");
    }
            
    (void)ram_idx;
    init_all_pins();

    GPIOB->OSPEEDR = 0xFFFFFFFF;
    GPIOC->OSPEEDR = 0xFFFFFFFF;

    printf("Printf test %X\r\n", 0xDEADBEEF);

    __disable_irq();

    while (1) {

        selection_cart();

        printf("Game selected!\r\n");

        init_spi_gpio();

        strcat(SDPath, game_table[game_ram[0]].name);
        strcat(SDPath, ".GB");

        printf("Loading %s\r\n", game_table[game_ram[0]].name);

        FIL fp;

        if (f_open(&fp, SDPath, FA_READ) != FR_OK) {
            printf("Error opening game at path %s\r\n", SDPath);
            while (1);
        }

        init_flash();
        flash_unlock();
        flash_erase_bank2();

        uint32_t* flash_addr = (uint32_t*)0x08100000;
        uint8_t file_buffer[4096];
        uint32_t total_bytes = 0;
        while (1) {
            unsigned int bytes_read;

            if (f_read(&fp, file_buffer, 4096, &bytes_read) != FR_OK) {
                printf("Error reading game at path %s\r\n", SDPath);
                break;
            }

            if (bytes_read == 0) {
                break;
            }

            total_bytes += bytes_read;
            printf("Read %lu bytes\r\n", total_bytes);

            uint32_t words_read;
            words_read = (bytes_read + 3) / 4;

            flash_write_data((uint32_t*)flash_addr, (uint32_t*)file_buffer, words_read);
            flash_addr += words_read;
        }

        f_close(&fp);

        //printf("Done loading game\r\n");

        //uint8_t ram_size_gb = _game_rom_data[0x149];
        //uint8_t ram_size_gb = *(uint8_t*)0x08100149;

        //if (ram_size_gb > 0) {
        if (1) {
            //printf("Loading RAM\r\n");

            strcpy(SDPath, "/");
            strcat(SDPath, game_table[game_ram[0]].name);
            strcat(SDPath, ".SAV");

            if(f_open(&fp, SDPath, FA_READ) != FR_OK) {
                printf("Error opening save file %s\r\n", SDPath);
            } else {

                unsigned int bytes_read = 0;
                uint32_t total_bytes = 0;
                while (1) {
                    if (f_read(&fp, file_buffer, 4096, &bytes_read) != FR_OK) {
                        printf("Error reading save file\r\n");
                    }

                    if (bytes_read == 0) {
                        break;
                    }

                    memcpy(&game_ram[total_bytes], file_buffer, bytes_read);

                    total_bytes += bytes_read;

                    printf("Read %lu bytes\r\n", total_bytes);
                }

                f_close(&fp);
            }
        } else {
            printf("Game has no RAM\r\n");
        }

        init_all_pins();

        while (1) {
            mbc1_cart();
        }

        printf("Game exited\r\n");

        if (f_open(&fp, SDPath, FA_WRITE | FA_CREATE_ALWAYS) != FR_OK) {
            printf("Error creating save file %s\r\n", SDPath);
        }

        uint32_t total_bytes_written = 0;
        uint32_t total_bytes_left = 0x8000;
        while (total_bytes_written != 0x8000) {

            unsigned int bytes_written = 0;

            if (f_write(&fp, &game_ram[total_bytes_written], total_bytes_left, &bytes_written) != FR_OK) {
                printf("Error writing save file\r\n");
                break;
            }

            total_bytes_written += bytes_written;
            total_bytes_left -= bytes_written;
        }

        f_close(&fp);
    }

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

