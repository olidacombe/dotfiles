local ls = require("luasnip")

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


local c, i, f, s, t = ls.choice_node, ls.insert_node, ls.function_node, ls.s, ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets(nil, {
    rust = {
        -- Adding test module
        s(
            "modtest",
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
    }
})
