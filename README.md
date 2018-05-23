# autoformat-python

## Introduction

This is a plugin aimed to autoformat python statement. When you finish type a line and type \<Cr\> to start a new line, the previous line will be formatted automatically.

## Details

if you write python file like that:

```
a =1+2<cursor>
```
that looks ulgy, right? Don't worry. With the help of this plugin, you simply press return button in `insert mode` or `normal mode`, then the code will be formated automatically by autopep8 into this:

```
a = 1 + 2
<cursor>
```

## Installation

Use your plugin manager of choice.

- [Pathogen](https://github.com/tpope/vim-pathogen)
  - `git clone https://github.com/sillybun/autoformat-python ~/.vim/bundle/autoformat-python`
- [Vundle](https://github.com/gmarik/vundle)
  - Add `Bundle 'https://github.com/sillybun/autoformat-python'` to .vimrc
  - Run `:BundleInstall`
- [NeoBundle](https://github.com/Shougo/neobundle.vim)
  - Add `NeoBundle 'https://github.com/sillybun/autoformat-python'` to .vimrc
  - Run `:NeoBundleInstall`
- [vim-plug](https://github.com/junegunn/vim-plug)
  - Add `Plug 'https://github.com/sillybun/autoformat-python'` to .vimrc
  - Run `:PlugInstall`

## Setting

put `autocmd FileType python let g:autoformatpython_enabled = 1` in your vimrc.

Everytime you type enter, the previous line will be formatted automatically.
