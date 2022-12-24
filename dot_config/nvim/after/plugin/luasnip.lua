local ls = require("luasnip")
local extras = require("luasnip.extras")

ls.config.set_config({ update_events = 'TextChanged,TextChangedI' })

-- set snip expansion/jump next key
vim.keymap.set({ "i", "s" }, "<c-k>", function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end, { silent = true })

-- set jump back key
vim.keymap.set({ "i", "s" }, "<c-j>", function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end, { silent = true })

-- set choice_node selection key
vim.keymap.set("i", "<c-l>", function()
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
end)

local c, i, f, s, t = ls.choice_node, ls.insert_node, ls.function_node, ls.s, ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

local block_comment_head = function(index)
    return f(function(arg)
        return string.rep("#", string.len(arg[1][1]) + 4)
    end, { index })
end

ls.add_snippets(nil, {
    all = {
        -- Block comment
        s({ trig = "bc", docstring = "Block Comment (#-only currently)" }, fmt([[
            {}
            # {} #
            {}
        ]], { block_comment_head(1), i(1), block_comment_head(1) })),
        -- Just a test thing
        s("oi", fmt("{} == {}", { i(1), extras.rep(1) }))
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
        ]]   , {
                c(1, { t "    use super::*;", t "" }),
                i(0),
            })
        )
    },
    sh = {
        -- Basic bash preamble
        s("bash", fmt("#!/usr/bin/env bash\n\nset -euo pipefail\n\n\n", {})),
    },
})
