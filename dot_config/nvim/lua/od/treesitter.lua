local M = {}

-- State to track selection history
local selection_stack = {}

local function select_node(node)
    if not node then return end

    local start_row, start_col, end_row, end_col = node:range()

    -- Get current buffer
    local bufnr = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(bufnr)

    -- Clamp start to valid buffer range
    start_row = math.max(0, math.min(start_row, line_count - 1))

    -- For end position: if end_col is 0, we're actually pointing to the previous line's end
    -- Don't clamp end_row yet, we need to handle the end_col == 0 case first
    local actual_end_row, actual_end_col

    if end_col > 0 then
        -- Normal case: end position is on end_row
        actual_end_row = math.min(end_row, line_count - 1)
        local end_line = vim.api.nvim_buf_get_lines(bufnr, actual_end_row, actual_end_row + 1, false)[1] or ""
        actual_end_col = math.min(end_col - 1, math.max(0, #end_line - 1))
    else
        -- end_col is 0: the range ends at the beginning of end_row,
        -- which means we want everything up to the end of the previous line
        actual_end_row = math.min(end_row - 1, line_count - 1)
        local end_line = vim.api.nvim_buf_get_lines(bufnr, actual_end_row, actual_end_row + 1, false)[1] or ""
        actual_end_col = math.max(0, #end_line - 1)
    end

    -- Get the actual start line to validate column positions
    local start_line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1] or ""
    start_col = math.min(start_col, #start_line)

    -- Set cursor to start position (treesitter is 0-indexed, vim is 1-indexed for rows)
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })

    -- Enter visual mode
    vim.cmd('normal! v')

    -- Move to end position
    vim.api.nvim_win_set_cursor(0, { actual_end_row + 1, actual_end_col })
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

    local current_node = selection_stack[#selection_stack]
    if not current_node then
        return
    end

    if #selection_stack <= 1 then
        -- At root, try to go deeper into children
        local deepest = current_node
        while deepest do
            local child = deepest:named_child(0)
            if child then
                deepest = child
            else
                break
            end
        end

        if deepest and deepest ~= current_node then
            table.insert(selection_stack, deepest)
            select_node(deepest)
        else
            -- No children to go deeper, re-select current
            select_node(current_node)
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
