function! repl#AsList(value)
    if type(a:value) == type([])
        return a:value
    else
        return [a:value]
    end
endfunction

function! repl#GetConsoleName()
    return g:repl_console_name . string(tabpagenr())
endfunction

function! repl#Trim(value)
    if has('python3')
python3 << EOF
import vim
value = vim.eval("a:value").strip()
EOF
        return py3eval("value")
    elseif has('python')
python << EOF
import vim
value = vim.eval("a:value").strip()
EOF
        return pyeval("value")
    else
        return trim(a:value)
    end
endfunction

function! repl#ReverseStr(string)
pythonx << EOF
import vim
value = vim.eval("a:string")[::-1]
EOF
return pyxeval("value")
endfunction

function! repl#RStrip(string)
    return substitute(a:string, '\s*$', '', '')
endfunction

function! repl#LStrip(string)
    return substitute(a:string, '^\s*', '', '')
endfunction

function! repl#Strip(string)
    return repl#LStrip(repl#RStrip(a:string))
endfunction

function! repl#GetIndent(string)
    let l:string = substitute(a:string, "\t", "    ", "g")
    if repl#Trim(a:string) ==# ''
        return 9999
    else
        return len(a:string) - len(repl#LStrip(a:string))
    endif
endfunction

function! repl#StartWith(string, substring)
    if strlen(a:string) < strlen(a:substring)
        return 0
    elseif a:string[0:(strlen(a:substring)-1)] ==# a:substring
        return 1
    else
        return 0
    endif
endfunction

function! repl#EndWith(string, substring)
    return repl#StartWith(repl#ReverseStr(a:string), repl#ReverseStr(a:substring))
endfunction

function! repl#EndWithAny(string, substringlist)
    for l:substring in a:substringlist
        if repl#EndWith(a:string, l:substring)
            return 1
        endif
    endfor
    return 0
endfunction

function! repl#StartWithAny(string, substringlist)
    for l:substring in a:substringlist
        if repl#StartWith(a:string, l:substring)
            return 1
        endif
    endfor
    return 0
endfunction

function! repl#CurrentFilePath()
    return expand("%:p:h")
endfunction

function! repl#REPLGetName()
    if exists('t:REPL_OPEN_TERMINAL')
        return t:REPL_OPEN_TERMINAL
    elseif &buftype ==# 'terminal'
		return bufname('%')[1:]
	elseif has_key(g:repl_program, &filetype)
		let l:repl_options = g:repl_program[&filetype]
        if type(l:repl_options) == 1
            return l:repl_options
        else
            let l:count = len(l:repl_options)
            if l:count == 1
                return l:repl_options[0]
            elseif l:count > 1
                let l:choice = inputlist([ 'Select your REPL:' ]
                                      \ + map(copy(l:repl_options), '(v:key+1).". ".v:val')) - 1
                redraw
                if l:choice < 0 || l:choice >= l:count
                    throw "Unexpected-input-received"
                else
                    return l:repl_options[l:choice]
                endif
            endif
        endif
	elseif has_key(g:repl_program, 'default')
		let l:repl_options = g:repl_program['default']
        if type(l:repl_options) == 3
            return l:repl_options[0]
        else
            return l:repl_options
	else
		return 'bash'
	endif
endfunction

function! repl#StringAfter(word, token)
    let l:loc = strridx(a:word, a:token)
    return a:word[(l:loc+1):]
endfunction

function! repl#REPLGetShortName()
    let l:name = repl#REPLGetName()
    let l:temp = split(repl#StringAfter(l:name, '/'), ' ')[0]
    if l:temp ==# 'ptpython'
        return 'ptpython'
    elseif l:temp ==# 'ipython'
        return 'ipython'
    elseif l:temp ==# 'ipython3'
        return 'ipython'
    elseif l:temp =~# '.*python.*'
        return 'python'
    else
        return l:temp
    endif
endfunction

function! repl#REPLWin32Return()
    let l:name = repl#REPLGetShortName()
    if has('win32')
        if l:name ==# 'ipython'
            return 0
        else
            return 1
        endif
    else
        return 0
    endif
endfunction

function! repl#REPLGetShell()
    if has_key(g:repl_program, 'default')
        return g:repl_program['default']
    elseif has('win32')
        return 'cmd.exe'
    else
        return 'bash'
    endif
endfunction

function! repl#REPLGetExitCommand(...)
    if a:0 == 0
        let l:name = repl#REPLGetShortName()
    else
        let l:name = a:1
    end
	if has_key(g:repl_exit_commands, l:name)
		return g:repl_exit_commands[l:name]
	elseif has_key(g:repl_exit_commands, 'default')
		return g:repl_exit_commands['default']
	else
		return 'exit'
	endif
endfunction

function! repl#REPLGoToWindowForBufferName(name)
	if bufwinnr(bufnr(a:name)) != -1
		exe bufwinnr(bufnr(a:name)) . 'wincmd w'
		return 1
	else
		return 0
	endif
endfunction
function! repl#REPLClose()
	if repl#REPLIsVisible()
        if index(split(repl#REPLGetName(), ' '), 'ipdb') != -1 || index(split(repl#REPLGetName(), ' '), 'pdb') != -1
            call term_sendkeys(repl#GetConsoleName(), "\<C-W>\<C-C>")
            call repl#Sends(['quit()'], ['ipdb>', 'pdb>'])
        else
            call repl#REPLGoToWindowForBufferName(repl#GetConsoleName())
            if mode() ==# 'n'
                execute "normal! i"
            endif
            exe "call term_sendkeys('" . repl#GetConsoleName() . ''', "\<C-W>\<C-C>")'
            exe "call term_wait('" . repl#GetConsoleName() . ''', 50)'
            if repl#REPLIsVisible()
                if repl#REPLWin32Return()
                    exe "call term_sendkeys('" . repl#GetConsoleName() . "', \"\\r\\n\")"
                else
                    exe "call term_sendkeys('" . repl#GetConsoleName() . "', \"\\n\")"
                endif
                exe "call term_wait('" . repl#GetConsoleName() . ''', 50)'
                if repl#REPLWin32Return()
                    exe "call term_sendkeys('" . repl#GetConsoleName() . "', \"\\r\\n\")"
                else
                    exe "call term_sendkeys('" . repl#GetConsoleName() . "', \"\\n\")"
                endif
                exe "call term_wait('" . repl#GetConsoleName() . ''', 50)'
                if repl#REPLWin32Return()
                    exe "call term_sendkeys('" . repl#GetConsoleName() . ''', "' . repl#REPLGetExitCommand() . '\r\n")'
                else
                    exe "call term_sendkeys('" . repl#GetConsoleName() . ''', "' . repl#REPLGetExitCommand() . '\n")'
                endif
                exe "call term_wait('" . repl#GetConsoleName() . ''', 50)'
                exe "call term_sendkeys('" . repl#GetConsoleName() . ''', "' . '\<CR>")'
            endif
            let l:temp_return = "\n"
            if has('win32')
                let l:temp_return = "\r"
            endif
            if exists('g:REPL_VIRTUAL_ENVIRONMENT')
                call term_sendkeys(repl#GetConsoleName(), 'deactivate' . l:temp_return)
                call term_wait(repl#GetConsoleName(), 50)
                call term_sendkeys(repl#GetConsoleName(), repl#REPLGetExitCommand(repl#REPLGetShell()) . l:temp_return)
                call term_wait(repl#GetConsoleName(), 50)
                unlet g:REPL_VIRTUAL_ENVIRONMENT
            endif
		endif
    elseif repl#REPLIsHidden()
        call repl#REPLUnhide()
        call repl#REPLClose()
        return
	endif
    exe bufwinnr(g:repl_target_n) . 'wincmd w'
    unlet t:REPL_OPEN_TERMINAL
endfunction

function! repl#REPLHide()
	if repl#REPLIsVisible()
		call repl#REPLGoToWindowForBufferName(repl#GetConsoleName())
        hide
	endif
endfunction

function! repl#REPLUnhide()
    if repl#REPLIsHidden()
        if g:repl_position == 0
            exe 'bo unhide'
        elseif g:repl_position == 1
            exe 'to unhide'
        elseif g:repl_position == 2
            exe 'vert unhide'
        else
            exe 'vert rightb unhide'
        endif
    endif
endfunction

function! repl#REPLOpen(...)
    if a:0 == 0
        unlet! t:REPL_OPEN_TERMINAL
        let t:REPL_OPEN_TERMINAL = repl#REPLGetName()
    else
        let t:REPL_OPEN_TERMINAL = join(a:000, ' ')
    endif
    let l:REPL_OPEN_TERMINAL = t:REPL_OPEN_TERMINAL
	exe 'autocmd bufenter * if (winnr("$") == 1 && (&buftype == ''terminal'') && bufexists(repl#GetConsoleName())) | q! | endif'
    if !executable(split(repl#REPLGetName(), ' ')[0])
        echoerr 'The program ' . split(repl#REPLGetName(), ' ')[0] . ' is not executable.'
    endif
    if repl#REPLGetShortName() =~# '.*python.*'
        if repl#REPLGetShortName() == 'ipython' && !exists("g:repl_ipython_version")
            let temp = system(t:REPL_OPEN_TERMINAL . ' --version')
            let g:repl_ipython_version = temp[0:2]
        endif
        for l:i in range(1, line('$'))
            if repl#StartWith(getline(l:i), '#REPLENV:')
                let g:REPL_VIRTUAL_ENVIRONMENT = repl#Strip(getline(l:i)[strlen('#REPLENV:')+1: ])
                if repl#StartWith(getline(l:i+1), "#PYTHONPATH:")
                    let l:REPL_OPEN_TERMINAL = repl#Strip(getline(l:i+1)[strlen('#PYTHONPATH:')+1: ])
                endif
                if g:repl_position == 0
                    if exists('g:repl_height')
                        exe 'bo term ++close ++rows=' . float2nr(g:repl_height) . ' ' . repl#REPLGetShell()
                    else
                        exe 'bo term ++close ' . repl#REPLGetShell()
                    endif
                elseif g:repl_position == 1
                    if exists('g:repl_height')
                        exe 'to term ++close ++rows=' . float2nr(g:repl_height) . ' ' . repl#REPLGetShell()
                    else
                        exe 'to term ++close ' . repl#REPLGetShell()
                    endif
                elseif g:repl_position == 2
                    if exists('g:repl_width')
                        exe 'vert term ++close ++cols=' . float2nr(g:repl_width) . ' ' . repl#REPLGetShell()
                    else
                        exe 'vert term ++close ' . repl#REPLGetShell()
                    endif
                else
                    if exists('g:repl_width')
                        exe 'vert rightb term ++close ++cols=' . float2nr(g:repl_width) . ' ' . repl#REPLGetShell()
                    else
                        exe 'vert rightb term ++close ' . repl#REPLGetShell()
                    endif
                endif
                exe 'file ' . repl#GetConsoleName()
                exe 'setlocal noswapfile'
                if has('win32')
                    let l:temp_return = "\r\n"
                else
                    let l:temp_return = "\n"
                endif
                if repl#StartWith(g:REPL_VIRTUAL_ENVIRONMENT, "conda")
                    call term_sendkeys(repl#GetConsoleName(), g:REPL_VIRTUAL_ENVIRONMENT . l:temp_return)
                else
                    call term_sendkeys(repl#GetConsoleName(), 'source ' . g:REPL_VIRTUAL_ENVIRONMENT . l:temp_return)
                endif
                call term_wait(repl#GetConsoleName(), 100)
                call term_sendkeys(repl#GetConsoleName(), l:REPL_OPEN_TERMINAL . l:temp_return)
                return
            endif
        endfor
        if exists('g:repl_python_pre_launch_command')
            if g:repl_position == 0
                if exists('g:repl_height')
                    exe 'bo term ++close ++rows=' . float2nr(g:repl_height) . ' ' . repl#REPLGetShell()
                else
                    exe 'bo term ++close ' . repl#REPLGetShell()
                endif
            elseif g:repl_position == 1
                if exists('g:repl_height')
                    exe 'to term ++close ++rows=' . float2nr(g:repl_height) . ' ' . repl#REPLGetShell()
                else
                    exe 'to term ++close ' . repl#REPLGetShell()
                endif
            elseif g:repl_position == 2
                if exists('g:repl_width')
                    exe 'vert term ++close ++cols=' . float2nr(g:repl_width) . ' ' . repl#REPLGetShell()
                else
                    exe 'vert term ++close ' . repl#REPLGetShell()
                endif
            else
                if exists('g:repl_width')
                    exe 'vert rightb term ++close ++cols=' . float2nr(g:repl_width) . ' ' . repl#REPLGetShell()
                else
                    exe 'vert rightb term ++close ' . repl#REPLGetShell()
                endif
            endif
            exe 'file ' . repl#GetConsoleName()
            exe 'setlocal noswapfile'
            if has('win32')
                let l:temp_return = "\r"
            else
                let l:temp_return = "\n"
            endif
            if has('win32')
                if repl#StartWith(g:repl_python_pre_launch_command, 'conda ')
                    let g:REPL_VIRTUAL_ENVIRONMENT = repl#Strip(g:repl_python_pre_launch_command[strlen('conda '):])
                endif
            else
                if repl#StartWith(g:repl_python_pre_launch_command, 'source ')
                    let g:REPL_VIRTUAL_ENVIRONMENT = repl#Strip(g:repl_python_pre_launch_command[strlen('source '):])
                endif
            endif
            call term_sendkeys(repl#GetConsoleName(), g:repl_python_pre_launch_command . l:temp_return)
            call term_wait(repl#GetConsoleName(), 100)
            call term_sendkeys(repl#GetConsoleName(), l:REPL_OPEN_TERMINAL . l:temp_return)
            return
        endif
    endif
	if g:repl_position == 0
		if exists('g:repl_height')
			exe 'bo term ++close ++rows=' . float2nr(g:repl_height) . ' ' . repl#REPLGetName()
		else
			exe 'bo term ++close ' . repl#REPLGetName()
		endif
	elseif g:repl_position == 1
		if exists('g:repl_height')
			exe 'to term ++close ++rows=' . float2nr(g:repl_height) . ' ' . repl#REPLGetName()
		else
			exe 'to term ++close ' . repl#REPLGetName()
		endif
	elseif g:repl_position == 2
		if exists('g:repl_width')
			exe 'vert term ++close ++cols=' . float2nr(g:repl_width) . ' ' . repl#REPLGetName()
		else
			exe 'vert term ++close ' . repl#REPLGetName()
		endif
	else
		if exists('g:repl_width')
			exe 'vert rightb term ++close ++cols=' . float2nr(g:repl_width) . ' ' . repl#REPLGetName()
		else
			exe 'vert rightb term ++close ' . repl#REPLGetName()
		endif
	endif
    exe 'file ' . repl#GetConsoleName()
    exe 'setlocal noswapfile'
endfunction

function! repl#REPLIsHidden()
    if bufnr(repl#GetConsoleName()) == -1
        return 0
    elseif repl#REPLIsVisible() == 1
        return 0
    else
        return 1
    endif
endfunction

function! repl#REPLIsVisible()
	if bufwinnr(bufnr(repl#GetConsoleName())) != -1
		return 1
	else
		return 0
	endif
endfunction

function! repl#REPLToggle(...)
	if repl#REPLIsVisible()
		call repl#REPLClose()
    elseif repl#REPLIsHidden()
        call repl#REPLUnhide()
    else
        let l:cursor_pos = getpos('.')
		let g:repl_target_n = bufnr('')
		let g:repl_target_f = @%
        try
            call call(function('repl#REPLOpen'), a:000)
        catch /Unexpected-input-received/
            echom "Unexpected input received, REPL launch abort."
            return
        endtry
        exe 'setlocal nonu'
        if g:repl_stayatrepl_when_open == 0
            exe bufwinnr(g:repl_target_n) . 'wincmd w'
            if exists('g:repl_predefine_' . repl#REPLGetShortName())
                let l:command_dict = eval('g:repl_predefine_' . repl#REPLGetShortName())
                let l:precode = []
                for l:key in keys(l:command_dict)
                    if search(l:key) != 0
                        call add(l:precode, l:command_dict[l:key])
                    endif
                endfor
                call repl#Sends(l:precode, ['>>>', '...', 'ipdb>', 'pdb>'])
            endif
            if repl#REPLGetShortName() =~# '.*python.*' && g:repl_python_auto_import
                let l:code_tobe_sent = []
                for l:line_number in range(1, line("$"))
                    let l:gl = repl#Strip(getline(l:line_number))
                    if l:gl =~# '^import ' || l:gl =~# '^from .* import .*' || l:gl =~# '^sys\.path'
                        let l:code_tobe_sent = l:code_tobe_sent + [l:gl]
                    endif
                endfor
                let l:sn = repl#REPLGetShortName()
                if l:sn ==# 'ptpython'
                    call repl#Sends(repl#ToREPLPythonCode(l:code_tobe_sent, 'ptpython'), ['\.\.\.', '>>>', 'ipdb>', 'pdb>'])
                elseif l:sn ==# 'ipython'
                    call repl#Sends(repl#ToREPLPythonCode(l:code_tobe_sent, 'ipython'), ['\.\.\.', 'In'])
                elseif l:sn =~# 'python' || l:sn =~# 'python3'
                    call repl#Sends(repl#ToREPLPythonCode(l:code_tobe_sent, 'python'), ['>>>', '...', 'ipdb>', 'pdb>'])
                endif
            endif
            call cursor(l:cursor_pos[1], l:cursor_pos[2])
        endif
	endif
endfunction

function! repl#SendCurrentLine()
    if g:repl_unhide_when_send_lines && repl#REPLIsHidden()
        call repl#REPLUnhide()
    endif
	if bufexists(repl#GetConsoleName())
        let l:cursor_pos = getpos('.')
        if repl#REPLWin32Return()
            let l:code_tobe_sent = getline('.') . "\r\n"
        else
            let l:code_tobe_sent = getline('.') . "\n"
        endif
        if repl#REPLGetShortName() =~# '.*python.*'
            if exists('g:repl_auto_sends') && repl#StartWithAny(repl#Trim(getline('.')), g:repl_auto_sends)
                let l:end_line_number = repl#SendWholeBlock()
                " if g:repl_cursor_down
                "     call cursor(l:end_line_number + 1, l:cursor_pos[2])
                " endif
                if g:repl_cursor_down
                    let l:next_line_number = l:end_line_number + 1
                    while l:next_line_number <= line("$") && (repl#Strip(getline(l:next_line_number)) == "" || repl#StartWith(repl#Strip(getline(l:next_line_number)), "#"))
                        let l:next_line_number = l:next_line_number + 1
                    endwhile
                    call cursor(l:next_line_number, l:cursor_pos[2])
                endif
                return
            endif
            if exists('g:repl_auto_sends') && repl#EndWith(repl#RStrip(getline(".")), "\\")
                let l:end_line_number = repl#SendWholeBlock()
                if g:repl_cursor_down
                    let l:next_line_number = l:end_line_number + 1
                    while l:next_line_number <= line("$") && (repl#Strip(getline(l:next_line_number)) == "" || repl#StartWith(repl#Strip(getline(l:next_line_number)), "#"))
                        let l:next_line_number = l:next_line_number + 1
                    endwhile
                    call cursor(l:next_line_number, l:cursor_pos[2])
                endif
                return
            endif
            if exists('g:repl_python_auto_send_unfinish_line') && !repl#IsCodeFinish(repl#Strip(getline(".")))
                let l:end_line_number = repl#SendCompleteLine()
                if g:repl_cursor_down
                    let l:next_line_number = l:end_line_number + 1
                    while l:next_line_number <= line("$") && (repl#Strip(getline(l:next_line_number)) == "" || repl#StartWith(repl#Strip(getline(l:next_line_number)), "#"))
                        let l:next_line_number = l:next_line_number + 1
                    endwhile
                    call cursor(l:next_line_number, l:cursor_pos[2])
                endif
                return
            endif
            if repl#REPLGetShortName() ==# 'ipython'
                let l:terminalline = repl#GetTerminalLine()
                if repl#StartWith(l:terminalline, "In [")
                    let l:code_tobe_sent = repl#LStrip(l:code_tobe_sent)
                else
                    let l:bs_number = len(l:terminalline) - len(repl#RStrip(l:terminalline)) - 2
                    let l:code_tobe_sent = repeat("\<bs>", l:bs_number) . l:code_tobe_sent
                endif
            elseif repl#REPLGetShortName() ==# 'ptpython'
                let l:terminalline = repl#GetTerminalLine()
                let l:bs_number = len(l:terminalline) - len(repl#RStrip(l:terminalline)) - 2
                let l:code_tobe_sent = repeat("\<bs>", l:bs_number) . l:code_tobe_sent
            elseif repl#REPLGetShortName() ==# 'python' || repl#REPLGetShortName() ==# 'python2' || repl#REPLGetShortName() ==# 'python3'
                let l:terminalline = repl#GetTerminalLine()
                if repl#StartWith(l:terminalline, '>>> ')
                    let l:code_tobe_sent = repl#LStrip(l:code_tobe_sent)
                endif
            endif
        endif
        if repl#REPLGetShortName() ==# "ipython"
            call repl#Sends(repl#ToREPLPythonCode([l:code_tobe_sent], 'ipython'), ['\.\.\.', 'In'])
        else
            call term_sendkeys(repl#GetConsoleName(), l:code_tobe_sent)
        endif
        call term_wait(repl#GetConsoleName(), 50)
        if g:repl_cursor_down
            " call cursor(l:cursor_pos[1] + 1, l:cursor_pos[2])
            let l:next_line_number = l:cursor_pos[1] + 1
            while l:next_line_number <= line("$") && (repl#Strip(getline(l:next_line_number)) == "" || repl#StartWith(repl#Strip(getline(l:next_line_number)), "#"))
                let l:next_line_number = l:next_line_number + 1
            endwhile
            call cursor(l:next_line_number, l:cursor_pos[2])
        endif
	endif
endfunction

function! repl#SendRHSofCurrentLine()
    if g:repl_unhide_when_send_lines && repl#REPLIsHidden()
        call repl#REPLUnhide()
    endif
	if bufexists(repl#GetConsoleName())
        let l:cursor_pos = getpos('.')
        if repl#REPLWin32Return()
            let l:code_tobe_sent = getline('.') . "\r\n"
        else
            let l:code_tobe_sent = getline('.') . "\n"
        endif
        if repl#REPLGetShortName() =~# '.*python.*'
            if repl#REPLGetShortName() ==# 'ipython'
                let l:terminalline = repl#GetTerminalLine()
                if repl#StartWith(l:terminalline, "In [")
                    let l:code_tobe_sent = repl#LStrip(l:code_tobe_sent)
                else
                    let l:bs_number = len(l:terminalline) - len(repl#RStrip(l:terminalline)) - 2
                    let l:code_tobe_sent = repeat("\<bs>", l:bs_number) . l:code_tobe_sent
                endif
            elseif repl#REPLGetShortName() ==# 'ptpython'
                let l:terminalline = repl#GetTerminalLine()
                let l:bs_number = len(l:terminalline) - len(repl#RStrip(l:terminalline)) - 2
                let l:code_tobe_sent = repeat("\<bs>", l:bs_number) . l:code_tobe_sent
            elseif repl#REPLGetShortName() ==# 'python' || repl#REPLGetShortName() ==# 'python2' || repl#REPLGetShortName() ==# 'python3'
                let l:terminalline = repl#GetTerminalLine()
                if repl#StartWith(l:terminalline, '>>> ')
                    let l:code_tobe_sent = repl#LStrip(l:code_tobe_sent)
                endif
            endif
        endif
        if repl#REPLGetShortName() ==# "ipython"
            call repl#Sends([repl#RHSPythonCode(l:code_tobe_sent)], ['\.\.\.', 'In'])
        else
            call term_sendkeys(repl#GetConsoleName(), repl#RHSPythonCode(l:code_tobe_sent))
        endif
        call term_wait(repl#GetConsoleName(), 50)
        if g:repl_cursor_down
            let l:next_line_number = l:cursor_pos[1] + 1
            while l:next_line_number <= line("$") && (repl#Strip(getline(l:next_line_number)) == "" || repl#StartWith(repl#Strip(getline(l:next_line_number)), "#"))
                let l:next_line_number = l:next_line_number + 1
            endwhile
            call cursor(l:next_line_number, l:cursor_pos[2])
        endif
	endif
endfunction

function! repl#ToVimScript(lines)
    return formatvimscript#Format_to_repl(a:lines)
endfunction

function! repl#IsCodeFinish(code)
    if has('python3')
python3 << EOF
import vim
import sys
# sys.path.append(vim.eval("g:REPLVIM_PATH") + "autoload/")
import replpython
code = vim.eval("a:code")
if isinstance(code, list):
    finish_flag = int(replpython.getpythonindent(code)[1])
else:
    finish_flag = int(replpython.getpythonindent([code])[1])
EOF
        return py3eval("finish_flag")
    elseif has('python')
python << EOF
import vim
import sys
# sys.path.append(vim.eval("g:REPLVIM_PATH") + "autoload/")
import replpython
code = vim.eval("a:code")
if isinstance(code, list):
    finish_flag = int(replpython.getpythonindent(code)[1])
else:
    finish_flag = int(replpython.getpythonindent([code])[1])
EOF
        return pyeval("finish_flag")
    else
        return 1
    end
endfunction

function! repl#RHSPythonCode(line)
    if  has('python3')
python3 << EOF
import vim
import re
code = vim.eval("a:line").strip()
ret = code
regex = re.compile(r"[\w.]+[ ]*=[ ]*(.+)")
if code.startswith("return "):
    ret = code[len("return "):].strip()
elif code.startswith("yield "):
    ret = code[len("yield "):].strip()
else:
    m = regex.fullmatch(code)
    if m:
        ret = m.group(1)
EOF
        return py3eval('ret')
    elseif has('python')
python << EOF
import vim
import re
code = vim.eval("a:line").strip()
ret = code
regex = re.compile(r"[\w.]+[ ]*=[ ]*(.+)")
if code.startswith("return "):
    ret = code[len("return "):].strip()
elif code.startswith("yield "):
    ret = code[len("yield "):].strip()
else:
    m = regex.fullmatch(code)
    if m:
        ret = m.group(1)
EOF
        return pyeval('ret')
    endif
endfunction

function! repl#ToREPLPythonCode(lines, pythonprogram)
    if exists('g:repl_ipython_version')
        let l:version = g:repl_ipython_version
    else
        let l:version = -1
    endif
    if !has('python3') && !has('python') || g:repl_vimscript_engine
        if a:pythonprogram ==# 'ipython'
            let l:temp = formatpythoncode#Format_to_repl(a:lines, 'python', '')
            return ['%autoindent'] + l:temp + ['%autoindent']
        endif
        return formatpythoncode#Format_to_repl(a:lines, a:pythonprogram, l:version)
    elseif has('python3')
python3 << EOF
import vim
import sys
# sys.path.append(vim.eval("g:REPLVIM_PATH") + "autoload/")
import formatpythoncode
codes = vim.eval("a:lines")
pythonprogram = vim.eval("a:pythonprogram")
mergeunfinishline = int(vim.eval("g:repl_python_automerge"))
version = vim.eval("l:version")
newcodes = formatpythoncode.format_to_repl(codes, pythonprogram, mergeunfinishline, version, vim.eval("repl#CurrentFilePath()"))
EOF
        return py3eval('newcodes')
    elseif has('python')
python << EOF
import vim
import sys
# sys.path.append(vim.eval("g:REPLVIM_PATH") + "autoload/")
import formatpythoncode
codes = vim.eval("a:lines")
pythonprogram = vim.eval("a:pythonprogram")
mergeunfinishline = int(vim.eval("g:repl_python_automerge"))
version = vim.eval("l:version")
newcodes = formatpythoncode.format_to_repl(codes, pythonprogram, mergeunfinishline, version, vim.eval("repl#CurrentFilePath()"))
EOF
        return pyeval('newcodes')
    endif
endfunction

function! repl#GetTerminalLine() abort
    let l:tl = term_getline(repl#GetConsoleName(), '.')
    " return repl#RStrip(l:tl)
    return l:tl
endfunction

function! repl#GetCurrentLineNumber() abort
    return term_getcursor(repl#GetConsoleName())[0]
endfunction

function! repl#CheckInputState()
    let l:tl = repl#GetTerminalLine()
    if g:currentrepltype ==# 'ipython' && (!exists("g:repl_tasks") || (g:taskprocess == 0 || g:repl_tasks[g:taskprocess-1] ==# '') && (g:taskprocess == len(g:repl_tasks) || (g:repl_tasks[g:taskprocess] !=# '')) && (len(g:repl_tasks) > 1))
        if match(l:tl, 'In') != -1
            return 1
        else
            return 0
        endif
    endif
    for l:symbol in g:waitforsymbols
        if match(l:tl, l:symbol) != -1
            return 1
        endif
    endfor
    return 0
endfunction

function! repl#Sends(tasks, symbols)
    " echom a:tasks
    if len(a:tasks) == 0
        return
    end
    if exists("g:repl_tasks")
        let g:repl_tasks = g:repl_tasks + a:tasks
        return
    endif
    let g:repl_tasks = a:tasks
    let g:waitforsymbols = repl#AsList(a:symbols)
    let g:taskprocess = 0
    let g:currentlinenumber = -1
    let g:currentrepltype = repl#REPLGetShortName()
    if repl#REPLWin32Return()
        let g:term_send_task_codes = ['LABEL Start', 'sleep 10', 'wait repl#CheckInputState()', 'call term_sendkeys("' . repl#GetConsoleName() . '", g:repl_tasks[g:taskprocess] . "\r\n")', 'let g:taskprocess = g:taskprocess + 1', 'if g:taskprocess == len(g:repl_tasks)', 'unlet g:repl_tasks', 'return', 'endif', 'GOTO Start']
    else
        let g:term_send_task_codes = ['LABEL Start', 'sleep 10', 'wait repl#CheckInputState()', 'call term_sendkeys("' . repl#GetConsoleName() . '", g:repl_tasks[g:taskprocess] . "\n")', 'let g:taskprocess = g:taskprocess + 1', 'if g:taskprocess == len(g:repl_tasks)', 'unlet g:repl_tasks','return', 'endif', 'GOTO Start']
    endif
    if exists("g:repl_output_copy_to_register") && repl#REPLGetShortName() ==# "ipython"
        let g:term_send_task_codes = g:term_send_task_codes[:-4] + ["sleep 300", "wait repl#CheckInputState()", "call repl#GetTerminalLastOutput('" . g:repl_output_copy_to_register . "')"] + g:term_send_task_codes[-3:]
    endif
    " echom g:term_send_task_codes
    call async#AsyncCodeRun(g:term_send_task_codes, "term_send_task")
    " endif
endfunction

function! repl#WaitForSymbolsHandler(channel)
    let l:tl = repl#GetTerminalLine()
    if index(s:waitforsymbols, l:tl) == -1
        call repl#WAITFORSYMBOLS()
        return
    else
        return
    endif
endfunction

function! repl#WAITFORSYMBOLS() abort
    call job_start('sleep 0.03s', {'close_cb': 'repl#WaitForSymbolsHandler'})
endfunction

function! repl#WaitFor(symbols)
    let s:waitforsymbols = repl#AsList(a:symbols)
    call repl#WaitForSymbolsHandler(0)
endfunction

function! repl#SendChunkLines() range abort
    if g:repl_unhide_when_send_lines && repl#REPLIsHidden()
        call repl#REPLUnhide()
    endif
    if a:firstline == a:lastline
        let [l:line_start, l:column_start] = getpos("'<")[1:2]
        let [l:line_end, l:column_end] = getpos("'>")[1:2]
        let l:currentline = getline(a:firstline)
        if l:column_end - l:column_start + 1 >= len(l:currentline)
            call repl#SendLines(a:firstline, a:firstline)
        else
            let l:selected_content = l:currentline[l:column_start - 1 : l:column_end - 1]
            let l:selected_content = repl#Strip(l:selected_content)
            let l:repl_program = repl#REPLGetShortName()
            if has_key(g:repl_sendvariable_template, l:repl_program)
                let l:template = g:repl_sendvariable_template[l:repl_program]
                if repl#REPLWin32Return()
                    call term_sendkeys(repl#GetConsoleName(), substitute(l:template, '<input>', l:selected_content, '') . "\r\n")
                else
                    call term_sendkeys(repl#GetConsoleName(), substitute(l:template, '<input>', l:selected_content, '') . "\n")
                endif
            else
                if repl#REPLWin32Return()
                    call term_sendkeys(repl#GetConsoleName(), l:selected_content . "\r\n")
                else
                    call term_sendkeys(repl#GetConsoleName(), l:selected_content . "\n")
                endif
            endif
        endif
    else
        call repl#SendLines(a:firstline, a:lastline)
    endif
    if g:repl_cursor_down
        call cursor(a:lastline+1, 0)
    endif
endfunction

function! repl#SendLines(first, last) abort
	if bufexists(repl#GetConsoleName())
		let l:firstline = a:first
		while(l:firstline <= a:last && strlen(getline(l:firstline)) == 0)
			let l:firstline = l:firstline + 1
		endwhile
        let l:sn = repl#REPLGetShortName()
        if l:sn ==# 'ptpython'
            call repl#Sends(repl#ToREPLPythonCode(getline(l:firstline, a:last), 'ptpython'), ['\.\.\.', '>>>', 'ipdb>', 'pdb>'])
        elseif l:sn ==# 'ipython'
            call repl#Sends(repl#ToREPLPythonCode(getline(l:firstline, a:last), 'ipython'), ['\.\.\.', 'In'])
        elseif l:sn =~# 'python' || l:sn =~# 'python3'
            call repl#Sends(repl#ToREPLPythonCode(getline(l:firstline, a:last), 'python'), ['>>>', '...', 'ipdb>', 'pdb>'])
        elseif l:sn ==# 'vim'
            call repl#Sends(repl#ToVimScript(getline(l:firstline, a:last)), [':'])
        elseif has_key(g:repl_input_symbols, l:sn)
            call repl#Sends(add(getline(l:firstline, a:last), ''), g:repl_input_symbols[l:sn])
        else
            let l:fl = getline(l:firstline)
            let l:i = 0
            while(l:i < strlen(l:fl) && l:fl[l:i] ==# ' ')
                let l:i = l:i + 1
            endwhile
            for line in getline(l:firstline, a:last)
                let l:deletespaceline = line[l:i:]
                if repl#REPLWin32Return()
                    exe "call term_sendkeys('" . repl#GetConsoleName() . ''', l:deletespaceline . "\r\n")'
                else
                    exe "call term_sendkeys('" . repl#GetConsoleName() . ''', l:deletespaceline . "\n")'
                endif
                exe 'call term_wait("' . repl#GetConsoleName() . '", 50)'
            endfor
            if repl#REPLWin32Return()
                exe "call term_sendkeys('" . repl#GetConsoleName() . ''', "\r\n")'
            else
                exe "call term_sendkeys('" . repl#GetConsoleName() . ''', "\n")'
            endif
        endif
	endif
endfunction

function! repl#SendAll() abort
    call repl#SendLines(1, line('$'))
endfunction

function! repl#SendSession() abort
    if g:repl_unhide_when_send_lines && repl#REPLIsHidden()
        call repl#REPLUnhide()
    endif
    call cursor(0, col("$"))
    let g:repl_code_block_begin = get(g:repl_code_block_fences, &ft, '# %%')
    if exists("g:repl_code_block_fences_end") && has_key(g:repl_code_block_fences_end, &ft)
        let g:repl_code_block_end = g:repl_code_block_fences_end[&ft]
    else
        let g:repl_code_block_end = g:repl_code_block_begin
    endif
    let l:begin_line_number = search('^' . g:repl_code_block_begin, 'bnW')
    if l:begin_line_number == 0
        let l:begin_line_number = 1
    endif
    let l:end_line_number = search('^' . g:repl_code_block_end, 'nW')
    if l:end_line_number == 0
        let l:end_line_number = line("$")
    endif
    if l:begin_line_number == l:end_line_number
        echo "No more blocks below."
        return
    endif
    if g:repl_cursor_down
        call cursor(l:end_line_number+1, 0)
    endif
    if getline(l:begin_line_number) =~ '^' . g:repl_code_block_begin
        let l:begin_line_number += 1
    endif
    if getline(l:end_line_number) =~ '^' . g:repl_code_block_end
        let l:end_line_number -= 1
    endif
    if l:begin_line_number <= l:end_line_number
        call repl#SendLines(l:begin_line_number, l:end_line_number)
    endif
endfunction

function! repl#SendWholeBlock() abort
    let l:begin_line = getline('.')
    let l:begin_line_number = line('.')
    let l:begin_indent = repl#GetIndent(l:begin_line)
    let l:end_line_number = line('$')
    for i in range(line('.') + 1, line('$'))
        if repl#GetIndent(getline(i)) <= l:begin_indent
            if repl#GetIndent(getline(i)) == l:begin_indent && repl#StartWithAny(repl#LStrip(getline(i)), ['else:', 'elif ', 'except:', 'finally:', 'except '])
                continue
            end
            if i == l:begin_line_number + 1 && repl#StartWith(repl#LStrip(l:begin_line), "@") && repl#StartWithAny(repl#LStrip(getline(i)), ['def ', 'class '])
                continue
            endif
            let l:end_line_number = i - 1
            break
        endif
    endfor
    call repl#SendLines(l:begin_line_number, l:end_line_number)
    return l:end_line_number
endfunction

function! repl#SendCompleteLine() abort
    let l:begin_line = getline('.')
    let l:begin_line_number = line('.')
    let l:end_line_number = line('$')
    let l:codes = [getline('.')]
    for i in range(line('.') + 1, line('$'))
        let l:codes = l:codes + [getline(i)]
        if repl#IsCodeFinish(l:codes)
            let l:end_line_number = i
            break
        endif
        if i > line('.') + 100
            let l:end_line_number = l:begin_line_number
            break
        endif
    endfor
    call repl#SendLines(l:begin_line_number, l:end_line_number)
    return l:end_line_number
endfunction

function! repl#GetTerminalContent() abort
    return getbufline(repl#GetConsoleName(), max([1, line("$", bufwinid(repl#GetConsoleName())) - 300]), "$")
endfunction

function! repl#GetTerminalLastOutput(...) abort
    let l:terminal_content = repl#GetTerminalContent()
    try
        if has('python3')
python3 << EOF
import vim
# sys.path.append(vim.eval("g:REPLVIM_PATH") + "autoload/")
from replpython import GetLastOutput
terminal_content = vim.eval("l:terminal_content")
last_out = GetLastOutput(terminal_content, "ipython")
EOF
            if a:0 == 1
                try
                    execute "let @" . a:1 . " = '" . py3eval("last_out") . "'"
                catch /.*/
                    echom v:exception
                endtry
            endif
        elseif has('python')
python << EOF
import vim
# sys.path.append(vim.eval("g:REPLVIM_PATH") + "autoload/")
from replpython import GetLastOutput
terminal_content = vim.eval("l:terminal_content")
last_out = GetLastOutput(terminal_content, "ipython")
EOF
            if a:0 == 1
                try
                    execute "let @" . a:1 . " = '" . pyeval("last_out") . "'"
                catch /.*/
                    echom v:exception
                endtry
            endif
        endif
    catch /.*/
        echo 'Something went wrong, but I do not know what'
    endtry
endfunction

function! repl#REPLDebug() abort
    echo "VIM-REPL, last update: 2019.8.23"
    if  has('nvim')
        echoerr "this plugin dosen't work on neovim. Please use vim >= 8.1 instead."
    endif
    if has('win32')
        let l:os = 'Windows'
    else
        let l:os = substitute(system('uname'), "\n", "", "")
    endif
    echo 'Operation System: ' . l:os
    echo 'Support python3: ' . has('python3')
    echo 'Support python: ' . has('python')
    echo 'has +terminal: ' . has('terminal')
    echo 'has +timers: ' . has('timers')
    if ! has('python3') && ! has('python') && ! g:repl_vimscript_engine
        echoerr "g:repl_vimscript_engine should be set to 1 for vim not supported with python or python3"
        echoerr 'you should add `let g:repl_vimscript_engine = 1` to vimrc'
    endif
    if has('python3')
python3 << EOF
import sys
print(sys.version)
print(sys.path)
EOF
    elseif has('python')
python << EOF
import sys
print sys.version
print sys.path
EOF
    endif
    echo 'REPL program:'
    echo g:repl_program
    for l:file in keys(g:repl_program)
        let l:pros = g:repl_program[l:file]
        if type(l:pros) == 3
            for l:pro in l:pros
                if !executable(split(l:pro, ' ')[0])
                    echo split(l:pro, ' ')[0] . ' for ' . l:file . ' is not executable.'
                endif
            endfor
        elseif type(l:pros) == 1
            let l:pro = l:pros
            if !executable(split(l:pro, ' ')[0])
                echo split(l:pro, ' ')[0] . ' for ' . l:file . ' is not executable.'
            endif
        endif
    endfor
    unlet! t:REPL_OPEN_TERMINAL
    try
        let t:REPL_OPEN_TERMINAL = repl#REPLGetName()
    catch /Unexpected-input-received/
        echom "Unexpected input received, REPL Debug abort."
        return
    endtry
    if repl#REPLGetShortName() == 'ipython'
        if !exists("g:repl_ipython_version")
            let temp = system(t:REPL_OPEN_TERMINAL . ' --version')
            let g:repl_ipython_version = temp[0:2]
            echo "ipython version: " . temp
        endif
        echo "setted ipython version" . g:repl_ipython_version
        if g:repl_ipython_version == '7.0'
            echoerr "This plugin cannot work on ipython 7.01. Please use ipython >= 7.1.1"
        endif
    endif
    echo 'REPL exit commands:'
    echo g:repl_exit_commands
    echo 'Current File Type: ' . &filetype
    echo 'Current Type: ' . repl#REPLGetName()
    echo 'Current Exit Commands: ' . repl#REPLGetExitCommand()
endfunction
