
SECTION "graphics", ROMX[$4000], BANK[1]

;db $00, $18, $24, $24, $24, $24, $18, $00
;db $00, $18, $38, $18, $18, $18, $3C, $00
;db $00, $38, $44, $04, $08, $10, $3C, $00
;db $00, $18, $24, $04, $38, $04, $38, $00
;db $00, $24, $24, $24, $3C, $04, $04, $00
;db $00, $3C, $20, $20, $3C, $04, $3C, $00
;db $00, $1C, $20, $20, $38, $24, $18, $00
;db $00, $3C, $02, $04, $08, $10, $20, $00
;db $00, $3C, $42, $42, $3C, $42, $3C, $00
;db $00, $18, $24, $24, $18, $04, $18, $00
;db $00, $18, $24, $24, $3C, $24, $24, $00
;db $00, $20, $20, $20, $38, $24, $38, $00
;db $00, $3C, $40, $40, $40, $40, $3C, $00
;db $00, $78, $44, $44, $44, $44, $78, $00
;db $00, $3C, $20, $20, $3C, $20, $3C, $00
;db $00, $3C, $20, $20, $3C, $20, $20, $00



SECTION "start",ROM0[$100]
start: 
    nop
    jp main

SECTION "title",ROM0[$134]
db "SMILEY"

SECTION "pass_string",ROM0[$3000]
db "PASS", 0

SECTION "fail_string",ROM0[$3100]
db "FAIL", 0

SECTION "mbc", ROMX,BANK[2]
db $A5, $98

SECTION "mbc2", ROMX,BANK[3]
db $29, $F7

SECTION "main",ROM0[$150]
main:

    ld hl, $FFFE
    ld sp, hl

    ; Load background with blank tiles
    ; Blank tile
    ld a, $FE
    ;ld a, $1

    ld hl, $9800
    ; Load 256 sets of 4 bytes
    ld b, $80

blank_background_wait1:
    ; Wait for V-Blank
    ld hl, $FF44
    ld a, $90
    cp [hl]
    jr nz, blank_background_wait1

    ld a, $FE
    ld hl, $9800
    ; Load 128 sets of 4 bytes
    ld b, $60

blank_background_loop1:
    
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    dec b
    jr nz, blank_background_loop1

    push hl
    
blank_background_wait2:
    ; Wait for V-Blank
    ld hl, $FF44
    ld a, $90
    cp [hl]
    jr nz, blank_background_wait2

    pop hl
    ; Load 128 sets of 4 bytes
    ld b, $60
    ld a, $FE

blank_background_loop2:
    
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    dec b
    jr nz, blank_background_loop2

    push hl
    
blank_background_wait3:
    ; Wait for V-Blank
    ld hl, $FF44
    ld a, $90
    cp [hl]
    jr nz, blank_background_wait3

    pop hl
    ; Load 128 sets of 4 bytes
    ld b, $40
    ld a, $FE

blank_background_loop3:
    
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    dec b
    jr nz, blank_background_loop3
    
    ; Load tiles from 0x4000 to 0x9000
    ld hl, $8000
    ld bc, $4000
    ld a, $20


load_tiles_loop1:

    push af
    push hl
    
load_tiles_wait:
    ; Wait for V-Blank
    ld hl, $FF44
    ld a, $90
    cp [HL]
    jr nz, load_tiles_wait

    pop hl
    
    ld d, 64

load_tiles_loop2:

    ; Load 64 bytes into VRAM
    ld a, [bc]
    ; Invert the bits. Really should just invert the file
    ; so that I can remove this line
    xor $FF
    ld [hl+], a
    inc bc
    dec d
    jr nz, load_tiles_loop2

    ; Check if we've run the loop 32 times
    pop af
    dec a
    jr nz, load_tiles_loop1

    ; All tiles are copied into VRAM

LCD_init:
    ; Wait for V-Blank
    ld hl, $FF44
    ld a, [hl]
    cp a, 144
    jp nz, LCD_init

    ; Enable LCD
    ld hl, $FF40
    ld [hl], (1 | (1 << 1) | (1 << 4) | (1 << 7))

    ; Enable External RAM
    ld hl, $0
    ld a, $0A
    ld [hl], a

    ; Fill 0 check
    ld a, $0
    call write_cart_ram
    ld a, $0
    call check_cart_ram
    
    cp $0
    jp nz, ram_check_fail

    ; Fill FF check
    ld a, $FF
    call write_cart_ram
    ld a, $FF
    call check_cart_ram
    
    cp $0
    jp nz, ram_check_fail
    
    ; Fill A5 check
    ld a, $A5
    call write_cart_ram
    ld a, $A5
    call check_cart_ram
    
    cp $0
    jp nz, ram_check_fail
    
    ; Random values check
    ld hl, $A000
    ld [hl], $67
    ld hl, $A090
    ld [hl], $C9
    ld hl, $BC93
    ld [hl], $91
    ld hl, $A723
    ld [hl], $F0
    ld hl, $BFFF
    ld [hl], $0F

    ld b, $FF
random_check_loop:
    
    ld hl, $A000
    ld a, $67
    cp [hl]
    jp nz, ram_check_fail

    ld hl, $A090
    ld a, $C9
    cp [hl]
    jp nz, ram_check_fail

    ld hl, $BC93
    ld a, $91
    cp [hl]
    jp nz, ram_check_fail

    ld hl, $A723
    ld a, $F0
    cp [hl]
    jp nz, ram_check_fail

    ld hl, $BFFF
    ld a, $0F
    cp [hl]
    jp nz, ram_check_fail

    dec b
    
    jp nz, random_check_loop


ram_check_pass:
    ld hl, $3000
    ld bc, $9800
    call write_string

    jp ram_check_end

