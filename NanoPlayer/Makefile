#Set the path where the SDK is stored
LIBDEEZER_DIR=../libdeezer/SDK
LIBDEEZER_INC_DIR=$(LIBDEEZER_DIR)/Include
LIBDEEZER_LIB_DIR=$(LIBDEEZER_DIR)/Bins/Platforms/Linux/x86_64

#Set tools and flags
CC=gcc
CFLAGS=-W -Wall -I$(LIBDEEZER_INC_DIR) -Wno-unused-parameter
LDFLAGS=-L$(LIBDEEZER_LIB_DIR) \
-Wl,-rpath=$(LIBDEEZER_LIB_DIR) \
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
