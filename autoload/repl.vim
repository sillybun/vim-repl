function! repl#AsList(value)
    if type(a:value) == type([])
        return a:value
    else
        return [a:value]
    end
endfunction

function! repl#RStrip(string)
    return substitute(a:string, '\s*$', '', '')
endfunction

function! repl#LStrip(string)
    return substitute(a:string, '^\s*', '', '')
endfunction

function! repl#GetIndent(string)
    if trim(a:string) ==# ''
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

function! repl#StartWithAny(string, substringlist)
    for l:substring in a:substringlist
        if repl#StartWith(a:string, l:substring)
            return 1
        endif
    endfor
    return 0
endfunction

function! repl#REPLGetName()
    if exists('b:REPL_OPEN_TERMINAL')
        return b:REPL_OPEN_TERMINAL
    elseif &buftype ==# 'terminal'
		return bufname('%')[1:]
	elseif has_key(g:repl_program, &filetype)
		return g:repl_program[&filetype]
	elseif has_key(g:repl_program, 'default')
		return g:repl_program['default']
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
    elseif l:temp =~# '.*python.*'
        return 'python'
    else
        return l:temp
    endif
endfunction

function! repl#REPLGetExitCommand()
	let l:name = repl#REPLGetShortName()
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
            call term_sendkeys(g:repl_console_name, "\<C-W>\<C-C>")
            call repl#Sends(['quit()'], ['ipdb>', 'pdb>'])
        else
            exe "call term_sendkeys('" . g:repl_console_name . ''', "\<C-W>\<C-C>")'
            exe "call term_wait('" . g:repl_console_name . ''', 50)'
            if repl#REPLIsVisible()
                exe "call term_sendkeys('" . g:repl_console_name . "', \"\\n\")"
                exe "call term_wait('" . g:repl_console_name . ''', 50)'
                exe "call term_sendkeys('" . g:repl_console_name . "', \"\\n\")"
                exe "call term_wait('" . g:repl_console_name . ''', 50)'
                exe "call term_sendkeys('" . g:repl_console_name . ''', "' . repl#REPLGetExitCommand() . '\n")'
                exe "call term_wait('" . g:repl_console_name . ''', 50)'
            endif
		endif
    elseif repl#REPLIsHidden()
        call repl#REPLUnhide()
        call repl#REPLClose()
        return
	endif
    exe bufwinnr(g:repl_target_n) . 'wincmd w'
    unlet b:REPL_OPEN_TERMINAL
endfunction

