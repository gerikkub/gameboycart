BUILDDIR = build

DEVICE = libraries/CMSIS/device/ST/STM32F4xx
CMSIS = libraries/CMSIS
LIBRARIES = libraries/STM32F4xx_HAL_Driver
SYSTEM = system
SOURCE = src
GAMES  = games
FATFS = libraries/FatFs
FATFS_DRIVERS = $(FATFS)/drivers
BSP = libraries/BSP
CARTS = src/carts

#GAME = Tetris.gb
#SOURCES += $(GAMES)/$(GAME)

SOURCES += $(LIBRARIES)/source/stm32f4xx_hal_gpio.c \
		   $(LIBRARIES)/source/stm32f4xx_hal_cortex.c \
		   $(LIBRARIES)/source/stm32f4xx_hal_rcc.c \
		   $(LIBRARIES)/source/stm32f4xx_hal_rcc_ex.c \
		   $(LIBRARIES)/source/stm32f4xx_hal_pwr.c \
		   $(LIBRARIES)/source/stm32f4xx_hal_pwr_ex.c \
		   $(LIBRARIES)/source/stm32f4xx_hal_flash.c \
		   $(LIBRARIES)/source/stm32f4xx_hal_flash_ex.c \
		   $(LIBRARIES)/source/stm32f4xx_hal_sd.c \
		   $(LIBRARIES)/source/stm32f4xx_ll_sdmmc.c \
		   $(LIBRARIES)/source/stm32f4xx_hal_dma.c \
		   $(LIBRARIES)/source/stm32f4xx_hal_dma_ex.c \
		   $(LIBRARIES)/source/stm32f4xx_hal.c 

SOURCES += $(SYSTEM)/startup_stm32f427xx.s \
		   $(SYSTEM)/system_stm32f4xx.c

SOURCES += $(SOURCE)/main.c \
		   $(SOURCE)/bsp.c \
		   $(SOURCE)/gb.c

SOURCES += $(CARTS)/selection_cart.s \
		   $(CARTS)/mbc1.s

SOURCES += $(SOURCE)/drivers/rcc.c \
		   $(SOURCE)/drivers/gpio.c \
		   $(SOURCE)/drivers/exti.c \
		   $(SOURCE)/drivers/spi_gpio.c \
		   $(SOURCE)/drivers/sdio.c \
		   $(SOURCE)/drivers/flash.c

SOURCES += $(SOURCE)/rtt/SEGGER_RTT.c
SOURCES += $(SOURCE)/rtt/SEGGER_RTT_printf.c
SOURCES += $(SOURCE)/rtt/rtt.c

SOURCES += $(SOURCE)/syscalls/SEGGER_RTT_Syscalls_GCC.c


#SOURCES += $(GAMES)/ram_test.gb
SOURCES += $(GAMES)/selection.gb


SOURCES += $(FATFS)/diskio.c \
		   $(FATFS)/ff.c \
		   $(FATFS)/ff_gen_drv.c \

#SOURCES += $(FATFS_DRIVERS)/sd_diskio.c


OBJECTS = $(addprefix $(BUILDDIR)/, $(addsuffix .o, $(basename $(SOURCES))))

GAME_SYM = $(addprefix _binary_games_, $(addsuffix _gb_start, $(basename $(GAME))))

INCLUDES += -I$(DEVICE)/include \
			-I$(LIBRARIES)/include \
			-I$(CMSIS)/include \
			-I$(SYSTEM) \
			-I$(SOURCE) \
			-I$(SOURCE)/rtt \
			-I$(SOURCE)/drivers \
			-I$(GAMES) \
			-I$(FATFS) \
			-I$(FATFS_DRIVERS) \
			-I$(CARTS) \
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

$(BUILDDIR)/games/selection.o: games/selection.gb
	echo selection
	mkdir -p $(dir $@)
	$(OBJCOPY) -I binary -O elf32-littlearm -B arm --redefine-sym _binary_games_selection_gb_start=selection_data --rename-section .data=.game_sel $< $@

$(BUILDDIR)/%.o: %.gb
	echo $(GAME_SYM)
	mkdir -p $(dir $@)
	$(OBJCOPY) -I binary -O elf32-littlearm -B arm --redefine-sym $(GAME_SYM)=game_data --rename-section .data=.game $< $@


flash: $(BIN)
	JLinkExe -Device STM32F427VI -CommanderScript $(FLASH_SCRIPT)

clean:
	rm -rf build
