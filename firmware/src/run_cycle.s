
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
.set GPIOMODER,  0x00055501

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
# r2: gameDataOffset
# r3: GPIOB
# r4: GPIOC
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

    ldr r2, =gameData
    add r2, r2, $0x4000

    ldr r3, =GPIOB

    ldr r4, =GPIOC

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

    #ldr r0, =CYCCNT
    #ldr lr, [r0]

    # r0: [GPIOE->IDR]
    # r1: ctrl_pin_rd
    ldr r1, [r12]
    #ands r1, r0, $0x8

    # Branch if Z==1 (RD pin is set)
    #bne run_cycle_check_wr

    # r0: [GPIOA->IDR]
    # r1: [GPIOD->IDR]
    # r2: [GPIOC->DIR]
    ldr r0, [r10]

    bfi r1, r0, $0, $2
    tst r1, $0xA
    #ands r1, r0, $0x2

    # Branch if Z==1 (Addr[15] is set)
    beq run_cycle_loop_cont2

    b run_cycle_data_z

run_cycle_loop_cont2:

    # r3: addr_pins_lower
    # r4: temp

    ldr r1, [r8]
    ldr r14, [r11]


    # Check the 2nd msb for the bank
    tsts r0, $0x4

    #rbit r0, r0
    lsr r0, r0, $3
    bfi r1, r0, $13, $1


    lsr r0, r14, $4
    bfi r1, r0, $4, $2

    #uxth r1, r1
    #bfi r1, r1, $0, 14

    # From the and condition. eq means bank 0
    ite eq
    ldrbeq r0, [r5, r1]
    ldrbne r0, [r2, r1]

    ldr r1, =GPIOMODER
    str r1, [r3]

    # r0: data value

    str r1, [r4]

    # r3: temp out data for GPIOB->ODR
    lsl r1, r0, $6

    str r1, [r6]

    # r3: temp out data for GPIOC->ODR
    str r0, [r7]

    # Set Data pins to output
    # r1: Value to set MODER
    
    #ldr r1, =CYCCNT
    #ldr r1, [r1]

    # Save r2, r12
    #push {r2, r12}

    #orr r2, lr, 0

    #bl log_time

    #pop {r2, r12}
   
    b run_cycle_loop

run_cycle_end:
    pop {r0-r12, pc}

run_cycle_check_wr:

    # Set Data to High-Z
    ldr r1, =$0
    str r0, [r3]
    str r0, [r4]

    # Check for WR==0 & CS==0
    # Assume GPIOE->IDR is already in r0
    ands r1, r0, $0x18

    # Return to loop if WR==1 || CS==1
    bne run_cycle_loop

    push {r2}

    # Read data byte into r2
    ldr r0, [r10]
    ldr r1, [r9]
    lsr r1, r1, $7
    bfi r2, r1, $1, $3

    # Read address half-word into r1
    ldr r0, [r10]
    ldr r1, [r8]

    rbit r0, r0
    lsr r0, r0, $28
    bfi r1, r0, $13, $3

    ldr r0, [r11]

    lsr r0, r0, $4
    bfi r1, r0, $4, $2

    uxth r1, r1

    pop {r2}

    # Assume for now that the address is for setting the memory bank
    
    # Only the bottom 5 bits of the data are used
    and r0, r0, $0x1F
    
    # If data is 0, increment it by one
    cmp r0, $0
    bne run_cycle_check_wr_cont

    add r0, r0, $1

run_cycle_check_wr_cont:
    
    # Generate the bank offset
    lsl r0, r0, $14
    add r2, r5, r0
    
    # Go back to the loop
    b run_cycle_loop
    
run_cycle_data_z:

    ldr r0, =$0
    str r0, [r3]
    str r0, [r4]
    b run_cycle_loop
