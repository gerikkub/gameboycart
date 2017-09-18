
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.extern gameData

.extern log_time

.set GPIOA, 0x40020000
.set GPIOB, 0x40020400
.set GPIOC, 0x40020800
.set GPIOD, 0x40020C00
.set GPIOE, 0x40021000

.set CYCCNT, 0xE0001004

.set IDROffset, 0x10
.set ODROffset, 0x14

.set GPIOBMODER, 0x00054000
.set GPIOCMODER, 0x00005501

# GPIOA: 0x4002 0000
# GPIOB: 0x4002 0400
# GPIOC: 0x4002 0800
# GPIOD: 0x4002 0C00
# GPIOE: 0x4002 1000

# IDR Offset: 0x10
# ODR Offset: 0x14

.global run_cycle

# r0: 
# r1: 
# r2: 
# r3:
# r4:
# r5: gameData
# r6: GPIOB->ODR
# r7: GPIOC->ODR
# r8: GPIOA->IDR
# r9: GPIOB->IDR
# r10: GPIOC->IDR
# r11: GPIOD->IDR
# r12: GPIOE->IDR
run_cycle:
    
    push {r0-r12, lr}

    ldr r5, =gameData

    ldr r6, =GPIOB
    add r6, r6, ODROffset

    ldr r7, =GPIOC
    add r7, r7, ODROffset

    ldr r8, =GPIOA
    add r8, r8, IDROffset
    
    ldr r9, =GPIOB
    add r9, r9, IDROffset
    
    ldr r10, =GPIOC
    add r10, r10, IDROffset
    
    ldr r11, =GPIOD
    add r11, r11, IDROffset
    
    ldr r12, =GPIOE
    add r12, r12, IDROffset
    
run_cycle_loop:

    #.rept 100
    #nop
    #.endr
    

    #ldr r0, =CYCCNT
    #ldr lr, [r0]

    # r0: [GPIOE->IDR]
    # r1: ctrl_pin_rd
    #ldr r0, [r12]
    #ands r1, r0, $0x8

    # Branch if Z==1 (RD pin is set)
    #itttt ne
    #ldrne r0, =$0
    #strne r0, [r9, -IDROffset]
    #strne r0, [r10, -IDROffset]
    #bne run_cycle_loop
    #bne run_cycle_end

    # r0: [GPIOA->IDR]
    # r1: [GPIOD->IDR]
    # r2: [GPIOC->DIR]
    ldr r2, [r10]

    ands r3, r2, $0x2

    # Branch if Z==1 (Addr[15] is set)
    bne run_cycle_data_z

    # r3: addr_pins_lower
    # r4: temp

    ldr r0, [r8]
    ldr r1, [r11]

    rbit r2, r2
    lsr r2, r2, $28
    bfi r3, r2, $13, $3


    bfi r3, r0, $0, $4
    lsr r0, r0, $6
    bfi r3, r0, $6, $7

    lsr r1, r1, $4
    bfi r3, r1, $4, $2

    uxth r3, r3

    # r0: data value
    ldrb r0, [r5, r3]

    # r1: temp values for setting GPIOB->ODR
    # r2: temp values for setting GPIOC->ODR
    # r3: And mask
    #ldr r1, [r6]

    #mvn r3, $0x0380
    #and r1, r1, r3

    #ldr r2, [r7]
    #mvn r3, $0x00F1
    #and r2, r2, r3

    # r3: temp out data for GPIOB->ODR
    lsl r3, r0, $6
    and r3, r3, $0x0380
    #orr r1, r1, r3
    str r3, [r6]

    # r3: temp out data for GPIOC->ODR
    and r3, r0, $0x00F1
    #orr r2, r2, r3
    str r3, [r7]

    # Set Data pins to output
    # r1: Value to set MODER
    ldr r1, =GPIOBMODER
    str r1, [r9, -IDROffset]

    ldr r1, =GPIOCMODER
    str r1, [r10, -IDROffset]
    
    #ldr r2, =CYCCNT
    #ldr r1, [r2]
    #orr r2, lr, 0

    # Save r12 in r4
    #orr r4, r12, $0

    #bl log_time

    #orr r12, r4, $0
   
    b run_cycle_loop

run_cycle_end:
    pop {r0-r12, pc}

run_cycle_data_z:

    ldr r0, =$0
    str r0, [r9, -IDROffset]
    str r0, [r10, -IDROffset]
    b run_cycle_loop
