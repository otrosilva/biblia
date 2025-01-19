#!/usr/bin/env python3
"""Lector de la Biblia en formato Zefania XML.

Este script permite leer y mostrar información de la Biblia a partir de un archivo en formato Zefania XML.
Puede listar todos los libros y capítulos, mostrar un libro completo, un capítulo específico
o un versículo en particular, y también obtener un versículo aleatorio.

Uso:
    ./biblia.py
    ./biblia.py [libro]
    ./biblia.py [libro] [capítulo]
    ./biblia.py [libro] [capítulo] [versículo]
    ./biblia.py -s "texto a buscar"
    ./biblia.py -r
"""
import os
import xml.etree.ElementTree as ET
import sys
import difflib
import tempfile
import random


class BibleReader:
    def __init__(self):
        # Usar la ruta relativa al archivo biblia.xml
        self.file_path = os.path.join(os.path.dirname(__file__), "biblia.xml")
        self.load_xml_file()

    def load_xml_file(self):
        try:
            tree = ET.parse(self.file_path)
            self.root = tree.getroot()
        except Exception as e:
            print(
                f"Error: No se pudo abrir o analizar el archivo: {self.file_path}. {e}"
            )
            sys.exit(1)

    def list_books(self):
        output = []
        output.append("Libros y Capítulos:")
        books = []
        for book in self.root.findall(".//BIBLEBOOK"):
            book_name = book.get("bname")
            chapters = book.findall(".//CHAPTER")
            books.append(book_name.lower())
            output.append(f"{book_name} [{len(chapters)}]")
        return "\n".join(output)

    def suggest_similar_books(self, input_book):
        books = [
            book.lower()
            for book in [
                book.get("bname") for book in self.root.findall(".//BIBLEBOOK")
            ]
        ]
        suggestions = difflib.get_close_matches(
            input_book.lower(), books, n=3, cutoff=0.6
        )

        if suggestions:
            return f"El libro '{input_book}' no se encuentra.\n¿Quisiste decir: {', '.join(suggestions)}?"
        else:
            return f"El libro '{input_book}' no se encuentra. No se encontraron libros similares."

    def show_book(self, book_name):
        found = False
        output = []
        books = [
            book.get("bname").lower() for book in self.root.findall(".//BIBLEBOOK")
        ]
        if book_name.lower() in books:
            found = True
            for book in self.root.findall(".//BIBLEBOOK"):
                if book.get("bname").lower() == book_name.lower():
                    for chapter in book.findall(".//CHAPTER"):
                        chapter_number = chapter.get("cnumber")
                        for verse in chapter.findall(".//VERS"):
                            verse_number = verse.get("vnumber")
                            output.append(
                                f"[{book.get('bname')} {chapter_number}:{verse_number}] \n{verse.text}"
                            )
        if not found:
            output.append(self.suggest_similar_books(book_name))
        return "\n".join(output)

    def show_chapter(self, book_name, chapter_number):
        found_book = False
        found_chapter = False
        output = []
        for book in self.root.findall(".//BIBLEBOOK"):
            if book.get("bname").lower() == book_name.lower():
                found_book = True
                for chapter in book.findall(".//CHAPTER"):
                    if chapter.get("cnumber") == chapter_number:
                        found_chapter = True
                        for verse in chapter.findall(".//VERS"):
                            verse_number = verse.get("vnumber")
                            output.append(
                                f"[{book.get('bname')} {chapter_number}:{verse_number}] \n{verse.text}"
                            )
                        break
                break

        if not found_book:
            output.append(self.suggest_similar_books(book_name))
        elif not found_chapter:
            output.append(
                f"El capítulo '{chapter_number}' no se encuentra en el libro '{book_name}'."
            )
        return "\n".join(output)

    def show_verse(self, book_name, chapter_number, verse_number):
        found_book = False
        found_chapter = False
        found_verse = False
        output = []
        for book in self.root.findall(".//BIBLEBOOK"):
            if book.get("bname").lower() == book_name.lower():
                found_book = True
                for chapter in book.findall(".//CHAPTER"):
                    if chapter.get("cnumber") == chapter_number:
                        found_chapter = True
                        for verse in chapter.findall(".//VERS"):
                            if verse.get("vnumber") == verse_number:
                                found_verse = True
                                output.append(
                                    f"[{book.get('bname')} {chapter_number}:{verse_number}] \n{verse.text}"
                                )
                                break
                        break

        if not found_book:
            output.append(f"El libro '{book_name}' no se encuentra.")
            output.append(self.suggest_similar_books(book_name))
        elif not found_chapter:
            output.append(
                f"El capítulo '{chapter_number}' no se encuentra en el libro '{book_name}'."
            )
        elif not found_verse:
            output.append(
                f"El versículo '{verse_number}' no se encuentra en el capítulo '{chapter_number}' del libro '{book_name}'."
            )
        return "\n".join(output)

    def search_text(self, search_text):
        output = []
        for book in self.root.findall(".//BIBLEBOOK"):
            book_name = book.get("bname")
            for chapter in book.findall(".//CHAPTER"):
                chapter_number = chapter.get("cnumber")
                for verse in chapter.findall(".//VERS"):
                    verse_number = verse.get("vnumber")
                    verse_text = verse.text
                    if search_text.lower() in verse_text.lower():
                        output.append(
                            f"[{book_name} {chapter_number}:{verse_number}] \n{verse_text}"
                        )
        if not output:
            return (
                f"No se encontraron versículos que contengan el texto '{search_text}'."
            )
        return "\n".join(output)

    def get_random_verse(self):
        # Elegir un libro aleatorio
        books = self.root.findall(".//BIBLEBOOK")
        if not books:
            return "No se encontraron libros."

        random_book = random.choice(books)
        book_name = random_book.get("bname")

        # Elegir un capítulo aleatorio de ese libro
        chapters = random_book.findall(".//CHAPTER")
        if not chapters:
            return f"El libro '{book_name}' no tiene capítulos."

        random_chapter = random.choice(chapters)
        chapter_number = random_chapter.get("cnumber")

        # Elegir un versículo aleatorio de ese capítulo
        verses = random_chapter.findall(".//VERS")
        if not verses:
            return f"El capítulo '{chapter_number}' del libro '{book_name}' no tiene versículos."

        random_verse = random.choice(verses)
        verse_number = random_verse.get("vnumber")
        verse_text = random_verse.text

        return f"[{book_name} {chapter_number}:{verse_number}] \n{verse_text}"

    def display_output(self, output):
        """Escribe la salida en un archivo temporal y la muestra."""
        with tempfile.NamedTemporaryFile(mode="w+", delete=False) as temp_file:
            temp_file.write(output)
            temp_file_path = temp_file.name

        os.system(f"bat --style=plain {temp_file_path}")
        os.remove(temp_file_path)


def main():

    bible_reader = BibleReader()

    args = sys.argv[1:]

    if len(args) == 0:
        output = bible_reader.list_books()
    elif len(args) == 1:
        if args[0] == "-r":
            output = bible_reader.get_random_verse().strip()
        else:
            output = bible_reader.show_book(args[0])
    elif len(args) == 2 and args[0] == "-s":
        output = bible_reader.search_text(args[1])
    elif len(args) == 2:
        output = bible_reader.show_chapter(args[0], args[1])
    elif len(args) == 3:
        output = bible_reader.show_verse(args[0], args[1], args[2])
    else:
        output = "Error: Número de argumentos no válido."

    # Llamar al nuevo método para mostrar la salida
    bible_reader.display_output(output)


if __name__ == "__main__":
    main()
