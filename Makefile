NASM ?= nasm

all: bin/MM2GUS.COM

bin/MM2GUS.COM: src/MM2GUS.ASM
	mkdir -p bin
	$(NASM) -f bin $< -o $@

.PHONY: all
