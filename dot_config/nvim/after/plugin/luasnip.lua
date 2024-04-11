local ls = require("luasnip")
local extras = require("luasnip.extras")
local sn = ls.snippet_node

ls.config.set_config({
    enable_autosnippets = true,
    update_events = "TextChanged,TextChangedI",
})

-- set snip expansion/jump next key
vim.keymap.set({ "i", "s" }, "<c-c>", function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end, { silent = true })

-- set jump back key
vim.keymap.set({ "i", "s" }, "<c-g>", function()
    if ls.jumpable(-1) then
        ls.jump(-1)
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
    desc = "Reload Luasnips",
})

local c, d, i, f, s, t = ls.choice_node, ls.dynamic_node, ls.insert_node, ls.function_node, ls.s, ls.text_node
local dl, l = extras.dynamic_lambda, extras.lambda
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
        i(1),                                                                                  -- title
        c(2, { t("compact"), t("silent"), t("fullOutput"), t("inline") }),                     -- mode
        c(3, { t(""), sn(nil, { t(" "), i(1, "pkg") }) }),                                     -- package name
        c(4, { t("false"), t("true") }),                                                       -- needs confirmation
        c(5, { t(""), t('# @raycast.argument1 { "type": "text", "placeholder": "Placeholder" }') }), -- argument boilerplate
        i(6),                                                                                  --description
        c(7, { t("Oli Dacombe"), i(nil, "Author") }),
        c(8, { t(""), sn(nil, { t(" https://"), i(1, "example.com") }) }),                     -- author URL
        i(0),
    }
end

local sh_snips = {
    -- Basic bash preamble
    s("bash", fmt("#!/usr/bin/env bash\n\nset -euo pipefail\n\n\n", {})),
    -- check if executable in path
    s("isexe", fmt("command -v {} &> /dev/null {}", { i(1), i(0) })),
    -- raycast script
    s(
        { trig = "raycast", docstring = "Raycast Script 󱆃" },
        fmt("#!/usr/bin/env bash\n\n" .. raycast_preamble .. "\nset -euo pipefail\n\n{}", raycast_preamble_nodes())
    ),
    -- add dir to path
    s(
        { trig = "path", docstring = "Add dir to $PATH" },
        fmt(
            [[
                if [ -d "{}" ]; then
                    export PATH="${{PATH}}:{}"
                fi
                {}
            ]],
            { i(1), extras.rep(1), i(0) }
        )
    ),
}

local git = require("od.git")

local function jira_matcher(line_to_cursor, trigger) --, trigger)
    local trigger_match = line_to_cursor:match("^jj$")
    if trigger_match == nil then
        return nil
    end
    local git_branch = git.branch_name():lower()
    local jira_match = git_branch:match("%a%a%a%a%-%d%d%d%d")
    if jira_match then
        return line_to_cursor, { jira_match:upper(), git.commit_message_from_branch_name(git_branch:sub(10)) }
    else
        return nil
    end
end

local function jira_engine(trigger)
    return jira_matcher
end

-- TODO try and make a forced-uppercase input node 🤔 for use with rust snippets like OnceLock
local dyn_uppercase
dyn_uppercase = function(args)
    -- if #args == 0 then
    -- 	return sn(nil, { i(1) })
    -- end
    -- return sn(nil, { t(args[1]:upper()), d(1, dyn_uppercase, {}) })
    return sn(nil, { t(args[1]), i(1) })
end

