# CMO: Compilación modular

## Introducción

Un programa en C puede estar distribuido en varios archivos. Esta organización permite agrupar funciones relacionadas y separar responsabilidades, sin tener que reunir todo el código en un único archivo. Para construir el programa es necesario conocer qué aporta cada archivo y cómo se relaciona con los demás.

En este contexto, un **módulo** es una parte del programa que reúne funciones y datos relacionados con una responsabilidad específica, como leer la entrada, realizar cálculos o presentar resultados. En C suele organizarse mediante un archivo fuente `.c`, que contiene la implementación de las funciones, y un archivo de cabecera `.h`, que declara las funciones y los tipos que pueden utilizarse desde otros archivos. Por lo tanto, separar un programa en módulos no consiste solamente en repartir su código entre varios archivos, sino en organizarlo según la responsabilidad de cada parte.

En este laboratorio se trabajará con un programa que ya está separado en módulos. Primero se construirá desde sus archivos fuente y luego se realizará la compilación y el enlace como etapas independientes. A continuación, algunos de sus módulos se agruparán en una biblioteca estática.

Todas las construcciones se realizarán desde la terminal. En cada etapa se observarán los archivos generados y cómo se utilizan para construir el programa.

### Prerrequisitos

- Saber navegar por directorios, editar con Vim y compilar programas en C
- Saber ejecutar programas con archivos de entrada y comparar su salida con un archivo `.expected`
- Reconocer funciones, prototipos y estructuras en C
- Tener disponibles Bash, `gcc`, `ar`, `nm`, `file`, `diff` y `timeout` en Linux

### Objetivo general

- Construir y verificar programas modulares en C mediante compilación separada, enlace y uso de bibliotecas estáticas

### Objetivos específicos

- Distinguir declaraciones en cabeceras e implementaciones en archivos fuente
- Reconocer el propósito de las guardas de inclusión
- Generar archivos objeto y enlazarlos para construir un ejecutable
- Distinguir un error de compilación de un error de enlace
- Observar símbolos definidos y referencias pendientes en los objetos
- Construir y utilizar una biblioteca estática

### Estructura inicial

```text
workspace/
├── code/
│   ├── main.c
│   ├── mission.h
│   ├── scanner.c
│   ├── scanner.h
│   ├── navigation.c
│   ├── navigation.h
│   ├── report.c
│   └── report.h
├── tests/
│   ├── test001.in
│   ├── test001.expected
│   ├── test002.in
│   ├── test002.expected
│   ├── test003.in
│   └── test003.expected
└── scripts/
    ├── tests-run.sh
    └── check.sh
```

Los archivos fuente están completos y no contienen errores intencionales. No es necesario editar el código. Durante la actividad se omitirá un objeto al enlazar y se cambiará temporalmente el nombre de la biblioteca para observar qué ocurre en cada caso. Luego se retomará la lista completa de objetos y se restaurará el nombre de la biblioteca.

`tests-run.sh` ejecuta los tres test cases y compara las salidas. `check.sh` permite revisar los archivos construidos y su comportamiento, indicando qué actividades están completas y cuáles permanecen pendientes.

## Contexto

El Imperio Galáctico recibe solicitudes para enviar naves a distintos sectores. Antes de autorizar una misión, necesita comprobar que la nave dispone de combustible suficiente para llegar a su destino y enfrentar los riesgos del trayecto.

Cada solicitud indica el nombre del sector, la distancia que se recorrerá, el consumo de combustible por unidad de distancia, un nivel de riesgo y el combustible disponible. El consumo del trayecto se obtiene multiplicando la distancia por el consumo unitario. Además, se consideran veinticinco unidades de combustible por cada nivel de riesgo.

Una misión se aprueba cuando el combustible disponible alcanza para cubrir el requerimiento total, incluso si no queda combustible sobrante. El margen corresponde a la diferencia entre el combustible disponible y el requerido; un margen negativo indica cuánto falta.

El programa recibe primero la cantidad de misiones. Cada línea siguiente describe una misión mediante el nombre del sector y cuatro números, separados por espacios, en este orden:

1. Nombre del sector de destino
2. Distancia que recorrerá la nave, expresada en unidades de distancia
3. Consumo de combustible por cada unidad de distancia recorrida
4. Nivel de riesgo del trayecto, donde cada nivel agrega veinticinco unidades de combustible al requerimiento
5. Cantidad de combustible disponible en la nave

