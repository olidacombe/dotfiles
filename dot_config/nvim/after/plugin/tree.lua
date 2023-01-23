local wk = require("od.which-key")
local Api = require "nvim-tree.api"

local focus_node = function(node)
    if not node then return end
    Api.tree.find_file(node.absolute_path)
end

local next_sibling
next_sibling = function(node, closed)
    if not node or not node.parent then return end
    closed = closed or false
    local siblings = node.parent.nodes
    local s = 1
    repeat
        if siblings[s] == node then break end
        s = s + 1
        -- We sort of don't need to iterate all the way to the end here,
        -- if we reach one before the end here and haven't matched then
        -- we already know there's no next sibling.
    until (s > #siblings)
    for i = s + 1, #siblings do
        if siblings[i].type == "directory" then return siblings[i] end
    end
    return next_sibling(node.parent)
end

local next_dir
next_dir = function(node, closed)
    if not node then return end
    closed = closed or false
    if node.type == "directory" and node.open then
        for _, child in ipairs(node.nodes or {}) do
            if child.type == "directory" and not (closed and child.open) then return child end
        end
    end
    return next_sibling(node, closed)
end

local down_action
down_action = function(node)
    focus_node(next_dir(node))
end

local right_action
right_action = function(node)
    if node.type == "directory" then
        if node.open then
            return focus_node(next_dir(node, true))
        else
            Api.node.open.edit(node)
            vim.cmd("normal j")
        end
        return
    elseif node.type == "file" then
        return focus_node(next_dir(node.parent, true))
    end
    vim.cmd("normal j")
end

require("nvim-tree").setup({
    update_focused_file = {
        enable = true
    },
    view = {
        mappings = {
            custom_only = false,
            list = {
                -- allow tab to fall through to my default
                { key = "<Tab>", action = "" },
                { key = "<Left>", action = "close_node" },
                { key = "∂", action = "node debug", action_cb = function(node)
                    P(node)
                end },
                { key = "<Down>", action = "next_sibling", action_cb = down_action },
                { key = "<Up>", action = "prev_sibling" },
                { key = "<Right>", action = "Expand", action_cb = right_action },
                -- use + as inverse of - (dir_up)
                { key = "+", action = "cd" },
                { key = "zM", action = "Collapse all", action_cb = Api.tree.collapse_all },
                { key = "zR", action = "Expand all", action_cb = Api.tree.expand_all },
            },
        },
    },
})

wk.register_normal({
    w = {
        b = { "<cmd>NvimTreeToggle<CR>", "Browser" },
    },
})
