main.o: main.asm
	as -arch arm64 -o main.o main.asm

handler.o: handler.asm
	as -arch arm64 -o handler.o handler.asm

main.bin: main.o handler.o
	ld -o main.bin -e _start main.o handler.o  -e _start

run: main.bin
	echo "---- RUNNING ----"
	./main.bin


clean:
	rm -f main.o handler.o main.bin
	rm -f *.o
	rm -f *.out