Por ejemplo:

```text
1
Kessel 12 15 2 250
```

La primera línea indica que se procesará una misión. En la segunda línea:

- `Kessel` es el sector de destino
- `12` es la distancia que recorrerá la nave
- `15` es el consumo de combustible por cada unidad de distancia
- `2` es el nivel de riesgo del trayecto
- `250` es la cantidad de combustible disponible

Para recorrer las 12 unidades de distancia, la nave necesita 12 × 15 = 180 unidades de combustible. El nivel de riesgo 2 agrega otras 2 × 25 = 50 unidades. Por lo tanto, el requerimiento total es de 180 + 50 = 230 unidades. Como la nave dispone de 250, la misión se aprueba y queda un margen de 250 − 230 = 20 unidades.

El informe comienza con la versión del protocolo y luego muestra el resultado de cada misión. En el campo `combustible` se indica primero la cantidad requerida y después la disponible:

```text
Protocolo de navegacion: 12
Mision 001: APROBADA | sector=Kessel | combustible=230/250 | margen=20
```

Los archivos de prueba incluyen misiones aprobadas, rechazadas y con combustible justo. Todas las entradas entregadas son válidas.

## Actividad

### 1. Reconocer y construir un programa modular

#### 1.1. Revisar la organización

Desde la raíz del repositorio, entrar a `workspace/code` y revisar los archivos `.c` con las herramientas conocidas.

- `main.c` lee la cantidad de misiones y coordina las llamadas a los módulos
- `scanner.c` implementa la lectura de una misión
- `navigation.c` calcula el combustible requerido y decide si la misión se aprueba
- `report.c` imprime el resultado

#### 1.2. Compilar todo en una sola invocación

Hasta ahora se ha compilado indicando un solo archivo `.c`. Para construir un programa distribuido en varios archivos fuente, se escriben sus nombres en el mismo comando de `gcc`, separados por espacios. Se indica una sola salida mediante `-o`, porque todos esos archivos participan en la construcción de un único ejecutable:

```text
gcc <opciones> <fuente1.c> <fuente2.c> ... -o <ejecutable>
```

Construir el comando para este programa considerando lo siguiente:

- Incluir `main.c`, `scanner.c`, `navigation.c` y `report.c`, separados por espacios
- Utilizar las opciones `-Wall`, `-Wextra`, `-Werror`, `-std=c11`, `-g` y `-O0`
- Indicar mediante `-o` que el ejecutable se llamará `imperial_nav` y quedará en el directorio actual

Ejecutar el programa con `../tests/test001.in`, guardar la salida en `../tests/test001.out` y compararla con el `.expected` correspondiente. Si la compilación o la comparación falla, revisar los nombres, las rutas y los mensajes antes de continuar.

En esta invocación, `gcc` realiza dos operaciones: primero compila cada archivo fuente y luego reúne los resultados para generar el ejecutable. Esta segunda operación se llama **enlace** y conecta las llamadas a funciones de un módulo con sus implementaciones en los otros. En la actividad 2 se realizarán ambas operaciones por separado.

El programa ya está organizado en módulos, pero este comando vuelve a compilar los cuatro archivos fuente cada vez que se ejecuta. Si solo cambia la implementación de una función en `navigation.c`, repetirlo también recompila `main.c`, `scanner.c` y `report.c`, aunque no hayan cambiado. Separar la compilación del enlace permite conservar y reutilizar el trabajo realizado sobre esos archivos.

#### 1.3. Revisar las cabeceras

El comando anterior incluyó solamente archivos `.c`, pero el programa también utiliza archivos de cabecera `.h`. Revisarlos e identificar qué información aportan:

- `mission.h` define los tipos compartidos por los módulos
- `scanner.h`, `navigation.h` y `report.h` declaran las funciones que otros archivos pueden utilizar

Una declaración informa el nombre, los parámetros y el tipo de retorno de una función. Su definición contiene el cuerpo que se ejecutará. Comparar la declaración de `evaluate_mission` en `navigation.h` con su definición en `navigation.c`.

