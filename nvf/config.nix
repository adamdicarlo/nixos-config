# A module to be evaluated via lib.evalModules inside nvf's module system.
# All options supported by nvf will go under config.vim to create the final
# wrapped package. You may also add some new *options* under options.* to
# expand the module system.
{
  lib,
  nvim,
}: {
  # You may browse available options for nvf on the online manual. Please see
  # <https://notashelf.github.io/nvf/options.html>
  config.vim = {
    useSystemClipboard = true;

    keymaps = let
      # keymaps.*.silent defaults to true
      # keymaps.*.noremap defaults to true
      mapKey = mode: key: action: desc: {
        inherit mode key action desc;
      };
      mapKeyLua = mode: key: action: desc: {
        inherit mode key action desc;
        expr = true;
        lua = true;
        silent = false;
      };
      mapKeys = mode: keys: action: desc:
        lib.lists.map (k: mapKey mode k action desc) keys;
    in
      lib.lists.flatten [
        (mapKey "" "<C-s>" ":w<CR>" "Save")
        (mapKey "" "<C-q>" ":q<CR>" "Quit")

        (mapKey "n" "gl" "`." "Jump to the last change in the file")

        (mapKeyLua "c" "%%" ''
          function()
            return vim.fn.expand("%:h") .. "/"
          end'' "Insert active buffer's path")

        # Basic movement, originally adapted from: https://forum.colemak.com/topic/50-colemak-vim/#p184
        (mapKey "" "h" "k" "Up")
        (mapKey "" "j" "h" "Left")
        (mapKey "" "k" "j" "Down")

        # Window navigation and moving
        (mapKey "n" "<C-w>H" "<C-w>K" "Move window left")
        (mapKeys "n" ["<C-h>" "<C-w>h"] "<C-w>k" "Go to the left window")
        (mapKey "n" "<C-w>J" "<C-w>H" "Move window up")
        (mapKeys "n" ["<C-j>" "<C-w>j"] "<C-w>h" "Go to the above window")
        (mapKey "n" "<C-w>K" "<C-w>J" "Move window down")
        (mapKeys "n" ["<C-k>" "<C-w>k"] "<C-w>j" "Go to the below window")
        (mapKeys "n" ["<C-l>" "<C-w>l"] "<C-w>l" "Go to the right window")
      ];

    autocomplete.nvim-cmp.enable = true;
    bell = "visual";
    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
    };
    git = {
      enable = true;
      gitsigns = {
        codeActions.enable = true;
        enable = true;
      };
    };

    luaConfigRC = {
      custom-autocmds = nvim.dag.entryAnywhere (builtins.readFile ./lua/autocmds.lua);
      custom-options = nvim.dag.entryAfter ["optionsScript"] (builtins.readFile ./lua/options.lua);
    };

    # Language support and automatic configuration of companion plugins.
    # Note that enabling, e.g., languages.<lang>.diagnostics will automatically
    # enable top-level options such as enableLSP or enableExtraDiagnostics as
    # they are needed.
    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      bash.enable = true;
      css.enable = true;
      elm.enable = true;
      html.enable = true;
      lua.enable = true;
      markdown.enable = true;
      nix = {
        enable = true;
        lsp.options.nix.flake.autoArchive = true;
      };
      python.enable = true;
      tailwind.enable = true;
      terraform.enable = true;
      ts = {
        enable = true;
        extensions.ts-error-translator.enable = false;
      };
      yaml.enable = true;
    };
    lsp = {
      enable = true;
      formatOnSave = true;
      lightbulb.enable = true;
      lspSignature.enable = true;
      trouble.enable = true;
    };
    mini = {
      bufremove.enable = true;
    };
    options = {
      backup = true;
      writebackup = true;
      tabstop = 2;
    };
    statusline.lualine = {
      enable = true;
    };
    snippets.luasnip.enable = true;
    spellcheck = {
      enable = true;
      ignoredFiletypes = ["checkhealth"];
      programmingWordlist.enable = true;
      extraSpellWords = import ./spellcheck-extrawords.nix;
    };
    tabline.nvimBufferline.enable = true;
    telescope.enable = true;
    theme = {
      enable = true;
      name = "tokyonight";
      style = "moon";
    };
    treesitter.context.enable = true;
    visuals = {
      nvim-web-devicons.enable = true;
      nvim-cursorline.enable = true;
      highlight-undo.enable = true;
      indent-blankline.enable = true;
    };
  };
}
