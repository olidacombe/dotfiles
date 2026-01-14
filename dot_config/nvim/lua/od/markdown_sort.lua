local M = {}

local function get_heading_level_and_title(node, bufnr)
    local text = vim.treesitter.get_node_text(node, bufnr)
    local lines = vim.split(text, "\n", { plain = true })
    local first = lines[1] or ""
    if node:type() == "atx_heading" then
        local hashes, title = first:match("^(#+)%s*(.-)%s*#*%s*$")
        if not hashes then
            return nil
        end
        return #hashes, title
    end
    if node:type() == "setext_heading" then
        local underline = lines[2] or ""
        local level = nil
        if underline:match("^=+$") then
            level = 1
        elseif underline:match("^-+$") then
            level = 2
        end
        if not level then
            return nil
        end
        local title = (lines[1] or ""):gsub("%s+$", "")
        return level, title
    end
    return nil
end

local function collect_headings(bufnr, start_row, end_row)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown")
    if not ok then
        return {}
    end
    local tree = parser:parse()[1]
    if not tree then
        return {}
    end
    local root = tree:root()
    local query = vim.treesitter.query.parse(
        "markdown",
        [[
        (atx_heading) @heading
        (setext_heading) @heading
        ]]
    )
    local headings = {}
    for _, node in query:iter_captures(root, bufnr, start_row, end_row + 1) do
        local node_start_row = node:range()
        if node_start_row >= start_row and node_start_row <= end_row then
            local level, title = get_heading_level_and_title(node, bufnr)
            if level and title then
                table.insert(headings, {
                    level = level,
                    title = title,
                    start_row = node_start_row,
                })
            end
        end
    end
    table.sort(headings, function(a, b)
        return a.start_row < b.start_row
    end)
    return headings
end

local function sort_sections_in_range(bufnr, start_row, end_row)
    local headings = collect_headings(bufnr, start_row, end_row)
    if #headings < 2 then
        return
    end

    local min_level = math.huge
    for _, heading in ipairs(headings) do
        if heading.level < min_level then
            min_level = heading.level
        end
    end

    local top_headings = {}
    for _, heading in ipairs(headings) do
        if heading.level == min_level then
            table.insert(top_headings, heading)
        end
    end
    if #top_headings < 2 then
        return
    end

    local sections = {}
    for i, heading in ipairs(top_headings) do
        local next_heading = top_headings[i + 1]
        local section_start = heading.start_row
        local section_end = end_row
        if next_heading then
            section_end = math.min(next_heading.start_row - 1, end_row)
        end
        if section_end < section_start then
            section_end = section_start
        end
        local lines = vim.api.nvim_buf_get_lines(bufnr, section_start, section_end + 1, false)
        table.insert(sections, {
            title = heading.title,
            lines = lines,
            index = i,
            start_row = section_start,
            end_row = section_end,
        })
    end

    local first_start = sections[1].start_row
    local last_end = sections[#sections].end_row
    local pre_lines = vim.api.nvim_buf_get_lines(bufnr, start_row, first_start, false)
    local post_lines = vim.api.nvim_buf_get_lines(bufnr, last_end + 1, end_row + 1, false)

    table.sort(sections, function(a, b)
        local at = a.title:lower()
        local bt = b.title:lower()
        if at == bt then
            return a.index < b.index
        end
        return at < bt
    end)

    local new_lines = {}
    for _, line in ipairs(pre_lines) do
        table.insert(new_lines, line)
    end
    for _, section in ipairs(sections) do
        for _, line in ipairs(section.lines) do
            table.insert(new_lines, line)
        end
    end
    for _, line in ipairs(post_lines) do
        table.insert(new_lines, line)
    end

    vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, new_lines)
end

function M.setup()
    vim.api.nvim_buf_create_user_command(0, "MarkdownSortSections", function(opts)
        local start_row = opts.line1 - 1
        local end_row = opts.line2 - 1
        sort_sections_in_range(0, start_row, end_row)
    end, {
        range = true,
        desc = "Sort markdown sections by top-level headings",
    })
end

return M
