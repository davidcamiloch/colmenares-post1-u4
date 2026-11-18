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
