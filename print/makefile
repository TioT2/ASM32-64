build/print.o: print.s
	nasm -f elf64 print.s -lc -o build/print.o

build/main.o: main.c
	gcc -no-pie -nostartfiles -c -o build/main.o main.c

build: build/print.o build/main.o
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc build/main.o -lc build/print.o -o build/print

run:
	make build
	./build/print

debug:
	make build
	r2 -d ./build/print

clean:
	rm -r build/*