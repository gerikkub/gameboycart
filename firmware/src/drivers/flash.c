
#include "stm32f4xx_hal.h"

void init_flash() {
    // Set PSIZE to (0b10) in FLASH_CR

}

void flash_unlock() {
    // Write KEY1 (0x45670123) to FLASH_KEYR
    // Write KEY2 (0xCDEF89AB) to FLASH_KEYR

    FLASH->KEYR = 0x45670123;
    FLASH->KEYR = 0xCDEF89AB;
}

void flash_lock() {
    // Set LOCK in FLASH_CR

    FLASH->CR |= FLASH_CR_LOCK;
}

void flash_erase_bank2() {

    // Check BSY in FLASH_SR
    // SET MER or MER1 in FLASH_CR
    // SET STRT bit in FLASH_CR
    // Wait for BSY

    while (FLASH->SR & FLASH_SR_BSY)
    {}

    FLASH->CR = FLASH_CR_MER2 | // Erase bank 2 (This bit is call MER1 in the datasheet...)
                FLASH_CR_STRT;  // Start the operation

    
    while (1)
    {
        uint32_t status = FLASH->SR;
        if (status & FLASH_SR_BSY) {
            break;
        }
    }
}

void flash_write_data(uint32_t* address, uint32_t* data, uint32_t words) {

    // Check BSY in FLASH_SR
    // Set PG in FLASH_CR
    // Perform writes
    // Wait for BSY flag

    while (FLASH->SR & FLASH_SR_BSY)
    {}


    while (words--) {
        FLASH->CR = (0b10 << FLASH_CR_PSIZE_Pos) |
                    FLASH_CR_PG; // Programming enable

        *address++ = *data++;

        while (FLASH->SR & FLASH_SR_BSY)
        {}
    }


    FLASH->CR &= ~(FLASH_CR_PG);
}
