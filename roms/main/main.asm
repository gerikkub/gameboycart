
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

SECTION "test_string",ROM0[$3000]
db "TestString830", 0
db "mygb", 0
db "jenny8675", 0
db "str4", 0
db "alphabet", 0
db "zeta7", 0

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

    ; Setup palette
    ld hl, $FF47
    ld [hl], $E4

    ;ld hl, $3000
    ld hl, $A000
    ld bc, $9801

write_all_strings:

    ld a, [hl]
    and a
    jr z, write_all_strings_done

    push bc

    call write_string

    pop bc
    
    ld a, $20
    add c
    ld c, a

    jr nc, write_all_strings

    inc b
    jr write_all_strings

write_all_strings_done:

    ; Write arrow sprite

    ; Wait for V-Blank
sprite_init_vblank_wait:
    ld de, $FF44
    ld a, [de]
    cp a, 144
    jr nz, sprite_init_vblank_wait

    ld hl, $FE00
    ld a, $0
    ld b, $28

sprite_init_loop:
    ld [hl], a
    inc l
    inc l
    inc l
    inc l
    dec b
    jr nz, sprite_init_loop

    ld hl, $FE00
    ; Start at top left tile
    ld a, $10
    ld [hl+], a 
    ld a, $8
    ld [hl+], a
    ; Use arrow tile
    ld a, $37
    ld [hl+], a

    ld a, $0
    ld [hl+], a

    ld hl, $FF48
    ld a, $E4
    ld [hl+], a 

LCD_init:
    ; Wait for V-Blank
    ld hl, $FF44
    ld a, [hl]
    cp a, 144
    jp nz, LCD_init


    ; Enable LCD
    ld hl, $FF40
    ld [hl], (1 | (1 << 1) | (1 << 4) | (1 << 7))


    ; FF80 holds the selected game
    ;ld hl, $FF80
    ;ld a, 0
    ;ld [hl], a


end:
    jp end



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

