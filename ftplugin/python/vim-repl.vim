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
		call term_sendkeys('python', "\<Cr>")
		call term_sendkeys('python', "quit()\<Cr>")
    endif

    exe bufwinnr(g:repl_target_n) . "wincmd w"
endfunction"}}}

function! s:REPLOpen()"{{{
	if g:repl_at_top
		exe 'to term ++close ++rows=' . g:row_width . ' python'
	else
		exe 'bo term ++close ++rows=' . g:row_width . ' python'
	endif
endfunction"}}}

function! s:REPLIsVisible()"{{{
    if bufwinnr(bufnr("!python")) != -1
        return 1
    else
        return 0
    endif
endfunction"}}}

function! s:REPLToggle()"{{{
    if s:REPLIsVisible()
        call s:REPLClose()
    else
        let g:repl_target_n = bufnr('')
        let g:repl_target_f = @%
        call s:REPLOpen()
    endif
	if g:repl_stayatrepl_when_open == 1
		exe bufwinnr(g:repl_target_n) . "wincmd w"
	endif
endfunction"}}}

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

command! -range -bar SendLineToREPL <line1>,<line2>call s:SendChunkLines()
command REPLToggle call s:REPLToggle()
autocmd bufenter * if (winnr("$") == 1 && bufexists("!python")) | q! | endif
