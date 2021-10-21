CC=gcc `pkgconf sdl2_image sdl2 allegro_color-5 --cflags`
LIBS=`pkgconf sdl2_image sdl2 allegro_color-5 --libs`

run: spacess
	./spacess
spacess: main.o
	$(CC) main.o $(LIBS) -o spacess
main.o: main.c
	$(CC) main.c -c
main.c: main.m4
	m4 main.m4 > main.c
clean:
	rm *exe *c *o
list-dependencies: spacess
	ldd spacess
list-dependencies-msys2: spacess
	ldd spacess | grep -v "/c/"

run-lab: lab
	./lab
lab: lab.o
	gcc lab.o -o lab
lab.o: lab.c
	gcc lab.c -c
lab.c: lab.m4
	m4 lab.m4 > lab.c
