build/sqs.o: sqs.s
	nasm -f elf64 sqs.s -lc -o build/sqs.o

build: build/sqs.o
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc build/sqs.o -o build/sqs

run:
	make build
	./build/sqs

clean:
	rm -r build/*