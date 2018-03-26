;
; NASM animation on OS X with GLUT and OpenGL
;
; Example by SanGreel
;
; compile with:
; nasm -f macho work.asm -o work.o
; gcc -framework GLUT -framework OpenGL -m32 -o work.out work.o
; ./work.out
;

; Glut_PARAM
    %define GLUT_RGB            0
    %define GLUT_DOUBLE         0

    %define GL_POLYGON          9
    %define GL_COLOR_BUFFER_BIT 0x00004000

; frame buffer data
    %define width               400
    %define high                300

; GLUT stuff
    extern _glutCreateWindow
    extern _glutInit
    extern _glutInitDisplayMode
    extern _glutDisplayFunc
    extern _glutMainLoop
    extern _glutInitWindowPosition
    extern _glutInitWindowSize
    extern _glutSwapBuffers
    extern _glutTimerFunc
    extern _glutPostRedisplay
   extern  _glutSetWindow

; OpenGL stuff
    extern _glClearColor
    extern _glClear
    extern _glBegin
    extern _glEnd
    extern _glFlush
    extern _glVertex3f
    extern _glColor3f
    extern _glPolygonStipple

segment .data

    window_name:    db      "Ukrainian flag by SanGreel", 10, 0
    window_handle:  dd 0

    bl0             dd      0.0
    bl1             dd      1.0

    ad              dd      0.01
    su              dd     -0.01
    te              dd      0.00

    a               dd      0
    b               dd      0
    k               dd      0

    iter            dd      10

    x               dd     -0.50,  0.0,   0.25,  0.30,  0.45,  0.50, 0.50, 0.45, 0.30, 0.25, 0.0, -0.50
    t_y             dd      0.25,  0.20,  0.15,  0.16,  0.20,  0.25, 0.70, 0.68, 0.66, 0.65, 0.70, 0.75
    b_y             dd     -0.25, -0.30, -0.35, -0.34, -0.30, -0.25, 0.25, 0.21, 0.16, 0.15, 0.20, 0.25


segment .bss

    j               resb    1


segment .text

  global _main

    _main:
            lea     ecx, [esp+4]                ;load address of argc in stack to ecx
            lea     edx, [esp+8]                ;load address of argv in stack to edx

            push    ebp                         ; setup the frame
            mov     ebp, esp

            sub     esp, 24

        ;init OpenGL with GLUT
            mov     [esp+4],edx                 ;**argv
            mov     [esp],  ecx                 ;&argc
            call  _glutInit

        ;init display mode for OpenGL window
            mov     eax, GLUT_RGB
            or      eax, GLUT_DOUBLE
            mov     [esp], eax
            call  _glutInitDisplayMode

        ;define posion of OpenGL window
            mov     [esp+4],dword 80                
            mov     [esp],  dword 80
            call  _glutInitWindowPosition

        ;define OpenGL window size
            mov     [esp+4], dword high            
            mov     [esp],   dword width
            call  _glutInitWindowSize

        ;create OpenGL window
            mov     eax,   dword window_name
            mov     [esp], eax
            call  _glutCreateWindow
            mov     dword [window_handle],eax

        ;add own draw function as call back
            mov     [esp], dword _display_func
            call  _glutDisplayFunc

        ;add call back that triggers draw update(timer based)
            mov     [esp+8], dword 0
            mov     [esp+4], dword _timer_func
            mov     [esp], dword 100
            call  _glutTimerFunc

        ;start OpenGL main loop
            call  _glutMainLoop
            ret


    _timer_func:
            sub     esp,28

        ;select OpenGL window
            mov     eax,   [window_handle]
            mov     [esp], eax
            call  _glutSetWindow

        ;start redraw of OpenGL
            call    _glutPostRedisplay

        ;restart timer
            mov     [esp+8], dword 0
            mov     [esp+4], dword  _timer_func
            mov     [esp],   dword 100
            call  _glutTimerFunc

            add     esp,28
            ret


    _display_func:
            sub     esp, 12
            call  _draw
            add     esp, 12

            sub    esp, 12
            call  _recoord
            add    esp, 12
            ret


    _draw:
            sub     esp,8
            push    dword GL_COLOR_BUFFER_BIT
            call  _glClear
            add     esp,12

            sub     esp,8
            push    dword GL_POLYGON
            call  _glBegin
            add     esp,12

            push    dword [bl1]
            push    dword [bl0]
            push    dword [bl0]
            call  _glColor3f
            add     esp,12

            sub     esp,12
            mov byte [j], 0
            call  _draw_t
            add     esp,12

        ; Draw blue
            sub     esp,12
            call  _glEnd
            add     esp,12

            sub     esp,8
            push    dword GL_POLYGON
            call  _glBegin
            add     esp,12

            push    dword [bl0]
            push    dword [bl1]
            push    dword [bl1]
            call  _glColor3f
            add     esp,12

        ; Draw Yellow
            sub     esp,12
            mov byte [j], 0
            call  _draw_b
            add     esp,12

            sub     esp,12
            call  _glEnd
            add     esp,12

            sub     esp,12
            call  _glutSwapBuffers
            add     esp,12

            ret

      
    _draw_t:
            mov     ecx, 0
            mov     ecx, [j]

            push    dword 0
            push    dword [t_y+ecx*4]
            push    dword [x+ecx*4]

            call  _glVertex3f
            add     esp,12

            inc     byte [j]
            cmp     byte [j],12
            jne     _draw_t
            ret


    _draw_b:
            mov ecx, 0
            mov ecx, [j]

            push    dword 0
            push    dword [b_y+ecx*4]
            push    dword [x+ecx*4]

            call  _glVertex3f
            add     esp,12

            inc     byte [j]
            cmp     byte [j],12
            jne   _draw_b
            ret


    _recoord:
            sub     esp, 12
            call  _direction
            add     esp, 12

            sub     esp, 12
            mov     byte [j], 1
            call  _loop_recoord
            add     esp, 12
            ret


    _loop_recoord:
            mov     eax, 0
            mov     eax, [j]

            sub     esp, 12
            call  _change_y
            add     esp, 12

            inc     byte [j]
            cmp     byte [j],11
            jne   _loop_recoord
            ret


    _change_y:
            fld     dword [t_y+eax*4]
            fadd    dword [te]
            fstp    dword [t_y+eax*4]

            fld     dword [b_y+eax*4]
            fadd    dword [te]
            fstp    dword [b_y+eax*4]
            ret


    _direction:
            cmp     dword [k], 0
            je     if_k_z
            jne    if_k_o
            ret


    if_a_iter:
            mov     dword [k], 1
            mov     dword [b], 0
            ret

    if_b_iter:
            mov     dword [k], 0
            mov     dword [a], 0
            ret

    if_k_z:
            mov     edx, dword [ad]
            mov     dword [te] , edx

            mov     edx, [a]
            cmp     edx, [iter]
            je     if_a_iter
            inc     dword [a]
            ret

    if_k_o:
            mov     edx, dword [su]
            mov     dword [te] , edx

            mov     edx, [b]
            cmp     edx, [iter]
            je     if_b_iter
            inc     dword [b]
            ret
