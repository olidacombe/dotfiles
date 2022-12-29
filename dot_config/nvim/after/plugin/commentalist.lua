local commentalist = require("commentalist")

commentalist.setup()

vim.keymap.set({ "n", "v" }, "<leader>cm", "<cmd>Commentalist<CR>", { desc = "Commental" })