Antes de compilar el código C, se realiza una etapa de preparación llamada **preprocesamiento**. En ella se procesan instrucciones como `#include`, que incorpora el contenido de una cabecera. Por eso los `.h` no se agregaron al comando de compilación: su contenido se incorpora desde los archivos que los incluyen. El archivo `.c` después de esta preparación forma una **unidad de traducción**, que se compila de manera independiente de los otros `.c`.

Revisar las directivas que rodean el contenido de `mission.h`:

```c
#ifndef MISSION_H
#define MISSION_H
/* Declaraciones y tipos compartidos */
#endif
```

- `#ifndef` permite procesar el contenido solamente si el nombre aún no está definido
- `#define` registra ese nombre durante el procesamiento de la unidad de traducción
- `#endif` cierra la condición

Estas **guardas de inclusión** evitan que se repitan las definiciones de tipos cuando varias cabeceras incluyen indirectamente el mismo archivo. Por ejemplo, `main.c` incluye varias cabeceras que, a su vez, incluyen `mission.h`. La guarda permite que sus tipos se definan una sola vez dentro de esa unidad de traducción.

### 2. Separar compilación y enlace

#### 2.1. Generar archivos objeto

Al compilar un archivo fuente se puede conservar su resultado en un **archivo objeto**, normalmente con extensión `.o`. Este archivo contiene el código máquina y los datos de esa unidad de traducción, junto con información que permitirá conectarla con otras durante el enlace.

La opción `-c` solicita generar ese objeto y detener el proceso antes del enlace. Por ejemplo, desde `workspace/code`:

```bash
gcc -Wall -Wextra -Werror -std=c11 -g -O0 -c main.c
```

Cuando no se indica `-o`, el objeto conserva el nombre base del archivo fuente: en este caso se genera `main.o`.

Construir los comandos equivalentes para los otros tres archivos fuente. Revisar los cuatro `.o` mediante `file` y comparar su descripción con la del ejecutable. Un objeto contiene código y datos que participarán en el enlace; no corresponde a un programa que se deba ejecutar directamente.

#### 2.2. Enlazar y reconocer una implementación faltante

Construir un comando de `gcc` que reciba los cuatro objetos, sin usar `-c`, y genere nuevamente `imperial_nav`. La lista debe incluir `main.o`, que contiene la función principal, y los objetos de los tres módulos que utiliza. Separar sus nombres con espacios. No agregar archivos `.c` a este comando: ahora se utilizarán los resultados de la compilación anterior.

Repetir la ejecución y comparación de `test001`. La separación del proceso no debe cambiar el resultado.

Con los objetos disponibles, un cambio en la implementación de `navigation.c`, sin modificar sus cabeceras, requiere recompilar solamente ese archivo para actualizar `navigation.o`. Luego se repite el enlace con los cuatro objetos para actualizar el ejecutable. Los otros tres objetos se reutilizan sin recompilarlos. Si cambia una cabecera, también deben recompilarse los archivos fuente que la incluyen, directa o indirectamente.

Para observar un error de enlace, repetir el comando omitiendo `report.o` y solicitar un ejecutable distinto llamado `enlace_incompleto`. Leer el mensaje que menciona `undefined reference` e identificar la función cuya definición no se encontró.

La declaración de esa función permitió compilar el módulo que la utiliza, pero no aporta su implementación. El enlace requiere recibir el objeto que contiene esa implementación. No modificar el código para resolver este experimento: corregir la lista de objetos, reconstruir `imperial_nav` y comprobar su resultado.

#### 2.3. Observar símbolos y su visibilidad

Para conectar los módulos, el enlazador necesita identificar las funciones y los datos que cada objeto define o utiliza. Esos nombres se registran como **símbolos**. Por ejemplo, un objeto puede contener la definición de `evaluate_mission` y otro puede registrar que necesita esa función.

`nm` permite inspeccionar esos símbolos. Ejecutarlo sobre `main.o` y `navigation.o` y revisar las letras que acompañan a los nombres:

- `T` identifica una función definida cuyo nombre está disponible para otros objetos
- `U` identifica una referencia cuya definición no está en ese objeto
- `t` identifica una función local al objeto
- `R` identifica datos de solo lectura cuyo nombre está disponible para otros objetos

Localizar `evaluate_mission` en ambos objetos y comparar las letras que la acompañan. Luego localizar `risk_penalty`, declarada `static` en `navigation.c`: su nombre es interno a ese módulo y no se ofrece a los otros módulos.

