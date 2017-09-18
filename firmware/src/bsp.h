#ifndef __BSP_H
#define __BSP_H

#include <stdint.h>

#include "stm32f4xx_hal_conf.h"

#define PIN_GB_A0   GPIOA, 0
#define PIN_GB_A1   GPIOA, 1
#define PIN_GB_A2   GPIOA, 2
#define PIN_GB_A3   GPIOA, 3
#define PIN_GB_A4   GPIOD, 4
#define PIN_GB_A5   GPIOD, 5
#define PIN_GB_A6   GPIOA, 6
#define PIN_GB_A7   GPIOA, 7
#define PIN_GB_A8   GPIOA, 8
#define PIN_GB_A9   GPIOA, 9
#define PIN_GB_A10  GPIOA, 10
#define PIN_GB_A11  GPIOA, 11
#define PIN_GB_A12  GPIOA, 12
#define PIN_GB_A13  GPIOC, 1
#define PIN_GB_A14  GPIOC, 2
#define PIN_GB_A15  GPIOC, 3

#define PIN_GB_D0   GPIOC, 0
#define PIN_GB_D1   GPIOB, 7
#define PIN_GB_D2   GPIOB, 8
#define PIN_GB_D3   GPIOB, 9
#define PIN_GB_D4   GPIOC, 4
#define PIN_GB_D5   GPIOC, 5
#define PIN_GB_D6   GPIOC, 6
#define PIN_GB_D7   GPIOC, 7

#define PIN_GB_RST  GPIOD, 0
#define PIN_GB_WR   GPIOE, 2
#define PIN_GB_RD   GPIOE, 3
#define PIN_GB_CS   GPIOE, 4
#define PIN_GB_CLK  GPIOE, 5

#define PIN_SD_DATA0    GPIOC, 8
#define PIN_SD_DATA1    GPIOC, 9
#define PIN_SD_DATA2    GPIOC, 10
#define PIN_SD_DATA3    GPIOC, 11
#define PIN_SD_CLK      GPIOC, 12

#define GB_RST_MASK (0x1)
#define GB_WR_MASK (0x4)
#define GB_RD_MASK (0x8)
#define GB_CS_MASK (0x10)
#define GB_CLK_MASK (0x20)

#define GET_ADDR_PINS ((GPIOA->IDR & 0x1FCF) | (GPIOD->IDR & 0x0030) | ((__RBIT(GPIOC->IDR) >> 15) & 0xE000))
#define GET_ADDR_LOWER_PINS ((GPIOA->IDR & 0x0FCF) | (GPIOD->IDR & 0x0030))

#define GET_DATA_PINS (((GPIOB->IDR & 0x0380) >> 6) | (GPIOC->IDR & 0x00F1))
#define GET_CTRL_PINS ((GPIOE->IDR & 0x003C))

#define WRITE_DATA_PINS_1(x) GPIOC->ODR = (GPIOC->ODR &= ~(0x001F)) | ((x) & 0x1F)
#define WRITE_DATA_PINS_2(x) GPIOB->ODR = (GPIOB->ODR &= ~(0x0380)) | (((x) << 6) & 0x0380)

void init_all_pins();

uint32_t get_addr_pins();
uint32_t get_data_pins();
uint32_t get_ctrl_pins();

void write_data_pins(uint32_t data);

#endif
