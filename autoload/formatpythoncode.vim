function! formatpythoncode#Seperateintoblocks(codes)
    let l:index = 0
    let l:blocks = []
    while l:index < len(a:codes)
        let l:indentlevel = repl#GetIndent(a:codes[l:index])
        let l:blockend = l:index + 1
        let l:temp_block = [a:codes[l:index]]
        while l:blockend < len(a:codes) && repl#GetIndent(a:codes[l:blockend]) > l:indentlevel
            let l:temp_block = l:temp_block + [a:codes[l:blockend]]
            let l:blockend = l:blockend + 1
        endwhile
        let l:blocks = l:blocks + [l:temp_block]
        let l:index = l:blockend
    endwhile
    return blocks
endfunction

function! formatpythoncode#Trunctindent(blocks)
    let l:newblocks = []
    for l:block in a:blocks
        let l:indentlevel = repl#GetIndent(l:block[0])
        let l:temp_block = []
        for l:line in l:block
            let l:temp_block = l:temp_block + [l:line[l:indentlevel:]]
        endfor
        let l:newblocks = l:newblocks + [l:temp_block]
    endfor
    return l:newblocks
endfunction

function! formatpythoncode#AutoStop(line, pythonprogram, version)
    if a:pythonprogram ==# 'ptpython'
        if repl#StartWith(a:line, 'pass ')
            return 1
        else
            return 0
        endif
    elseif a:pythonprogram ==# 'ipython'
        if a:version[0] == '7'
            return 0
        elseif repl#StartWithAny(a:version, ['pass ', 'return ', 'raise ', 'continue ', 'break '])
            return 1
        else
            return 0
        endif
    endif
endfunction

function! formatpythoncode#Format_to_repl(codes, pythonprogram, version)
    let l:codes = []
    for l:i in range(len(a:codes))
        let l:code = a:codes[l:i]
        if len(repl#RStrip(l:code)) != 0
            let l:codes = l:codes + [l:code]
        endif
    endfor
    let l:blocks = formatpythoncode#Seperateintoblocks(l:codes)
    let l:blocks = formatpythoncode#Trunctindent(l:blocks)
    let l:newcodes = []
    for l:i in range(len(l:blocks))
        let l:block = l:blocks[l:i]
        for l:index in range(0, len(l:block)-1)
            let l:tempcodeline = l:block[l:index]
            if l:index == 0 || repl#StartWith(a:pythonprogram, 'python')
                let l:newcodes = l:newcodes + [l:tempcodeline]
                continue
            else
                if repl#GetIndent(l:block[l:index - 1]) > repl#GetIndent(l:tempcodeline)
                    let l:lineneedbs = repl#LStrip(l:tempcodeline)
                    let l:bs_number = repl#GetIndent(l:block[l:index - 1]) - repl#GetIndent(l:tempcodeline) + 4 * formatpythoncode#AutoStop(l:block[l:index - 1], a:pythonprogram, a:version)
                    for l:i in range(l:bs_number)
                        let l:lineneedbs = "\<bs>" . l:lineneedbs
                    endfor
                    let l:newcodes = l:newcodes + [l:lineneedbs]
                else
                    let l:newcodes = l:newcodes + [repl#LStrip(l:tempcodeline)]
                endif
            endif
        endfor
        if repl#StartWith(a:pythonprogram, 'python') || a:pythonprogram ==# 'ptpython'
            if repl#StartWithAny(l:block[0], ['def ', 'class ', 'for ', 'while ', 'try ', 'if '])
                let l:newcodes = l:newcodes + ['']
            endif
        else
            if repl#StartWithAny(l:block[0], ['def ', 'class ', 'for ', 'while ', 'try ', 'if '])
                if repl#GetIndent(l:block[-1]) - 4 * formatpythoncode#AutoStop(l:block[-1], 'ipython', a:version) == 0
                    let l:newcodes = l:newcodes + ['', '']
                else
                    let l:newcodes = l:newcodes + ['']
                endif
            endif
        endif
    endfor
    return l:newcodes
endfunction
