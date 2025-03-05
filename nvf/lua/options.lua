-- options.lua

vim.opt.showcmd = true
vim.opt.softtabstop = 2
vim.opt.formatoptions:append({ "l", "n" })
vim.opt.backupdir = { vim.fn.expand("$HOME/.local/state/nvim/backup//") }
