local M = {}

function M.output_result(result)
    local comando = "bat --style=plain" -- Comando de salida
    local handle = io.popen(comando, "w")
    handle:write(result)
    handle:close()
end

return M
