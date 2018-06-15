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

function! s:SendCurrentLine() abort
	if bufexists('!'. s:REPLGetName())
		exe "call term_sendkeys('" . s:REPLGetName() . ''', getline(".") . "\<Cr>")'
		exe "call term_wait('" . s:REPLGetName() . ''',  50)'
	endif
endfunction

function! s:SendChunkLines() range abort
	if bufexists('!' . s:REPLGetName())
		let l:firstline = a:firstline
		while(l:firstline <= a:lastline && strlen(getline(l:firstline)) == 0)
			let l:firstline = l:firstline + 1
		endwhile
		let l:fl = getline(l:firstline)
		let l:i = 0
		while(l:i < strlen(l:fl) && l:fl[l:i] == ' ')
			let l:i = l:i + 1
		endwhile
		for line in getline(l:firstline, a:lastline)
			let l:deletespaceline = line[l:i:]
			exe "call term_sendkeys('" . s:REPLGetName() . ''', l:deletespaceline . "\<Cr>")'
			exe "call term_wait('" . s:REPLGetName() . ''', 50)'
			" sleep 50m
		endfor
		exe "call term_sendkeys('" . s:REPLGetName() . ''', "\<Cr>")'
	endif
endfunction

function! s:REPLDebug() abort
    echo "REPL program"
    echo g:repl_program
    echo "REPL exit commands"
    echo g:repl_exit_commands
    echo "Current File Type:"
    echo &filetype
    echo "Current Type:"
    echo s:REPLGetName()
    echo "Current Exit Commands"
    echo s:REPLGetExitCommand()
endfunction

let invoke_key = g:sendtorepl_invoke_key

silent! exe 'nnoremap <silent> ' . invoke_key . ' :SendCurrentLine<Cr>'
silent! exe 'vnoremap <silent> ' . invoke_key . ' :SendLineToREPL<Cr>'

command! -range SendLineToREPL <line1>,<line2>call s:SendChunkLines()
command! SendCurrentLine call s:SendCurrentLine()
command! REPLToggle call s:REPLToggle()
command! REPLDebug call s:REPLDebug()
