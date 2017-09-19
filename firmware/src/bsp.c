
#include <stdint.h>

#include "stm32f4xx_hal_conf.h"

#include "gpio.h"
#include "bsp.h"

void init_all_pins() {

    config_pin_basic(PIN_GB_A0, PIN_INPUT);
    config_pin_basic(PIN_GB_A1, PIN_INPUT);
    config_pin_basic(PIN_GB_A2, PIN_INPUT);
    config_pin_basic(PIN_GB_A3, PIN_INPUT);
    config_pin_basic(PIN_GB_A4, PIN_INPUT);
    config_pin_basic(PIN_GB_A5, PIN_INPUT);
    config_pin_basic(PIN_GB_A6, PIN_INPUT);
    config_pin_basic(PIN_GB_A7, PIN_INPUT);
    config_pin_basic(PIN_GB_A8, PIN_INPUT);
    config_pin_basic(PIN_GB_A9, PIN_INPUT);
    config_pin_basic(PIN_GB_A10, PIN_INPUT);
    config_pin_basic(PIN_GB_A11, PIN_INPUT);
    config_pin_basic(PIN_GB_A12, PIN_INPUT);
    config_pin_basic(PIN_GB_A13, PIN_INPUT);
    config_pin_basic(PIN_GB_A14, PIN_INPUT);
    config_pin_basic(PIN_GB_A15, PIN_INPUT);

    config_pin_basic(PIN_GB_D0, PIN_INPUT);
    config_pin_basic(PIN_GB_D1, PIN_INPUT);
    config_pin_basic(PIN_GB_D2, PIN_INPUT);
    config_pin_basic(PIN_GB_D3, PIN_INPUT);
    config_pin_basic(PIN_GB_D4, PIN_INPUT);
    config_pin_basic(PIN_GB_D5, PIN_INPUT);
    config_pin_basic(PIN_GB_D6, PIN_INPUT);
    config_pin_basic(PIN_GB_D7, PIN_INPUT);

    config_pin_basic(PIN_GB_RST, PIN_INPUT);
    config_pin_basic(PIN_GB_WR, PIN_INPUT);
    config_pin_basic(PIN_GB_RD, PIN_INPUT);
    config_pin_basic(PIN_GB_CS, PIN_INPUT);
    config_pin_basic(PIN_GB_CLK, PIN_INPUT);

    config_pin_basic(GPIOA, 13, PIN_INPUT);
    config_pin_basic(GPIOA, 14, PIN_INPUT);
    config_pin_basic(GPIOA, 15, PIN_INPUT);
}

uint32_t get_addr_pins() {

    uint32_t pin_states;
    
    // A0-3, 6-12
    pin_states = GPIOA->IDR & 0x1FCF;

    // A4-5
    pin_states |= GPIOD->IDR & 0x0030;

    // A13-15
    pin_states |= (__RBIT(GPIOC->IDR) >> 15) & 0xE000;

    return pin_states;
}

uint32_t get_data_pins() {
    uint32_t pin_states;

    // D1-3
    pin_states = (GPIOB->IDR & 0x0380) >> 6;

    // D0, 4-7
    pin_states |= (GPIOC->IDR & 0x00F1);

    return pin_states;
}

uint32_t get_ctrl_pins() {
    // CLK, WR, RD, CS, RST

    uint32_t pin_states;

    pin_states = (GPIOE->IDR & 0x003C);

    pin_states |= (GPIOD->IDR & 0x0001);

    return pin_states;
}

void write_data_pins(uint32_t data) {
    uint32_t gpioc_state = GPIOC->ODR;

    gpioc_state &= ~(0x001F);
    GPIOC->ODR = gpioc_state | (data & 0x1F);

    uint32_t gpiob_state = GPIOB->ODR;

    gpiob_state &= ~(0x0380);
    GPIOB->ODR = gpiob_state | ((data << 6) & 0x0380);
};
            

