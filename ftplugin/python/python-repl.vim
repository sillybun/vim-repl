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
endfunction}}}"

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

function! s:REPLDebugIPDB() "{{{
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
command! REPLDebugRun call s:REPLDebugRun()
command! REPLDebug call s:REPLDebugIPDB()
