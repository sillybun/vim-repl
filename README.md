# vim-repl

## Introduction

Open the interactive environment with the code you are writing.

Read–Eval–Print Loop (REPL), also known as an interactive toplevel or language shell, is extremely useful in python coding. However, it's difficult to interact with REPL when writing python with vim. Therefore, I write this plugin to provide a better repl environment for coding python or other file in vim. It use the terminal feature for vim8. So your vim version must be no less than 8.0 and support termianl function to use this plugin.

如果您想阅读中文文档，请移步：[知乎-vim-repl](https://zhuanlan.zhihu.com/p/37231865)

## Details

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/repl.gif)

Use vim to open a file, run `:REPLToggle` to open the REPL environment.

By default, Python and Perl are supported. If you run `:REPLToggle` in a `python` file, you will get `python` in the terminal buffer. In a `perl` file, vim-repl will try to use `perlconsole`, `reply` and `re.pl` (in that order); so one of them should be installed.
In order to support more languages, you will have to specify which program to run for each specific filetype.

There are three ways to send codes to REPL environment, the first way: stay in normal mode and press `<leader>w` and the whole line of the cursor will be sent to REPL.

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/usage-1.gif)

The second way is that in normal mode, move the cursor to the first line of one block (start of a function: `def functionname(argv):`, start of a for/while loop, start of a if-else statement) and press `<leader>w`, the whole block will be sent to REPL automatically.

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/usage2.gif)

The third way is to select some lines in visual mode and press `<leader>w`, the seleted code will be sent to REPL.

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/usage-3.gif)
If the REPL is already open. `:REPLToggle` will close REPL.

## Installation

This plugin support all platforms (Windows, MacOS, Linux). Use your plugin manager of choice.

For MacOS, Windows and Linux Users (vim should have `+terminal` support):

- [vim-plug](https://github.com/junegunn/vim-plug) (**recommended**)
  - Add `Plug 'sillybun/vim-repl'` to .vimrc
  - Run `:PlugInstall`

However, the following intalling setting use `vim-async` to provide more stable code sending performance (vim should have the `+terminal` and `+timers` support)

- [vim-plug](https://github.com/junegunn/vim-plug) (**recommended**)
  - Add `Plug 'sillybun/vim-repl'` to .vimrc
  - Add `Plug 'sillybun/vim-async'` to .vimrc
  - Run `:PlugInstall`


## Usage

### How to open REPL

```
:REPLToggle
```


### How to exit REPL

```
:REPLToggle
```

> If you bind `<lead>r` to `:REPLToggle` by `nnoremap <leader>r :REPLToggle`, you only need to press `<leader>r` to open or close REPL.

> leader key is set by `let g:mapleader=' '`

### How to send code to REPL

- In Normal Mode, press `<leader>w`, code in the current line (including leading space and the end center) will be transmitted to REPL
- In Normal Mode, move the cursor to the begin of a block and press `<leader>w` and the whole block will be sent to REPL
- In Visual Mode, press `<leader>w`, selected code (whole line includeing leading space and the last center) will be trasmitted to REPL

Currently, asynchronous transmission is completed and it is supported for all language if you correctly set the input symbols of the corresponding language.
Setting for python is already done by author. Supported command shell for python include `python`, `ipython` and `ptpython`.

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

### How to debug python script?

> Debug function need the support of vim-async and zytutil. Since I have to use a small program in C++ to delay some time, this function can only work on MacOS and Linux.

I suggest the following key binding:

```
autocmd Filetype python nnoremap <F12> <Esc>:REPLDebugStopAtCurrentLine<Cr>
autocmd Filetype python nnoremap <F10> <Esc>:REPLPDBN<Cr>
autocmd Filetype python nnoremap <F11> <Esc>:REPLPDBS<Cr>
```

To debug python code, move the cursor to certain line and press `<F12>`, and ipdb will be run and the program will be stopped at that line. Press `<F10>` will run a single line and Press `<F11>` will also run a single line but will jump into functions.

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/debug-python.gif)

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
			\	'python': 'python',
			\	'default': 'bash'
			\	}
```

> For those who use `ipython` as REPL program: Since ipython 7 and ipython 6 have a big difference, I have to treat them seperately and have to detect the version of ipython by `ipython --version` which will cause a obvious lagging. You have better to **specify version of ipython** by setting:

```
let g:repl_ipython_version = '6'
```

or

```
let g:repl_ipython_version = '7.7'
```

I have tested some version of ipython and find that this plugin cannot work on 7.0.1. Please use version >= 7.1.1

**repl_exit_command**

It controls the command to exit different repl program correctly. (Notice: exitcommand depends on repl program not filetype of the current file, so if you want to specify exit command for program like 'ipython', please add `"ipython": "quit()"` in the dictionary)

```
let g:repl_exit_commands = {
			\	'python': 'quit()',
			\	'bash': 'exit',
			\	'zsh': 'exit',
			\	'default': 'exit',
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

If `g:repl_cursor_down` is 1, once user sends code blocks using visual selection, the cursor will move to the next line of the last line of the code blocks.

```
let g:repl_python_automerge = 0
```

If `g:repl_python_automerge` is 1, once user sends code which is seperated into multilines, they are combined into one line automatically. For example, if the code is:

```
a = 1+\
    2+\
    3
```

, then `a = 1+2+3` will be sent to the repl environment instead of three lines.

```
let g:repl_console_name = 'ZYTREPL'
```
represents the name for repl console.

```
let g:repl_vimscript_engine = 0
```

If your vim doesn't support python or python3, I provides limited supported for it: it cannot work for `ipython` and `ptpython`, which means `g:repl_repl_program['python']='python'` is required.

Name of REPL environment.

# My Configuation for Vim-Repl

```
Plug 'sillybun/vim-repl'
let g:repl_program = {
            \   'python': 'ipython',
            \   'default': 'zsh',
            \   'r': 'R',
            \   'lua': 'lua',
            \   }
let g:repl_predefine_python = {
            \   'numpy': 'import numpy as np',
            \   'matplotlib': 'from matplotlib import pyplot as plt'
            \   }
let g:repl_auto_sends = ['class ', 'def ', 'for ', 'if ', 'while ']
let g:repl_cursor_down = 1
let g:repl_python_automerge = 1
let g:repl_ipython_version = '7'
nnoremap <leader>r :REPLToggle<Cr>
autocmd Filetype python nnoremap <F12> <Esc>:REPLDebugStopAtCurrentLine<Cr>
autocmd Filetype python nnoremap <F10> <Esc>:REPLPDBN<Cr>
autocmd Filetype python nnoremap <F11> <Esc>:REPLPDBS<Cr>
let g:repl_position = 3
```

# Updates:

## 2019.8.9

- Add limited support for vim without python or python3 support.
- Rewrite `vim-async` using `timer_start`

## 2019.8.7

- Fix bug for windows
- `g:repl_cursor_down` will also affect SendCurrentLine

## 2019.8.6

- Add support for ipython version >= 7

## 2019.8.3

- Rewrite the program to format python codes using python language
- Abandon using C++ to handle python code
- `g:repl_python_automerge` is provided.
- `g:repl_console_name` is provided
- Support both `python` and `python3`
- Remove Checkpoint function

## 2019.5.28

- Support REPL environment for Windows.

## 2019.5.14

- `g:repl_cursor_down` is provided.

## 2019.4.27

- Async feature is provided by [vim-async](https://github.com/sillybun/vim-async)

## 2018.7.7

- Use job feature in vim 8.0 to provide better performance.

## 2018.7.26

- Add support for temporary hide the terminal window.
If the REPL is already open. `:REPLToggle` will close REPL.
