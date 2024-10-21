local register_normal = require("od.which-key").register_normal
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")
local telescope = require("telescope")

local normal_mappings = {
    { "f",  group = "Fuzzy Find" },
    { "fc", builtin.lsp_references, desc = "References" },
    { "fC", builtin.colorscheme,    desc = "Colourscheme" },
    {
        "ff",
        function()
            builtin.git_files({
                hidden = true,
                show_untracked = true,
                use_git_root = false, -- handy for monorepo
            })
        end,
        desc = "Files<=Repo",
    },
    {
        "fF",
        function()
            builtin.find_files({
                hidden = true,
            })
        end,
        desc = "Files",
    },
    { "fr", builtin.registers, desc = "Registers" },
    { "fR", builtin.resume,    desc = "Resume" },
    { "fG", builtin.live_grep, desc = "Grep" },
    {
        "fg",
        function()
            builtin.grep_string({
                shorten_path = true,
                word_match = "-w",
                only_sort_text = true,
                search = "",
            })
        end,
        desc = '"Rg - ish"',
    },
    { "fj", "<cmd>Telescope jira<cr>",         desc = "Jira" },
    { "fk", builtin.keymaps,                   desc = "Keymaps" },
    { "fb", builtin.current_buffer_fuzzy_find, desc = "Within buffer" },
    { "fB", builtin.buffers,                   desc = "Buffers" },
    { "fh", builtin.help_tags,                 desc = "Help" },
    { "fm", "<cmd>Telescope makemapper<cr>",   desc = "Make Targets" },
    { "fs", builtin.lsp_document_symbols,      desc = "Document Symbols" },
    { "fS", builtin.lsp_workspace_symbols,     desc = "Workspace Symbols" },
    { "fq", builtin.quickfix,                  desc = "Quickfix" },
    { 'f"', builtin.registers,                 desc = "Registers" },
    { "gb", builtin.git_branches,              desc = "Branch" },
    { "gc", builtin.git_commits,               desc = "Commits" },
}

register_normal(normal_mappings)

local has_selections = function(prompt_bufnr)
    -- return true if any selections have been made
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selections = picker:get_multi_selection()
    return (#selections > 0)
end

local send_to_qflist = function(prompt_bufnr, mode, target)
    -- send selections or whole filtered list when none have been made
    if has_selections(prompt_bufnr) then
        return actions.send_selected_to_qflist(prompt_bufnr, mode, target)
    end
    return actions.send_to_qflist(prompt_bufnr, mode, target)
end

telescope.setup({
    defaults = {
        file_ignore_patterns = {
            ".git/",
            "%.cache",
            "%.o",
            "%.a",
            "%.out",
            "%.class",
            "%.pdf",
            "%.mkv",
            "%.zip",
            "%.mp4",
        },
        mappings = {
            i = {
                ["<C-q>"] = send_to_qflist,
            },
            n = {
                ["<C-q>"] = send_to_qflist,
            },
        },
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--hidden",
            "--smart-case",
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        },
        jira = {
            limit = 500,
            projects = {
                "ibau",
                "infr",
                "gsra",
            },
        },
    },
    pickers = {
        colorscheme = {
            enable_preview = true,
        },
    },
})

telescope.load_extension("fzf")
telescope.load_extension("harpoon")
telescope.load_extension("jira")
telescope.load_extension("makemapper")
telescope.load_extension("monorepo")

-- temp fix for https://github.com/nvim-telescope/telescope.nvim/issues/2027
local od_i2027 = vim.api.nvim_create_augroup("Od_i2027", { clear = true })
vim.api.nvim_create_autocmd(
-- Prevent entering buffers in insert mode.
    "WinLeave",
    {
        group = od_i2027,
        pattern = "*",
        callback = function()
            if vim.bo.ft == "TelescopePrompt" and vim.fn.mode() == "i" then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "i", false)
            end
        end,
    }
)
