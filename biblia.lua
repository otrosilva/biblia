#!/usr/bin/env lua5.4
-- biblia.lua
-- Lector de la Biblia en formato Zefania XML para Lua usando luaexpat.

local lfs = require("lfs") -- Necesario para manejar rutas de archivos
local lxp = require("lxp.lom") -- Requiere luaexpat para el análisis XML
local random = math.random
math.randomseed(os.time())

local comando = "bat --style=plain" -- Comando de salida

-- Obtener la ruta del directorio donde se encuentra el script
local script_path = debug.getinfo(1, "S").source:sub(2) -- Eliminar el primer carácter '@'
local script_dir = lfs.currentdir() -- Obtener el directorio actual
local file_path = script_path:match("(.*/)") .. "biblia.xml" -- Construir la ruta al archivo biblia.xml

local root

local function load_xml_file()
	local file, err = io.open(file_path, "r")
	if not file then
		error("Error al abrir el archivo: " .. err)
	end

	local content = file:read("*all")
	file:close()

	root = lxp.parse(content) -- Usar luaexpat para analizar el contenido
end

local function output_result(result)
	local handle = io.popen(comando, "w")
	handle:write(result)
	handle:close()
end

local function list_books()
	local output = { "Libros y Capítulos:" }
	for _, book in ipairs(root) do
		if book.tag == "BIBLEBOOK" then
			local book_name = book.attr.bname
			local chapters = 0
			for _, chapter in ipairs(book) do
				if chapter.tag == "CHAPTER" then
					chapters = chapters + 1
				end
			end
			table.insert(output, string.format("%s [%d]", book_name, chapters))
		end
	end
	return table.concat(output, "\n")
end

local function show_book(book_name)
	for _, book in ipairs(root) do
		if book.tag == "BIBLEBOOK" and string.lower(book.attr.bname) == string.lower(book_name) then
			local output = {}
			for _, chapter in ipairs(book) do
				if chapter.tag == "CHAPTER" then
					for _, verse in ipairs(chapter) do
						if verse.tag == "VERS" then
							table.insert(
								output,
								string.format(
									"[%s %s:%s] %s",
									book.attr.bname,
									chapter.attr.cnumber,
									verse.attr.vnumber,
									verse[1]
								)
							)
						end
					end
				end
			end
			return table.concat(output, "\n")
		end
	end
	return string.format("El libro '%s' no se encuentra.", book_name)
end

local function show_chapter(book_name, chapter_number)
	for _, book in ipairs(root) do
		if book.tag == "BIBLEBOOK" and string.lower(book.attr.bname) == string.lower(book_name) then
			for _, chapter in ipairs(book) do
				if chapter.tag == "CHAPTER" and chapter.attr.cnumber == chapter_number then
					local output = {}
					for _, verse in ipairs(chapter) do
						if verse.tag == "VERS" then
							table.insert(
								output,
								string.format(
									"[%s %s:%s] %s",
									book.attr.bname,
									chapter.attr.cnumber,
									verse.attr.vnumber,
									verse[1]
								)
							)
						end
					end
					return table.concat(output, "\n")
				end
			end
			return string.format("El capítulo '%s' no se encuentra en el libro '%s'.", chapter_number, book_name)
		end
	end
	return string.format("El libro '%s' no se encuentra.", book_name)
end

local function show_verse(book_name, chapter_number, verse_number)
	for _, book in ipairs(root) do
		if book.tag == "BIBLEBOOK" and string.lower(book.attr.bname) == string.lower(book_name) then
			for _, chapter in ipairs(book) do
				if chapter.tag == "CHAPTER" and chapter.attr.cnumber == chapter_number then
					for _, verse in ipairs(chapter) do
						if verse.tag == "VERS" and verse.attr.vnumber == verse_number then
							return string.format(
								"[%s %s:%s] %s",
								book.attr.bname,
								chapter.attr.cnumber,
								verse.attr.vnumber,
								verse[1]
							)
						end
					end
					return string.format(
						"El versículo '%s' no se encuentra en el capítulo '%s' del libro '%s'.",
						verse_number,
						chapter_number,
						book_name
					)
				end
			end
			return string.format("El capítulo '%s' no se encuentra en el libro '%s'.", chapter_number, book_name)
		end
	end
	return string.format("El libro '%s' no se encuentra.", book_name)
end

local function search_text(search_text)
	local output = {}
	for _, book in ipairs(root) do
		if book.tag == "BIBLEBOOK" then
			for _, chapter in ipairs(book) do
				if chapter.tag == "CHAPTER" then
					for _, verse in ipairs(chapter) do
						if verse.tag == "VERS" then
							if string.find(string.lower(verse[1]), string.lower(search_text)) then
								table.insert(
									output,
									string.format(
										"[%s %s:%s] %s",
										book.attr.bname,
										chapter.attr.cnumber,
										verse.attr.vnumber,
										verse[1]
									)
								)
							end
						end
					end
				end
			end
		end
	end
	if #output == 0 then
		return string.format("No se encontraron versículos que contengan el texto '%s'.", search_text)
	end
	return table.concat(output, "\n")
end

local function get_random_verse()
	local books = {}
	for _, book in ipairs(root) do
		if book.tag == "BIBLEBOOK" then
			table.insert(books, book)
		end
	end

	local random_book = books[random(#books)]
	local chapters = {}
	for _, chapter in ipairs(random_book) do
		if chapter.tag == "CHAPTER" then
			table.insert(chapters, chapter)
		end
	end

	local random_chapter = chapters[random(#chapters)]
	local verses = {}
	for _, verse in ipairs(random_chapter) do
		if verse.tag == "VERS" then
			table.insert(verses, verse)
		end
	end

	local random_verse = verses[random(#verses)]

	return string.format(
		"[%s %s:%s] %s",
		random_book.attr.bname,
		random_chapter.attr.cnumber,
		random_verse.attr.vnumber,
		random_verse[1]
	)
end

-- Función principal para manejar argumentos de la línea de comandos
local function main()
	load_xml_file() -- Cargar el archivo XML al inicio
	local args = arg

	if #args == 0 then
		output_result(list_books())
	elseif #args == 1 then
		if args[1] == "-r" then
			output_result(get_random_verse())
		else
			output_result(show_book(args[1]))
		end
	elseif #args == 2 then
		if args[1] == "-s" then
			output_result(search_text(args[2]))
		else
			output_result(show_chapter(args[1], args[2]))
		end
	elseif #args == 3 then
		output_result(show_verse(args[1], args[2], args[3]))
	else
		output_result("Error: Número de argumentos no válido.")
	end
end

-- Ejecutar el script
main()
