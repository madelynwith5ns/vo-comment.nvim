-- Installation instructions:
-- {vocomref::mSRjOYv8fRcylT8QTNuw} 
-- {vocomref::aM3B2Y4XSyqZs0o2TGLg} 
-- {vocomref::v8BXo6RTyg54vt5Bq9DM} 
-- {vocomref::n6StM2wCHY2Dzq9f7ElK} 
-- {vocomref::rJhTl0pQg7GRxWmSgrXD} 
local m = {}

local ns = vim.api.nvim_create_namespace("vocomment")
vim.api.nvim_create_augroup("vocomment-group", { clear = true })

m.setup = function()
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter" }, {
        group = "vocomment-group",
        callback = function()
            local buf = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true);

            for i = 0, #lines, 1 do
                if lines[i + 1] ~= nil then
                    local match = string.match(lines[i + 1], "{vocomref::(%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w)}")
                    if match ~= nil then
                        local start = string.find(lines[i + 1], "{vocomref::(%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w)}")
                        if start ~= nil then
                            vim.api.nvim_buf_set_extmark(buf, ns, i, start, {
                                virt_text = { { "This line has a voice comment!", "DiagnosticInfo" } },
                                virt_text_pos = 'overlay'
                            });
                        end
                    end
                end
            end
        end
    })
end

m.vocomplay = function()
    local ln = vim.api.nvim_win_get_cursor(0)[1];
    local line = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), ln - 1, ln, true);
    local match = string.match(line[1], "{vocomref::(%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w)}")
    if match ~= nil then
        local start = string.find(line[1], "{vocomref::(%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w)}")
        if start ~= nil then
            print("Playing voice comment... (ID: " .. match .. ")")
            vim.fn.system("mplayer .vocomment/" .. match)
            print("Done")
        end
    else
        print("No voice comment on this line")
    end
end

m.vocomrecord = function()
    local id = vim.fn.system("tr -dc A-Za-z0-9 </dev/urandom | head -c 20; echo");
    print("Recording your voice comment now... Press ^C to end.")
    local name = ".vocomment/" .. id
    vim.fn.system("pw-record " .. name)
    print(id);
    local row,col = unpack(vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win()))
    local t = "{vocomref::" .. id .. "}";
    t = t.gsub(t,"\n","");
    vim.api.nvim_buf_set_text(vim.api.nvim_get_current_buf(), row - 1, col, row - 1, col, { t })
end

return m;
