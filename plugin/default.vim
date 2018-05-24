if !exists("g:repl_program")
	let g:repl_program = {
				\	"python": "python",
				\	"default": "bash"
				\	}
endif

if !exists('g:sendtorepl_invoke_key')
	let g:sendtorepl_invoke_key = "ww"
endif

if !exists('g:repl_row_width')
	let g:repl_row_width = 10
endif

if !exists('g:repl_at_top')
	let g:repl_at_top = 0
endif

if !exists('g:repl_stayatrepl_when_open')
	let g:repl_stayatrepl_when_open = 0
endif

