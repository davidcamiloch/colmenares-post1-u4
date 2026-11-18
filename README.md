# colmenares-post1-u4

Laboratorio del Post-contenido de la Unidad 4 de Arquitectura de Computadores (UFPS). El repositorio reúne dos programas en lenguaje ensamblador NASM para DOS de 16 bits, ensamblados con NASM, enlazados con ALINK y ejecutados en DOSBox.

| Parte | Archivos | Tema |
|-------|----------|------|
| 1 | `programa.asm` | Secciones `.data`, `.bss` y `.text`; directivas `DB`, `DW`, `DD`, `RESB`, `RESW`, `EQU` y `TIMES`; salida con INT 21h funciones 09h y 02h |
| 2 | `macros.asm`, `programa2.asm` | Macros con parámetros y etiquetas locales `%%`; macro con `%rep`; bucle con `LOOP`; condicionales con `CMP`/`Jcc` |

## Prerrequisitos

- DOSBox 0.74 o superior.
- NASM 2.14 o superior (`nasm.exe` dentro de la carpeta montada).
- ALINK (`alink.exe` dentro de la misma carpeta).
- Archivos fuente guardados en ASCII sin BOM.

## Estructura

```
colmenares-post1-u4/
├── programa.asm      Parte 1
├── macros.asm        Parte 2: biblioteca de macros
├── programa2.asm     Parte 2: programa integrador
├── capturas/         evidencia de ensamblado y ejecución
└── README.md
```

## Configuración de DOSBox

```
Z:\> mount C C:\Users\estudiante\lab-post1-u4
Z:\> C:
C:\> nasm -v
```

## Parte 1: Segmentos, directivas y salida por interrupciones DOS

### Compilación y ejecución

```
C:\> nasm -f obj programa.asm -o programa.obj
C:\> alink programa.obj -oEXE -o programa.exe -entry main
C:\> programa.exe
```

### Salida esperada

```
=== Laboratorio NASM - Unidad 4 ===
----------------------------------------
Variable A (byte + 30h): Z
Tabla de bytes (+30h):   : D N X b
Programa finalizado correctamente.
```

El carácter `Z` sale de `var_byte` (42 = 2Ah) más 30h, que da 5Ah. La tabla `10, 20, 30, 40, 50` más 30h produce `:`, `D`, `N`, `X` y `b`; la conversión con 30h solo es exacta para valores de 0 a 9, y el programa la usa aquí como demostración del recorrido con `SI` y `LOOP`.

### Notas de implementación

- DS se inicializa con `mov ax, seg bienvenida` y `mov ds, ax`. La forma `@data` pertenece a MASM y TASM; en el formato `obj` de NASM el operador `seg` devuelve el segmento del símbolo y ALINK lo reubica al cargar el ejecutable.
- El programa declara un segmento de pila de 256 bytes (`section pila stack class=STACK`). Con él ALINK fija SS:SP en el encabezado MZ y no emite el aviso de ejecutable sin pila.
- Las cadenas usan solo caracteres ASCII; un carácter fuera de ese rango se imprime distinto en la página de códigos de DOS.
