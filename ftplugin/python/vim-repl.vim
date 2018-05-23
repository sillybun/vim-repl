function! s:SendCurrentLine()
	if bufexists('!python')
		call term_sendkeys('python', getline(".") . "\<Cr>")
	endif
endfunction

function! s:SendChunkLines() range
	if bufexists('!python')
		for line in getline(a:firstline, a:lastline)
			call term_sendkeys('python', line . "\<Cr>")
		endfor
	endif
endfunction


if !exists('g:sendtorepl_invoke_key')
	let g:sendtorepl_invoke_key = "ww"
endif

if !exists('g:repl_row_width')
	let g:repl_row_width = 12
endif

let row_width = float2nr(g:repl_row_width)

silent! exe 'command! REPL :term ++close ++rows=' . row_width . ' python'

let invoke_key = g:sendtorepl_invoke_key

silent! exe 'nnoremap <silent> ' . invoke_key . ' :SendLineToREPL<Cr>'
silent! exe 'vnoremap <silent> ' . invoke_key . ' :SendLineToREPL<Cr>'

command! -range -bar SendLineToREPL <line1>,<line2>call s:SendChunkLines()
autocmd bufenter * if (winnr("$") == 1 && bufexists("!python")) | q! | endif