ls.add_snippets(nil, {
    gitcommit = {
        -- Jira issue branch
        s(
            {
                snippetType = "autosnippet",
                trig = "jj",
                trigEngine = jira_engine,
            },
            fmt("{}: {}{}", {
                f(function(_, snip)
                    return snip.captures[1]
                end),
                i(0),
                c(1, { f(function(_, snip)
                    return snip.captures[2]
                end), t("") }),
            })
        ),
    },
    lua = {
        -- OOP Boilerplate
        s(
            { trig = "class", docstring = "Class boilerplate" },
            fmt(
                [[
                local {} = {{}}

                function {}:new(o)
                    o = o or {{}}
                    setmetatable(o, self)
                    self.__index = self
                    return o
                end
            ]],
                { i(1), extras.rep(1) }
            )
        ),
        -- Module boilerplate
        s(
            { trig = "mod", docstring = "Start a module file" },
            fmt(
                [[
                local M = {{}}

                {}

                return M
            ]],
                { i(0) }
            )
        ),
        -- Require with same name
        s(
            { trig = "req", docstring = "Require with same name" },
            fmt(
                'local {} = require("{}")\n{}',
                { f(function(args)
                    return (args[1][1] or ""):match("[^.]*$") or ""
                end, { 1 }), i(1), i(0) }
            )
        ),
    },
    make = {
        -- .PHONY target
        s(
            { trig = "phony", docstring = "PHONY target" },
            fmt(
                [[
                .PHONY: {}
                {}:
                {}{}
            ]],
                { i(1), extras.rep(1), t("\t"), i(0) }
            )
        ),
    },
    markdown = {
        -- Expandable details
        s(
            { trig = "expand", docstring = "Expandable Details" },
            fmt(
                [[
           <details>
           <summary>{}</summary>
           {}
           </details>
        ]],
                { i(1), i(0) }
            )
        ),
    },
    python = {
        -- raycast script
        s(
            { trig = "raycast", docstring = "Raycast Script " },
            fmt("#!/usr/bin/env python\n\n" .. raycast_preamble .. "\n\n{}", raycast_preamble_nodes())
        ),
    },
    rust = {
        -- Adding test module
        s(
            { trig = "modtest", docstring = "Add test module" },
            fmt(
                [[
                #[cfg(test)]
                mod test {{
                {}

                    {}
                }}
            ]],
                {
                    c(1, { t("    use super::*;"), t("") }),
                    i(0),
                }
            )
        ),
        -- OnceLock
        s(
            { trig = "once", docstring = "OnceLock" },
            fmt(
                [[
			         static {}: OnceLock<{}> = OnceLock::new();
			         {}.get_or_init(|| {})
			         ]],
                {
                    i(1), -- TODO force uppercase somehow
                    i(2),
                    extras.rep(1),
                    i(0),
                }
            )
        ),
        -- Regex OnceCell boilerplate
        s(
            { trig = "rgx", docstring = "Regex OnceCell" },
            fmt(
                [[
            static {}: OnceLock<Regex> = OnceLock::new();
            {}.get_or_init(|| Regex::new(r"{}").unwrap()){}
        ]],
                {
                    i(1),
                    extras.rep(1),
                    i(2),
                    i(0),
                }
            )
        ),
        -- Adding test
        s(
            { trig = "test", docstring = "Add test" },
            fmt(
                [[
                #[test]
                fn {}() {}{{
                    {}{}
                }}
            ]],
                {
                    i(1),
                    c(2, {
                        t(""),
                        t("-> Result<()> "),
                    }),
                    i(0),
                    f(function(arg)
                        if string.find(arg[1][1], "Result") == nil then
                            return ""
                        end
                        return { "", "    Ok(())" }
                    end, { 2 }),
                }
            )
        ),
    },
    sh = sh_snips,
    template = {
        s(
            { trig = "osswitch", docstring = "OS-based switch-case" },
            fmt(
                [[
                {{{{ if eq .chezmoi.os "darwin" -}}}}
                {}
                {{{{ else if eq .chezmoi.os "linux" -}}}}
                {{{{ end -}}}}
            ]],
                { i(0) }
            )
        ),
    },
    terraform = {
        s(
            {
                trig = "^dd",
                regTrig = true,
                snippetType = "autosnippet",
            },
            fmt(
                [[
                data "{}" "{}" {{
                    {}
                }}
            ]],
                { i(1), i(2), i(0) }
            )
        ),
        s(
            {
                trig = "output",
            },
            fmt(
                [[
                output "{}" {{
                    value = {}
                }}
            ]],
                { i(1), i(0) }
            )
        ),
        s(
            {
                trig = "^rr",
                regTrig = true,
                snippetType = "autosnippet",
            },
            fmt(
                [[
                resource "{}" "{}" {{
                    {}
                }}
            ]],
                { i(1), i(2), i(0) }
            )
        ),
        s(
            {
                trig = "var",
            },
            fmt(
                [[
                variable "{}" {{
                    type = {}
                    {}
                }}
            ]],
                {
                    i(1),
                    c(2, {
                        t("string"),
                        t("number"),
                        t("bool"),
                        sn(nil, { t("list("), i(1), t(")") }),
                        sn(nil, { t("set("), i(1), t(")") }),
                        sn(nil, { t("map("), i(1), t(")") }),
                    }),
                    i(0),
                }
            )
        ),
    },
    zsh = sh_snips,
})
