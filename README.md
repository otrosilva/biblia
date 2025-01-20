# Lector de la Biblia en formato Zefania XML

Este script en Python permite leer y mostrar información de la Biblia a partir de un archivo en formato Zefania XML. Puedes listar todos los libros y capítulos, mostrar un libro completo, un capítulo específico o un versículo en particular, y también obtener un versículo aleatorio.

## Requisitos

- Python 3.x
- Archivo "biblia.xml" en el mismo directorio que el script.

## Uso:

./biblia.py # -- Muestra la lista de libros y capítulos.
./biblia.py -s "texto a buscar" # -- Busca el texto en todo el archivo.
./biblia.py -r # -- Muestra un versículo aleatorio.
./biblia.py [libro] # -- Muestra todos los capítulos del libro elegido.
./biblia.py [libro] [capítulo] # -- Muestra todos los versículos del capítulo elegido del libro.
./biblia.py [libro] [capítulo] [versículo] # -- Muestra el versículo correspondiente.
