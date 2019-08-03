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

function! repl#REPLGetCheckID(line) abort
    if repl#StartWith(a:line, '# '. g:repl_checkpoint_notation)
        if strlen(a:line) > strlen('# '. g:repl_checkpoint_notation .' ')
            let l:checkID = a:line[strlen('# '. g:repl_checkpoint_notation .' '):]
            if stridx(l:checkID, ' ') == -1
                return l:checkID
            endif
        endif
    endif
    return ''
endfunction

function! repl#RandomNumber() abort
python3 << EOF
import random
randomnumber = random.randint(100000, 10000000)
EOF
return py3eval('randomnumber')
endfunction

function! repl#REPLAddCheckPoint() abort
    let l:currentline = getline('.')
    if repl#StartWith(l:currentline, '# ' . g:repl_checkpoint_notation)
        if repl#REPLGetCheckID(l:currentline) !=# ''
            return
        endif
        let l:checkid = repl#RandomNumber()
        call setline('.', '# ' . g:repl_checkpoint_notation . ' ' . l:checkid)
    else
        let l:checkid = repl#RandomNumber()
        call append(line('.'), '# ' . g:repl_checkpoint_notation . ' ' . l:checkid)
    endif
endfunction

function! repl#REPLSaveCheckPoint() abort
    let l:currentline = getline('.')
    if repl#StartWith(l:currentline, '# ' . g:repl_checkpoint_notation)
        if repl#REPLGetCheckID(l:currentline) ==# ''
            call repl#REPLAddCheckPoint()
        endif
        let l:checkid = repl#REPLGetCheckID(getline('.'))
        if repl#REPLIsVisible()
            call term_sendkeys('ZYTREPL', '__import__("dill").dump_session("CHECKPOINT_' . l:checkid .  '.data")' . "\<Cr>")
            if matchstr(getline(line('.') + 1), '# \d\d\d\d-\d\d\?-\d\d?') !=# ''
                call setline(line('.') + 1, '# ' . strftime('%Y-%m-%d'))
            else
                call append(line('.'), '# '. strftime('%Y-%m-%d'))
            endif
        endif
    endif
endfunction

function! repl#REPLLoadCheckPoint() abort
    let l:currentline = getline('.')
    if repl#REPLGetCheckID(l:currentline) ==# ''
        return
    endif
    let l:checkid = repl#REPLGetCheckID(getline('.'))
    if repl#REPLIsVisible()
        call term_sendkeys('ZYTREPL', '__import__("dill").load_session("CHECKPOINT_' . l:checkid .  '.data")' . "\<Cr>")
    endif
endfunction

function! repl#SendCurrentLine() abort
	if bufexists('ZYTREPL')
        if repl#REPLGetShortName() =~# '.*python.*'
            if repl#StartWith(getline('.'), '# ' . g:repl_checkpoint_notation)
                if repl#REPLGetCheckID(getline('.')) !=# ''
                    call repl#REPLLoadCheckPoint()
                    return
                else
                    call repl#REPLSaveCheckPoint()
                    return
                endif
            elseif exists('g:repl_auto_sends') && repl#StartWithAny(trim(getline('.')), g:repl_auto_sends)
                call repl#SendWholeBlock()
                return
            endif
        endif
		exe "call term_sendkeys('" . 'ZYTREPL' . ''', getline(".") . "\<Cr>")'
		exe "call term_wait('" . 'ZYTREPL' . ''',  50)'
	endif
endfunction

function! repl#RemoveExtraEmptyLine(lines, repl_program)
python3 << EOF
import vim

def GetBlockType(codeblock):
    if not codeblock:
        return "EMPTY"
    elif codeblock[0].lstrip().startswith("if "):
        return "IF"
    elif codeblock[0].lstrip().startswith("for "):
        if codeblock[-1].strip().endswith("pass"):
            return "FOR-PASS"
        else:
            return "FOR"
    elif codeblock[0].lstrip().startswith("while "):
        return "WHILE"
    elif codeblock[0].lstrip().startswith("try "):
        return "TRY"
    elif codeblock[0].lstrip().startswith("def "):
        return "FUNCTION"
    elif codeblock[0].lstrip().startswith("class "):
        return "FUNCTION"
    elif codeblock[0].lstrip().startswith("with "):
        return "WITH"
    else:
        return "UNK"

