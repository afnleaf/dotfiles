-- init.lua

-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true


-- Number line
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- Set up transparency
vim.api.nvim_command('hi Normal guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi SignColumn guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi NormalNC guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi MsgArea guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi TelescopeBorder guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi NvimTreeNormal guibg=NONE ctermbg=NONE')

-- Mouse Support
vim.opt.mouse = 'a'

-- State
vim.g.lsp_enabled = true
vim.g.completion_enabled = true

-- Autoreload
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

-- Toggle LSP
function Toggle_lsp()
    local buf = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({buffer = buf})
    if #clients > 0 then
        -- If there are active clients, stop them
        for _, client in ipairs(clients) do
            vim.lsp.stop_client(client.id)
        end
        vim.g.lsp_enabled = false
        vim.notify("LSP disabled for current buffer")
    else
        -- Restart LSP for current buffer
        vim.cmd("LspStart")
        vim.g.lsp_enabled = true
        vim.notify("LSP enabled for current buffer")
    end
end

-- Toggle completion
function Toggle_completion()
    local cmp = require('cmp')
    if vim.g.completion_enabled then
        cmp.setup.buffer({ enabled = false })
        vim.g.completion_enabled = false
        vim.notify("Completion disabled")
    else
        cmp.setup.buffer({ enabled = true })
        vim.g.completion_enabled = true
        vim.notify("Completion enabled")
    end
