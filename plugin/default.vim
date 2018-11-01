if !exists("g:repl_program")
	let g:repl_program = {
				\	"python": "python",
				\	"default": "bash"
				\	}
endif

if !exists('g:sendtorepl_invoke_key')
	let g:sendtorepl_invoke_key = "<leader>w"
endif

if !exists('g:repl_exit_commands')
	let g:repl_exit_commands = {
				\	"python": "quit()",
                \   "ptpython": "quit()",
				\	"bash": "exit",
				\	"zsh": "exit",
                \   "R": "q()",
				\	"default": "exit",
				\	}
end

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
