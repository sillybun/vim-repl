function! replforwin32#WaitHandlerNotCall(channel) abort
    if len(s:tasks) == s:taskprocess
        return
    endif
    let l:tl = repl#GetTerminalLine()
    let l:flag = 0
    for l:symbol in s:waitforsymbols
        if match(l:tl, l:symbol) != -1
            let l:flag = 1
        endif
    endfor
    if l:flag == 0
        call replforwin32#WaitWHNotCall()
        return
    else
        call term_sendkeys(g:repl_console_name, s:tasks[s:taskprocess] . "\n")
        let s:taskprocess = s:taskprocess + 1
        call replforwin32#WaitWHNotCall()
        return
    endif
endfunction

function! replforwin32#WaitWHNotCall() abort
    " call job_start('sleep 0.03', {'close_cb': 'replforwin32#WaitHandlerNotCall'})
    call timer_start(30, 'replforwin32#WaitHandlerNotCall')
endfunction

function! replforwin32#Sends(tasks, symbols)
    let s:tasks = a:tasks
    let s:waitforsymbols = repl#AsList(a:symbols)
    let s:taskprocess = 0
    let s:currentlinenumber = -1
    call replforwin32#WaitHandlerNotCall(0)
endfunction

function! replforwin32#WaitForSymbolsHandler(channel)
    let l:tl = replforwin32#GetTerminalLine()
    if index(s:waitforsymbols, l:tl) == -1
        call replforwin32#WAITFORSYMBOLS()
        return
    else
        return
    endif
endfunction


function! replforwin32#WAITFORSYMBOLS() abort
    " call job_start('sleep 0.03', {'close_cb': 'replforwin32#WaitForSymbolsHandler'})
    call timer_start(30, 'replforwin32#WaitForSymbolsHandler')
endfunction

function! replforwin32#WaitFor(symbols)
    let s:waitforsymbols = repl#AsList(a:symbols)
    call replforwin32#WaitForSymbolsHandler(0)
endfunction
