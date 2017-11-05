
SECTION "graphics", ROMX[$4000], BANK[1]

db $00, $18, $24, $24, $24, $24, $18, $00
db $00, $18, $38, $18, $18, $18, $3C, $00
db $00, $38, $44, $04, $08, $10, $3C, $00
db $00, $18, $24, $04, $38, $04, $38, $00
db $00, $24, $24, $24, $3C, $04, $04, $00
db $00, $3C, $20, $20, $3C, $04, $3C, $00
db $00, $1C, $20, $20, $38, $24, $18, $00
db $00, $3C, $02, $04, $08, $10, $20, $00
db $00, $3C, $42, $42, $3C, $42, $3C, $00
db $00, $18, $24, $24, $18, $04, $18, $00
db $00, $18, $24, $24, $3C, $24, $24, $00
db $00, $20, $20, $20, $38, $24, $38, $00
db $00, $3C, $40, $40, $40, $40, $3C, $00
db $00, $78, $44, $44, $44, $44, $78, $00
db $00, $3C, $20, $20, $3C, $20, $3C, $00
db $00, $3C, $20, $20, $3C, $20, $20, $00



SECTION "start",ROM0[$100]
start: 
    nop
    jp main

SECTION "title",ROM0[$134]
db "SMILEY"

SECTION "mbc", ROMX,BANK[2]
db $A5, $98

SECTION "mbc2", ROMX,BANK[3]
db $29, $F7

SECTION "main",ROM0[$150]
main:

    ld hl, $FFFE
    ld sp, hl

    ld hl, $FF44
    ld a, [hl]
    cp a, 144
    jp nz, main

    ld hl, $FF40
    ld [hl], (1 | (1 << 7))

    ;ld h, $98
    ;ld l, 32
    ;ld [hl], 1
    ;inc hl
    ;ld [hl], 2
    ;inc hl
    ;ld [hl], 3
    ;inc hl
    ;ld [hl], 4
    ;inc hl
    ;ld [hl], 5
    ;inc hl
    ;ld [hl], 6
    ;inc hl
    ;ld [hl], 7
    ;inc hl
    ;ld [hl], 8
    ;inc hl
    ;ld [hl], 9
    ;inc hl
    ;ld [hl], $A
    ;inc hl
    ;ld [hl], $B
    ;inc hl
    ;ld [hl], $C
    ;inc hl
    ;ld [hl], $D
    ;inc hl
    ;ld [hl], $E
    ;inc hl
    ;ld [hl], $F
    ;inc hl
    ;ld [hl], $10
    
    ld h, $90
    ld l, 16
    ld b, 64
    ld de, $4000

loop1:

    ld a, [de]
    inc de
    ld [hl+], a
    ld [hl+], a
    dec b
    jp nz, loop1


loop2_start:
    ld hl, $FF44
    ld a, [hl]
    cp a, 144
    jp nz, loop2_start

    ld h, $90
    ld l, 144
    ld b, 64
    ld de, $4040


loop2:

    ld a, [de]
    inc de
    ld [hl+], a
    ld [hl+], a
    dec b
    jp nz, loop2

    ld hl, $FF47
    ld [hl], $E4

    ;ld h, $21
    ;ld l, $00
    ;ld a, 3
    ;nop
    ;nop
    ;nop
    ;nop
    ;ld [hl], a
    ;inc a
    ;ld [hl], a
    ;inc a
    ;ld [hl], a
    ;inc a
    ;ld [hl], a
    ;inc a
    ;ld [hl], a
    ;inc a
    ;ld [hl], a
    ;inc a
    ;ld [hl], a
    ;inc a
    ;ld [hl], a

    
    ;ld a, 2
    ;ld b, 0
    ;call get_bank_byte

    ;ld b, 0
    ;call write_byte

    ;ld a, 2
    ;ld b, 1
    ;call get_bank_byte
    
    ;ld b, 3
    ;call write_byte


    ;ld a, 3
    ;ld b, 0
    ;call get_bank_byte

    ;ld b, 32
    ;call write_byte

    ;ld a, 3
    ;ld b, 1
    ;call get_bank_byte
    
    ;ld b, 35
    ;call write_byte

    ld h, $01
    ld l, $00
    ld a, $A
    ld [hl], a


    ld d, 0

loop_read:

    ld h, $A0
    ld l, $40
    ld b, $8E
    ld [hl], b

    ld a, d
    sla a
    sla a
    sla a
    sla a
    sla a
    ld b, a
    ld a, [hl]
    
    call write_byte
    
    inc d

    ld a, d
    cp a, $8
    jp nz, loop_read

end:
    jp end
    

get_bank_byte:
    
    ld h, $21
    ld l, $00
    ld [hl], a

    ld h, $40
    ld l, b

    ld a, [hl]
    ret
    
    

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

