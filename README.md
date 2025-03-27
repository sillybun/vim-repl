# vim-repl

* [vim-repl](#vim-repl)
   * [Introduction](#introduction)
   * [Details](#details)
   * [Installation](#installation)
   * [Usage](#usage)
      * [How to open REPL](#how-to-open-repl)
      * [How to exit REPL](#how-to-exit-repl)
      * [How to send code to REPL](#how-to-send-code-to-repl)
      * [How to switch to REPL environment](#how-to-switch-to-repl-environment)
      * [How to hide the REPL environment](#how-to-hide-the-repl-environment)
      * [How to debug python script?](#how-to-debug-python-script)
      * [How to open python with virtual environment?](#how-to-open-python-with-virtual-environment)
      * [How to send python code block seperated by # %% or other tag](#how-to-send-python-code-block-seperated-by---or-other-tag)
      * [How to just send right hand side of current line to REPL environment?](#how-to-just-send-right-hand-side-of-current-line-to-repl-environment)
   * [Setting](#setting)
   * [My Configuration for Vim-Repl](#my-configuration-for-vim-repl)
   * [Updates](#updates)
      * [2021.3.23](#2021323)
      * [2020.10.22](#20201022)
      * [2020.4.29](#2020429)
      * [2019.10.14](#20191014)
      * [2019.8.27](#2019827)
      * [2019.8.16](#2019816)
      * [2019.8.11](#2019811)
      * [2019.8.10](#2019810)
      * [2019.8.9](#201989)
      * [2019.8.7](#201987)
      * [2019.8.6](#201986)
      * [2019.8.3](#201983)
      * [2019.5.28](#2019528)
      * [2019.5.14](#2019514)
      * [2019.4.27](#2019427)
      * [2018.7.7](#201877)
      * [2018.7.26](#2018726)
   * [Troubleshooting](#troubleshooting)

## Introduction

Open the interactive environment with the code you are writing.

Read–Eval–Print Loop (REPL), also known as an interactive toplevel or language shell, is extremely useful in python coding. However, it's difficult to interact with REPL when writing python with vim. Therefore, I write this plugin to provide a better repl environment for coding python or other file in vim. It use the terminal feature for vim8. So your vim version must be no less than 8.0 and support termianl function to use this plugin.


如果您想阅读中文文档，请移步：[知乎-vim-repl](https://zhuanlan.zhihu.com/p/37231865)


## Details

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/repl.gif)

Use vim to open a file, run `:REPLToggle` to open the REPL environment. If the REPL is already open. `:REPLToggle` will close REPL.

By default, Python Perl and Vimscript are supported. If you run `:REPLToggle` in a `python` file, you will get `python` in the terminal buffer. In a `perl` file, vim-repl will try to use `perlconsole`, `reply` and `re.pl` (in that order); so one of them should be installed. In a `vim` file, `vim-repl` will try to open `vim -e`.
In order to support more languages, you will have to specify which program to run for each specific filetype.

There are three ways to send codes to REPL environment:

- the first way: stay in normal mode and press `<leader>w` and the whole line of the cursor will be sent to REPL.

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/usage-1.gif)

- The second way is that in normal mode, move the cursor to the first line of one block (start of a function: `def functionname(argv):`, start of a for/while loop, start of a if-else statement) and press `<leader>w`, the whole block will be sent to REPL automatically.

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/usage2.gif)

- The third way is to select some lines in visual mode and press `<leader>w`, the seleted code will be sent to REPL.

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/usage-3.gif)

- The last way is to select some word in visual mode and press `<leader>w` and the selected word will be sent to REPL.

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/usage4.gif)

Note: currently this plugin doesn't support NeoVim.

## Installation

This plugin support all platforms (Windows, MacOS, Linux). Use your plugin manager of choice.

For MacOS, Windows and Linux Users (vim should have `+terminal` and `+timers` support):

- [vim-plug](https://github.com/junegunn/vim-plug) (**recommended**)
  - Add `Plug 'sillybun/vim-repl'` to .vimrc
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
- In Normal Mode, move the cursor to the begin of a block and press `<leader>w` and the whole block will be sent to REPL (By default, code block start with `def`, `class`, `while`, `for`, `if` will be automatically sent. You can control the definition of start of code block by setting `g:repl_auto_sends`)
- In Visual Mode, press `<leader>w`, selected code (whole line includeing leading space and the last center) will be trasmitted to REPL
- In Visual Mode, selected a word and press `<leader>w`, and the selected word will be sent to REPL according to certain rules defined by `g:repl_sendvariable_template`.

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


### How to switch to REPL environment

You can switch buffer between file and REPL environment the same as change between two vim buffer. press `<C-W><C-w>` will change between file and REPL environment. `<C-w><C-h,j,k,l>` also work the way it should be

### How to hide the REPL environment

```
:REPLHide
```

use `REPLUnhide` or `REPLToggle` to reveal the hidden terminal.

### How to debug python script?

Note: You should have to install `ipdb` to debug python script! check it via:

```
python -m ipdb
```

if not installed, install it via:

```
python -m pip install ipdb
```

The default debugger is `python3 -m pip`, you can specify it through adding `'python-debug' : '<debugger program, such as ipdb3>'` to `g:repl_program`

I suggest the following key binding:

```
autocmd Filetype python nnoremap <F12> <Esc>:REPLDebugStopAtCurrentLine<Cr>
autocmd Filetype python nnoremap <F10> <Esc>:REPLPDBN<Cr>
autocmd Filetype python nnoremap <F11> <Esc>:REPLPDBS<Cr>
```

To debug python code, (don't open python REPL environment via `:REPLToggle`), move the cursor to certain line and press `<F12>`, and ipdb will be run and the program will be stopped at that line. Press `<F10>` will run a single line and Press `<F11>` will also run a single line but will jump into functions.

![usage](https://github.com/sillybun/vim-repl/blob/master/assets/debug-python.gif)

### How to open python with virtual environment?

There are two ways to open python with virtual environment.

The first method (global) is that put:
```
g:repl_python_pre_launch_command = 'source /path_to_new_venv/bin/activate'
```
in `.vimrc`. And once you toggle python, the following command will be run:
```
:terminal [g:repl_program['default'][0]/bash/cmd.exe]
source /path_to_new_venv/bin/activate
python/ipython/ptpython
```

The second method (specific virtual environment) is that put:
```
#REPLENV: /path_to_new_venv/bin/activate
```
in python script. If you open this python file with vim and toggle vim-repl, python will be run in specific virtual environment.

### How to send python code block seperated by # %% or other tag

If you have the following code seperated into two blocks:

```
# %%
print(1)
print(2)

# %%
print(3)
print(5)
```

Just move cursor to some code block and use command `:REPLSendSession`, whole block will be sent to the REPL environment (e.g. Both `print(1)` and `print(2)`)

Code block seperator are defined by

```
let g:repl_code_block_fences = {'python': '# %%', 'zsh': '# %%', 'markdown': '```'}
```

and `g:repl_code_block_fences_end` (by default the latter is the same as the former). So if you want to seperate code block by `###`, just put:

```
let g:repl_code_block_fences = {'python': '###', 'zsh': '# %%', 'markdown': '```'}
```

to `.vimrc`

If you want to start code block with `### Start` and end it with `### End`, just put:

```
let g:repl_code_block_fences = {'python': '### Start', 'zsh': '# %%', 'markdown': '```'}
let g:repl_code_block_fences_end = {'python': '### End', 'zsh': '# %%', 'markdown': '```'}
```

to `.vimrc`

### How to just send right hand side of current line to REPL environment?

If your cursor is on line, for example:

```
return [x for x in range(10)]
```

and you only want to send `[x for x in range(10)]` to REPL environment and to check result of it, You can use command `:REPLSendRHSofCurrentLine<Cr>`.

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
			\	'python': ['python'],
			\	'default': ['bash']
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
let g:repl_auto_sends = ['class ', 'def ', 'for ', 'if ', 'while ', 'with ', 'async def', '@', 'try']
```

If `g:repl_auto_sends` is defined, once user sends a line starts with any pattern contained in the list, whole block will be send automatically.

```
let g:repl_python_auto_send_unfinish_line = 1
```

If `g:repl_python_auto_send_unfinish_line` is set to 1, once user sends a line that is not finished yet, complete line will be send automatically. For example, for codes:

```
f(1,
        2)
```

press `<leader>w` in the first line, `f(1,2)` will be sent automatically.

```
let g:repl_cursor_down = 1
```

If `g:repl_cursor_down` is 1, once user sends code blocks using visual selection, the cursor will move to the next line of the last line of the code blocks.

```
let g:repl_python_auto_import = 1
```

If `g:repl_python_auto_import` is 1, once user toggle python REPL environment, all import code will be automatically send to the REPL environment

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

If your vim doesn't support python or python3, I provides limited supported for it:
- It works for `python` and `ipython`
- It also works for `ptpython` but every line of the codes to be send should be complete, which means if you seperate a line of code into two or more lines, the plugin will not handle it correctly.

```
let g:repl_sendvariable_template = {
            \ 'python': 'print(<input>)',
            \ 'ipython': 'print(<input>)',
            \ 'ptpython': 'print(<input>)',
            \ }
```

`g:repl_sendvariable_template` defines how word is sent to REPL. For example, by default, if you select `some_variable` and presss `<leader>w`, `print(some_variable)` will be sent to REPL. You can define your rule with the help of `g:repl_sendvariable_template`. `<input>` will be replaced by selected word and then be sent to REPL.

```
let g:repl_unhide_when_send_lines = 0
```

If `g:repl_unhide_when_send_lines = 1`, when REPL is hidden and you want to send lines, REPL environment will be unhiden before the code is sent.

```
g:repl_output_copy_to_register
```

If `g:repl_output_copy_to_register` is set to a letter (a-z), then output of REPL program will be copied to the corresponding register. (Currently only support ipython)

## My Configuration for Vim-Repl

```
Plug 'sillybun/vim-repl'
let g:repl_program = {
            \   'python': 'ipython',
            \   'default': 'zsh',
            \   'r': 'R',
            \   'lua': 'lua',
            \   'vim': 'vim -e',
            \   }
let g:repl_predefine_python = {
            \   'numpy': 'import numpy as np',
            \   'matplotlib': 'from matplotlib import pyplot as plt'
            \   }
let g:repl_cursor_down = 1
let g:repl_python_automerge = 1
let g:repl_ipython_version = '7'
let g:repl_output_copy_to_register = "t"
nnoremap <leader>r :REPLToggle<Cr>
nnoremap <leader>e :REPLSendSession<Cr>
autocmd Filetype python nnoremap <F12> <Esc>:REPLDebugStopAtCurrentLine<Cr>
autocmd Filetype python nnoremap <F10> <Esc>:REPLPDBN<Cr>
autocmd Filetype python nnoremap <F11> <Esc>:REPLPDBS<Cr>
let g:repl_position = 3
```

## Updates

### 2021.3.23

- Add support for auto send uncompleted line
- Fix the bug that continuously send lines to REPL will cause former codes missing.

### 2020.10.22

- Add support for auto import package for python file
- Add support for import from relative path. For example, if in package 'python_package', there are two file 'a.py' and 'b.py' and a `__init__.py`. If you import 'B.py' in 'A.py' through `import .B`. Then if you edit `A.py` using vim and run `vim-repl`. `import .B` will be automatically transformed into `import python_package.B` and be sent to REPL environment.

### 2020.4.29

- Add support for mulitiple repl program. Thanks to @roachsinai 's great work.

### 2019.10.14

- Add support for python virtual environment.

### 2019.8.27

- Set the default program in Windows to `cmd.exe`

### 2019.8.16

- Add support for vimscript REPL.

### 2019.8.11

- Add send selected word function and `g:repl_sendvariable_template`.

### 2019.8.10

- `vim-repl` no longer need the support of `vim-async` anymore.

### 2019.8.9

- Add almost full support for vim without `+python` or `+python3` support.
- Rewrite `vim-async` using `timer_start`
- Set the default value of `g:repl_auto_sends` to `['class ', 'def ', 'for ', 'if ', 'while ']`
- Set the default value of `g:repl_cursor_down` to 1

### 2019.8.7

- Fix bug for windows
- `g:repl_cursor_down` will also affect SendCurrentLine

### 2019.8.6

- Add support for ipython version >= 7

### 2019.8.3

- Rewrite the program to format python codes using python language
- Abandon using C++ to handle python code
- `g:repl_python_automerge` is provided.
- `g:repl_console_name` is provided
- Support both `python` and `python3`
- Remove Checkpoint function

### 2019.5.28

- Support REPL environment for Windows.

### 2019.5.14

- `g:repl_cursor_down` is provided.

### 2019.4.27

- Async feature is provided by [vim-async](https://github.com/sillybun/vim-async)

### 2018.7.7

- Use job feature in vim 8.0 to provide better performance.

### 2018.7.26

- Add support for temporary hide the terminal window.
If the REPL is already open. `:REPLToggle` will close REPL.

## Troubleshooting

- The python code cannot send porperly to REPL environment

This trouble cann only happen for vim without `+python` or `+python3` support. Without python engine, vim-repl can only use vimscript to manipulate code to be sent, and it now cannot handle code seperated into multilines. For example, the following code cannot be sent porperly.

```
some_dict = {1:1,
        2:2,
        3:3}
print(some_dict)
```

You should combine mulitlines code into one line to make the plugin work porperly as following:
```
some_dict = {1:1, 2:2, 3:3}
print(some_dict)
```

For vim with `+python` or `+python3` support, this problem will not happen. If it happens, check whether `g:repl_vimscript_engine` is set to `0`. If `g:repl_vimscript_engine = 0`, there is a bug here. Please report the bug; If `g:repl_vimscript_engine=1`, search `let g:repl_vimscript_engine = 1` in vimrc and remove it.

- `<space>r` doesn't work for my vim

`<space>` in the example mean the leader key. Check the your leader key mapping in vimrc. To set leader key to `<space>`, add `let g:mapleader=' '`

- Error detected while processing function repl#REPLToggle [10].. repl #REPLOpen

The reason of this error is that vim-repl try to open the program which is not installed on your machine. For example, if you havn't install `ipython` and set `g:repl_program['python']=['ipython']`, this error will occur.

- How to change to Normal Mode in REPL environment?

In REPL environment, press `<C-W>N`. Or you can use the setting:

```
tnoremap <C-n> <C-w>N
tnoremap <ScrollWheelUp> <C-w>Nk
tnoremap <ScrollWheelDown> <C-w>Nj
```

And then you can press `<C-n>` to change to Normal Mode.

-----

If you like my plugin, please give me a star!

