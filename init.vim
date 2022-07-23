" Basic configs
" set number
set relativenumber
set mouse=a  " enable mouse
" set nowrap
set incsearch
set encoding=utf-8
set noswapfile
set scrolloff=8
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
" set autoindent
set fileformat=unix
" set clipboard=unnamedplus
set clipboard=unnamedplus,unnamed
set splitbelow " new horizontal splits are on the bottom
set splitright " new vertical splits are on the right
filetype indent on " load filetype-specific indent files
let mapleader = " "
syntax on
set ignorecase
set smartcase

au BufNewFile,BufRead *.py,*.json set colorcolumn=79
au BufNewFile,BufRead *.js, *.html, *.css, *.yaml
    \ set tabstop=2
    \ softtabstop=2
    \ shiftwidth=2
    \ expandtab

" run current script with python3 by CTRL+R in command and insert mode
autocmd FileType python map <buffer> <F5> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F5> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>

" Удаление пробелов в конце строк при сохранении
autocmd BufWritePre * :%s/\s\+$//e
au BufRead /tmp/psql.edit.* set syntax=sql

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
Plug 'williamboman/nvim-lsp-installer'
Plug 'preservim/nerdtree'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'tyru/caw.vim' " For comments
Plug 'lewis6991/gitsigns.nvim' " For git
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tomasiser/vim-code-dark' " Color schema
Plug 'vim-airline/vim-airline' " Statusline
Plug 'nvie/vim-flake8' " Python style check
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " расширенная подсветка синтаксиса
call plug#end()

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_section_z = airline#section#create('%3p%% %#__accent_bold#%4l%#__restore__#%#__accent_bold#/%L%#__restore__# %3v')

" Vim-flake8
let g:flake8_show_in_file = 1 " To customize whether the show marks in the file
let g:flake8_show_in_gutter = 1 " To customize whether the show signs in the gutter
let g:flake8_show_quickfix = 0 " To customize whether the quickfix window opens
" autocmd InsertLeave,BufNewFile,BufRead,BufWritePost *.py call flake8#Flake8()
autocmd BufWritePost *.py call flake8#Flake8() " Run the Flake8 check every time you write a Python file

" Theme
if (has("termguicolors"))
  set termguicolors
endif
set noshowmode
set cursorline
set list listchars=tab:▸\ ,trail:·,nbsp:%,extends:❯,precedes:❮
" set lcs+=space:·  " Настройка отображения невидимых символов
set list  " Вкл. отображение невидимых символов
let g:codedark_italics = 1 " Enable italic comment
colorscheme codedark

" turn off search highlight
nnoremap ,<space> :nohlsearch<CR>

" Settings NerdTree Plugin
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Settings buffers keys
map gn :bn<cr>
map gp :bp<cr>
map gw :bw<cr>

" Window navigation
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

" Fuzzy search files with fzf
map <Leader>ff :Files<CR>
map <Leader>fb :BLines<CR>
map <Leader>fa :Rg<CR>
let g:fzf_layout = { 'down': '40%' }


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
      -- behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

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
  --vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
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
  vim.keymap.set('n', '<space>i', function()
    vim.lsp.buf.execute_command(
      {command='pyright.organizeimports', arguments={vim.uri_from_bufnr(0)}}
  )
  end, bufopts)
end

require("nvim-lsp-installer").setup {}
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'pyright' }
for _, lsp in pairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    }
  }
end

require('gitsigns').setup()
require('nvim-treesitter.configs').setup {
  ensure_installed = {"python"},
  highlight = {
    enable = true,
  },
}
EOF
