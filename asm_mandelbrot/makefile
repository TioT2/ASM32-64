build/main.o: src/main.s
	nasm -f elf64 src/main.s -lc -o build/main.o

build/render.o: src/render.s
	nasm -f elf64 src/render.s -lc -o build/render.o

build/print.o: src/print.s
	nasm -f elf64 src/print.s -lc -o build/print.o

build/render_init.o: src/render_init.c
	gcc -no-pie -nostartfiles -c -o build/render_init.o src/render_init.c

build: build/main.o build/print.o build/render.o build/render_init.o
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc build/render_init.o -lc build/print.o -lc build/render.o -lc build/main.o -o build/mnd

run:
	make build
	./build/mnd

debug:
	make build
	r2 -d ./build/mnd

clean:
	rm -r build/*