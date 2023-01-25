local wk = require("od.which-key")
local Api = require "nvim-tree.api"
local quickcycle = require("od.quickcycle")

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

local last_child_or_self
last_child_or_self = function(node)
    if node.type ~= "directory" then return node end
    if not node.open then return node end
    local children = node.nodes
    if #children == 0 then return node end
    for i = #children, 1, -1 do
        local child = children[i]
        if child.type == "directory" then return last_child_or_self(child) end
    end
    return node
end

local prev_sibling
prev_sibling = function(node, closed)
    if not node or not node.parent then return end
    closed = closed or false
    local siblings = node.parent.nodes
    local s = #siblings
    repeat
        if siblings[s] == node then break end
        s = s - 1
        -- We sort of don't need to iterate all the way to the end here,
        -- if we reach one before the end here and haven't matched then
        -- we already know there's no next sibling.
    until (s == 0)
    for i = s - 1, 1, -1 do
        if siblings[i].type == "directory" then return last_child_or_self(siblings[i]) end
    end
    return node.parent
end

local next_dir = function(node, closed)
    if not node then return end
    closed = closed or false
    if node.type == "directory" and node.open then
        for _, child in ipairs(node.nodes or {}) do
            if child.type == "directory" and not (closed and child.open) then return child end
        end
    end
    return next_sibling(node, closed)
end

local prev_dir = function(node, closed)
    if not node then return end
    return prev_sibling(node, closed)
end

local up_action = function(node)
    focus_node(prev_dir(node))
end

local down_action = function(node)
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
                { key = "<Down>", action = " Dir", action_cb = down_action },
                { key = "<Up>", action = " Dir", action_cb = up_action },
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

--               _____      ______                     ______
-- ______ ____  ____(_)________  /____________  __________  /____
-- _  __ `/  / / /_  /_  ___/_  //_/  ___/_  / / /  ___/_  /_  _ \
-- / /_/ // /_/ /_  / / /__ _  ,<  / /__ _  /_/ // /__ _  / /  __/
-- \__, / \__,_/ /_/  \___/ /_/|_| \___/ _\__, / \___/ /_/  \___/
--   /_/                                 /____/
--
local quickcycle_mappings = quickcycle.new({
    { "diag", next = "normal ]e", prev = "normal [e" },
    { "change", next = "normal ]c", prev = "normal [c" },
})

local tree_buffers = {}

local od_tree = vim.api.nvim_create_augroup("Od_Tree", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufEnter", {
    group = od_tree,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "NvimTree" then return end
        local bufnr = vim.api.nvim_get_current_buf()
        if tree_buffers[bufnr] then return end
        tree_buffers[bufnr] = true
        quickcycle.push(quickcycle_mappings)
    end
})

autocmd("BufLeave", {
    group = od_tree,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "NvimTree" then return end
        local bufnr = vim.api.nvim_get_current_buf()
        if not tree_buffers[bufnr] then return end
        tree_buffers[bufnr] = nil
        quickcycle.pop()
    end
})
