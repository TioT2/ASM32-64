# Main makefile

build/ql.o: ql.s
	nasm -f elf64 ql.s -lc -o build/ql.o

build/main.o: main.c
	gcc -no-pie -c -o build/main.o main.c
#	gcc -no-pie -nostartfiles -c -o build/main.o main.c

build: build/ql.o build/main.o
	gcc -no-pie -o build/print build/main.o build/ql.o
#	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc build/main.o -lc build/ql.o -o build/print

run:
	make build
	./build/print

debug:
	make build
	r2 -d ./build/print

clean:
	rm -r build/*

# makefile
