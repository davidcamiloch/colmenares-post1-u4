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
========================================
```

El carácter `Z` sale de `var_byte` (42 = 2Ah) más 30h, que da 5Ah. La tabla `10, 20, 30, 40, 50` más 30h produce `:`, `D`, `N`, `X` y `b`; la conversión con 30h solo es exacta para valores de 0 a 9, y el programa la usa aquí como demostración del recorrido con `SI` y `LOOP`. La última línea son 40 signos `=` generados con `TIMES`.

### Notas de implementación

- DS se inicializa con `mov ax, seg bienvenida` y `mov ds, ax`. La forma `@data` pertenece a MASM y TASM; en el formato `obj` de NASM el operador `seg` devuelve el segmento del símbolo y ALINK lo reubica al cargar el ejecutable.
- El programa declara un segmento de pila de 256 bytes (`section pila stack class=STACK`). Con él ALINK fija SS:SP en el encabezado MZ y no emite el aviso de ejecutable sin pila.
- Las cadenas usan solo caracteres ASCII; un carácter fuera de ese rango se imprime distinto en la página de códigos de DOS.

### Decisión técnica 1: EQU frente a %define para ANCHO_LINEA

El ancho de la línea decorativa se define como `ANCHO_LINEA EQU 40` y se usa en `TIMES ANCHO_LINEA DB '='`. EQU crea un símbolo numérico que el propio ensamblador evalúa y verifica; su valor queda fijado en una sola definición y NASM rechaza redefinirlo con otro valor. %define, en cambio, es una sustitución de texto que el preprocesador hace antes de ensamblar una sola instrucción; NASM no ve un número sino los caracteres que la macro deja en su lugar. Para ANCHO_LINEA esa diferencia decide. El valor se usa como argumento numérico de TIMES y podría usarse después en una comparación como `cmp cx, ANCHO_LINEA`; con EQU cualquier uso recibe exactamente el número 40. Con %define una definición como `%define ANCHO_LINEA 30+10` se expandiría como texto y una expresión como `ANCHO_LINEA*2` daría 50 y no 80, un error silencioso por precedencia. Por eso EQU es el mecanismo correcto para una constante numérica pura. %define sí sería la opción adecuada dentro de este mismo programa para reutilizar texto literal; por ejemplo `%define FIN_CADENA CR, LF, TERMINADOR`, que permitiría escribir `db "Mensaje", FIN_CADENA` en cada cadena. Ahí lo que se repite es un fragmento de código fuente y no un valor, y la sustitución textual es justo lo que se necesita.

### Decisión técnica 2: TIMES en .data frente a RESB con relleno en tiempo de ejecución

La línea decorativa se construye con `TIMES ANCHO_LINEA DB '='` dentro de `section .data`. Frente a escribir a mano los 40 signos dentro de un literal DB, TIMES concentra el ancho en un solo número; cambiar la línea a 60 caracteres exige modificar un valor y no contar y editar caracteres, con el riesgo de equivocarse en el conteo. La alternativa de reservar `RESB 40` en `section .bss` y llenar el espacio con un bucle LOOP al inicio de main es válida en principio y produciría la misma salida. En este caso concreto resulta innecesaria; el contenido de la línea nunca cambia entre una ejecución y la siguiente, así que no hay nada que calcular en tiempo de ejecución. Con TIMES los 40 bytes ya forman parte de la imagen del ejecutable y DOS los carga junto con el resto de `.data`; el programa no ejecuta ninguna instrucción para producirlos. Con RESB más bucle el arranque añade la carga de DI y CX, la escritura del carácter y unas 40 iteraciones de LOOP, además de los dos bytes finales CR y LF y el terminador "$" que también habría que escribir. RESB conviene cuando el contenido se conoce solo al ejecutar, como el `buffer` de 80 bytes reservado para una entrada de teclado. Para datos fijos conocidos al ensamblar, TIMES en .data es la opción correcta.

## Parte 2: Macros con parámetros y control de flujo

### Compilación y ejecución

```
C:\> nasm -f obj programa2.asm -o programa2.obj -l programa2.lst
C:\> alink programa2.obj -oEXE -o programa2.exe -entry main
C:\> programa2.exe
```

El archivo `programa2.lst` muestra cada línea con su dirección, su código máquina y las expansiones de las macros, marcadas por NASM con el nivel de anidamiento (`<1>`, `<2>`, `<3>`).

### Salida esperada

```
=== Macros y Control de Flujo ===
[Linea A] Primera impresion
[Linea A] Primera impresion
[Linea A] Primera impresion
Suma 1+2+3 = 6
El valor mayor es: 9
Los valores son iguales.
Fin del programa.
```

### Notas de implementación

- `macros.asm` contiene solo macros y se incluye con `%include`; no genera bytes hasta que una macro se invoca.
- `print_str` preserva AX con PUSH y POP. En MS-DOS real la función 09h devuelve AL = 24h, un efecto no documentado; sin esa protección `print_str msg_mayor` seguido de `print_digito` imprimiría `4` (24h AND 0Fh) en lugar del valor comparado. DOSBox conserva AL, pero el programa no depende de esa diferencia.
- El resultado de la suma usa su propio mensaje `msg_suma` en lugar de reutilizar `msg_mayor`.
- `sumar_serie`, `comparar_e_imprimir` y `comparar_menor_o_igual` preservan con PUSH y POP los registros que modifican y que el llamador necesita.
