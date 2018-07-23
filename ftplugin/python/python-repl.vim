if !exists('g:REPLPythonLoaded')
    let g:REPLPythonLoaded = 1
else
    finish
endif

function! g:REPLDebugRunAsync(channel) abort
    if s:iter_dra == 0 && repl#GetTerminalLine() == 'ipdb>'
        call term_sendkeys('ZYTREPL', "c\<Cr>")
        let s:iter_dra = s:iter_dra + 1
    elseif s:iter_dra == 1 && repl#GetTerminalLine() == 'ipdb>'
        call s:REPLDebugMoveCursor()
        let s:iter_dra = s:iter_dra + 1
        return
    endif
    call s:WAIT_REPLDebugRunAsync()
endfunction

function! s:WAIT_REPLDebugRunAsync() abort
    call job_start('sleep 0.03s', {'close_cb': 'g:REPLDebugRunAsync'})
endfunction

function! s:REPLDebugRun() abort
    if repl#REPLIsVisible()
        if repl#GetTerminalLine() != 'ipdb>'
            call term_sendkeys('ZYTREPL', "\<Cr>")
            call term_wait('ZYTREPL', 50)
        endif
        let s:iter_dra = 0
        call s:WAIT_REPLDebugRunAsync()
    else
        call s:REPLDebugIPDB()
        call term_wait('ZYTREPL', 50)
        call s:REPLDebugRun()
    endif
endfunction

function! s:REPLDebugWaitForInput() abort
    call repl#WaitFor(['ipdb>'])
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

command! -nargs=* REPLDebugStopAtCurrentLine silent call s:REPLDebugStopAtCurrentLine(<f-args>)
command! REPLPDBC silent call s:REPLDebugRun()
command! REPLPDBN silent call s:REPLDebugN()
command! REPLPDBS silent call s:REPLDebugS()
command! REPLPDBU silent call s:REPLDebugU()
command! REPLDebug silent call s:REPLDebugIPDB()
