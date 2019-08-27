let g:REPLVIM_PATH = expand('<sfile>:p')
let g:REPLVIM_PATH = g:REPLVIM_PATH[:strridx(g:REPLVIM_PATH, "plugin") - 1]

if has('win32')
    let s:repl_default_program = {
                \	'python': 'python',
                \	'default': 'cmd.exe',
                \   'vim': 'vim -e',
                \	}
else
    let s:repl_default_program = {
                \	'python': 'python',
                \	'default': 'bash',
                \   'vim': 'vim -e',
                \	}
endif
if exists("g:repl_program")
    call extend(s:repl_default_program, g:repl_program)
endif
let g:repl_program = s:repl_default_program

if g:repl_program['python'] == 'ipython' && !exists("g:repl_ipython_version")
    let temp = system('ipython --version')
    let g:repl_ipython_version = temp[0:2]
endif

if !has_key(g:repl_program, 'perl')
  if executable('perlconsole')
    let g:repl_program.perl = 'perlconsole'
  elseif executable('reply')
    let g:repl_program.perl = 'reply'
  elseif executable('re.pl')
    let g:repl_program.perl = 're.pl'
  else
    if has('win32')
        let g:repl_program.perl = g:REPLVIM_PATH . 'ftplugin\\perl\\psh'
    else
        let g:repl_program.perl = g:REPLVIM_PATH . 'ftplugin/perl/psh'
    endif
  endif
endif

if !exists('g:sendtorepl_invoke_key')
	let g:sendtorepl_invoke_key = "<leader>w"
endif

if !exists('g:repl_auto_sends')
    let g:repl_auto_sends = ['class ', 'def ', 'for ', 'if ', 'while ']
endif

if !exists('g:repl_cursor_down')
    let g:repl_cursor_down = 1
endif

if !exists('g:repl_python_automerge')
    let g:repl_python_automerge = 0
endif

if !exists('g:repl_vimscript_engine')
    let g:repl_vimscript_engine = 0
endif

if !exists('g:repl_console_name')
    let g:repl_console_name = 'ZYTREPL'
endif

let s:repl_default_exit_commands = {
            \	"python": "quit()",
            \   "ptpython": "quit()",
            \   "ipython": "quit()",
            \	"bash": "exit",
            \	"zsh": "exit",
            \   "R": "q()",
            \   'lua': 'os.exit()',
            \   'vim': 'q',
            \	"default": "exit",
            \	}
if exists('g:repl_exit_commands')
    call extend(s:repl_default_exit_commands, g:repl_exit_commands)
endif
let g:repl_exit_commands = s:repl_default_exit_commands

let s:repl_default_input_symbols = {
            \   'python': ['>>>', '>>>>', 'ipdb>', 'pdb', '...'],
            \   'vim': [':'],
            \   }
if exists('g:repl_input_symbols')
    call extend(s:repl_default_input_symbols, g:repl_input_symbols)
end
let g:repl_input_symbols = s:repl_default_input_symbols

if !exists('g:repl_position')
	let g:repl_position = 0
endif

if !exists('g:repl_stayatrepl_when_open')
	let g:repl_stayatrepl_when_open = 0
endif

if !exists('g:repl_sendvariable_template')
    let g:repl_sendvariable_template = {
                \ 'python': 'print(<input>)',
                \ 'ipython': 'print(<input>)',
                \ 'ptpython': 'print(<input>)',
                \ }
endif
