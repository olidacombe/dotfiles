require "makemapper".setup()

require("which-key").register({
    m = { name = "make" }
}, { mode = "n", prefix = "<leader>" })
