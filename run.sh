nasm -f macho work.asm -o work.o
gcc -framework GLUT -framework OpenGL -m32 -o work.out work.o
./work.out