codes = vim.eval("a:lines")
repl_program = vim.eval("a:repl_program")

codes_splited = []
temp_codes_block = []

for i in range(len(codes)):
    if codes[i] == '':
        if temp_codes_block:
            codes_splited.append(temp_codes_block)
            temp_codes_block = []
        else:
            continue
    elif codes[i][0] != " " and GetBlockType([codes[i]]) != "UNK" and temp_codes_block:
        codes_splited.append(temp_codes_block)
        temp_codes_block = [codes[i]]
    else:
        temp_codes_block.append(codes[i])

if temp_codes_block:
    codes_splited.append(temp_codes_block)


def GetBlockSpace(codeblock):
    if repl_program == "ptpython":
        bt = GetBlockType(codeblock)
        if bt == "EMPTY":
            return 0
        elif bt == "IF":
            return 1
        elif bt == "FOR":
            return 1
        elif bt == "FOR-PASS":
            return 1
        elif bt == "WHILE":
            return 1
        elif bt == "TRY":
            return 1
        elif bt == "FUNCTION":
            return 2
        elif bt == "CLASS":
            return 1
        elif bt == "WITH":
            return 1
        else:
            return 0
    elif repl_program == "ipython":
        bt = GetBlockType(codeblock)
        if bt == "EMPTY":
            return 0
        elif bt == "IF":
            return 1
        elif bt == "FOR":
            return 1
        elif bt == "FOR-PASS":
            return 2
        elif bt == "WHILE":
            return 1
        elif bt == "TRY":
            return 1
        elif bt == "FUNCTION":
            return 2
        elif bt == "CLASS":
            return 1
        elif bt == "WITH":
            return 1
        else:
            return 0
    else:
        if GetBlockType(codeblock) == "UNK":
            return 0
        else:
            return 1

final_codes = []

for code_block in codes_splited:
    final_codes += code_block
    for i in range(GetBlockSpace(code_block)):
        final_codes.append("")

# print(final_codes)
EOF
return py3eval("final_codes")
endfunction

function! repl#RemoveLeftSpace(lines, repl_program)
python3 << EOF
import vim
import sys

sys.path.append(vim.eval("g:REPLVIM_PATH") + "autoload/")

try:
    import afpython
except Exception:
    import replpython as afpython


def getindent(line):
    if line.strip() == '':
        return 10000
    else:
        return len(line) - len(line.lstrip())

def AutoStop(line):
    line = line.lstrip()
    if vim.eval("a:repl_program") == "ptpython":
        if line.startswith("pass"):
            return True
        else:
            return False
    elif vim.eval("a:repl_program") == "ipython":
        if line.startswith("pass") or line.startswith("return") or line.startswith("raise") or line.startswith("continue") or line.startswith("break"):
            return True
        else:
            return False
    else:
        return False


codes = vim.eval("a:lines")
oldcode = vim.eval("a:lines")


if vim.eval("a:repl_program") == "ptpython" or vim.eval("a:repl_program") == "ipython":
    for i in range(1, len(codes)):
        lastcode = oldcode[i-1]
        code = oldcode[i]
        indentlevel, finishflag, finishtype = afpython.getpythonindent(oldcode[:(i+1)])
        oldindentlevel, oldfinishflag, oldfinishtype = afpython.getpythonindent(oldcode[:i])
        if not oldfinishflag:
            if i == 1:
                continue
            old2indentlevel, old2finishflag, old2finishtype = afpython.getpythonindent(oldcode[:(i-1)])
            if old2finishflag == True and old2indentlevel > oldindentlevel:
                codes[i] = ''.join(["\b"] * ((old2indentlevel - oldindentlevel) * 4 - 4 * AutoStop(oldcode[i-2]))) + code.lstrip()
            continue
        elif lastcode != '' and code != '':
            # Avoid the situation
            # if True:
            #     f(1,               ---- i-2
            #         2)             ---- i-1
            #     g()                ---- i
            # But need to conside:
            # if True:
            #     f(1,
            #         2)
            # else:
            #     print(1)
            sourceindex = i - 1
            while sourceindex >= 1:
                if afpython.getpythonindent(oldcode[:sourceindex])[1] == False:
                    sourceindex = sourceindex - 1
                else:
                    break
            sourceindentlevel, sourcefinishflag, sourcefinishtype = afpython.getpythonindent(oldcode[:(sourceindex + 1)])
            if sourceindentlevel == indentlevel + 1 and not AutoStop(oldcode[i-1]):
                codes[i] = ''.join(["\b"] * 4) + code.lstrip()
            elif sourceindentlevel > indentlevel + 1:
                codes[i] = ''.join(["\b"] * ((sourceindentlevel - indentlevel) * 4 - 4 * AutoStop(oldcode[i-1]))) + code.lstrip()