Revisar también `NAVIGATION_PROTOCOL_VERSION`. La cabecera utiliza `extern` para declarar la constante, mientras que `navigation.c` contiene su definición y su valor. La declaración permite utilizarla desde otro archivo sin crear una nueva definición en cada módulo. Localizarla en la salida de `nm`: en `main.o` aparece como una referencia pendiente (`U`) y en `navigation.o`, como datos de solo lectura (`R`).

### 3. Agrupar módulos en una biblioteca estática

#### 3.1. Crear e inspeccionar la biblioteca

Una biblioteca estática agrupa archivos objeto. Durante el enlace, el código necesario de esos objetos se incorpora al ejecutable. En Linux, su nombre suele comenzar con `lib` y terminar en `.a`.

Esto permite reutilizar los módulos desde distintos programas, cada uno con su propia función `main`. Para compilar un programa que utiliza la biblioteca se necesitan sus cabeceras; para enlazarlo se utiliza el archivo `.a`.

El comando `ar` permite crear y examinar archivos que agrupan otros archivos. Se utilizará para reunir los objetos en una biblioteca estática, con la siguiente forma:

```text
ar rcs <BIBLIOTECA.a> <OBJETOS>
```

- `r` agrega archivos objeto o reemplaza los que tienen el mismo nombre
- `c` evita el aviso de creación cuando la biblioteca no existe
- `s` genera o actualiza el índice de símbolos para el enlace

Crear `libnavgrid.a` con los objetos de lectura, navegación e informe. No incorporar `main.o`: la función principal pertenece al ejecutable que utilizará la biblioteca.

Consultar su contenido usando `ar t <BIBLIOTECA.a>` y comprobar que contiene los tres objetos solicitados. La opción `t` muestra sus nombres sin extraer ni modificar los archivos.

#### 3.2. Enlazar con la biblioteca

Construir `imperial_nav_static` utilizando solamente `main.o` y la biblioteca. Para ello, incorporar estas opciones al comando de enlace:

- `-L.` agrega el directorio actual a las rutas de búsqueda de bibliotecas durante el enlace
  - Sin `-L`, el enlazador busca en sus directorios predeterminados
  - El directorio actual no se incluye automáticamente: que la biblioteca esté junto a `main.o` no basta para encontrarla mediante `-l:`
- `-l:libnavgrid.a` selecciona el archivo con ese nombre exacto

Colocar `main.o` antes de la opción que selecciona la biblioteca. En el enlace con bibliotecas estáticas, el orden importa: la biblioteca debe aparecer después de los objetos que necesitan sus símbolos.

Ejecutar `test001` con el nuevo programa y comparar su salida. Luego cambiar temporalmente el nombre de `libnavgrid.a`, repetir la ejecución y restaurar el nombre original. El programa debe seguir funcionando: el código requerido ya quedó incorporado durante el enlace.

### 4. Revisar los resultados

#### 4.1. Ejecutar la suite

Desde `workspace/code`, agregar permiso de ejecución para el propietario a `../scripts/tests-run.sh`. El script recibe la ruta de un ejecutable y la carpeta que contiene los test cases:

```text
../scripts/tests-run.sh ./<EJECUTABLE> ../tests
```

Ejecutar la suite para las dos construcciones: `imperial_nav` e `imperial_nav_static`.

El script guarda cada salida en un `.out`. Informa `PASS` cuando coincide con el `.expected`, `FAIL` cuando el programa termina normalmente pero produce un resultado distinto y `ERRO` cuando no puede completar la prueba. Si hay diferencias, revisar la entrada, la salida y los mensajes antes de repetir.

#### 4.2. Habilitar la revisión

Volver a `workspace` y agregar permiso de ejecución para el propietario a `scripts/check.sh`.

#### 4.3. Ejecutar la revisión

Ejecutar `scripts/check.sh`. El script revisa los objetos, la biblioteca estática, los dos ejecutables y sus resultados, sin borrar los archivos construidos. Sus mensajes indican qué actividades están completas y cuáles permanecen pendientes. No puede comprobar si se realizaron las observaciones o los experimentos temporales: esos pasos deben revisarse durante la actividad.

Conservar los archivos generados hasta finalizar la revisión. No se necesita cambiar permisos a los ejecutables producidos por `gcc`.
