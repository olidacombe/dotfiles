--        ,                                                     .  ,
--     ._/),                                                   .(\/),
--     ii// )/)     ,-=-.       ,-=-.       ,-=-.       ,-=-.     (\/|/)
-- ,^=-9 ,//) )=-="'     '"=-="'     '"=-="'     '"=-="'     '"=-="/ }/)
--  ""_,),,/ "      ,-=-.       ,-=-.       ,-=-.       ,-=-.      ,/`~
--   """ )))\))=-="'     '"=-="'     '"=-="'     '"=-="'     '"=-="
--            <<  <<                             <<   <<
--          ((( >((( >                         ((( > ((( >
--
--                 WIP run bash blocks in markdown files
--        ,                                                     .  ,
--     ._/),                                                   .(\/),
--     ii// )/)     ,-=-.       ,-=-.       ,-=-.       ,-=-.     (\/|/)
-- ,^=-9 ,//) )=-="'     '"=-="'     '"=-="'     '"=-="'     '"=-="/ }/)
--  ""_,),,/ "      ,-=-.       ,-=-.       ,-=-.       ,-=-.      ,/`~
--   """ )))\))=-="'     '"=-="'     '"=-="'     '"=-="'     '"=-="
--            <<  <<                             <<   <<
--  gpyy    ((( >((( >                         ((( > ((( >

-- local get_root = function()
--     local parser = vim.treesitter.get_parser()
--     local tree = parser:parse()[1]
--     local root = tree:root()
--     return root
-- end
--
-- -- TODO also validate that it's a ```bash block
-- local get_bash_block = function()
--     local root = get_root()
--     local node = vim.treesitter.get_node()
--     -- P(ts_utils.get_node_text(node, 0))
--     -- if node == nil then
--     --     print("node is nil")
--     --     return nil
--     -- end
--
--     -- Try to find a parent bash block
--     while node:type() ~= "fenced_code_block" do
--         if node == root then
--             return nil
--         end
--         node = node:parent()
--     end
--
--     -- TODO try to find "next" bash block
--
--     for child in node:iter_children() do
--         if child:type() == "code_fence_content" then
--             local text = vim.treesitter.get_node_text(child, 0)
--             return text
--         end
--     end
--     return nil
-- end
--
-- local run_bash_block = function()
--     local block_content = get_bash_block()
--     if block_content == nil then
--         return
--     end
--
--     vim.cmd("vsplit | terminal bash -c \"" .. block_content .. "\"")
--     -- P(block_content)
-- end
--
-- vim.keymap.set("n", "<leader>r", run_bash_block, {
--     desc = "Run markdown bash block",
--     noremap = true,
--     nowait = true,
--     silent = true,
-- })

vim.keymap.set({ "n", "v" }, "<leader>jt", ":JiraTable<CR>", {
    desc = "Create Markdown Table From JQL",
    noremap = true,
    nowait = true,
    silent = true,
})

vim.keymap.set("n", "<leader>A", "<Nop>", {
    desc = "AWS"
})

vim.keymap.set("n", "<leader>Ac", ":ShowAwsCostGraphPicker<CR>", {
    desc = "Costs",
    noremap = true,
    nowait = true,
    silent = true,
})
