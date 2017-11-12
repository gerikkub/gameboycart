
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

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

.global selection_cart

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

.align 16

selection_cart:
    
    push {r0-r12, lr}


    ldr r5, =selection_data

    ldr r6, =$0x4000

    ldr r7, =game_ram

    ldr r8, =GPIOA
    ldr r9, =GPIOB
    ldr r10, =GPIOC
    ldr r11, =GPIOD
    ldr r12, =GPIOE
    
sel_run_cycle_loop:

    # Wait while the clock is low
    ldr r0, [r12, IDROffset]
    tst r0, $0x20
    beq sel_run_cycle_loop

    .rept 30
    nop
    .endr

    # r0: [GPIOE->IDR]
    # Test the rd pin
    ldr r0, [r12, IDROffset]
    tst r0, $0x8
    bne sel_run_cycle_check_wr

    # r0: [GPIOC->IDR]
    ldr r0, [r10, IDROffset]

    # Check if A15 is set
    tst r0, $0x2
    bne sel_run_cycle_ram

    # r1: [GPIOA->IDR]
    # r14: [GPIOD->IDR]
    ldr r1, [r8, IDROffset]
    ldr r14, [r11, IDROffset]

    # Check the 2nd msb for the bank
    tst r0, $0x4

    # Place GB_A13 into address (r1)
    lsr r0, r0, $3
    bfi r1, r0, $13, $1

    # Place GB_A4-5 into address (r1)
    lsr r0, r14, $4
    bfi r1, r0, $4, $2

    bfc r1, $14, $2

    # Run a conditional on the previous tst
    # Tested GB_A14 to determine which bank (0 or X)
    # to read from.
    # r0: Contains the byte read from the ROM
    itee eq
    ldrbeq r0, [r5, r1]
    addne r4, r5, r6
    ldrbne r0, [r4, r1]

    # Write the MODER value to GPIOB/C
    ldr r1, =GPIOBMODER
    str r1, [r9]
    ldr r1, =GPIOCMODER
    str r1, [r10]

    # Write the ROM byte to GPIOB/C
    lsl r1, r0, $6
    str r1, [r9, ODROffset]

    str r0, [r10, ODROffset]
    
    b sel_run_cycle_loop

sel_run_cycle_ram:

    # Check A14. It should be clear for a RAM address
    tst r0, $0x4
    bne sel_run_cycle_loop

    # Check A13. It should be set for a RAM address
    tst r0, $8
    beq sel_run_cycle_loop

    # Read in the rest of the address
    # r1: [GPIOA->IDR]
    # r14: [GPIOD->IDR]
    ldr r1, [r8, IDROffset]
    ldr r14, [r11, IDROffset]

    # Place GB_A4-5 into address (r1)
    lsr r0, r14, $4
    bfi r1, r0, $4, $2

    bfc r1, $14, $2

    # We have a read from RAM
    # Clear A12-13
    bfc r1, $12, $2

    # Run a conditional on the previous tst
    # Tested GB_A14 to determine which bank (0 or X)
    # to read from.
    # r0: Contains the byte read from the ROM
    ldrb r0, [r7, r1]

    # Write the MODER value to GPIOB/C
    ldr r1, =GPIOBMODER
    str r1, [r9]
    ldr r1, =GPIOCMODER
    str r1, [r10]

    # Write the RAM byte to GPIOB/C
    lsl r1, r0, $6
    str r1, [r9, ODROffset]

    str r0, [r10, ODROffset]

    b sel_run_cycle_loop


sel_run_cycle_check_wr:

    # Set Data to High-Z
    ldr r1, =$0
    str r1, [r9]
    str r1, [r10]

    # Read in the address

    # Read address half-word into r1
    ldr r0, [r10, IDROffset]

    # r1: [GPIOA->IDR]
    # r14: [GPIOD->IDR]
    ldr r1, [r8, IDROffset]
    ldr r14, [r11, IDROffset]

    # Place GB_A13 into address (r1)
    rbit r0, r0
    lsr r0, r0, $28
    bfi r1, r0, $13, $3

    # Place GB_A4-5 into address (r1)
    lsr r0, r14, $4
    bfi r1, r0, $4, $2


    # Normally this would be a cartridge write, but not
    # when using the selection cartridge
    tst r1, $0x8000
    beq sel_run_cycle_loop

    tst r1, $0x4000
    bne sel_run_cycle_loop

    lsr r0, r1, $12
    and r0, r0, $0x3
    cmp r0, $1
    bls sel_run_cycle_loop

    # If we got here we have a RAM write

sel_run_cycle_ram_wait:
    ldr r2, [r12, IDROffset]
    tst r2, $0x4
    bne sel_run_cycle_ram_wait

    # Read data byte into r2
    ldr r2, [r10, IDROffset]
    ldr r0, [r9, IDROffset]
    lsr r0, r0, $7
    bfi r2, r0, $1, $3

    # r2 contains data byte
    # r1 contains address
    ldr r0, =0x0FFF
    and r1, r1, r0

    strb r2, [r7, r1]

    # Quit after writing ram
    b selection_cart_done
    


selection_cart_done:

    # A write to RAM is our cue to load the image
    pop {r0-r12, pc}