function! repl#REPLHide()
	if repl#REPLIsVisible()
		call repl#REPLGoToWindowForBufferName(g:repl_console_name)
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
        let b:REPL_OPEN_TERMINAL = repl#REPLGetName()
    else
        let b:REPL_OPEN_TERMINAL = join(a:000, ' ')
    endif
	exe 'autocmd bufenter * if (winnr("$") == 1 && (&buftype == ''terminal'') && bufexists(''' . g:repl_console_name . ''')) | q! | endif'
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
    exe 'file ' . g:repl_console_name
    exe 'setlocal noswapfile'
endfunction

function! repl#REPLIsHidden()
    if bufnr(g:repl_console_name) == -1
        return 0
    elseif repl#REPLIsVisible() == 1
        return 0
    else
        return 1
    endif
endfunction

function! repl#REPLIsVisible()
	if bufwinnr(bufnr(g:repl_console_name)) != -1
		return 1
	else
		return 0
	endif
endfunction

function! repl#REPLToggle(...)
	if repl#REPLIsVisible()
        let l:cursor_pos = getpos('.')
		call repl#REPLClose()
    elseif repl#REPLIsHidden()
        call repl#REPLUnhide()
    else
        let l:cursor_pos = getpos('.')
		let g:repl_target_n = bufnr('')
		let g:repl_target_f = @%
        call call(function('repl#REPLOpen'), a:000)
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
            call cursor(l:cursor_pos[1], l:cursor_pos[2])
        endif
	endif
endfunction

function! repl#SendCurrentLine() abort
	if bufexists(g:repl_console_name)
        let l:cursor_pos = getpos('.')
        if repl#REPLGetShortName() =~# '.*python.*'
            if exists('g:repl_auto_sends') && repl#StartWithAny(trim(getline('.')), g:repl_auto_sends)
                call repl#SendWholeBlock()
                return
            endif
        endif
		exe "call term_sendkeys('" . g:repl_console_name . ''', getline(".") . "\n")'
		exe "call term_wait('" . g:repl_console_name . ''',  50)'
        if g:repl_cursor_down
            call cursor(l:cursor_pos[1] + 1, l:cursor_pos[2])
        endif
	endif
endfunction

function! repl#ToREPLPythonCode(lines, pythonprogram)
    if exists('g:repl_ipython_version')
        let l:version = g:repl_ipython_version
    else
        let l:version = -1
    endif
    if !has('python3') && !has('python') || g:repl_vimscript_engine
        return a:lines
    elseif has('python3')
python3 << EOF
import vim
import sys
sys.path.append(vim.eval("g:REPLVIM_PATH") + "autoload/")
import formatpythoncode
codes = vim.eval("a:lines")
pythonprogram = vim.eval("a:pythonprogram")
mergeunfinishline = int(vim.eval("g:repl_python_automerge"))
version = vim.eval("l:version")
newcodes = formatpythoncode.format_to_repl(codes, pythonprogram, mergeunfinishline, version)
EOF
        return py3eval('newcodes')
    elseif has('python')
python << EOF
import vim
import sys
sys.path.append(vim.eval("g:REPLVIM_PATH") + "autoload/")
import formatpythoncode
codes = vim.eval("a:lines")
pythonprogram = vim.eval("a:pythonprogram")
mergeunfinishline = int(vim.eval("g:repl_python_automerge"))
version = vim.eval("l:version")
newcodes = formatpythoncode.format_to_repl(codes, pythonprogram, mergeunfinishline, version)
EOF
        return pyeval('newcodes')
    endif
endfunction

function! repl#GetTerminalLine() abort
    let l:tl = term_getline(g:repl_console_name, '.')
    return repl#RStrip(l:tl)
endfunction

function! repl#GetCurrentLineNumber() abort
    return term_getcursor(g:repl_console_name)[0]
endfunction

function! repl#CheckInputState()
    let l:tl = repl#GetTerminalLine()
    if g:currentrepltype ==# 'ipython' && g:taskprocess != 0 && g:tasks[g:taskprocess-1] ==# '' && g:tasks[g:taskprocess] !=# ''
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
    if len(a:tasks) == 0
        return
    end
    if has('win32') || !exists('g:has_async_engine')
        call replforwin32#Sends(a:tasks, a:symbols)
    else
        let g:tasks = a:tasks
        let g:waitforsymbols = repl#AsList(a:symbols)
        let g:taskprocess = 0
        let g:currentlinenumber = -1
        let g:currentrepltype = repl#REPLGetShortName()
        " echom len(g:tasks)
        let g:term_send_task_codes = ['LABEL Start', 'wait repl#CheckInputState()', 'call term_sendkeys("' . g:repl_console_name . '", g:tasks[g:taskprocess] . "\n")', 'let g:taskprocess = g:taskprocess + 1', 'if g:taskprocess == len(g:tasks)', 'return', 'endif', 'GOTO Start']
        call AsyncCodeRun(g:term_send_task_codes, "term_send_task")
    endif
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
    call repl#SendLines(a:firstline, a:lastline)
    if g:repl_cursor_down
        call cursor(a:lastline+1, 0)
    endif
endfunction

function! repl#SendLines(first, last) abort
	if bufexists(g:repl_console_name)
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
                exe "call term_sendkeys('" . g:repl_console_name . ''', l:deletespaceline . "\n")'
                exe 'call term_wait("' . g:repl_console_name . '", 50)'
            endfor
            exe "call term_sendkeys('" . g:repl_console_name . ''', "\n")'
        endif
	endif
endfunction

function! repl#SendAll() abort
    call repl#SendLines(1, line('$'))
endfunction

function! repl#SendSession() abort
    let l:begin_line_number = line('.')
    let l:end_line_number = line('.')
    for i in range(1, line('.'))
        if getline(i) == '# BEGIN'
            let l:begin_line_number = i
        endif
    endfor
    for i in range(line('.'), line('$'))
        if getline(i) == '# END'
            let l:end_line_number = i
            break
        endif
    endfor
    if l:begin_line_number + 1 < l:end_line_number
        call repl#SendLines(l:begin_line_number+1, l:end_line_number-1)
    endif
endfunction

function! repl#SendWholeBlock() abort
    let l:begin_line = getline('.')
    let l:begin_line_number = line('.')
    let l:begin_indent = repl#GetIndent(l:begin_line)
    let l:end_line_number = line('$')
    for i in range(line('.') + 1, line('$'))
        if repl#GetIndent(getline(i)) <= l:begin_indent
            if repl#GetIndent(getline(i)) == l:begin_indent && repl#StartWithAny(repl#LStrip(getline(i)), ['else:', 'elif '])
                continue
            end
            let l:end_line_number = i - 1
            break
        endif
    endfor
    call repl#SendLines(l:begin_line_number, l:end_line_number)
endfunction

function! repl#REPLDebug() abort
    let l:os = substitute(system('uname'), "\n", "", "")
    echo 'Operation System: ' . l:os
    echo 'Support python3: ' . has('python3')
    echo 'Support python: ' . has('python')
    if ! has('python3') && ! has('python') && ! g:repl_vimscript_engine
        echoerr "g:repl_vimscript_engine should be set to 1 for vim not supported with python or python3"
    endif
    if has('python3')
python3 << EOF
import sys
print(sys.version)
EOF
    elseif has('python')
python << EOF
import sys
print sys.version
EOF
    endif
    echo 'REPL program:'
    echo g:repl_program
    if g:repl_program['python'] == 'ipython'
        echo "ipython version: " . system('ipython --version')
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
    if has('win32') || !exists('g:has_async_engine')
        echo 'Use Build-in Async Engine'
    else
        echo 'Use Vim-Async Engine'
    endif
endfunction
