if !exists('g:REPLPythonLoaded')
    let g:REPLPythonLoaded = 1
else
    finish
endif

function! s:REPLDebugRunAsync() abort
    let l:code = ["wait repl#GetTerminalLine() == 'ipdb>'", 'call term_sendkeys("' . g:repl_console_name . '", "c\<Cr>")', "sleep 20ms", "wait repl#GetTerminalLine() == 'ipdb>'", 'call g:REPLDebugMoveCursor()']
    call AsyncCodeRun(l:code, 'REPLDebugRunAsync')
endfunction

function! s:REPLDebugRun() abort
    if repl#REPLIsVisible()
        if repl#GetTerminalLine() != 'ipdb>'
            call term_sendkeys(g:repl_console_name, "\<Cr>")
            call term_wait(g:repl_console_name, 50)
        endif
        call s:REPLDebugRunAsync()
    else
        call s:REPLDebugIPDB()
        call term_wait(g:repl_console_name, 50)
        call s:REPLDebugRun()
    endif
endfunction

function! g:REPLDebugMoveCursor() abort
    " echom repl#GetTerminalLine()
    for l:currentlinenumber in range(repl#GetCurrentLineNumber(), 1, -1)
        let l:t = term_getline(g:repl_console_name, l:currentlinenumber)
        if stridx(l:t, '>') == 0
            let l:t = l:t[2:]
            let l:i = stridx(l:t, '(')
            let l:j = l:currentlinenumber
            while l:i == -1
                let l:j = l:j + 1
                let l:nextline = term_getline(g:repl_console_name, l:j)
                let l:t = l:t . l:nextline
                let l:i = stridx(l:t, '(')
            endwhile
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
    let l:code = ['if repl#GetTerminalLine() != "ipdb>"', 'call term_sendkeys("' . g:repl_console_name . '", "\<Cr>")', 'endif', 'call term_sendkeys("' . g:repl_console_name . '", "n\<Cr>")', 'sleep 10ms', 'wait repl#GetTerminalLine() == "ipdb>"', 'call g:REPLDebugMoveCursor()']
    call AsyncCodeRun(l:code, "REPLDebugN")
endfunction

function! s:REPLDebugU() abort
    if !repl#REPLIsVisible()
        return
    endif
    let l:code = ['if repl#GetTerminalLine() != "ipdb>"', 'call term_sendkeys("' . g:repl_console_name . '", "\<Cr>")', 'endif', 'call term_sendkeys("' . g:repl_console_name . '", "u\<Cr>")', 'sleep 10ms', 'wait repl#GetTerminalLine() == "ipdb>"', 'call g:REPLDebugMoveCursor()']
    call AsyncCodeRun(l:code, "REPLDebugU")
endfunction

function! s:REPLDebugS() abort
    if !repl#REPLIsVisible()
        return
    endif
    let l:code = ['if repl#GetTerminalLine() != "ipdb>"', 'call term_sendkeys("' . g:repl_console_name . '", "\<Cr>")', 'endif', 'call term_sendkeys("' . g:repl_console_name . '", "s\<Cr>")', 'sleep 10ms', 'wait repl#GetTerminalLine() == "ipdb>"', 'call g:REPLDebugMoveCursor()']
    call AsyncCodeRun(l:code, "REPLDebugS")
endfunction

function! s:REPLDebugStopAtCurrentLine(...) abort
    if repl#REPLIsVisible()
        if a:0 == 0
            call g:REPLSend('tbreak ' . line('.'))
        else
            let l:condition = join(a:000, ' ')
            call g:REPLSend('tbreak ' . line('.') . ', ' . l:condition)
        endif
        while 1
            call term_wait(g:repl_console_name, 20)
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
endfunction

function! s:REPLDebugIPDB() abort
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
    call term_wait(g:repl_console_name, 20)
    let l:n = 0
    while l:n < 50
        let l:tl = repl#GetTerminalLine()
        if !(l:tl ==# 'ipdb>')
            call term_wait(g:repl_console_name, 20)
        else
            break
        endif
        let l:n = l:n + 1
    endwhile
endfunction

command! -nargs=* REPLDebugStopAtCurrentLine silent call s:REPLDebugStopAtCurrentLine(<f-args>)
command! REPLPDBC silent call s:REPLDebugRun()
command! REPLPDBN silent call s:REPLDebugN()
command! REPLPDBS silent call s:REPLDebugS()
command! REPLPDBU silent call s:REPLDebugU()
command! REPLDebug silent call s:REPLDebugIPDB()
command! REPLAddCheckPoint silent call s:REPLAddCheckPoint()
command! REPLSaveCheckPoint call s:REPLSaveCheckPoint()
command! REPLLoadCheckPoint silent call s:REPLLoadCheckPoint()
