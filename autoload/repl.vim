function! repl#AsList(value)
    if type(a:value) == type([])
        return a:value
    else
        return [a:value]
    end
endfunction

function! repl#REPLGetName()
    if exists("b:REPL_OPEN_TERMINAL")
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
    elseif l:temp =~ '.*python.*'
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
            call term_sendkeys('ZYTREPL', "\<C-W>\<C-C>")
            call repl#Sends(['quit()'], ['ipdb>', 'pdb>'])
        else
            exe "call term_sendkeys('" . 'ZYTREPL' . ''', "\<C-W>\<C-C>")'
            exe "call term_wait('" . 'ZYTREPL' . ''', 50)'
            if repl#REPLIsVisible()
                exe "call term_sendkeys('" . 'ZYTREPL' . "', \"\\<Cr>\")"
                exe "call term_wait('" . 'ZYTREPL' . ''', 50)'
                exe "call term_sendkeys('" . 'ZYTREPL' . "', \"\\<Cr>\")"
                exe "call term_wait('" . 'ZYTREPL' . ''', 50)'
                exe "call term_sendkeys('" . 'ZYTREPL' . ''', "' . repl#REPLGetExitCommand() . '\<Cr>")'
                exe "call term_wait('" . 'ZYTREPL' . ''', 50)'
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
		call repl#REPLGoToWindowForBufferName('ZYTREPL')
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
	exe 'autocmd bufenter * if (winnr("$") == 1 && (&buftype == ''terminal'') && bufexists(''ZYTREPL'')) | q! | endif'
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
    exe 'file ZYTREPL'
    exe 'setlocal noswapfile'
endfunction

function! repl#REPLIsHidden()
    if bufnr('ZYTREPL') == -1
        return 0
    elseif repl#REPLIsVisible() == 1
        return 0
    else
        return 1
    endif
endfunction

function! repl#REPLIsVisible()
	if bufwinnr(bufnr('ZYTREPL')) != -1
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
        if g:repl_stayatrepl_when_open == 0
            exe bufwinnr(g:repl_target_n) . 'wincmd w'
            if exists('g:repl_predefine_' . repl#REPLGetShortName())
                let l:command_dict = eval('g:repl_predefine_' . repl#REPLGetShortName())
                let l:precode = []
                for l:key in keys(l:command_dict)
                    if search(l:key) != 0
                        " call g:REPLSend(l:command_dict[l:key])
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
	if bufexists('ZYTREPL')
		exe "call term_sendkeys('" . 'ZYTREPL' . ''', getline(".") . "\<Cr>")'
		exe "call term_wait('" . 'ZYTREPL' . ''',  50)'
	endif
endfunction


function! repl#RemoveLeftSpace(lines)
python3 << EOF
import vim

codes = vim.eval("a:lines")
codes = [code.lstrip() for code in codes]
EOF
return py3eval("codes")
endfunction

function! repl#GetPythonCode(lines)
python3 << EOF
import vim

codes = vim.eval("a:lines")
firstline = ''
firstlineno = 0
for t in codes:
    if len(t) != 0:
        firstline = t
        break
    else:
        firstlineno += 1

def getindent(line):
    if line.strip() == '':
        return 10000
    else:
        return len(line) - len(line.lstrip())

def isnewline(line):
    return codes[i][0] != ' ' and not codes[i].strip() == "else:" and not codes[i].strip().startswith("elseif ") and not codes[i].strip().startswith("except ")

if firstline == '':
    newlines = []
else:
    indentfirst = len(firstline) - len(firstline.lstrip())
    newlines = []
    if indentfirst != 0 and all(getindent(code) >= indentfirst for code in codes):
        codes = [code[indentfirst:] if code.strip() != '' else '' for code in codes]
    for i in range(firstlineno, len(codes)):
        if len(codes[i].strip()) != 0:
            if isnewline(codes[i]):
                if i != 0 and codes[i-1].startswith(" "):
                    newlines.append("")
            newlines.append(codes[i])
        else:
            flag = False
            for j in range(i+1, len(codes)):
                if len(codes[j].strip()) == 0:
                    continue
                elif codes[j][0] == ' ':
                    flag = False
                    break
                else:
                    if isnewline(codes[j]):
                        flag = True
                    else:
                        flag = False
                    break
            if flag:
                newlines.append('')
EOF
return py3eval("newlines")
endfunction

function! repl#GetTerminalLine() abort
    let l:tl = term_getline('ZYTREPL', '.')
python3 << EOF
import vim
line = vim.eval('l:tl').rstrip()
EOF
return py3eval('line')
endfunction

function! repl#GetCurrentLineNumber() abort
    return term_getcursor('ZYTREPL')[0]
endfunction

function! repl#WaitHandlerNotCall(channel) abort
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
        call repl#WaitWHNotCall()
        return
    else
        call term_sendkeys('ZYTREPL', s:tasks[s:taskprocess] . "\<Cr>")
        let s:taskprocess = s:taskprocess + 1
        call repl#WaitWHNotCall()
        return
    endif
endfunction

function! repl#WaitWHNotCall() abort
    call job_start('sleep 0.03s', {'close_cb': 'repl#WaitHandlerNotCall'})
endfunction

function! repl#Sends(tasks, symbols)
    let s:tasks = a:tasks
    let s:waitforsymbols = repl#AsList(a:symbols)
    let s:taskprocess = 0
    let s:currentlinenumber = -1
    call repl#WaitHandlerNotCall(0)
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
endfunction

function! repl#SendLines(first, last) abort
	if bufexists('ZYTREPL')
		let l:firstline = a:first
		while(l:firstline <= a:last && strlen(getline(l:firstline)) == 0)
			let l:firstline = l:firstline + 1
		endwhile
        let l:sn = repl#REPLGetShortName()
        if l:sn ==# 'ptpython'
            call repl#Sends(repl#RemoveLeftSpace(add(repl#GetPythonCode(getline(l:firstline, a:last)), '')), ['>>>', '\.\.\.', 'ipdb>', 'pdb>'])
        elseif l:sn ==# 'ipython'
            call repl#Sends(repl#RemoveLeftSpace(add(repl#GetPythonCode(getline(l:firstline, a:last)), '')), ['\.\.\.', 'In'])
        elseif l:sn =~ 'python' || l:sn =~ 'python3'
            call repl#Sends(add(repl#GetPythonCode(getline(l:firstline, a:last)), ''), ['>>>', '...', 'ipdb>', 'pdb>'])
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
                exe "call term_sendkeys('" . 'ZYTREPL' . ''', l:deletespaceline . "\<Cr>")'
                exe 'call term_wait("ZYTREPL", 50)'
            endfor
            exe "call term_sendkeys('" . 'ZYTREPL' . ''', "\<Cr>")'
        endif
	endif
endfunction

function! repl#SendAll() abort
    call repl#SendLines(1, line('$'))
endfunction

function! repl#REPLDebug() abort
    echo "REPL program"
    echo g:repl_program
    echo "REPL exit commands"
    echo g:repl_exit_commands
    echo "Current File Type:"
    echo &filetype
    echo "Current Type:"
    echo repl#REPLGetName()
    echo "Current Exit Commands"
    echo repl#REPLGetExitCommand()
endfunction
