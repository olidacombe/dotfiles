local M = {}

local function find_fenced_block(node, root)
    local current = node
    while current and current ~= root do
        if current:type() == "fenced_code_block" then
            return current
        end
        current = current:parent()
    end
    return nil
end

local function get_block_parts(block, bufnr)
    local info_string = nil
    local content = nil
    for child in block:iter_children() do
        local ctype = child:type()
        if ctype == "info_string" then
            info_string = vim.treesitter.get_node_text(child, bufnr)
        elseif ctype == "code_fence_content" then
            content = vim.treesitter.get_node_text(child, bufnr)
        end
    end
    return info_string, content
end

local function run_bash_block()
    local bufnr = 0
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown")
    if not ok then
        vim.notify("Treesitter parser not available for markdown", vim.log.levels.WARN)
        return
    end
    local tree = parser:parse()[1]
    if not tree then
        return
    end
    local root = tree:root()
    local node = vim.treesitter.get_node()
    if not node then
        return
    end

    local block = find_fenced_block(node, root)
    if not block then
        vim.notify("No fenced code block found", vim.log.levels.INFO)
        return
    end

    local info_string, content = get_block_parts(block, bufnr)
    local lang = info_string and info_string:match("^%s*(%S+)")
    if lang ~= "bash" and lang ~= "sh" then
        vim.notify("Not a bash fenced block", vim.log.levels.INFO)
        return
    end
    if not content or content == "" then
        vim.notify("Empty bash block", vim.log.levels.INFO)
        return
    end

    vim.cmd("split")
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)
    vim.fn.termopen({ "bash", "-c", content })
    vim.cmd("startinsert")
end

function M.setup()
    vim.api.nvim_buf_create_user_command(0, "MarkdownRunBashBlock", run_bash_block, {
        desc = "Run the surrounding markdown bash block",
    })
end

return M
