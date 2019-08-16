function! formatvimscript#Format_to_repl(codes)
    let l:codes = []
    for l:i in range(len(a:codes))
        let l:code = a:codes[l:i]
        if len(repl#RStrip(l:code)) != 0
            let l:codes = l:codes + [repl#LStrip(l:code)]
        endif
    endfor
    return l:codes
endfunction
