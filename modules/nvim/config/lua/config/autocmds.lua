local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("elm"),
  pattern = { "elm" },
  callback = function()
    vim.opt_local.shiftwidth = 4
  end,
})
