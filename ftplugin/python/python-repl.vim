function! s:REPLDebugRun() abort "{{{
    if repl#REPLIsVisible()
        call g:REPLSend('c')
    else
        call s:REPLDebugIPDB()
        call g:REPLSend('c')
    endif
endfunction}}}"

function! s:REPLDebugStopAtCurrentLine(...) abort "{{{
    if repl#REPLIsVisible()
        if a:0 == 0
            call g:REPLSend('tbreak ' . line('.'))
        else
            let l:condition = join(a:000, ' ')
            call g:REPLSend('tbreak ' . line('.') . ', ' . l:condition)
        endif
        call term_wait('ZYTREPL', 50)
        call s:REPLDebugRun()
    else
        call s:REPLDebugIPDB()
        call call(function('s:REPLDebugStopAtCurrentLine'), a:000)
    endif
endfunction}}}"

function! s:REPLDebugIPDB() "{{{
    call repl#REPLToggle('python -m ipdb %')
    call term_wait('ZYTREPL', 1000)
endfunction}}}"

command! -nargs=* REPLDebugStopAtCurrentLine call s:REPLDebugStopAtCurrentLine(<f-args>)
command! REPLDebugRun call s:REPLDebugRun()
command! REPLDebug call s:REPLDebugIPDB()
