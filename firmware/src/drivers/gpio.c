

#include "stm32f4xx_hal_conf.h"

#include "gpio.h"

void config_pin_basic(GPIO_TypeDef* port, uint8_t pin, PinState pin_state) {

    if (pin_state == PIN_INPUT) {

        // Set MODER bits to 00
        port->MODER &= ~(0x3 << (pin * 2));

        // Enable Pulldown
        port->PUPDR &= ~(0x3 << (pin * 2));
        port->PUPDR |= (0x2 << (pin * 2));


    } else if(pin_state == PIN_OUTPUT) {

        // Set MODR bits to 01
        port->MODER &= ~(0x3 << (pin * 2));
        port->MODER |= 0x01 << (pin * 2);

        // Set OTYPER to push-pull
        port->OTYPER &= ~(1 << pin);

        // Set OSPEEDR to very high speed
        port->OSPEEDR |= 0x3 << (pin * 2);

        // Disable Pullup-pulldown
        port->PUPDR &= ~(0x3 << (pin * 2));
    }
}