end

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fs.normalize(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")
--if not vim.loop.fs_stat(lazypath) then
--if not vim.fs.stat(lazypath) then
if vim.fn.empty(vim.fn.glob(lazypath)) > 0 then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Configure plugins
require("lazy").setup({
    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "javascript", "typescript", "python" },
                ignore_install = {},
                modules = {},
                sync_install = true,
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = true
                }
            })
        end,
    },
    -- Monokai theme
    {
        "tanvirtin/monokai.nvim",
        priority = 1000, -- Load colorscheme before other plugins
        config = function()
            -- Configure the colorscheme
            require('monokai').setup {
                palette = require('monokai').pro,
                transparent = true,
                terminal_colors = true,
                styles = {
                    comments = { italic = true },
                    keywords = { italic = true },
                    functions = { bold = true },
                    strings = { italic = true },
                    variables = {}
                },
            }
            -- Set the colorscheme
            vim.cmd.colorscheme("monokai")

            -- Custom highlight colour
            vim.api.nvim_set_hl(0, 'Visual', { bg = "#264F78" })

            -- Force transparency after colorscheme is loaded
            vim.api.nvim_command('hi Normal guibg=NONE ctermbg=NONE')
            vim.api.nvim_command('hi LineNr guibg=NONE ctermbg=NONE')
            vim.api.nvim_command('hi Folded guibg=NONE ctermbg=NONE')
            vim.api.nvim_command('hi NonText guibg=NONE ctermbg=NONE')
            vim.api.nvim_command('hi SpecialKey guibg=NONE ctermbg=NONE')
            vim.api.nvim_command('hi VertSplit guibg=NONE ctermbg=NONE')
            vim.api.nvim_command('hi SignColumn guibg=NONE ctermbg=NONE')
            vim.api.nvim_command('hi EndOfBuffer guibg=NONE ctermbg=NONE')
        end,
    },
    -- Minimap
    --{
    --   'gorbit99/codewindow.nvim',
    --    dependencies = {
    --        "nvim-treesitter/nvim-treesitter",
    --    },
    --    config = function()
    --        local codewindow = require('codewindow')
    --        codewindow.setup({
    --            active_in_terminals = false,
    --            max_minimap_height = 100,
    --            minimap_width = 20,
    --            use_treesitter = true,
    --            exclude_filetypes = {'help'},
    --            window_border = 'single',
    --            use_lsp = true,
    --            screen_bounds = 'lines',
    --            z_index = 1,
    --            window = {
    --                scrollbar = true,
    --                focusable = true,
    --            },
    --        })

    --        codewindow.apply_default_keybinds()
    --    end,
    --},
    -- Auto-pairs
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = function()
            local npairs = require('nvim-autopairs')
            npairs.setup({
                check_ts = true, -- Use treesitter to check for pairs
                enable_check_bracket_line = true,  -- Don't add pairs if it already has a close pair in the same line
                ignored_next_char = "[%w%.]", -- Don't add pairs if the next char is alphanumeric
                -- Add spaces between parentheses
                enable_afterquote = true,  -- add bracket pairs after quote
                enable_moveright = true,   -- enable moving right when inserting pairs
            })

            -- Add specific rules
            local Rule = require('nvim-autopairs.rule')
            -- Add spaces between parentheses
            local brackets = { { '(', ')' }, { '[', ']' }, { '{', '}' }}
            npairs.add_rules {
                -- Add space between parentheses
                Rule(' ', ' ')
                    :with_pair(function (opts)
                        local pair = opts.line:sub(opts.col - 1, opts.col)
                        return vim.tbl_contains({
                            brackets[1][1]..brackets[1][2],
                            brackets[2][1]..brackets[2][2],
                            brackets[3][1]..brackets[3][2],
                        }, pair)
                    end)
            }
            -- Add <> pairs
            npairs.add_rules({
                Rule('<', '>')
                    :with_pair(function()
                        -- Add pair only in specific file types
                        return vim.tbl_contains({ 'html', 'xml', 'tsx', 'jsx', 'vue', 'svelte', 'rs' }, vim.bo.filetype)
                    end)
            })
            npairs.add_rules({
                Rule('|', '|')
                    :with_pair(function()
                        return vim.bo.filetype == 'rust'
                    end)
                    :with_move(function(opts)
                        return opts.char == '|'
                    end)
            })
        end
    },
    -- Mason for LSP management
    {
        "williamboman/mason.nvim",
        lazy = true,
        event = "VeryLazy",
        build = ":MasonUpdate",
        config = function()
            require("mason").setup()
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",       -- Lua
                    "pyright",      -- Python
                    "cssls",        -- CSS
                    "html",         -- HTML
                    "emmet_ls",     -- Emmet
                    "jsonls",       -- JSON
                    "ts_ls",        -- Javascript/Typescript
                    -- i don't want to use one for rust, compiler better

                },
                automatic_installation = true,
            })
        end
    },
    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile"},
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/nvim-cmp",
            "L3MON4D3/LuaSnip",
            "b0o/schemastore.nvim",
        },
        config = function()
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- new function to set up LSP keymaps properly
            local function setup_lsp_keymaps(client, bufnr)
                local function buf_set_keymap(mode, lhs, rhs, opts)
                    local options = {noremap = true, silent = true}
                    if opts then options = vim.tbl_extend('force', options, opts) end
                    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, options)
                end

                if client.server_capabilities then
                    -- Set up all your existing keymaps as buffer-local
                    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
                    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
                    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
                    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
                    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
                    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
                    buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
                    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
                    buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.format()<CR>')
                end
            end


            -- LSP setup function
            local function setup_lsp(server, config)
                config = config or {}
                config.capabilities = capabilities
                config.on_attach = function(client, bufnr)
                    setup_lsp_keymaps(client, bufnr)
                end
                lspconfig[server].setup(config)
            end

            local function get_mason_bin(bin)
                local is_windows = vim.fn.has("win32") == 1
                local mason_root = vim.fs.normalize(vim.fn.stdpath("data") .. "/mason/bin")

                if is_windows then
                    return mason_root .. bin .. ".cmd"
                else
                    return mason_root .. bin
                end
            end

            -- Set up each LSP server with all your existing configurations
            setup_lsp('lua_ls', {
                cmd = { get_mason_bin("/lua-language-server") },
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { 'vim' }
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            })

            setup_lsp('pyright', {
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                        },
                    },
                },
            })

            setup_lsp('html', {
                filetypes = { "html", "htmldjango" },
            })

            setup_lsp('cssls')

            setup_lsp('jsonls', {
                settings = {
                    json = {
                        schemas = require('schemastore').json.schemas(),
                        validate = { enable = true },
                    },
                },
            })

            setup_lsp('emmet_ls', {
                cmd = { get_mason_bin("/emmet-ls"), "--stdio" },
                filetypes = {
                    'html', 'css', 'scss', 'javascript',
                    'javascriptreact', 'typescriptreact',
                    'svelte', 'vue', 'htmldjango'
                },
            })

            setup_lsp("ts_ls", {
                cmd = { get_mason_bin("/typescript-language-server"), "--stdio"},
                filetypes = {
                    "javascript", "javascriptreact", "javascript.jsx",
                    "typescript", "typescriptreact", "typescript.tsx"
                },
                settings = {
                    javascript = {
                        suggesstFromUseImport = true,
                        importModuleSpecifier = "relative"
                    },
                    typescript = {
                        suggesstFromUseImport = true,
                        importModuleSpecifier = "relative"
                    },
                }
            })

        end
    },
    -- Autocompletion setup
    {
        'hrsh7th/nvim-cmp',
        event = { "InsertEnter", "CmdlineEnter"},
        dependencies = {
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'path' },
                }),
            })
        end
    },
})

-- Keymaps
vim.api.nvim_set_keymap('n', '<leader>tl', ':lua Toggle_lsp()<CR>',
    {noremap = true, silent = true, desc = 'Toggle LSP'})
vim.api.nvim_set_keymap('n', '<leader>tc', ':lua Toggle_completion()<CR>',
    {noremap = true, silent = true, desc = 'Toggle Completion'})
vim.api.nvim_set_keymap('n', '<leader>tr', ':set relativenumber!<CR>',
    {noremap = true, silent = true, desc = 'Toggle relative line numbers'})



-- Keymaps for minimap control
--vim.api.nvim_set_keymap('n', '<Leader>mm', ':lua require("codewindow").toggle_minimap()<CR>',
--    {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<Leader>mo', ':lua require("codewindow").open_minimap()<CR>',
--    {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<Leader>mc', ':lua require("codewindow").close_minimap()<CR>',
--    {noremap = true, silent = true})
