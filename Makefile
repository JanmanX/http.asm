main.o: main.asm
	as -arch arm64 -o main.o main.asm

main.bin: main.o
	ld -o main.bin -e _start main.o -syslibroot xcrun  -e _start -arch arm64

run: main.bin
	echo "---- RUNNING ----"
	./main.bin


clean:
	rm -f main.o main.bin
	rm -f *.o
	rm -f *.out
