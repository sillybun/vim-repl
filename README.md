# vim-repl

## Introduction

Open the interactive environment with the code you are writing.

Read–Eval–Print Loop (REPL), also known as an interactive toplevel or language shell, is extremely useful in python coding. However, it's difficult to interact with REPL when writing python with vim. Therefore, I write this plugin to provide a better repl environment for coding python or other file in vim. It use the terminal feature for vim8. So your vim version must be no less than 8.0 and support termianl function to use this plugin.

如果您想阅读中文文档，请移步：[知乎-vim-repl](https://zhuanlan.zhihu.com/p/37231865)

## Details

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/repl.gif)

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/bigarray_new.gif)

Use vim to open a file, run `:REPLToggle` to open the REPL environment.

In order to support various types of file, you have to specify which program to run for certain filetype. The default only support python file, onde you run `:REPLToggle`, `python` will running in the termianl buffer.

To communicate with REPL environment, select your code, press `<leader>w`. And the code will be send to REPL and run automatically.
Or you can just stay in normal mode and press `<leader>w` and the code in the current line will be send REPL.

If the REPL is already open. `:REPLToggle` will close REPL.

## Installation

Use your plugin manager of choice.

- [vim-plug](https://github.com/junegunn/vim-plug) (**recommended**)
  - Add `Plug 'sillybun/vim-repl', {'do': './install.sh'}` to .vimrc
  - Add `Plug 'sillybun/vim-async', {'do': './install.sh'}` to .vimrc
  - Add `Plug 'sillybun/zytutil'` to .vimrc
  - Run `:PlugInstall`

- [Vundle](https://github.com/gmarik/vundle)
  - Add `Bundle 'https://github.com/sillybun/vim-repl'` to .vimrc
  - Add `Bundle 'sillybun/vim-async'` to .vimrc
  - Add `Bundle 'sillybun/zytutil'` to .vimrc
  - Run `:BundleInstall`
  - And change to the plugin directory of vim-repl and run in shell `./install.sh`
  - And change to the plugin directory of vim-async and run in shell `./install.sh`


## Usage

### How to open REPL

```
:REPLToggle
```

### How to exit REPL

```
:REPLToggle
```

### How to send code to REPL

- In Normal Mode, press `<leader>w`, code in the current line (including leading space and the end center) will be transmitted to REPL
- In Visual Mode, press `<leader>w`, selected code (whole line includeing leading space and the last center) will be trasmitted to REPL

Currently, asynchronous transmission is completed and it is supported for all language if you correctly set the input symbols of the corresponding language.
Setting for python is already done by author.

Take a typical python REPL environment as an example

```
>>> 1+1
2
>>> for i in range(3):
...     print(i)
...
>>>
```

Therefore, the input symbols for python includes `'>>>'` and `'...'`. They tell the plugin that it can continue send another line to the REPL environment if the current line of the REPL environment is either `'>>>'` or `'...'`. If you want async support for other language aside from python, you have to add entry for this language to `g:repl_input_symbols`

The default value of `g:repl_input_symbols` is, the value of the dictionary can be either a list of string or a string:

```
let g:repl_input_symbols = {
            \   'python': ['>>>', '>>>>', 'ipdb>', 'pdb', '...'],
            \   }
```


### How to change to REPL environment

You can change buffer between file and REPL environment the same as change between two vim buffer. press `<C-W><C-w>` will change between file and REPL environment. `<C-w><C-h,j,k,l>` also work the way it should be

### How to hide the REPL environment

```
:REPLHide
```

use `REPLUnhide` or `REPLToggle` to reveal the hidden terminal.

## Setting

you can bind the `REPLToggle` command to a certain key to make it more convenience.

```
nnoremap <leader>r :REPLToggle<Cr>
```

**g:repl_width**

it represents the width of REPL windows. there is no default value.

**g:sendtorepl_invoke_key**

you can customize the key to send code to REPL environment. The default key is `<leader>w`

```
let g:sendtorepl_invoke_key = "<leader>w"
```

**repl_position**
it controls the location where REPL windows will appear
- 0 represents bottom
- 1 represents top
- 2 represents left
- 3 represents right

```
let g:repl_position = 0
```

**repl_stayatrepl_when_open**

it controls whether the cursor will return to the current buffer or just stay at the REPL environment when open REPL environment using `REPLToggle` command

0 represents return back to current file.

1 represents stay in REPL environment.

```
let g:repl_stayatrepl_when_open = 0
```

**repl_program**

It controls which program will be run for certain filetype. If there is no entry in the dictionary, the program specified by "default" will be run. If there is no "default" entry, "bash" will be the choice.

```
let g:repl_program = {
			\	"python": "python",
			\	"default": "bash"
			\	}
```

**repl_exit_command**

It controls the command to exit different repl program correctly. (Notice: exitcommand depends on repl program not filetype of the current file, so if you want to specify exit command for program like 'ipython', please add `"ipython": "quit()"` in the dictionary)

```
let g:repl_exit_commands = {
			\	"python": "quit()",
			\	"bash": "exit",
			\	"zsh": "exit",
			\	"default": "exit",
			\	}
```

Once user run `:REPLToggle` when the REPL environment is already open, this plugin will try to close the repl environment by the following step:

- send a interupt signal `<C-C>` to the program
- if the program is not close, then send two `\n` and the `exit_command + \n` to the program.

```
let g:repl_auto_sends = ['def ', 'class ']
```

If `g:repl_auto_sends` is defined, once user sends a line starts with any pattern contained in the list, whole block will be send automatically.

```
let g:repl_cursor_down = 0
```

If `g:repl_cursor_down` is 1, once user send code blocks using visual selection, the cursor will move to the next line of the last line of the code blocks.

# My Configuation for Vim-Repl

```
Plug 'sillybun/vim-repl', {'do': './install.sh'}
let g:repl_program = {
            \   'python': 'ipython',
            \   'default': 'zsh',
            \   'r': 'R',
            \   }
let g:repl_predefine_python = {
            \   'numpy': 'import numpy as np',
            \   'matplotlib': 'from matplotlib import pyplot as plt'
            \   }
let g:repl_checkpoint_position = '~/.temp/'
let g:repl_auto_sends = ['class ', 'def ']
let g:repl_cursor_down = 1
nnoremap <leader>r :REPLToggle<Cr>
autocmd Filetype python nnoremap <F12> <Esc>:REPLDebugStopAtCurrentLine<Cr>
autocmd Filetype python nnoremap <F10> <Esc>:REPLPDBN<Cr>
autocmd Filetype python nnoremap <F11> <Esc>:REPLPDBS<Cr>
let g:repl_checkpoint_notation = "CP"
let g:repl_position = 3
```

# Updates:

## 2019.5.14

- `g:repl_cursor_down` is provided.

## 2019.4.27

- Async feature is provided by [vim-async](https://github.com/sillybun/vim-async)

## 2018.7.7

- Use job feature in vim 8.0 to provide better performance.

## 2018.7.26

- Add support for temporary hide the terminal window.
