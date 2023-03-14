#TOOLCHAIN=~/toolchain/gcc-arm-none-eabi-4_9-2014q4/bin
#PREFIX=$(TOOLCHAIN)/arm-none-eabi-
PREFIX=arm-none-eabi-

ARCHFLAGS=-mthumb -mcpu=cortex-m0plus
COMMONFLAGS=-g3 -Og -Wall -Werror $(ARCHFLAGS)

CFLAGS=-I./includes -I./drivers $(COMMONFLAGS) -D CPU_MKL46Z256VLL4
LDFLAGS=$(COMMONFLAGS) --specs=nano.specs -Wl,--gc-sections,-Map,$(TARGET).map,-Tlink.ld
LDLIBS=

CC=$(PREFIX)gcc
LD=$(PREFIX)gcc
OBJCOPY=$(PREFIX)objcopy
RM=rm -f

TARGETHELLO = hello_world
TARGETLED = led_blinky

SRC=$(wildcard *.c drivers/*.c)
OBJ=$(patsubst %.c, %.o, $(SRC))

HELLO = $(filter-out pin_mux_blinky.c pin_mux_blinky.h led_blinky.c, $(SRC))
LED = $(filter-out pin_mux.c pin_mux.h hello_world.c, $(SRC))
HELLOBJ = $(patsubst %.c, %.o, $(HELLO))
LEDOBJ = $(patsubst %.c, %.o, $(LED))

all: build 
build: elf
elf: $(TARGETHELLO).elf $(TARGETLED).elf

clean:
	$(RM) $(TARGETLED).elf $(TARGETLED).map $(TARGETHELLO).elf $(TARGETHELLO).map $(HELLOBJ) $(LEDOBJ) 

$(TARGETHELLO).elf: $(HELLOBJ) 
	$(LD) $(LDFLAGS)  $(HELLOBJ) $(LDLIBS) -o $@

$(TARGETLED).elf: $(LEDOBJ) 
	$(LD) $(LDFLAGS) $(LEDOBJ) $(LDLIBS) -o $@	


flash_hello_world: all
	openocd -f openocd.cfg -c "program $(TARGETHELLO).elf verify reset exit"

flash_led_blinky: all
	openocd -f openocd.cfg -c "program $(TARGETLED).elf verify reset exit"