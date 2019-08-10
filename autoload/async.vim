let s:VaildCommand = ['let ', 'echo ', 'echom ', 'execute ', 'call ', 'unlet ', 'map', 'umap', 'imap', 'nmap', 'vmap', 'inoremap ', 'nnoremap ', 'vnoremap ', 'autocmd ', 'Plug ', 'au ', 'set ', 'filetype ', 'syntax ']

let s:filename=expand('<sfile>:p:h')

function! async#StartWith(string, substring)
    if strlen(a:string) < strlen(a:substring)
        return 0
    elseif a:string[0:(strlen(a:substring)-1)] ==# a:substring
        return 1
    else
        return 0
    endif
endfunction

function! async#StartWithAnyone(string, list)
    for l:l in a:list
        if async#StartWith(a:string, l:l)
            return 1
        endif
    endfor
    return 0
endfunction

function! async#AsyncRunEngine(codelist, currentline, wait_time, channel) abort
    let l:index = a:currentline
    let l:wait_time = a:wait_time
    while l:index != len(a:codelist)
        let l:currentcode = a:codelist[l:index]
        if async#StartWithAnyone(l:currentcode, s:VaildCommand)
            execute l:currentcode
            let l:index = l:index + 1
            continue
        elseif async#StartWith(l:currentcode, 'if ')
            if eval(l:currentcode[3:])
                let l:index = l:index + 1
                continue
            else
                let l:temp = l:index + 1
                let l:level = 0
                while l:temp < len(a:codelist)
                    if async#StartWith(a:codelist[l:temp], 'if ')
                        let l:level = l:level + 1
                    elseif async#StartWith(a:codelist[l:temp], 'endif')
                        let l:level = l:level - 1
                    endif
                    if l:level == 0 && a:codelist[l:temp] ==# 'else'
                        let l:index = l:temp + 1
                        break
                    elseif l:level == 0 && async#StartWith(a:codelist[l:temp], 'elseif')
                        if eval(a:codelist[l:temp][7:])
                            let l:index = l:temp + 1
                            break
                        endif
                    elseif l:level == -1
                        let l:index = l:temp + 1
                        break
                    endif
                    let l:temp = l:temp + 1
                endwhile
            endif
        elseif l:currentcode ==# 'else'
            let l:temp = l:index + 1
            let l:level = 0
            while l:temp < len(a:codelist)
                if async#StartWith(a:codelist[l:temp], 'if ')
                    let l:level = l:level + 1
                elseif a:codelist[l:temp] ==# 'endif'
                    let l:level = l:level - 1
                endif
                let l:temp = l:temp + 1
                if l:level == -1
                    break
                endif
            endwhile
            let l:index = l:temp
        elseif l:currentcode ==# 'endif'
            let l:index = l:index + 1
        elseif async#StartWith(l:currentcode, 'wait')
            if eval(l:currentcode[5:])
                let l:index = l:index + 1
                let l:wait_time = 0
            else
                let l:sleep_time = 50 + 10 * l:wait_time
                let l:wait_time = l:wait_time + 1
                call timer_start(l:sleep_time, function('async#AsyncRunEngine', [a:codelist, l:index, l:wait_time]))
                return
            endif
        elseif async#StartWith(l:currentcode, 'LABEL ')
            let l:index = l:index + 1
        elseif async#StartWith(l:currentcode, 'GOTO ')
            let l:temp = 0
            while l:temp < len(a:codelist)
                if async#StartWith(a:codelist[l:temp], 'LABEL ') && a:codelist[l:temp][6:] ==# l:currentcode[5:]
                    let l:index = l:temp + 1
                    break
                endif
                let l:temp = l:temp + 1
            endwhile
        elseif async#StartWith(l:currentcode, 'sleep ')
            call timer_start(str2nr(l:currentcode[6:]), function('async#AsyncRunEngine', [a:codelist, l:index+1, 0]))
            return
        elseif async#StartWith(l:currentcode, 'return')
            return
        endif
    endwhile
endfunction

function! async#AsyncCodeRun(...)
    call async#AsyncRunEngine(a:1, 0, 0, 0)
endfunction
