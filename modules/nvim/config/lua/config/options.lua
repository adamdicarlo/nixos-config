--- Options are automatically loaded before lazy.nvim startup
--- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

opt.showcmd = true
opt.wrap = true
opt.autoindent = true
opt.softtabstop = 2
opt.formatoptions:append({ "l", "n" })
