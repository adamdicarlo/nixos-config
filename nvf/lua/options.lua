local o, opt = vim.o, vim.opt

o.cursorline = true

o.scrolloff = 5
o.shiftwidth = 2
o.showcmd = true
o.softtabstop = 2
o.tabstop = 2
o.undofile = true

opt.backupdir = { vim.fn.expand("$HOME/.local/state/nvim/backup//") }
opt.formatoptions:append({ "l", "n" })
