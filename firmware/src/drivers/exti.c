
#include "stm32f4xx_hal_conf.h"

#include "SEGGER_RTT.h"

void run_cycle();

void enable_gb_clock_exti() {

    SYSCFG->EXTICR[1] = SYSCFG_EXTICR2_EXTI5_PE;
    EXTI->IMR = EXTI_IMR_IM5;
    EXTI->FTSR = EXTI_FTSR_TR5;

    NVIC_EnableIRQ(EXTI9_5_IRQn);

}

//void EXTI9_5_IRQHandler() {
    ////SEGGER_RTT_WriteString(0, "IRQ\r\n");
    //run_cycle();
    
    //EXTI->PR = EXTI_PR_PR5;

//}
