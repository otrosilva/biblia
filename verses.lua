local M = {}

function M.show_verse(root, book_name, chapter_number, verse_number)
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

function M.search_text(root, search_text)
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

function M.get_random_verse(root)
    local books = {}
    for _, book in ipairs(root) do
        if book.tag == "BIBLEBOOK" then
            table.insert(books, book)
        end
    end

    local random_book = books[math.random(#books)]
    local chapters = {}
    for _, chapter in ipairs(random_book) do
        if chapter.tag == "CHAPTER" then
            table.insert(chapters, chapter)
        end
    end

    local random_chapter = chapters[math.random(#chapters)]
    local verses = {}
    for _, verse in ipairs(random_chapter) do
        if verse.tag == "VERS" then
            table.insert(verses, verse)
        end
    end

    local random_verse = verses[math.random(#verses)]

    return string.format(
        "[%s %s:%s] %s",
        random_book.attr.bname,
        random_chapter.attr.cnumber,
        random_verse.attr.vnumber,
        random_verse[1]
    )
end

return M
