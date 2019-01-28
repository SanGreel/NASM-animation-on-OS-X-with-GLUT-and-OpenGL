NASM animation on OS X with GLUT and OpenGL
===========================================

For compilation use run.sh or run in the terminal:

```sh
nasm -f macho work.asm -o work.o
gcc -framework GLUT -framework OpenGL -m32 -o work.out work.o
./work.out
```

The small article related to this repository - https://andrewkurochkin.com/portfolio/assembler-animation-on-mac-glut-and-opengl.

How it should look like

![NASM animation on OS X with GLUT and OpenGL](https://andrewkurochkin.com/media/img/post/4/159.png)
