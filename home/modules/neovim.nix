# Neovim configuration — lazy.nvim plugin manager
# LSP coverage: Rust, Python, C/C++, Lua, Nix, Java, Bash, HTML/CSS/JSON

{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable        = true;
    defaultEditor = true;
    viAlias       = true;
    vimAlias      = true;
    vimdiffAlias  = true;
    withPython3   = true;
    withNodeJs    = true;

    # LSP servers and formatters are managed by Nix, not Mason.
    # This keeps the Nix store as the single source of truth for tool versions.
    # lazy.nvim is also provided by Nix — no git clone at runtime.
    extraPackages = with pkgs; [
      # lazy.nvim — loaded via Nix, not git clone
      vimPlugins.lazy-nvim

      # LSP servers
      rust-analyzer
      pyright
      clang-tools
      lua-language-server
      nil
      bash-language-server
      vscode-langservers-extracted

      # Formatters
      stylua
      black
      rustfmt
      nixpkgs-fmt
      prettier

      # Linters
      shellcheck
      luajitPackages.luacheck

      # Telescope dependencies
      ripgrep
      fd
      tree-sitter
      gcc
    ];

    extraLuaConfig = ''
      -- ── Bootstrap ────────────────────────────────────────────────────────
      -- lazy.nvim is provided by Nix — no git clone needed.
      -- ${pkgs.vimPlugins.lazy-nvim} is the Nix store path.
      vim.opt.rtp:prepend("${pkgs.vimPlugins.lazy-nvim}")

      -- ── Leader keys ───────────────────────────────────────────────────────
      vim.g.mapleader      = " "
      vim.g.maplocalleader = "\\"

      -- ── Options ───────────────────────────────────────────────────────────
      local opt = vim.opt
      opt.number         = true
      opt.relativenumber = true
      opt.cursorline     = true
      opt.signcolumn     = "yes"
      opt.colorcolumn    = "80"

      opt.tabstop     = 4
      opt.shiftwidth  = 4
      opt.expandtab   = true
      opt.smartindent = true

      opt.wrap      = false
      opt.scrolloff = 8

      opt.incsearch  = true
      opt.ignorecase = true
      opt.smartcase  = true

      opt.splitright = true
      opt.splitbelow = true

      opt.undofile = true
      opt.swapfile = false
      opt.backup   = false

      opt.termguicolors = true
      opt.background    = "dark"

      opt.updatetime   = 100
      opt.timeoutlen   = 300
      opt.completeopt  = "menu,menuone,noselect"
      opt.conceallevel = 2

      -- ── Plugins ───────────────────────────────────────────────────────────
      require("lazy").setup({

        -- ── Colorscheme ─────────────────────────────────────────────────────
        {
          "ellisonleao/gruvbox.nvim",
          priority = 1000,
          config = function()
            require("gruvbox").setup({
              terminal_colors   = true,
              undercurl         = true,
              contrast          = "hard",
              palette_overrides = {},
              overrides         = {},
              dim_inactive      = false,
              transparent_mode  = true,
            })
            vim.cmd("colorscheme gruvbox")
          end,
        },

        -- ── Treesitter ──────────────────────────────────────────────────────
        {
          "nvim-treesitter/nvim-treesitter",
          build = ":TSUpdate",
          config = function()
            require("nvim-treesitter.configs").setup({
              ensure_installed = {
                "lua", "rust", "python", "c", "cpp",
                "nix", "java", "bash", "json", "yaml",
                "toml", "markdown", "markdown_inline",
                "html", "css", "javascript",
              },
              highlight = { enable = true },
              indent    = { enable = true },
            })
          end,
        },

        -- ── LSP ─────────────────────────────────────────────────────────────
        {
          "neovim/nvim-lspconfig",
          dependencies = { "hrsh7th/cmp-nvim-lsp" },
          config = function()
            local lspconfig = require("lspconfig")
            local caps = require("cmp_nvim_lsp").default_capabilities()

            for _, server in ipairs({
              "rust_analyzer", "pyright", "clangd",
              "lua_ls", "nil_ls", "bashls",
            }) do
              lspconfig[server].setup({ capabilities = caps })
            end

            local k = vim.keymap.set
            k("n", "gd",         vim.lsp.buf.definition,  { desc = "Go to definition" })
            k("n", "gr",         vim.lsp.buf.references,   { desc = "References" })
            k("n", "gi",         vim.lsp.buf.implementation, { desc = "Implementation" })
            k("n", "K",          vim.lsp.buf.hover,        { desc = "Hover docs" })
            k("n", "<leader>rn", vim.lsp.buf.rename,       { desc = "Rename" })
            k("n", "<leader>ca", vim.lsp.buf.code_action,  { desc = "Code action" })
            k("n", "<leader>f",  vim.lsp.buf.format,       { desc = "Format" })
            k("n", "[d",         vim.diagnostic.goto_prev)
            k("n", "]d",         vim.diagnostic.goto_next)
          end,
        },

        -- ── Completion ──────────────────────────────────────────────────────
        {
          "hrsh7th/nvim-cmp",
          dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
          },
          config = function()
            local cmp     = require("cmp")
            local luasnip = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
              snippet = {
                expand = function(args) luasnip.lsp_expand(args.body) end,
              },
              mapping = cmp.mapping.preset.insert({
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                  if cmp.visible() then cmp.select_next_item()
                  elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                  else fallback() end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                  if cmp.visible() then cmp.select_prev_item()
                  elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                  else fallback() end
                end, { "i", "s" }),
              }),
              sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "path" },
              }, {
                { name = "buffer", keyword_length = 3 },
              }),
            })
          end,
        },

        -- ── Fuzzy finder ────────────────────────────────────────────────────
        {
          "nvim-telescope/telescope.nvim",
          dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
          },
          config = function()
            local tel = require("telescope")
            tel.setup({
              defaults = {
                prompt_prefix    = "  ",
                selection_caret  = "  ",
                layout_strategy  = "horizontal",
                sorting_strategy = "ascending",
                layout_config    = { prompt_position = "top" },
              },
            })
            tel.load_extension("fzf")

            local b = require("telescope.builtin")
            local k = vim.keymap.set
            k("n", "<leader>ff", b.find_files,    { desc = "Find files" })
            k("n", "<leader>fg", b.live_grep,     { desc = "Live grep" })
            k("n", "<leader>fb", b.buffers,       { desc = "Buffers" })
            k("n", "<leader>fh", b.help_tags,     { desc = "Help tags" })
            k("n", "<leader>fr", b.oldfiles,      { desc = "Recent files" })
            k("n", "<leader>fd", b.diagnostics,   { desc = "Diagnostics" })
            -- Git telescope pickers
            k("n", "<leader>gc", b.git_commits,   { desc = "Git commits" })
            k("n", "<leader>gb", b.git_branches,  { desc = "Git branches" })
            k("n", "<leader>gs", b.git_status,    { desc = "Git status" })
            k("n", "<leader>gS", b.git_stash,     { desc = "Git stash" })
          end,
        },

        -- ── File tree ───────────────────────────────────────────────────────
        {
          "nvim-neo-tree/neo-tree.nvim",
          branch = "v3.x",
          dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
          },
          config = function()
            vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "File tree" })
          end,
        },

        -- ── Status line ─────────────────────────────────────────────────────
        {
          "nvim-lualine/lualine.nvim",
          config = function()
            require("lualine").setup({
              options = {
                theme                = "gruvbox",
                component_separators = { left = "", right = "" },
                section_separators   = { left = "", right = "" },
                globalstatus         = true,
              },
              -- Show git branch in statusline
              sections = {
                lualine_b = { "branch", "diff", "diagnostics" },
              },
            })
          end,
        },

        -- ── Buffer tabs ─────────────────────────────────────────────────────
        {
          "akinsho/bufferline.nvim",
          config = function()
            require("bufferline").setup({
              options = { diagnostics = "nvim_lsp" },
            })
          end,
        },

        -- ── Git integration ─────────────────────────────────────────────────

        -- Gitsigns — inline git blame, hunk navigation, stage/reset hunks
        {
          "lewis6991/gitsigns.nvim",
          config = function()
            require("gitsigns").setup({
              current_line_blame = true,   -- inline blame on current line
              current_line_blame_opts = {
                delay        = 500,
                virt_text_pos = "eol",
              },
              on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local k  = vim.keymap.set

                -- Hunk navigation
                k("n", "]c", gs.next_hunk,         { buffer = bufnr, desc = "Next hunk" })
                k("n", "[c", gs.prev_hunk,         { buffer = bufnr, desc = "Prev hunk" })

                -- Hunk actions
                k("n", "<leader>hs", gs.stage_hunk,    { buffer = bufnr, desc = "Stage hunk" })
                k("n", "<leader>hr", gs.reset_hunk,    { buffer = bufnr, desc = "Reset hunk" })
                k("n", "<leader>hS", gs.stage_buffer,  { buffer = bufnr, desc = "Stage buffer" })
                k("n", "<leader>hR", gs.reset_buffer,  { buffer = bufnr, desc = "Reset buffer" })
                k("n", "<leader>hu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo stage hunk" })

                -- Preview & blame
                k("n", "<leader>hp", gs.preview_hunk,  { buffer = bufnr, desc = "Preview hunk" })
                k("n", "<leader>hb", gs.blame_line,    { buffer = bufnr, desc = "Blame line" })
                k("n", "<leader>hd", gs.diffthis,      { buffer = bufnr, desc = "Diff this" })

                -- Toggle
                k("n", "<leader>tb", gs.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle blame" })
              end,
            })
          end,
        },

        -- Diffview — full diff and merge tool
        {
          "sindrets/diffview.nvim",
          cmd  = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
          keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<CR>",              desc = "Diff view" },
            { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>",     desc = "File history" },
            { "<leader>gH", "<cmd>DiffviewFileHistory<CR>",       desc = "Repo history" },
            { "<leader>gx", "<cmd>DiffviewClose<CR>",             desc = "Close diff" },
          },
        },

        -- LazyGit — full git TUI inside Neovim
        {
          "kdheepak/lazygit.nvim",
          dependencies = { "nvim-lua/plenary.nvim" },
          keys = {
            { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
          },
        },

        -- ── Keybinding hints ────────────────────────────────────────────────
        { "folke/which-key.nvim", event = "VeryLazy", config = true },

        -- ── Editing helpers ─────────────────────────────────────────────────
        { "windwp/nvim-autopairs",  event = "InsertEnter", config = true },
        { "numToStr/Comment.nvim",  config = true },
        { "kylechui/nvim-surround", config = true },

        -- ── Indent guides ───────────────────────────────────────────────────
        { "lukas-reineke/indent-blankline.nvim", main = "ibl", config = true },

        -- ── Rust-specific enhancements ──────────────────────────────────────
        { "mrcjkb/rustaceanvim", ft = { "rust" } },

        -- ── Diagnostics panel ───────────────────────────────────────────────
        {
          "folke/trouble.nvim",
          cmd    = "Trouble",
          config = true,
          keys   = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
          },
        },

        -- ── Start screen ────────────────────────────────────────────────────
        {
          "nvimdev/dashboard-nvim",
          event = "VimEnter",
          config = function()
            require("dashboard").setup({
              theme = "hyper",
              config = {
                header = {
                  "",
                  "  ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗",
                  "  ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝",
                  "  ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗",
                  "  ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║",
                  "  ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║",
                  "  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝",
                  "",
                },
              },
            })
          end,
        },

      }, {
        ui      = { border = "rounded" },
        checker = { enabled = true, notify = false },
        -- Tell lazy.nvim not to manage itself — Nix handles it
        performance = {
          rtp = {
            paths = { "${pkgs.vimPlugins.lazy-nvim}" },
          },
        },
      })

      -- ── Window navigation ─────────────────────────────────────────────────
      local k = vim.keymap.set
      k("n", "<C-h>", "<C-w>h")
      k("n", "<C-j>", "<C-w>j")
      k("n", "<C-k>", "<C-w>k")
      k("n", "<C-l>", "<C-w>l")

      -- ── Buffer navigation ─────────────────────────────────────────────────
      k("n", "<S-l>",      "<cmd>bnext<CR>")
      k("n", "<S-h>",      "<cmd>bprevious<CR>")
      k("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

      -- ── Visual line movement ──────────────────────────────────────────────
      k("v", "J", ":m '>+1<CR>gv=gv")
      k("v", "K", ":m '<-2<CR>gv=gv")

      -- ── Keep cursor centred while scrolling / searching ───────────────────
      k("n", "<C-d>", "<C-d>zz")
      k("n", "<C-u>", "<C-u>zz")
      k("n", "n",     "nzzzv")
      k("n", "N",     "Nzzzv")

      -- ── Quick save / quit ─────────────────────────────────────────────────
      k({ "n", "i" }, "<C-s>", "<cmd>w<CR>")
      k("n", "<leader>q",  "<cmd>q<CR>")
      k("n", "<leader>Q",  "<cmd>qa!<CR>")
    '';
  };
}
