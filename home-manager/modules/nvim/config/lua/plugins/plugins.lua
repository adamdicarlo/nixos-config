local custom_attach = function(client)
  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end
end

return {

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        elm = { "elm_format" },
      },
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
  },

  { "folke/flash.nvim", enabled = false },
  {
    "echasnovski/mini.surround",
    enabled = false,
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },

  {
    "williamboman/mason.nvim",
    enabled = false,
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
      },
    },
  },

  -- @see https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-bracketed.md
  { "echasnovski/mini.bracketed" },

  { "gpanders/editorconfig.nvim", enabled = true },
  { "folke/lazy.nvim" },

  {
    "ggandor/leap.nvim",
    keys = {},
    opts = function(_, opts)
      vim.notify(opts)
      opts.mappings = {}
      return opts
    end,
  },

  -- FIND THE CRASH
  --
  -- { "echasnovski/mini.bracketed", enabled = false },
  -- { "echasnovski/mini.comment", enabled = false },
  { "echasnovski/mini.indentscope", enabled = false },
  { "echasnovski/mini.pairs", enabled = false },
  -- { "echasnovski/mini.bufremove", enabled = false },
  -- { "echasnovski/mini.surround", enabled = false },
  { "echasnovski/mini.ai", enabled = false },

  -- { "akinsho/bufferline.nvim", enabled = false },
  -- { "nvim-lualine/lualine.nvim", enabled = false },

  -- { "saadparwaiz1/cmp_luasnip", enabled = false },
  -- { "hrsh7th/cmp-buffer", enabled = false },
  -- { "hrsh7th/cmp-path", enabled = false },

  { "hrsh7th/cmp-nvim-lsp" },

  {
    "nvim-treesitter/nvim-treesitter",
    -- enabled = false,
    opts = function(_, opts)
      -- vim.notify(opts)

      -- opts.highlight = { enable = false }
      -- opts.context_commentstring = { enable = false }
      -- opts.incremental_selection = { enable = false }
      -- opts.textobjects = { enable = false }
      -- opts.indent = { enable = false }

      vim.list_extend(opts.ensure_installed, {
        "css",
        "elm",
        "html",
        "typescript",
      }, nil, nil)
    end,
  },

  -- { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },

  -- treesitter "Foo.|" CRASH CAUSER?!?!?!?!? fuhhhh, guess not
  -- { "RRethy/vim-illuminate", enabled = false },
  -- { "tpope/vim-repeat", enabled = false },

  -- /FIND THE CRASH

  -- { "nvim-treesitter/nvim-treesitter", enabled = false },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.defaults["gz"] = nil
      return opts
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      -- LSP Server Settings
      ---@type lspconfig.options
      -- @see https://github.com/elm-tooling/elm-language-server#server-settings
      -- @see https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/elmls.lua
      servers = {
        elmls = {
          rootPatterns = { "elm.json" },
          init_options = {
            disableElmLSDiagnostics = false,
            elmReviewDiagnostics = "error",
            elmPath = "/home/adam/.nix-profile/bin/lamdera",
            elmReviewPath = "./node_modules/.bin/elm-review",
            elmTestRunner = {
              showElmTestOutput = true,
            },
            onlyUpdateDiagnosticsOnSave = true,
            rootPatterns = { "elm.json" },
            skipInstallPackageConfirmation = false,
            trace = {
              server = "messages",
            },
          },
        },
        tsserver = {},
        ["nil_ls"] = {
          init_options = {
            formatting = {
              command = { "alejandra" },
            },
          },
        },
        tailwindcss = {
          filetypes = {
            "elm",
          },
          init_options = {
            userLanguages = {
              elm = "html",
            },
          },
          settings = {
            tailwindCSS = {
              classAttributes = {},
              headwind = {
                runOnSave = true,
              },
              includeLanguages = {
                elm = "html",
              },
              experimental = {
                classRegex = {
                  '\\bclass[\\s(<|]+"([^"]*)"',
                  '\\bclass[\\s(]+"[^"]*"[\\s+]+"([^"]*)"',
                  '\\bclass[\\s<|]+"[^"]*"\\s*\\+{2}\\s*" ([^"]*)"',
                  '\\bclass[\\s<|]+"[^"]*"\\s*\\+{2}\\s*" [^"]*"\\s*\\+{2}\\s*" ([^"]*)"',
                  '\\bclass[\\s<|]+"[^"]*"\\s*\\+{2}\\s*" [^"]*"\\s*\\+{2}\\s*" [^"]*"\\s*\\+{2}\\s*" ([^"]*)"',
                  '\\bclassList[\\s\\[\\(]+"([^"]*)"',
                  '\\bclassList[\\s\\[\\(]+"[^"]*",\\s[^\\)]+\\)[\\s\\[\\(,]+"([^"]*)"',
                  '\\bclassList[\\s\\[\\(]+"[^"]*",\\s[^\\)]+\\)[\\s\\[\\(,]+"[^"]*",\\s[^\\)]+\\)[\\s\\[\\(,]+"([^"]*)"',
                },
              },
              lint = {
                cssConflict = "error",
                recommendedVariantOrder = "error",
              },
            },
          },
        },
      },

      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        elmls = function(_, opts)
          local default_config = require("lspconfig.server_configurations.elmls").default_config
          local final_config = vim.tbl_deep_extend("force", default_config, opts, { on_attach = custom_attach })

          -- print(vim.inspect(final_config))
          -- final_config.root_dir = function(a, b)
          --   vim.notify("root_dir" .. vim.inspect({ a, b }))
          --   return "/home/adam/work/marketing-site"
          -- end
          require("lspconfig").elmls.setup(final_config)

          return true
        end,
        nil_ls = function(_, opts)
          -- Lovingly copied from https://github.com/oxalica/nil/blob/main/dev/nvim-lsp.nix:

          -- https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
          -- https://github.com/hrsh7th/cmp-nvim-lsp/issues/42#issuecomment-1283825572
          local caps = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities(),
            -- File watching is disabled by default for neovim.
            -- See: https://github.com/neovim/neovim/pull/22405
            { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
          )
          require("lspconfig").nil_ls.setup({
            autostart = true,
            capabilities = caps,
            settings = {
              ["nil"] = opts.init_options,
            },
          })
          return true
        end,
        -- example to setup with typescript.nvim
        -- tsserver = function(_, opts)
        --   require("typescript").setup({ server = opts })
        --   return true
        -- end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
  },

  { "echasnovski/mini.pairs", enabled = false },

  { "echasnovski/mini.ai", enabled = false },

  -- Similar to vim-abolish.
  -- @see https://github.com/johmsalas/text-case.nvim
  { "johmsalas/text-case.nvim" },
}
