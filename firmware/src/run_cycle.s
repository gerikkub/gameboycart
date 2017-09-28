
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.extern game_data

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


    ldr r5, =game_data

    ldr r6, =game_data
    add r6, r6, $0x4000

    ldr r7, =game_ram

    ldr r8, =GPIOA
    ldr r9, =GPIOB
    ldr r10, =GPIOC
    ldr r11, =GPIOD
    ldr r12, =GPIOE
    
run_cycle_loop:

    #ldr r0, =CYCCNT
    #ldr lr, [r0]

    # Wait while the clock is low
    ldr r0, [r12, IDROffset]
    tst r0, $0x20
    beq run_cycle_loop

    .rept 32
    nop
    .endr

    # r0: [GPIOE->IDR]
    # Test the rd pin
    ldr r0, [r12, IDROffset]
    tst r0, $0x8
    bne run_cycle_check_wr

    # r0: [GPIOC->IDR]
    ldr r0, [r10, IDROffset]

    # Check if A15 is set
    tst r0, $0x2
    bne run_cycle_ram

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
    ite eq
    ldrbeq r0, [r5, r1]
    ldrbne r0, [r6, r1]

    # Write the MODER value to GPIOB/C
    ldr r1, =GPIOBMODER
    str r1, [r9]
    ldr r1, =GPIOCMODER
    str r1, [r10]

    # Write the ROM byte to GPIOB/C
    lsl r1, r0, $6
    str r1, [r9, ODROffset]

    str r0, [r10, ODROffset]
    
    b run_cycle_loop

run_cycle_ram:

    # Check A14. It should be clear for a RAM address
    tst r0, $0x4
    bne run_cycle_loop

    # Check A13. It should be set for a RAM address
    tst r0, $8
    beq run_cycle_loop

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
    
    b run_cycle_loop


run_cycle_check_wr:

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


    tst r1, $0x8000
    beq run_cycle_write_mbc1

    tst r1, $0x4000
    bne run_cycle_loop

    lsr r0, r1, $12
    and r0, r0, $0x3
    cmp r0, $1
    bls run_cycle_loop

    # If we got here we have a RAM write

run_cycle_ram_wait:
    ldr r2, [r12, IDROffset]
    tst r2, $0x4
    bne run_cycle_ram_wait

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

    #ldr r2, =log_ptr
    #ldr r2, [r2]
    #stmia r2!, {r1, r2, r7}
    #ldr r0, =log_ptr
    #str r2, [r0]

    b run_cycle_loop
    



run_cycle_write_mbc1:

    # Check if the address is for us
    cmp r1, $0x3
    bhi run_cycle_loop
    
    cmp r1, $0x1
    bls run_cycle_loop
    
    # Address is for us
    # Wait until WR goes low to read in data

run_cycle_check_wr_wait:
    ldr r2, [r12, IDROffset]
    tst r2, $0x4
    bne run_cycle_check_wr_wait

    # Read data byte into r2
    ldr r2, [r10, IDROffset]
    ldr r1, [r9, IDROffset]
    lsr r1, r1, $7
    bfi r2, r1, $1, $3

    #ldr r1, =log_ptr
    #ldr r1, [r1]
    #stmia r1!, {r0, r2}

    # Assume for now that the address is for setting the memory bank
    
    # Only the bottom 5 bits of the data are used
    and r0, r2, $0x1F
    
    # If data is 0, increment it by one
    cmp r0, $0
    bne run_cycle_check_wr_cont

    add r0, r0, $1

run_cycle_check_wr_cont:
    
    # Generate the bank offset
    lsl r0, r0, $14
    add r6, r5, r0

    #push {r2-r3, lr}

    #bl print_data

    #pop {r2-r3, lr}

    #stmia r1!, {r2}
    #ldr r0, =log_ptr
    #str r1, [r0]
    
    # Go back to the loop
    b run_cycle_loop
    
