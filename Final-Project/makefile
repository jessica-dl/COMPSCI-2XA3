all: sorthem

sorthem: sorthem.o asm_io.o driver.c
	gcc -m32 -o sorthem driver.c sorthem.o asm_io.o
sorthem.o: sorthem.asm asm_io.inc 
	nasm -f elf32 sorthem.asm
asm_io.o: asm_io.asm
	nasm -f elf32 -d ELF_TYPE asm_io.asm

