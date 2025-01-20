#!/usr/bin/env lua5.4
-- biblia.lua
-- Lector de la Biblia en formato Zefania XML para Lua usando luaexpat.

local lfs = require("lfs") -- Necesario para manejar rutas de archivos
local lxp = require("lxp.lom") -- Requiere luaexpat para el análisis XML
local random = math.random
math.randomseed(os.time())

-- Obtener la ruta del directorio donde se encuentra el script
local script_path = debug.getinfo(1, "S").source:sub(2) -- Eliminar el primer carácter '@'
local script_dir = script_path:match("(.*[/\\])") or "./" -- Obtener el directorio del script

-- Añadir el directorio del script a package.path
package.path = package.path .. ";" .. script_dir .. "?.lua"

-- Ahora puedes requerir los módulos sin necesidad de concatenar la ruta
local loader = require("loader")
local output = require("output")
local books = require("books")
local verses = require("verses")

-- Construir la ruta al archivo biblia.xml
local file_path = script_dir .. "biblia.xml" -- Esto sigue siendo necesario para la ruta del archivo XML

local function load_xml_file()
	root = loader.load(file_path) -- Usar el módulo loader para cargar el XML
end

-- Función principal para manejar argumentos de la línea de comandos
local function main()
	load_xml_file() -- Cargar el archivo XML al inicio
	local args = arg

	if #args == 0 then
		output.output_result(books.list_books(root))
	elseif #args == 1 then
		if args[1] == "-r" then
			output.output_result(verses.get_random_verse(root))
		else
			output.output_result(books.show_book(root, args[1]))
		end
	elseif #args == 2 then
		if args[1] == "-s" then
			output.output_result(verses.search_text(root, args[2]))
		else
			output.output_result(books.show_chapter(root, args[1], args[2]))
		end
	elseif #args == 3 then
		output.output_result(verses.show_verse(root, args[1], args[2], args[3]))
	else
		output.output_result("Error: Número de argumentos no válido.")
	end
end

-- Ejecutar el script
main()
