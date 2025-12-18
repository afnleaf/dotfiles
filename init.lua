-- init.lua

-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.shada = ''
vim.opt.colorcolumn = "80"

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
                ensure_installed = {
                    "lua",
                    "javascript",
                    "typescript",
                    "python"
                },
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
--    -- Solarized theme
--    {
--        'maxmx03/solarized.nvim',
--        priority = 1000, -- Make sure to load this before other plugins
--        opts = {
--            -- Configure transparency
--            transparent = {
--                enabled = true,   -- Master switch for transparency
--                normal = true,    -- Main editor background
--                normalfloat = true, -- Floating windows
--                telescope = true,
--                nvimtree = true,
--                -- You can add more components here if you like
--            },
--            -- You can optionally configure styles here
--            styles = {
--                comments = { italic = true },
--                keywords = { italic = true },
--                functions = { bold = true },
--                strings = { italic = true },
--            },
--        },
--        config = function(_, opts)
--            -- CRITICAL: Set the background to 'light' for Solarized Light
--            vim.o.background = 'light'
--
--            -- Enable true color support
--            vim.o.termguicolors = true
--
--            -- Load the colorscheme
--            require('solarized').setup(opts)
--            vim.cmd.colorscheme 'solarized'
--
--            -- Your custom highlight for Visual mode (optional, you can remove this)
--            vim.api.nvim_set_hl(0, 'Visual', { bg = "#93a1a1" })
--
--            -- You may not need these force-transparency lines anymore,
--            -- as the theme's `transparent = true` option should handle it.
--            -- You can try commenting them out to see if it still works.
--            -- vim.api.nvim_command('hi Normal guibg=NONE ctermbg=NONE')
--            -- vim.api.nvim_command('hi LineNr guibg=NONE ctermbg=NONE')
--            -- ... etc
--        end,
--    },
    -- Monokai theme
    {
        "tanvirtin/monokai.nvim",
        -- Load colorscheme before other plugins
        priority = 1000,
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
    -- Auto-pairs
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = function()
            local npairs = require('nvim-autopairs')
            npairs.setup({
                -- Use treesitter to check for pairs
                check_ts = true,
                -- Don't add pairs if it already has
                -- a close pair in the same line
                enable_check_bracket_line = true,
                -- Don't add pairs if the next char is alphanumeric
                ignored_next_char = "[%w%.]",
                -- Add spaces between parentheses
                -- add bracket pairs after quote
                enable_afterquote = true,
                -- enable moving right when inserting pairs
                enable_moveright = true,
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
                        return vim.tbl_contains({
                            'html',
                            'xml',
                            'tsx',
                            'jsx',
                            'vue',
                            'svelte',
                            'rust'
                        }, vim.bo.filetype)
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
    -- Autocompletion setup
    {
        'hrsh7th/nvim-cmp',
        event = { "InsertEnter", "CmdlineEnter"},
        dependencies = {
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            --'hrsh7th/cmp-path',
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
                    --{ name = 'path' },
                }),
            })
        end
    },
})

-- Keymaps
vim.api.nvim_set_keymap('n', '<leader>tc', ':lua Toggle_completion()<CR>',
    {noremap = true, silent = true, desc = 'Toggle Completion'})
vim.api.nvim_set_keymap('n', '<leader>tr', ':set relativenumber!<CR>',
    {noremap = true, silent = true, desc = 'Toggle relative line numbers'})

