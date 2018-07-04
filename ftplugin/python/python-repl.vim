function! s:REPLDebugRun() abort "{{{
    if repl#REPLIsVisible()
        if repl#GetTerminalLine() != 'ipdb>'
            call term_sendkeys('ZYTREPL', "\<Cr>")
            call term_wait('ZYTREPL', 50)
            call term_sendkeys('ZYTREPL', "c\<Cr>")
        else
            call term_sendkeys('ZYTREPL', "c\<Cr>")
        endif
    else
        call s:REPLDebugIPDB()
        call g:REPLSend('c')
    endif
    while 1
        call term_wait('ZYTREPL', 20)
        let l:tl = repl#GetTerminalLine()
        if l:tl ==# 'ipdb>'
            break
        endif
    endwhile
    call s:REPLDebugMoveCursor()
endfunction}}}"

function! s:REPLDebugWaitForInput() abort
    while 1
        call term_wait('ZYTREPL', 20)
        let l:tl = repl#GetTerminalLine()
        if l:tl ==# 'ipdb>'
            break
        endif
    endwhile
endfunction

function! s:REPLDebugMoveCursor() abort
    for i in range(repl#GetCurrentLineNumber(), 1, -1)
        let l:t = term_getline('ZYTREPL', i)
        if stridx(l:t, '>') == 0
            let l:t = l:t[2:]
            let l:i = stridx(l:t, '(')
            let l:filefullpath = l:t[0:(l:i - 1)]
            let l:linenumber = str2nr(l:t[(l:i+1):])
            if l:filefullpath !=# expand('%:p') && l:filefullpath[0] ==# '/'
                silent exe 'edit ' . l:filefullpath
            endif
            if l:linenumber != line('.')
                call cursor(l:linenumber, 1)
            endif
            break
        endif
    endfor
endfunction

function! s:REPLDebugN() abort
    if !repl#REPLIsVisible()
        return
    endif
    if repl#GetTerminalLine() != 'ipdb>'
        call term_sendkeys('ZYTREPL', "\<Cr>")
        call s:REPLDebugWaitForInput()
        call term_sendkeys('ZYTREPL', "n\<Cr>")
    else
        call term_sendkeys('ZYTREPL', "n\<Cr>")
    endif
    call s:REPLDebugWaitForInput()
    call s:REPLDebugMoveCursor()
endfunction

function! s:REPLDebugU() abort
    if !repl#REPLIsVisible()
        return
    endif
    if repl#GetTerminalLine() != 'ipdb>'
        call term_sendkeys('ZYTREPL', "\<Cr>")
        call s:REPLDebugWaitForInput()
        call term_sendkeys('ZYTREPL', "u\<Cr>")
    else
        call term_sendkeys('ZYTREPL', "u\<Cr>")
    endif
    call s:REPLDebugWaitForInput()
    call s:REPLDebugMoveCursor()
endfunction

function! s:REPLDebugS() abort
    if !repl#REPLIsVisible()
        return
    endif
    if repl#GetTerminalLine() != 'ipdb>'
        call term_sendkeys('ZYTREPL', "\<Cr>")
        call s:REPLDebugWaitForInput()
        call term_sendkeys('ZYTREPL', "s\<Cr>")
    else
        call term_sendkeys('ZYTREPL', "s\<Cr>")
    endif
    call s:REPLDebugWaitForInput()
    call s:REPLDebugMoveCursor()
endfunction

function! s:REPLDebugStopAtCurrentLine(...) abort "{{{
    if repl#REPLIsVisible()
        if a:0 == 0
            call g:REPLSend('tbreak ' . line('.'))
        else
            let l:condition = join(a:000, ' ')
            call g:REPLSend('tbreak ' . line('.') . ', ' . l:condition)
        endif
        while 1
            call term_wait('ZYTREPL', 20)
            let l:tl = repl#GetTerminalLine()
            if l:tl ==# 'ipdb>'
                break
            endif
        endwhile
        call s:REPLDebugRun()
    else
        call s:REPLDebugIPDB()
        call call(function('s:REPLDebugStopAtCurrentLine'), a:000)
    endif
endfunction}}}"

function! s:REPLDebugIPDB() abort "{{{
	if repl#REPLIsVisible()
        return
	else
		let g:repl_target_n = bufnr('')
		let g:repl_target_f = @%
        call repl#REPLOpen('python -m ipdb %')
	endif
	if g:repl_stayatrepl_when_open == 0
		exe bufwinnr(g:repl_target_n) . 'wincmd w'
	endif
    call term_wait('ZYTREPL', 20)
    let l:n = 0
    while l:n < 50
        let l:tl = repl#GetTerminalLine()
        if !(l:tl ==# 'ipdb>')
            call term_wait('ZYTREPL', 20)
        else
            break
        endif
        let l:n = l:n + 1
    endwhile
endfunction}}}"

command! -nargs=* REPLDebugStopAtCurrentLine call s:REPLDebugStopAtCurrentLine(<f-args>)
command! REPLPDBC call s:REPLDebugRun()
command! REPLPDBN call s:REPLDebugN()
command! REPLPDBS call s:REPLDebugS()
command! REPLPDBU call s:REPLDebugU()
command! REPLDebug call s:REPLDebugIPDB()
