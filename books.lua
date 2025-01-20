local M = {}

function M.list_books(root)
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

function M.show_book(root, book_name)
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

function M.show_chapter(root, book_name, chapter_number)
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

return M
