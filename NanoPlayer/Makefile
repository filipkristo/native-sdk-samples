#Set the path where the SDK is stored
SDK_DIR=../NativeSDK
SDK_INC_DIR=$(SDK_DIR)/Include
SDK_LIB_DIR=$(SDK_DIR)/Bins/Platforms

ifeq ($(OS),Windows_NT)
ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
$(info $************  WINDOWS 64 Bits  ************)
endif
ifeq ($(PROCESSOR_ARCHITECTURE),x86)
$(info $************  WINDOWS 32 Bits  ************)
endif
else
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
$(info $************  Linux  ************)
SDK_LIB_DIR:=$(addsuffix /Linux,$(SDK_LIB_DIR))
endif
ifeq ($(UNAME_S),Darwin)
$(info $************  MacOS  ************)
SDK_LIB_DIR:=$(addsuffix /MacOSX,$(SDK_LIB_DIR))
endif
UNAME_P := $(shell uname -p)
ifeq ($(UNAME_P),x86_64)
$(info $************  64 Bits  ************)
SDK_LIB_DIR:=$(addsuffix /x86_64,$(SDK_LIB_DIR))
endif
ifneq ($(filter %86,$(UNAME_P)),)
$(info $************  32 Bits  ************)
SDK_LIB_DIR:=$(addsuffix /i386,$(SDK_LIB_DIR))
endif
ifneq ($(filter arm%,$(UNAME_P)),)
$(info $************  ARM  ************)
SDK_LIB_DIR:=$(addsuffix /arm,$(SDK_LIB_DIR))
endif
endif

#Set tools and flags
CC=gcc
CFLAGS=-W -Wall -I$(SDK_INC_DIR) -Wno-unused-parameter
LDFLAGS=-L$(SDK_LIB_DIR) \
-Wl,-rpath=$(SDK_LIB_DIR) \
-ldeezer
EXEC=NanoPlayer

all: $(EXEC)

NanoPlayer: main.o
	$(CC) -o $@ $^ $(LDFLAGS)

# Build every source files
%.o: %.c
	$(CC) -o $@ -c $< $(CFLAGS)

.PHONY: clean mrproper

# Clean every temporary files
clean:
	rm -rf *.o

# Clean everything than can be generated
mrproper: clean
	rm -rf $(EXEC)
