local lxp = require("lxp.lom")

local M = {}

function M.load(file_path)
    local file, err = io.open(file_path, "r")
    if not file then
        error("Error al abrir el archivo: " .. err)
    end

    local content = file:read("*all")
    file:close()

    return lxp.parse(content) -- Usar luaexpat para analizar el contenido
end

return M
