-- init.lua

-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Set up transparency
vim.api.nvim_command('hi Normal guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi SignColumn guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi NormalNC guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi MsgArea guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi TelescopeBorder guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi NvimTreeNormal guibg=NONE ctermbg=NONE')

-- Mouse Support
vim.opt.mouse = 'a'

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "javascript", "typescript", "python" },
                highlight = {
                    enable = true,
                },
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
                }
            }
            -- Set the colorscheme
            vim.cmd.colorscheme("monokai")

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
    {
       'gorbit99/codewindow.nvim',
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            local codewindow = require('codewindow')
            codewindow.setup({
                active_in_terminals = false,
                max_minimap_height = 100,
                minimap_width = 20,
                use_treesitter = true,
                exclude_filetypes = {'help'},
                window_border = 'single',
                use_lsp = true,
                screen_bounds = 'lines',
                z_index = 1,
                window = {
                    scrollbar = true,
                    focusable = true,
                },
            })

            codewindow.apply_default_keybinds()
        end, 
    },
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
                fast_wrap = {
                    map = '<M-e>',  -- Alt+e to fast wrap the pair
                    chars = { '{', '[', '(', '"', "'" },
                    pattern = [=[[%'%"%>%]%)%}%,]]=],
                    end_key = '$',
                    keys = 'qwertyuiopzxcvbnmasdfghjkl',
                    check_comma = true,
                    highlight = 'Search',
                    highlight_grey='Comment'
                },
                -- Add spaces between parentheses
                enable_afterquote = true,  -- add bracket pairs after quote
                enable_moveright = true,   -- enable moving right when inserting pairs
            })

            -- Add specific rules
            local Rule = require('nvim-autopairs.rule')
            -- Add spaces between parentheses
            local brackets = { { '(', ')' }, { '[', ']' }, { '{', '}' } }
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
                    :with_pair(function(opts)
                        -- Add pair only in specific file types
                        return vim.tbl_contains({ 'html', 'xml', 'tsx', 'jsx', 'vue', 'svelte' }, vim.bo.filetype)
                    end)
            })
        end
    },
    -- Mason for LSP management
    {
        "williamboman/mason.nvim",
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
                    "lua_ls",          -- Lua
                    "pyright",         -- Python
                    "cssls",           -- CSS
                    "html",            -- HTML
                    "emmet_ls",        -- Emmet
                    "jsonls",          -- JSON
                },
                automatic_installation = true,
            })
        end
    },
    -- Add schemastore plugin
    ---- LSP config
    --{
    --    "neovim/nvim-lspconfig",
    --    dependencies = {
    --        "hrsh7th/cmp-nvim-lsp",
    --        "hrsh7th/nvim-cmp",
    --        "L3MON4D3/LuaSnip",
    --        "b0o/schemastore.nvim",  -- Add dependency here as well
    --    },
    --    config = function()
    --        local lspconfig = require('lspconfig')
    --        local capabilities = require('cmp_nvim_lsp').default_capabilities()

    --        -- Lua LSP configuration
    --        lspconfig.lua_ls.setup({
    --            capabilities = capabilities,
    --            settings = {
    --                Lua = {
    --                    diagnostics = {
    --                        globals = { 'vim' }
    --                    },
    --                    workspace = {
    --                        library = vim.api.nvim_get_runtime_file("", true),
    --                        checkThirdParty = false,
    --                    },
    --                    telemetry = {
    --                        enable = false,
    --                    },
    --                },
    --            },
    --        })

    --        -- Python LSP configuration
    --        lspconfig.pyright.setup({
    --            capabilities = capabilities,
    --            settings = {
    --                python = {
    --                    analysis = {
    --                        typeCheckingMode = "basic",
    --                        autoSearchPaths = true,
    --                        useLibraryCodeForTypes = true,
    --                    },
    --                },
    --            },
    --        })

    --        -- HTML LSP configuration
    --        lspconfig.html.setup({
    --            capabilities = capabilities,
    --            filetypes = { "html", "htmldjango" },
    --        })

    --        -- CSS LSP configuration
    --        lspconfig.cssls.setup({
    --            capabilities = capabilities,
    --        })

    --        -- JSON LSP configuration
    --        lspconfig.jsonls.setup({
    --            capabilities = capabilities,
    --            settings = {
    --                json = {
    --                    schemas = require('schemastore').json.schemas(),
    --                    validate = { enable = true },
    --                },
    --            },
    --        })

    --        -- Emmet LSP configuration
    --        lspconfig.emmet_ls.setup({
    --            capabilities = capabilities,
    --            filetypes = {
    --                'html', 'css', 'scss', 'javascript',
    --                'javascriptreact', 'typescriptreact',
    --                'svelte', 'vue', 'htmldjango'
    --            },
    --        })

    --        -- Global LSP keybindings
    --        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { noremap = true, silent = true })
    --        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { noremap = true, silent = true })
    --        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { noremap = true, silent = true })
    --        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { noremap = true, silent = true })
    --        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { noremap = true, silent = true })
    --        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { noremap = true, silent = true })
    --        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { noremap = true, silent = true })
    --        vim.keymap.set('n', 'gr', vim.lsp.buf.references, { noremap = true, silent = true })
    --        vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { noremap = true, silent = true })
    --    end
    --},
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/nvim-cmp",
            "L3MON4D3/LuaSnip",
            "b0o/schemastore.nvim",
        },
        config = function()
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- New function to set up LSP keymaps properly
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

            -- Common LSP setup function
            local function setup_lsp(server, config)
                config = config or {}
                config.capabilities = capabilities
                config.on_attach = function(client, bufnr)
                    setup_lsp_keymaps(client, bufnr)
                end
                lspconfig[server].setup(config)
            end

            -- Set up each LSP server with all your existing configurations
            setup_lsp('lua_ls', {
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
                filetypes = {
                    'html', 'css', 'scss', 'javascript',
                    'javascriptreact', 'typescriptreact',
                    'svelte', 'vue', 'htmldjango'
                },
            })
        end
    },
    -- Autocompletion setup
    {
        'hrsh7th/nvim-cmp',
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
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
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

-- Keymaps for minimap control
vim.api.nvim_set_keymap('n', '<Leader>mm', ':lua require("codewindow").toggle_minimap()<CR>', 
    {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>mo', ':lua require("codewindow").open_minimap()<CR>', 
    {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>mc', ':lua require("codewindow").close_minimap()<CR>', 
    {noremap = true, silent = true})

