local commentalist = require("commentalist")

commentalist.setup()

vim.keymap.set({ "n", "v" }, "<leader>mm", ":Commentalist<CR>", { desc = "Commental" })
