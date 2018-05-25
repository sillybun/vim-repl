if !exists("g:repl_program")
	let g:repl_program = {
				\	"python": "python",
				\	"default": "bash"
				\	}
endif

if !exists('g:sendtorepl_invoke_key')
	let g:sendtorepl_invoke_key = "ww"
endif

if !exists('g:repl_exit_commands')
	let g:repl_exit_commands = {
				\	"python": "quit()",
				\	"bash": "exit",
				\	"zsh": "exit",
				\	"default": "exit",
				\	}
end

if !exists('g:repl_position')
	let g:repl_position = 0
endif

if !exists('g:repl_stayatrepl_when_open')
	let g:repl_stayatrepl_when_open = 0
endif

