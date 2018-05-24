# vim-repl

## Introduction

Open the interactive environment with the code you are writing.

Read–Eval–Print Loop (REPL), also known as an interactive toplevel or language shell, is extremely useful in python coding. However, it's difficult to interact with REPL when writing python with vim. Therefore, I write this plugin to provide a better repl environment for python in vim. It use the terminal feature for vim8. So your vim version must be no less than 8.0 and support termianl function to use this plugin.

## Details

![usage](https://github.com/sillybun/vim-repl/blob/master/repl.gif)

use vim to open a python file, run `:REPLToggle` to open the REPL environment.

To communicate with REPL environment, select your code, press `ww`. And the code will be send to REPL and run automatically.
Or you can just stay in normal mode and press `ww` and the code in the current line will be send REPL.

If the REPL is already open. `:REPLToggle` will close REPL.

## Installation

Use your plugin manager of choice.

- [Pathogen](https://github.com/tpope/vim-pathogen)
  - `git clone https://github.com/sillybun/vim-repl ~/.vim/bundle/vim-repl`
- [Vundle](https://github.com/gmarik/vundle)
  - Add `Bundle 'sillybun/vim-repl/'` to .vimrc
  - Run `:BundleInstall`
- [NeoBundle](https://github.com/Shougo/neobundle.vim)
  - Add `NeoBundle 'sillybun/vim-repl/'` to .vimrc
  - Run `:NeoBundleInstall`
- [vim-plug](https://github.com/junegunn/vim-plug)
  - Add `Plug 'sillybun/vim-repl/'` to .vimrc
  - Run `:PlugInstall`

## Setting

you can bind the `REPLToggle` command to a certain key to make it more convince.

```
autocmd Filetype python nnoremap <leader>r :REPLToggle<Cr>
```

**g:repl_row_width**

it represents the height of repl windows. default value is 10.
```
let g:repl_row_width = 10
```

**g:sendtorepl_invoke_key**

you can customize the key to send code to REPL environment.

```
let g:sendtorepl_invoke_key = "ww" 
```

**repl_at_top**
it controls the location where REPL windows will appear, 0 represents at bottom, 1 represents at top.

```
let g:repl_at_top = 0
```
**repl_stayatrepl_when_open**

it controls whether the cursor will return to the current buffer or just stay at the REPL environment when open REPL environment using `REPLToggle` command

0 represents return back to current file.

1 represents stay in REPL environment.

```
let g:repl_stayatrepl_when_open = 0
```
