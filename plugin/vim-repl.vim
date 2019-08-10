let invoke_key = g:sendtorepl_invoke_key

silent! exe 'nnoremap <silent> ' . invoke_key . ' :SendCurrentLine<Cr>'
silent! exe 'vnoremap <silent> ' . invoke_key . ' :SendLineToREPL<Cr>'

command! -range SendLineToREPL <line1>,<line2>call repl#SendChunkLines()
command! SendCurrentLine call repl#SendCurrentLine()
command! -nargs=* REPLToggle call repl#REPLToggle(<f-args>)
command! REPLDebugInfo call repl#REPLDebug()
command! REPLIsVisible echo repl#REPLIsVisible()
command! REPLTerminalLine echo repl#GetTerminalLine()
command! REPLHide call repl#REPLHide()
command! REPLUnhide call repl#REPLUnhide()
command! REPLSendAll call repl#SendAll()
command! REPLSendSession call repl#SendSession()
