local M = {}

-- State to track selection history
local selection_stack = {}

local function select_node(node)
    if not node then return end

    local start_row, start_col, end_row, end_col = node:range()

    -- Validate cursor positions are within buffer bounds
    local bufnr = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(bufnr)

    -- Clamp to valid buffer range
    start_row = math.max(0, math.min(start_row, line_count - 1))
    end_row = math.max(0, math.min(end_row, line_count - 1))

    -- Get the actual line to validate column positions
    local start_line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1] or ""
    start_col = math.min(start_col, #start_line)

    -- Set cursor to start position (treesitter is 0-indexed, vim is 1-indexed for rows)
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })

    -- Enter visual mode
    vim.cmd('normal! v')

    -- Move to end position
    -- Treesitter end is exclusive, so end_col points one past the last character
    -- We want to select up to and including the last character
    if end_col > 0 then
        -- Normal case: select up to end_col - 1
        local end_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ""
        local target_col = math.min(end_col - 1, #end_line > 0 and #end_line - 1 or 0)
        vim.api.nvim_win_set_cursor(0, { end_row + 1, target_col })
    else
        -- end_col is 0, meaning the selection ends at column 0 of end_row
        -- This means we want the entire previous line
        if end_row > 0 then
            local prev_line = vim.api.nvim_buf_get_lines(bufnr, end_row - 1, end_row, false)[1] or ""
            local target_col = math.max(0, #prev_line - 1)
            vim.api.nvim_win_set_cursor(0, { end_row, target_col })
        else
            -- Edge case: can't go back, just select to column 0
            vim.api.nvim_win_set_cursor(0, { end_row + 1, 0 })
        end
    end
end

function M.init_selection()
    selection_stack = {}
    local node = vim.treesitter.get_node()
    if node then
        table.insert(selection_stack, node)
        select_node(node)
    end
end

function M.node_incremental()
    -- Exit visual mode using escape key
    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
    vim.api.nvim_feedkeys(esc, 'x', false)

    local current_node = selection_stack[#selection_stack]
    if not current_node then
        M.init_selection()
        return
    end

    local parent = current_node:parent()
    if parent then
        table.insert(selection_stack, parent)
        select_node(parent)
    else
        -- Already at root, just re-select current node
        select_node(current_node)
    end
end

function M.node_decremental()
    -- Exit visual mode using escape key
    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
    vim.api.nvim_feedkeys(esc, 'x', false)

    if #selection_stack <= 1 then
        -- Re-select current
        if selection_stack[1] then
            select_node(selection_stack[1])
        end
        return
    end

    table.remove(selection_stack)
    local previous_node = selection_stack[#selection_stack]
    if previous_node then
        select_node(previous_node)
    end
end

function M.scope_incremental()
    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
    vim.api.nvim_feedkeys(esc, 'x', false)

    local current_node = selection_stack[#selection_stack] or vim.treesitter.get_node()
    if not current_node then return end

    local parent = current_node:parent()
    while parent do
        if parent:named_child_count() > 1 then
            table.insert(selection_stack, parent)
            select_node(parent)
            return
        end
        parent = parent:parent()
    end

    -- If we didn't find a suitable parent, just re-select current
    select_node(current_node)
end

return M