ram_check_fail:
    ld hl, $3100
    ld bc, $9800
    call write_string

    jp ram_check_end


ram_check_end:
    jp ram_check_end


write_cart_ram:
    ld hl, $A000
    ld b, $C0
    ld c, a

write_cart_ram_loop:
    ld a, c

    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a

    ld a, h
    cp b
    jp nz, write_cart_ram_loop
    
    ret

check_cart_ram:
    ld hl, $A000
    ld b, $c0
    ld c, a

check_cart_ram_loop:
    ld a, c

    cp [hl]
    jp nz, check_cart_ram_fail

    inc hl

    ld a, h
    cp b
    jp nz, check_cart_ram_loop

    jp check_cart_ram_pass
    
check_cart_ram_pass:
    ld a, 0
    ret

check_cart_ram_fail:
    ld a, 1
    ret


    


write_string:

    ld de, $FF44
    ld a, [de]
    cp a, 144
    jp nz, write_string

write_string_loop
    ; hl: string address
    ; bc: vram address

    ; Get character
    ld a, [hl+]

    ; Check for null and exit 
    and a
    ret z

    cp $2f
    jr c, write_string_loop ; Invalid char
    
    cp $3A
    jr c, write_string_num ; Is number

    cp $40
    jr c, write_string_loop ; Invalid char
    
    cp $5B
    jr c, write_string_alpha_upper ; Is uppercase

    cp $60
    jr c, write_string_loop ; Invalid char

    cp $7B
    jr c, write_string_alpha_lower

    jr write_string_loop

write_string_num:
    ; Add 0x40 to a to get correct tile offset
    add $40
    jr write_string_cont

write_string_alpha_upper:
    ; Subtract 0x41 to get correct tile offset
    sub $41
    jr write_string_cont

write_string_alpha_lower:
    ; Subtract 0x61 to get correct tile offset
    sub $61
    jr write_string_cont

write_string_cont:

    ; Write the tile location to VRAM
    ld [bc], a

    ; Increment VRAM address for next char
    inc bc
    jr write_string_loop


    
write_byte:

    ld c, a

write_byte_sync_video
    ld hl, $FF44
    ld a, [hl]
    cp a, 144
    jp nz, write_byte_sync_video

    ld h, $98
    ld l, b

    ld a, c
    and a, $F0
    srl a
    srl a
    srl a
    srl a
    inc a

    ld [hl+], a

    ld a, c
    and a, $F
    inc a

    ld [hl+], a
    
    ret

vblank_isr:

    ; If FF82 is not 0, then we need before reading another button
    ldh a, [$82]
    and a
    jr nz, dec_button_counter

    call read_buttons

    ld b, a

    ld b, a
    and $40
    jr z, up_pressed

    ld a, b
    and $80
    jr z, down_pressed

    ld a, b
    and $4
    jr z, finish_selection

    ret

dpad_done:

    ; Fix the Y location of the arrow
    ldh a, [$81]

    sla a
    sla a
    sla a
    add $10

    ld hl, $FE00
    ld [hl], a

    ld a, $6
    ldh [$82], a

    ret

dec_button_counter:

    ldh a, [$82]
    dec a
    ldh [$82], a

    ret

up_pressed:

    ; Get the currently selected game
    ldh a, [$81]

    ; If we are already at game 0, quit
    cp $0
    jr z, dpad_done

    ; Otherwise, decrement and write value
    dec a
    ldh [$81], a
    
    jr dpad_done

down_pressed:

    ; Get the currently selected game
    ldh a, [$81]

    ld b, a

    ldh a, [$80]
    dec a

    ; Compare our position to the number of games
    ; Quit if we are at the last game
    cp a, b
    jr z, dpad_done

    ld a, b
    inc a
    ldh [$81], a
    
    jr dpad_done

finish_selection:

    ; Copy the load_poll procedure to RAM
    ld hl, load_poll
    ld bc, $C000
    ld de, load_poll_done

finish_selection_loop:
    ld a, [hl+]
    ld [bc], a
    inc bc
    
    ld a, l
    cp e
    jr nz, finish_selection_loop

    ld a, h
    cp d
    jr nz, finish_selection_loop

    ; Loaded section to RAM, jump to it

    jp $C000


read_buttons:

    ld a, $20
    ldh [$00], a

    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]

    ld b, a
    
    ld a, $10
    ldh [$00], a

    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]
    ldh a, [$00]

    and $0F

    sla b
    sla b
    sla b
    sla b

    or b

    ret



SECTION "load_poll",ROM0[$1000]

load_poll:

    ld hl, $0
    ld a, $A
    ld [hl], a
    
    ; Mark that we are ready for the game load by writing
    ; the selected game number to external RAM
    ldh a, [$81]
    ld hl, $A000
    ld [hl], a

    ld hl, $0104
    ld b, $CE

    ; Keep checking ROM until we get 0xCE at address 0x104
load_poll_loop:
    ld a, [hl]
    cp b
    jr nz, load_poll_loop

    ; Wait for a V-Blank
load_poll_vblank:
    ldh a, [$44]
    cp $90
    jr nz, load_poll_vblank

    ; The firmware has loaded the game and we can try to run it

    ; Load proper inital values to LCD

    ld a, $91
    ldh [$40], a

    ld a, $FC
    ldh [$45], a

    ; Prepare the load address
    ld sp, $FFFE
    ld hl, $100
    push hl

    ; Load proper inital values to registers

    ; Can't write HL directly
    ld hl, $11B0
    push hl
    pop af

    ld bc, $0013
    ld de, $00D8
    ld hl, $014D

    ; Pop the return address off the stack and start running the gameLCD!
    ret

load_poll_done:
