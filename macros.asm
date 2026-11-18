; macros.asm - biblioteca de macros utilitarias (Laboratorio Post1 Unidad 4, Parte 2)
; Se incluye en el programa principal con %include "macros.asm".
; El archivo solo define macros: no genera bytes hasta que una macro se invoca.

; Macro: terminar el programa DOS con codigo de salida 0
%macro fin_dos 0
    mov ax, 4C00h
    int 21h
%endmacro

; Macro: imprimir nueva linea (CR + LF) con la funcion 02h
%macro nueva_linea 0
    mov ah, 02h
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h
%endmacro

; Macro: imprimir una cadena terminada en "$"
; %1 = etiqueta de la cadena
; Preserva AX: en MS-DOS real la funcion 09h devuelve AL = 24h ("$"), un efecto
; no documentado que DOSBox no reproduce; con PUSH/POP el valor que el llamador
; conserva en AL para imprimirlo despues no depende del entorno.
%macro print_str 1
    push ax
    mov ah, 09h
    mov dx, %1
    int 21h
    pop ax
%endmacro

; Macro: imprimir un caracter unico
; %1 = valor ASCII del caracter (inmediato o registro de 8 bits)
%macro print_char 1
    mov ah, 02h
    mov dl, %1
    int 21h
%endmacro

; Macro: leer un caracter desde teclado sin eco
; El resultado queda en AL
%macro leer_char 0
    mov ah, 07h
    int 21h
%endmacro

; Macro: imprimir una cadena N veces con un bucle LOOP en tiempo de ejecucion
; %1 = etiqueta de la cadena; %2 = numero de repeticiones
; %% genera una etiqueta distinta en cada expansion de la macro
%macro repetir_str 2
    mov cx, %2                  ; CX = contador de repeticiones
%%ciclo:
    mov ah, 09h
    mov dx, %1
    int 21h
    loop %%ciclo                ; CX = CX - 1; repetir mientras CX != 0
%endmacro

; Macro: imprimir como digito decimal el nibble bajo de AL (valores 0-9)
%macro print_digito 0
    push ax                     ; preservar AX
    and al, 0Fh                 ; conservar el nibble bajo
    add al, 30h                 ; 0 -> "0" ... 9 -> "9"
    mov ah, 02h
    mov dl, al
    int 21h
    pop ax                      ; restaurar AX
%endmacro

; Macro: imprimir separador_corto N veces, desenrollada al ensamblar con %rep
; %1 = numero de copias (constante conocida al ensamblar)
; No usa CX, LOOP ni etiquetas: cada copia es codigo independiente.
%macro bloque_decorativo 1
    %rep %1
        print_str separador_corto
    %endrep
%endmacro
