function! s:REPLGetName()"{{{
	if has_key(g:repl_program, &filetype)
		return g:repl_program[&filetype]
	elseif has_key(g:repl_program, "default")
		return g:repl_program["default"]
	else
		return "bash"
	endif
endfunction}}}"

function! s:REPLGoToWindowForBufferName(name)"{{{
	if bufwinnr(bufnr(a:name)) != -1
		exe bufwinnr(bufnr(a:name)) . "wincmd w"
		return 1
	else
		return 0
	endif
endfunction"}}}

function! s:REPLClose()"{{{

	if s:REPLIsVisible()
		exe "call term_sendkeys('" . s:REPLGetName() . "', \"\\<Cr>\")"
		exe "call term_sendkeys('" . s:REPLGetName() . "', \"quit()\\<Cr>\")"
	endif

	exe bufwinnr(g:repl_target_n) . "wincmd w"

endfunction"}}}

function! s:REPLHide()
	if s:REPLIsVisible()
		call s:REPLGoToWindowForBufferName("!" . s:REPLGetName())
		hide!
	endif
endfunction

function! s:REPLOpen()"{{{
	exe 'autocmd bufenter * if (winnr("$") == 1 && bufexists("!' . s:REPLGetName() . '")) | q! | endif'
	if g:repl_at_top
		exe 'to term ++close ++rows=' . g:row_width . ' ' . s:REPLGetName()
	else
		exe 'bo term ++close ++rows=' . g:row_width . ' ' . s:REPLGetName()
	endif
endfunction"}}}

function! s:REPLIsVisible()"{{{
	if bufwinnr(bufnr("!" . s:REPLGetName())) != -1
		return 1
	else
		return 0
	endif
endfunction"}}}

function! s:REPLToggle()"{{{
	if s:REPLIsVisible()
		call s:REPLClose()
		" call s:REPLHide()
	else
		let g:repl_target_n = bufnr('')
		let g:repl_target_f = @%
		call s:REPLOpen()
	endif
	if g:repl_stayatrepl_when_open == 0
		exe bufwinnr(g:repl_target_n) . "wincmd w"
	endif
endfunction"}}}

function! s:SendCurrentLine()
	if bufexists('!'. s:REPLGetName())
		exe "call term_sendkeys('" . s:REPLGetName() . ''', getline(".") . "\<Cr>")'
	endif
endfunction

function! s:SendChunkLines() range
	if bufexists('!' . s:REPLGetName())
		for line in getline(a:firstline, a:lastline)
			exe "call term_sendkeys('" . s:REPLGetName() . ''', line . "\<Cr>")'
		endfor
	endif
endfunction


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

let row_width = float2nr(g:repl_row_width)

" silent! exe 'command! REPL :bo term ++close ++rows=' . row_width . ' python'

let invoke_key = g:sendtorepl_invoke_key

silent! exe 'nnoremap <silent> ' . invoke_key . ' :SendLineToREPL<Cr>'
silent! exe 'vnoremap <silent> ' . invoke_key . ' :SendLineToREPL<Cr>'

command! -range SendLineToREPL <line1>,<line2>call s:SendChunkLines()
command! REPLToggle call s:REPLToggle()
"kautocmd bufenter * if (winnr("$") == 1 && bufexists("!" . s:REPLGetName())) | q! | endif