codes = [code.lstrip() for code in codes]
EOF
" echom string(py3eval('codes'))
return py3eval('codes')
endfunction

function! repl#RemovePythonComments(codes)
python3 << EOF
import vim

import sys

sys.path.append(vim.eval("g:REPLVIM_PATH") + "autoload/")
try:
    import afpython
except Exception:
    import replpython as afpython

codes = vim.eval("a:codes")
newcodes = []

for i in range(len(codes)):
    if codes[i].lstrip().startswith("#"):
        indentlevel, finishflag, finishtype = afpython.getpythonindent(codes[:(i+1)])
        if finishflag:
            continue
    newcodes.append(codes[i])
EOF
return py3eval('newcodes')
endfunction

function! repl#ToREPLPythonCode(lines, pythonprogram)
python3 << EOF
sys.path.append(vim.eval("g:REPLVIM_PATH") + "autoload/")
import formatpythoncode
codes = vim.eval("a:lines")
pythonprogram = vim.eval("a:pythonprogram")

newcodes = formatpythoncode.format_to_repl(codes, pythonprogram)
EOF
return py3eval('newcodes')
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
    return line.strip() != "" and line[0] != ' ' and not line.strip() == "else:" and not line.strip().startswith("elseif ") and not line.strip().startswith("except ")

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
                    newlines.append("")
                    temp = i - 1
                    temp_last = i - 1
                    while temp_last >= 0:
                        if len(codes[temp_last].strip()) > 0:
                            break
                        temp_last = temp_last - 1
                    while temp >= 0:
                        if len(codes[temp]) > 0 and codes[temp][0] != ' ':
                            break
                        temp = temp - 1
                    if codes[temp].startswith("def "):
                        newlines.append("")
                        #if codes[temp].startswith("for ") and codes[temp_last].endswith("pass"):
                        #newlines.append("")
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
                temp = i - 1
                temp_last = i - 1
                while temp_last >= 0:
                    if len(codes[temp_last].strip()) > 0:
                        break
                    temp_last = temp_last - 1
                while temp >= 0:
                    if len(codes[temp]) > 0 and codes[temp][0] != ' ':
                        break
                    temp = temp - 1
                if codes[temp].startswith("def "):
                    newlines.append("")
                #if codes[temp].startswith("for ") and codes[temp_last].endswith("pass"):
                    #newlines.append("")
                newlines.append('')
                newlines.append('')
# print(newlines)
EOF
return py3eval('newlines')
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
        let g:term_send_task_codes = ['LABEL Start', 'wait repl#CheckInputState()', 'call term_sendkeys("ZYTREPL", g:tasks[g:taskprocess] . "\<Cr>")', 'let g:taskprocess = g:taskprocess + 1', 'if g:taskprocess == len(g:tasks)', 'return', 'endif', 'GOTO Start']
        " let g:term_send_task_index = 0
        " call job_start("echo 'g:term_send_task'", {'close_cb': 'AsyncFuncRun'})
        call AsyncCodeRun(g:term_send_task_codes, "term_send_task")
        " call repl#WaitHandlerNotCall(0)
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
	if bufexists('ZYTREPL')
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
            " call repl#Sends(repl#RemoveExtraEmptyLine(repl#GetPythonCode(getline(l:firstline, a:last)), 'python'), ['>>>', '...', 'ipdb>', 'pdb>'])
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
    echo 'REPL program'
    echo g:repl_program
    echo 'REPL exit commands'
    echo g:repl_exit_commands
    echo 'Current File Type:'
    echo &filetype
    echo 'Current Type:'
    echo repl#REPLGetName()
    echo 'Current Exit Commands'
    echo repl#REPLGetExitCommand()
    if has('win32') || !exists('g:has_async_engine')
        echo 'Use Build-in Async Engine'
    else
        echo 'Use Vim-Async Engine'
    endif
endfunction
