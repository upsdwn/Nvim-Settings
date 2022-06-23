set mouse=a  " enable mouse
set encoding=utf-8
" set number
set rnu
set noswapfile
set scrolloff=5

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set fileformat=unix
filetype indent on      " load filetype-specific indent files

set clipboard=unnamedplus
" Show whitespaces
" set list listchars=tab:→\ ,nbsp:␣,trail:·,space:·,extends:⟩,precedes:⟨

set cursorline
set lcs+=space:·  " Настройка отображения невидимых символов
set list  " Вкл. отображение невидимых символов
set splitbelow " new horizontal splits are on the bottom
set splitright " new vertical splits are on the right

au BufNewFile,BufRead *.py,*.json set colorcolumn=79
au BufNewFile,BufRead *.js, *.html, *.css, *.yaml
    \ set tabstop=2
    \ softtabstop=2
    \ shiftwidth=2
    \ expandtab

call plug#begin('~/.vim/plugged')
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
Plug 'preservim/nerdtree'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'tyru/caw.vim' " For comments
Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
Plug 'Mofiqul/vscode.nvim' " color schema
" Using vim-plug
call plug#end()

" For dark theme (neovim's default)
set background=dark
" Enable transparent background
" let g:vscode_transparency = 1
" Enable italic comment
let g:vscode_italic_comment = 1
" Disable nvim-tree background color
let g:vscode_disable_nvimtree_bg = v:true
colorscheme vscode

" turn off search highlight
nnoremap ,<space> :nohlsearch<CR>
" Settings NerdTree Plugin
"nnoremap <leader>n :NERDTreeFocus<CR>
"nnoremap <silent> <special> <C-t> :NERDTreeToggle <Bar> if &filetype ==# 'nerdtree' <Bar> wincmd p <Bar> endif<CR>
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
" Settings buffers keys
map gn :bn<cr>
map gp :bp<cr>
map gw :bw<cr>
" bind ctrl move keys in insert mode
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

set termguicolors
lua << EOF
require("bufferline").setup{
    options = {
        diagnostics = "nvim_lsp",
        show_buffer_icons = true,
        show_buffer_close_icons = false,
        show_buffer_default_icon = true, -- whether or not an unrecognised filetype should show a default icon
        show_close_icon = true,
        show_tab_indicators = true
    }
}
EOF

lua << EOF
-- luasnip setup
local luasnip = require 'luasnip'
-- nvim-cmp setup
local cmp = require 'cmp'

cmp.setup {
  completion = {
    completeopt = 'menu'
  },
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body)
    end
  },
  window = {
--    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = {
    ['<S-Tab>'] = cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Select}),
    ['<Tab>'] = cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Select}),
    ['<C-d>'] = cmp.mapping.scroll_docs(-1),
    ['<C-f>'] = cmp.mapping.scroll_docs(1),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}
EOF

lua << EOF
local nvim_lsp = require('lspconfig')
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
 -- vim.keymap.set('n', '<space>f', vim.lsp.buf.format, bufopts)
  --[[vim.keymap.set('n', '<space>i', function()
    vim.lsp.buf.execute_command(
      {command='pyright.organizeimports', arguments={vim.uri_from_bufnr(0)}}
  ) 
  end, bufopts)]]

  vim.keymap.set('n', '<space>i', function()
    vim.lsp.buf.execute_command(
      {command='!isort % <cr>', arguments={vim.uri_from_bufnr(0)}}
  ) 
  end, bufopts)
--  vim.keymap.set('n', '<space>i', 'silent !isort % <cr>', bufopts)
end



-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'pylsp' }
for _, lsp in pairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    }
  }
end
--[[
local function organize_imports()
  local params = {
    command = 'pyright.organizeimports',
    arguments = { vim.uri_from_bufnr(0) },
  }
  vim.lsp.buf.execute_command(params)
end

nvim_lsp.pyright.setup{
  commands = {
    PyrightOrganizeImports = {
      organize_imports,
      description = 'Organize Imports',
    },
  },
}]]
EOF

" run current script with python3 by CTRL+R in command and insert mode
autocmd FileType python map <buffer> <F5> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F5> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>
