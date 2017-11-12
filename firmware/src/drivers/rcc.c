
#include "stm32f4xx_hal_conf.h"

void setup_clocks() {

    RCC_OscInitTypeDef osc;

    osc.OscillatorType = RCC_OSCILLATORTYPE_HSE |
                         RCC_OSCILLATORTYPE_HSI |
                         RCC_OSCILLATORTYPE_LSE |
                         RCC_OSCILLATORTYPE_LSI;
    osc.HSEState = RCC_HSE_OFF;
    osc.LSEState = RCC_LSE_OFF;
    osc.HSIState = RCC_HSI_ON;
    osc.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
    osc.LSIState = RCC_LSI_OFF;
    osc.PLL.PLLState = RCC_PLL_ON;
    osc.PLL.PLLSource = RCC_PLLSOURCE_HSI;
    osc.PLL.PLLM = 4;
    osc.PLL.PLLN = 90;
    osc.PLL.PLLP = RCC_PLLP_DIV2;
    //osc.PLL.PLLQ = 8;

    HAL_RCC_OscConfig(&osc);

    RCC_ClkInitTypeDef clocks;

    clocks.ClockType = RCC_CLOCKTYPE_SYSCLK |
                       RCC_CLOCKTYPE_HCLK |
                       RCC_CLOCKTYPE_PCLK1 |
                       RCC_CLOCKTYPE_PCLK2;
    clocks.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    clocks.AHBCLKDivider = RCC_SYSCLK_DIV1;
    clocks.APB1CLKDivider = RCC_HCLK_DIV4;
    clocks.APB2CLKDivider = RCC_HCLK_DIV2;

    HAL_PWREx_EnableOverDrive();

    HAL_RCC_ClockConfig(&clocks, FLASH_LATENCY_5);

    FLASH->ACR |= FLASH_ACR_DCRST | // Reset Data cache
                  FLASH_ACR_ICRST;  // Reset Instruction cache

    FLASH->ACR |= FLASH_ACR_DCEN |  // Enable Data cache
                  FLASH_ACR_ICEN;   // Enable Instruction cache
                  
    //HAL_RCC_MCOConfig(RCC_MCO1, RCC_MCO1SOURCE_HSI, RCC_MCODIV_5);


    //GPIO_InitTypeDef gpio;
    //gpio.Pin = GPIO_PIN_8;
    //gpio.Mode = GPIO_MODE_OUTPUT_PP;
    //gpio.Pull = GPIO_NOPULL;
    //gpio.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
    //gpio.Alternate = GPIO_AF0_MCO;

    //HAL_GPIO_Init(GPIOA, &gpio);
}

void enable_perf_clocks() {

    // Enable all clocks
    RCC->AHB1ENR = 0xFFFFFFFF;
    RCC->AHB2ENR = 0xFFFFFFFF;
    RCC->AHB3ENR = 0xFFFFFFFF;
    RCC->APB1ENR = 0xFFFFFFFF;
    RCC->APB2ENR = 0xFFFFFFFF;
}

