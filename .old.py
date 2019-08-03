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
