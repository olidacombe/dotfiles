local commentalist = require("commentalist")

commentalist.setup()

vim.keymap.set({ "n", "v" }, "<leader>cm", ":Commentalist<CR>", { desc = "Commental" })
