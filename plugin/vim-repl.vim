let invoke_key = g:sendtorepl_invoke_key

function! g:REPLSend(...)
    for l:code in a:000
        exe "call term_sendkeys('" . 'ZYTREPL' . ''', "' . l:code . '\<Cr>")'
		exe "call term_wait('" . 'ZYTREPL' . ''',  50)'
    endfor
endfunction

silent! exe 'nnoremap <silent> ' . invoke_key . ' :SendCurrentLine<Cr>'
silent! exe 'vnoremap <silent> ' . invoke_key . ' :SendLineToREPL<Cr>'

let g:REPLVIM_PATH = expand('<sfile>:p')
let g:REPLVIM_PATH = g:REPLVIM_PATH[:strridx(g:REPLVIM_PATH, "plugin") - 1]

command! -range SendLineToREPL <line1>,<line2>call repl#SendChunkLines()
command! SendCurrentLine call repl#SendCurrentLine()
command! -nargs=* REPLSend call g:REPLSend(<f-args>)
command! -nargs=* REPLToggle call repl#REPLToggle(<f-args>)
command! REPLDebugInfo call repl#REPLDebug()
command! REPLIsVisible echo repl#REPLIsVisible()
command! REPLTerminalLine echo repl#GetTerminalLine()
command! REPLHide call repl#REPLHide()
command! REPLUnhide call repl#REPLUnhide()
command! REPLSendAll call repl#SendAll()
command! REPLSendSession call repl#SendSession()
