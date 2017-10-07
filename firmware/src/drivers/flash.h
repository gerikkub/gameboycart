#ifndef __FLASH_H
#define __FLASH_H

#include "stm32f4xx_hal.h"

void init_flash();
void flash_unlock();
void flash_lock();
void flash_erase_bank2();
void flash_write_data(uint32_t* address, uint32_t* data, uint32_t words);

#endif
