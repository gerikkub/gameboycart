
TARGET := main.gb

TILES := Zelda_tiles.bin

all: $(TARGET)

%.gb: %.o
	rgblink -o $@ $<
	dd if=$(TILES) of=$@ seek=16384 bs=1 count=2048
	rgbfix -v -p 0 -m 3 -n 1 -r 2 $@

%.o: %.asm
	rgbasm -o $@ $<
