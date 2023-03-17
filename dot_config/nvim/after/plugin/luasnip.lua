local ls = require("luasnip")
local extras = require("luasnip.extras")
local sn = ls.snippet_node

ls.config.set_config({ update_events = 'TextChanged,TextChangedI' })

-- set snip expansion/jump next key
vim.keymap.set({ "i", "s" }, "<c-c>", function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end, { silent = true })

-- set jump back key
vim.keymap.set({ "i", "s" }, "<c-g>", function()
    if ls.jumpable( -1) then
        ls.jump( -1)
    end
end, { silent = true })

-- set choice_node selection key
vim.keymap.set({ "i", "s" }, "<c-n>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end)

-- easy reload during development
vim.keymap.set("n", "<leader><leader>s", function()
    -- TODO, something less brutal?
    ls.cleanup()
    -- TODO, something less "roundabout"?
    vim.cmd.source(vim.api.nvim_get_runtime_file("after/plugin/luasnip.lua", true)[1])
end, {
    desc = "Reload Luasnips"
})

local c, i, f, s, t = ls.choice_node, ls.insert_node, ls.function_node, ls.s, ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

local raycast_preamble = [[
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title {}
# @raycast.mode {}

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName{}
# @raycast.needsConfirmation {}
{}

# Documentation:
# @raycast.description {}
# @raycast.author {}
# @raycast.authorURL{}
]]

local raycast_preamble_nodes = function()
    return {
        i(1), -- title
        c(2, { t "compact", t "silent", t "fullOutput", t "inline" }), -- mode
        c(3, { t "", sn(nil, { t " ", i(1, "pkg") }) }), -- package name
        c(4, { t "false", t "true" }), -- needs confirmation
        c(5, { t "", t '# @raycast.argument1 { "type": "text", "placeholder": "Placeholder" }' }), -- argument boilerplate
        i(6), --description
        c(7, { t "Oli Dacombe", i(nil, "Author") }),
        c(8, { t "", sn(nil, { t " https://", i(1, "example.com") }) }), -- author URL
        i(0)
    }
end

local sh_snips = {
    -- Basic bash preamble
    s("bash", fmt("#!/usr/bin/env bash\n\nset -euo pipefail\n\n\n", {})),
    -- check if executable in path
    s("isexe", fmt("command -v {} &> /dev/null {}", { i(1), i(0) })),
    -- raycast script
    s({ trig = "raycast", docstring = "Raycast Script 󱆃" },
        fmt("#!/usr/bin/env bash\n\n" .. raycast_preamble .. "\nset -euo pipefail\n\n{}", raycast_preamble_nodes())
    ),
    -- add dir to path
    s({ trig = "path", docstring = "Add dir to $PATH" },
        fmt([[
                if [ -d "{}" ]; then
                    export PATH="${{PATH}}:{}"
                fi
                {}
            ]], { i(1), extras.rep(1), i(0) })
    ),
}

ls.add_snippets(nil, {
    lua = {
        -- OOP Boilerplate
        s({ trig = "class", docstring = "Class boilerplate" },
            fmt([[
                local {} = {{}}

                function {}:new(o)
                    o = o or {{}}
                    setmetatable(o, self)
                    self.__index = self
                    return o
                end
            ]], { i(1), extras.rep(1), })
        ),
        -- Module boilerplate
        s({ trig = "mod", docstring = "Start a module file" },
            fmt([[
                local M = {{}}

                {}

                return M
            ]], { i(0) })
        ),
        -- Require with same name
        s({ trig = "req", docstring = "Require with same name" },
            fmt('local {} = require("{}")\n{}', { f(function(args)
                return (args[1][1] or ""):match("[^.]*$") or ""
            end, { 1 }), i(1), i(0) })
        ),
    },
    python = {
        -- raycast script
        s({ trig = "raycast", docstring = "Raycast Script " },
            fmt("#!/usr/bin/env python\n\n" .. raycast_preamble .. "\n\n{}", raycast_preamble_nodes())
        )
    },
    rust = {
        -- Adding test module
        s(
            { trig = "modtest", docstring = "Add test module" },
            fmt([[
                #[cfg(test)]
                mod test {{
                {}

                    {}
                }}
            ]], {
                c(1, { t "    use super::*;", t "" }),
                i(0),
            })
        ),
        -- Adding test
        s(
            { trig = "test", docstring = "Add test" },
            fmt([[
                #[test]
                fn {}() {}{{
                    {}{}
                }}
            ]], {
                i(1), c(2, {
                t "",
                t "-> Result<()> "
            }), i(0),
                f(function(arg)
                    if string.find(arg[1][1], "Result") == nil then
                        return ""
                    end
                    return { "", "    Ok(())" }
                end, { 2 })
            }
            ))
    },
    sh = sh_snips,
    template = {
        s(
            { trig = "osswitch", docstring = "OS-based switch-case" },
            fmt([[
                {{{{ if eq .chezmoi.os "darwin" -}}}}
                {}
                {{{{ else if eq .chezmoi.os "linux" -}}}}
                {{{{ end -}}}}
            ]], {i(0)})
        ),
    },
    zsh = sh_snips,
})
