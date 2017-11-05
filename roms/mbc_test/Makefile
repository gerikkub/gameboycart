
TARGET := mbc_test.gb



all: $(TARGET)

%.gb: %.o
	rgblink -o $@ $<
	rgbfix -v -p 0 -m 3 -n 1 -r 2 $@

%.o: %.asm
	rgbasm -o $@ $<

clean:
	rm *.gb *.c *.o *.sav

