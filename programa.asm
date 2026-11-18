; programa.asm - Laboratorio Post1 Unidad 4 (Parte 1)
; Proposito: demostrar directivas de seccion, datos y constantes en NASM,
;            inicializacion de DS y salida por pantalla con INT 21h (09h y 02h).
; Ensamblado: nasm -f obj programa.asm -o programa.obj
; Enlazado:   alink programa.obj -oEXE -o programa.exe -entry main

; -- Constantes (EQU: simbolos numericos, no reservan memoria) ----------------
CR          EQU 0Dh             ; retorno de carro
LF          EQU 0Ah             ; salto de linea
TERMINADOR  EQU 24h             ; "$" terminador de cadena para la funcion 09h
ITERACIONES EQU 5               ; elementos de tabla_bytes que recorre el bucle
ANCHO_LINEA EQU 40              ; ancho de la linea decorativa generada con TIMES

; -- Datos inicializados -------------------------------------------------------
section .data
bienvenida  db "=== Laboratorio NASM - Unidad 4 ===", CR, LF, TERMINADOR
separador   db "----------------------------------------", CR, LF, TERMINADOR
linea_gruesa:
            TIMES ANCHO_LINEA DB '='   ; ANCHO_LINEA bytes '=' creados al ensamblar
            DB CR, LF, TERMINADOR
etiqueta_a  db "Variable A (byte + 30h): ", TERMINADOR
etiqueta_t  db "Tabla de bytes (+30h):   ", TERMINADOR
fin_msg     db "Programa finalizado correctamente.", CR, LF, TERMINADOR

; Tipos de datos demostrados
var_byte    db 42                     ; 1 byte con valor 42 (2Ah)
var_word    dw 1234h                  ; 2 bytes, almacenados como 34h 12h
var_dword   dd 0DEADBEEFh             ; 4 bytes, almacenados como EFh BEh ADh DEh
tabla_bytes db 10, 20, 30, 40, 50     ; 5 bytes consecutivos

; -- Datos no inicializados ----------------------------------------------------
section .bss
buffer      resb 80                   ; 80 bytes reservados para una entrada futura
resultado   resw 1                    ; 1 word reservada para un calculo

; -- Pila del programa ---------------------------------------------------------
section pila stack class=STACK
            resb 256                  ; 256 bytes de pila; ALINK fija SS:SP aqui

; -- Codigo ejecutable ---------------------------------------------------------
section .text
global main

main:
    ; DS debe apuntar al segmento que contiene los datos
    mov ax, seg bienvenida      ; AX = segmento de .data (resuelto al cargar)
    mov ds, ax                  ; DS no admite inmediatos: se carga desde AX

    ; === Funcion 09h: imprimir cadenas terminadas en "$" ===
    mov ah, 09h
    mov dx, bienvenida          ; DS:DX = direccion de la cadena
    int 21h
    mov dx, separador           ; AH sigue en 09h
    int 21h

    mov dx, etiqueta_a
    int 21h

    ; === Funcion 02h: imprimir un caracter cargado en DL ===
    mov al, [var_byte]          ; AL = 42 (2Ah)
    add al, 30h                 ; 2Ah + 30h = 5Ah = "Z" (demostracion)
    mov dl, al
    mov ah, 02h
    int 21h

    mov dl, CR                  ; nueva linea con dos llamadas a 02h
    int 21h
    mov dl, LF
    int 21h

    mov ah, 09h
    mov dx, etiqueta_t
    int 21h

    ; === Recorrer tabla_bytes e imprimir cada elemento ===
    lea si, [tabla_bytes]       ; SI = offset del primer byte de la tabla
    mov cx, ITERACIONES         ; CX = 5 iteraciones

imprimir_tabla:
    mov dl, [si]                ; DL = byte actual de la tabla
    add dl, 30h                 ; conversion simple a ASCII (exacta solo para 0-9)
    mov ah, 02h
    int 21h
    mov dl, 20h                 ; espacio entre elementos
    int 21h
    inc si                      ; avanzar al siguiente byte
    loop imprimir_tabla         ; CX = CX - 1; repetir mientras CX != 0

    mov dl, CR
    int 21h
    mov dl, LF
    int 21h

    ; === Mensaje final y linea decorativa generada con TIMES ===
    mov ah, 09h
    mov dx, fin_msg
    int 21h
    mov dx, linea_gruesa
    int 21h

    ; Terminar el programa
    mov ax, 4C00h               ; funcion 4Ch: terminar con codigo de salida 0
    int 21h
