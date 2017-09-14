BUILDDIR = build

DEVICE = libraries/CMSIS/device/ST/STM32F4xx
CMSIS = libraries/CMSIS
LIBRARIES = libraries/STM32F4xx_HAL_Driver
SYSTEM = system

SOURCES += main.c

SOURCES += $(LIBRARIES)/source/stm32f4xx_hal_gpio.c \
		   $(LIBRARIES)/source/stm32f4xx_hal_cortex.c \
		   $(LIBRARIES)/source/stm32f4xx_hal.c

SOURCES += $(SYSTEM)/startup_stm32f427xx.s \
		   $(SYSTEM)/system_stm32f4xx.c

OBJECTS = $(addprefix $(BUILDDIR)/, $(addsuffix .o, $(basename $(SOURCES))))

INCLUDES += -I$(DEVICE)/include \
			-I$(LIBRARIES)/include \
			-I$(CMSIS)/include \
			-I$(SYSTEM) \
			-I.

ELF = $(BUILDDIR)/program.elf
HEX = $(BUILDDIR)/program.hex
BIN = $(BUILDDIR)/program.bin
MAP = $(BUILDDIR)/program.map

CC = arm-none-eabi-gcc
LD = arm-none-eabi-gcc
AR = arm-none-eabi-ar
OBJCOPY = arm-none-eabi-objcopy

WARNINGS = -Wall -Werror -Wno-unused-function
	
CFLAGS  = -O0 -g \
   -mcpu=cortex-m4 -mthumb \
   -mfloat-abi=soft \
   $(INCLUDES) -DUSE_STDPERIPH_DRIVER \
   -D STM32F427xx \
   -fno-omit-frame-pointer \
   $(WARNINGS)

LDSCRIPT = system/stm32_flash.ld
LDFLAGS += -T$(LDSCRIPT) -mthumb -mcpu=cortex-m4 -nostdlib -Lnewlib

LDLIBS += -lc -lm -lnosys

FLASH_SCRIPT = tools/flash.jlink

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

$(ELF): $(OBJECTS)
	$(LD) $(LDFLAGS) -Wl,-Map=$(MAP) -o $@ $(OBJECTS) $(LDLIBS)
	arm-none-eabi-size $@

$(BUILDDIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILDDIR)/%.o: %.s
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

flash: $(BIN)
	JLinkExe -Device STM32F427VI -CommanderScript $(FLASH_SCRIPT)

clean:
	rm -rf build
