-- huge thanks to https://github.com/alpha2phi/neovim-for-beginner
local M = {}

local navic = require "nvim-navic"
local utils = require "utils"

local function get_location()
    local location = navic.get_location()
    if not utils.is_empty(location) then
        return "%#WinBarContext#" .. " " .. location .. "%*"
    end
    return ""
end

function M.get_winbar()
    if navic.is_available() then
        return "%#WinBarSeparator#"
            .. "%="
            .. "%*"
            .. get_location()
            .. "%#WinBarSeparator#"
            .. "%*"
    else
        return "%#WinBarSeparator#" .. "%=" .. "%*" .. "%#WinBarSeparator#" .. "%*"
    end
end

return M
