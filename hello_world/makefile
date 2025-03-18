build/hello_world.o: hello_world.s
	nasm -f elf64 hello_world.s -o build/hello_world.o

build: build/hello_world.o
	ld build/hello_world.o -o build/hello_world

run:
	make build
	./build/hello_world

clean:
	rm -r build/*