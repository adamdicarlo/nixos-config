-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

local function map2(mode, lhses, rhs, opts)
  map(mode, lhses[1], rhs, opts)
  map(mode, lhses[2], rhs, opts)
end

local function textcase_cw(op)
  return function()
    require("textcase").current_word(op)
  end
end

local function textcase_cwv(op)
  return function()
    require("textcase").visual(op)
  end
end

map("n", "gau", textcase_cw("to_upper_case"), { desc = "Change current word to upper case" })
map("n", "gal", textcase_cw("to_lower_case"), { desc = "Change current word to lower case" })
map("n", "gas", textcase_cw("to_snake_case"), { desc = "Change current word to snake case" })
map("n", "gad", textcase_cw("to_dash_case"), { desc = "Change current word to dash case" })
map("n", "gan", textcase_cw("to_constant_case"), { desc = "Change current word to constant case" })
map("n", "ga.", textcase_cw("to_dot_case"), { desc = "Change current word to dot case" })
map("n", "gaa", textcase_cw("to_phrase_case"), { desc = "Change current word to phrase case" })
map("n", "gac", textcase_cw("to_camel_case"), { desc = "Change current word to camel case" })
map("n", "gap", textcase_cw("to_pascal_case"), { desc = "Change current word to pascal case" })
map("n", "gat", textcase_cw("to_title_case"), { desc = "Change current word to title case" })
map("n", "gaf", textcase_cw("to_path_case"), { desc = "Change current word to path case" })

map("v", "gau", textcase_cwv("to_upper_case"), { desc = "Change current word to upper case" })
map("v", "gal", textcase_cwv("to_lower_case"), { desc = "Change current word to lower case" })
map("v", "gas", textcase_cwv("to_snake_case"), { desc = "Change current word to snake case" })
map("v", "gad", textcase_cwv("to_dash_case"), { desc = "Change current word to dash case" })
map("v", "gan", textcase_cwv("to_constant_case"), { desc = "Change current word to constant case" })
map("v", "ga.", textcase_cwv("to_dot_case"), { desc = "Change current word to dot case" })
map("v", "gaa", textcase_cwv("to_phrase_case"), { desc = "Change current word to phrase case" })
map("v", "gac", textcase_cwv("to_camel_case"), { desc = "Change current word to camel case" })
map("v", "gap", textcase_cwv("to_pascal_case"), { desc = "Change current word to pascal case" })
map("v", "gat", textcase_cwv("to_title_case"), { desc = "Change current word to title case" })
map("v", "gaf", textcase_cwv("to_path_case"), { desc = "Change current word to path case" })

map("c", "%%", function()
  return vim.fn.expand("%:h") .. "/"
end, { desc = "Insert active buffer's path", expr = true })

map("", "<C-s>", ":w<CR>", { silent = true })
map("", "<C-q>", ":q<CR>")

map("n", "gl", "`.", { desc = "Jump to the last change in the file" })

-- vim.go.lmap = "hk,jh,kj"

--[[
--  Basic movement
-   Adapted from: http://forum.colemak.com/viewtopic.php?pid=184#p184 )
--]]
map("", "h", "k", { desc = "Up", silent = true })
map("", "j", "h", { desc = "Left", silent = true })
map("", "k", "j", { desc = "Down", silent = true })

-- map("", "zh", "zk", { desc = "Up" })
-- zK does not exis
-- map("", "zj", "zh", { desc = "Chararcter left" })
-- map("", "zJ", "zH", { desc = "Half screen right" })
-- map("", "zk", "zj", { desc = "Character down" })
-- zJ does not exist

-- Window movement
map2("n", { "<C-w>H", "<C-H>" }, "<C-w>K", { desc = "Move window left" })
map2("n", { "<C-w>J", "<C-J>" }, "<C-w>H", { desc = "Move window up" })
map2("n", { "<C-w>K", "<C-K>" }, "<C-w>J", { desc = "Move window down" })
map("n", "<C-L>", "<C-w>L", { desc = "Move window right" })

-- Split navigation key mappings
-- Easy split navigation, adapted from <https://github.com/sjl/dotfiles/blob/master/vim/vimrc#L509>.
map2("n", { "<C-h>", "<C-w>h" }, "<C-w>k", { desc = "Go to the left window" })
map2("n", { "<C-j>", "<C-w>j" }, "<C-w>h", { desc = "Go to the below window" })
map2("n", { "<C-k>", "<C-w>k" }, "<C-w>j", { desc = "Go to the above window" })
map2("n", { "<C-l>", "<C-w>l" }, "<C-w>l", { desc = "Go to the right window" })
--
-- Terminal configuration
vim.terminal_scrollback_buffer_size = 15000
-- this ruins running, e.g. lazygit
-- map("t", "<Esc>", "<C-\\><C-n>")
map("t", "<C-j>", "<C-\\><C-n><C-w>h", { desc = "Go to the left window" })
map("t", "<C-k>", "<C-\\><C-n><C-w>j", { desc = "Go to the below window" })
map("t", "<C-h>", "<C-\\><C-n><C-w>k", { desc = "Go to the above window" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Go to the right window" })
