
TARGET := mbc_test.gb



all: $(TARGET)

%.gb: %.o
	rgblink -o $@ $<
	rgbfix -v -p 0 $@

%.o: %.asm
	rgbasm -o $@ $<
