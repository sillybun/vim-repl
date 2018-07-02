let invoke_key = g:sendtorepl_invoke_key

function! g:REPLSend(...)"{{{
    for l:code in a:000
        exe "call term_sendkeys('" . 'ZYTREPL' . ''', "' . l:code . '\<Cr>")'
		exe "call term_wait('" . 'ZYTREPL' . ''',  50)'
    endfor
endfunction}}}"

silent! exe 'nnoremap <silent> ' . invoke_key . ' :SendCurrentLine<Cr>'
silent! exe 'vnoremap <silent> ' . invoke_key . ' :SendLineToREPL<Cr>'

command! -range SendLineToREPL <line1>,<line2>call repl#SendChunkLines()
command! SendCurrentLine call repl#SendCurrentLine()
command! -nargs=* REPLSend call g:REPLSend(<f-args>)
command! -nargs=* REPLToggle call repl#REPLToggle(<f-args>)
command! REPLDebugInfo call repl#REPLDebug()
command! REPLIsVisible echo repl#REPLIsVisible()
command! REPLTerminalLine echo repl#GetTerminalLine()
