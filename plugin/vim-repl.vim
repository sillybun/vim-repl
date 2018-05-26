function! s:REPLGetName()"{{{
	if &buftype == "terminal"
		return bufname("%")[1:]
	elseif has_key(g:repl_program, &filetype)
		return g:repl_program[&filetype]
	elseif has_key(g:repl_program, "default")
		return g:repl_program["default"]
	else
		return "bash"
	endif
endfunction}}}"

function! s:REPLGetExitCommand()"{{{
	let name = s:REPLGetName()
	if has_key(g:repl_exit_commands, name)
		return g:repl_exit_commands[name]
	elseif has_key(g:repl_exit_commands, "default")
		return g:repl_exit_commands["default"]
	else
		return "exit"
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
		exe "call term_sendkeys('" . s:REPLGetName() . ''', "\<C-W>\<C-C>")'
		if s:REPLIsVisible()
			exe "call term_sendkeys('" . s:REPLGetName() . "', \"\\<Cr>\")"
			exe "call term_sendkeys('" . s:REPLGetName() . "', \"\\<Cr>\")"
			exe "call term_sendkeys('" . s:REPLGetName() . ''', "' . s:REPLGetExitCommand() . '\<Cr>")'
		endif
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
	exe 'autocmd bufenter * if (winnr("$") == 1 && (&buftype == ''terminal'') && bufexists("!' . s:REPLGetName() . '")) | q! | endif'
	if g:repl_position == 0
		if exists('g:repl_height')
			exe 'bo term ++close ++rows=' . float2nr(g:repl_height) . ' ' . s:REPLGetName()
		else
			exe 'bo term ++close ' . s:REPLGetName()
		endif
	elseif g:repl_position == 1
		if exists('g:repl_height')
			exe 'to term ++close ++rows=' . float2nr(g:repl_height) . ' ' . s:REPLGetName()
		else
			exe 'to term ++close ' . s:REPLGetName()
		endif
	elseif g:repl_position == 2
		if exists('g:repl_width')
			exe 'vert term ++close ++cols=' . float2nr(g:repl_width) . ' ' . s:REPLGetName()
		else
			exe 'vert term ++close ' . s:REPLGetName()
		endif
	else
		if exists('g:repl_width')
			exe 'vert rightb term ++close ++cols=' . float2nr(g:repl_width) . ' ' . s:REPLGetName()
		else
			exe 'vert rightb term ++close ' . s:REPLGetName()
		endif
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
			sleep 10m
		endfor
	endif
endfunction

let invoke_key = g:sendtorepl_invoke_key

silent! exe 'nnoremap <silent> ' . invoke_key . ' :SendLineToREPL<Cr>'
silent! exe 'vnoremap <silent> ' . invoke_key . ' :SendLineToREPL<Cr>'

command! -range SendLineToREPL <line1>,<line2>call s:SendChunkLines()
command! REPLToggle call s:REPLToggle()
