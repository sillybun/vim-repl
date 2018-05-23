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

command! REPL :term ++close ++rows=10 python

nnoremap <silent> ww :SendLineToREPL<Cr>
vnoremap <silent> ww :SendLineToREPL<Cr>

command! -range -bar SendLineToREPL <line1>,<line2>call s:SendChunkLines()
autocmd bufenter * if (winnr("$") == 1 && bufexists("!python")) | q! | endif
