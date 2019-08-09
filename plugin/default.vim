let g:REPLVIM_PATH = expand('<sfile>:p')
let g:REPLVIM_PATH = g:REPLVIM_PATH[:strridx(g:REPLVIM_PATH, "plugin") - 1]

if !exists("g:repl_program")
	let g:repl_program = {
				\	"python": "python",
				\	"default": "bash"
				\	}
endif

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
    let g:repl_program.perl = g:REPLVIM_PATH . 'ftplugin/perl/psh'
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

if !exists('g:repl_exit_commands')
	let g:repl_exit_commands = {
				\	"python": "quit()",
                \   "ptpython": "quit()",
				\	"bash": "exit",
				\	"zsh": "exit",
                \   "R": "q()",
                \   'lua': 'os.exit()',
				\	"default": "exit",
				\	}
endif

if !exists('g:repl_input_symbols')
    let g:repl_input_symbols = {
                \   'python': ['>>>', '>>>>', 'ipdb>', 'pdb', '...'],
                \   }
end

if !exists('g:repl_position')
	let g:repl_position = 0
endif

if !exists('g:repl_stayatrepl_when_open')
	let g:repl_stayatrepl_when_open = 0
endif

if !exists('g:repl_checkpoint_notation')
    let g:repl_checkpoint_notation = "CHECKPOINT"
endif
