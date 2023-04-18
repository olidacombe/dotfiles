local winbar = require("config.winbar")

require('lualine').setup({
    extensions = {},
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {}
    },
    inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
    options = {
        always_divide_middle = true,
        component_separators = {
            left = "",  -- "",
            right = "", -- ""
        },
        disabled_filetypes = {
            statusline = {},
            winbar = {
                "help",
                "startify",
                "dashboard",
                "neogitstatus",
                "NvimTree",
                "Trouble",
                "alpha",
                "lir",
                "Outline",
                "spectre_panel",
                "toggleterm",
            },
        },
        globalstatus = true,
        icons_enabled = true,
        ignore_focus = {},
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000
        },
        section_separators = {
            left = "",  --"",
            right = "", --""
        },
        theme = "auto"
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics", function()
            return "易" .. require("od.quickcycle").get_current()
        end },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" }
    },
    tabline = {
        -- nicer tab decor, e.g. https://github.com/alvarosevilla95/luatab.nvim +  OBVS
        -- or at least tone down the highlight...
        lualine_a = { {
            'tabs',
            -- mode 1 shows tab names
            mode = 1,
            tabs_color = {
                -- Same values as the general color option can be used here.
                active = 'lualine_b_normal',     -- Color for active tab.
                inactive = 'lualine_c_inactive', -- Color for inactive tab.
            },
            fmt = function(name, context)
                -- Show + if buffer is modified in tab
                local buflist = vim.fn.tabpagebuflist(context.tabnr)
                local winnr = vim.fn.tabpagewinnr(context.tabnr)
                local bufnr = buflist[winnr]
                local mod = vim.fn.getbufvar(bufnr, '&mod')

                return name .. (mod == 1 and '' or '')
            end
        } },
        lualine_b = {},
        lualine_c = {},
        lualine_x = { winbar.get_winbar },
        lualine_y = {},
        lualine_z = {},
    },
    winbar = {},
})
