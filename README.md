# vim-repl

## Introduction

Open the interactive environment with the code you are writing.

Read–Eval–Print Loop (REPL), also known as an interactive toplevel or language shell, is extremely useful in python coding. However, it's difficult to interact with REPL when writing python with vim. Therefore, I write this plugin to provide a better repl environment for coding python or other file in vim. It use the terminal feature for vim8. So your vim version must be no less than 8.0 and support termianl function to use this plugin.

## Details

![usage](https://github.com/sillybun/vim-repl/blob/master/repl.gif)

Use vim to open a file, run `:REPLToggle` to open the REPL environment.

In order to support various types of file, you have to specify which program to run for certain filetype. The default only support python file, onde you run `:REPLToggle`, `python` will running in the termianl buffer.

To communicate with REPL environment, select your code, press `<leader>w`. And the code will be send to REPL and run automatically.
Or you can just stay in normal mode and press `<leader>w` and the code in the current line will be send REPL.

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

- In Normal Mode, press `ww`, code in the current line (including leading space and the end center) will be transmitted to REPL
- In Visual Mode, press `ww`, selected code (whole line includeing leading space and the last center) will be trasmitted to REPL

### How to change to REPL environment

You can change buffer between file and REPL environment the same as change between two vim buffer. press `<C-W><C-w>` will change between file and REPL environment. `<C-w><C-h,j,k,l>` also work the way it should be

## Setting

you can bind the `REPLToggle` command to a certain key to make it more convince.

```
nnoremap <leader>r :REPLToggle<Cr>
```

**g:repl_width**

it represents the width of repl windows. there is no default value.

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

It controls the command to exit different repl program correctly.

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
