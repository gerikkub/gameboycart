#ifndef __GPIO_H
#define __GPIO_H

typedef enum {
    PIN_INPUT,
    PIN_OUTPUT
} PinState;

void config_pin_basic(GPIO_TypeDef* port, uint8_t pin, PinState input);

#endif
