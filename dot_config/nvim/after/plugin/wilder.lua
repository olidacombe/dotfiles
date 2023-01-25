local wilder = require('wilder')
wilder.setup({
    modes = { ':', '/', '?' },
    accept_key = '<c-c>',
    reject_key = '<c-g>',
})

wilder.set_option('renderer', wilder.popupmenu_renderer({
    highlighter = wilder.basic_highlighter(),
    left = { ' ', wilder.popupmenu_devicons() },
    right = { ' ', wilder.popupmenu_scrollbar() },
}))
