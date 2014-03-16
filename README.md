NASM-animation-on-OS-X-with-GLUT-and-OpenGL
===========================================

For compile use ./run.sh

Or write in terminal :
nasm -f macho work.asm -o work.o
gcc -framework GLUT -framework OpenGL -m32 -o work.out work.o
./work.out
