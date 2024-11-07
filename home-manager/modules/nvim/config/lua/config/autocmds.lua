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

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup("devbox"),
  pattern = { "devbox.json" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.filetype = "jsonc"
  end,
})

vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, bufnr)
        local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
        if vim.regex([[^#!.*\<tiv\>.*\<bash\>]]):match_str(content) ~= nil then
          return "bash"
        elseif vim.regex([[^#!.*\<tiv\>.*\<node\>]]):match_str(content) ~= nil then
          return "javascript"
        end
      end,
      { priority = -math.huge },
    },
  },
})
