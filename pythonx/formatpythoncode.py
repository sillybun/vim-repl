import sys
import os

# currentpath = os.path.dirname(os.path.abspath(__file__))
# sys.path = [currentpath] + sys.path

"""
sys.path.append("/Users/zhangyiteng/.vim/plugged/vim-repl/autoload")
"""

# try:
#     import afpython as replpython
# except Exception:
import replpython
from filemanager import path
import filemanager

THREE_DOUBLEQUOTE = '"' * 3
THREE_SINGLEQUOTE = '"' * 3

class UnfinishType:
    LEFT_PARAENTHESE = 1 # (
    LEFT_BRACE = 2 # {
    LEFT_BRACKET = 3 # [
    DOUBLEQUOTE = 4 # "
    SINGLEQUOTE = 5 # '
    LONGSTRING = 11 # '''
    RAWLONGSTRING = 12
    RAWCOMMENT = 13
    COMMENT = 6 # """
    TYPEHINT = 7 # def f(a: int)
    TYPEALPHA = 10
    DEFAULTVALUE = 8 # def f(a=1)
    DICTVALUE = 9 # {1:2}

class pythoncodes:
    def __init__(self, replprogram = "ipython", flag_mergefinishline = False, version="", filepath=""):
        self.rawcontents = list()
        self.replprogram = replprogram
        self.flag_mergefinishline = flag_mergefinishline
        self.version = version
        self.filepath = filepath
        self.blocks = list() # List[List[str], List[int]]

    def getcode(self, code):
        self.rawcontents = [line.replace("\t", "    ") for line in code if len(line.strip()) != 0]
        self.removecomments()
        if len(self.rawcontents) == 0:
            return self
        if self.flag_mergefinishline == 1 and len(self.rawcontents) > 1:
            self.mergeunfinishline()
        self.analysepythonindent()
        self.seperateintoblocks()
        self.trunctindent()
        self.expand_import_from_relative_path()
        return self

    def expand_import_from_relative_path(self):
        if self.filepath == "":
            return
        for index in range(len(self.blocks)):
            block = self.blocks[index]
            if len(block[0]) == 1 and (block[0][0].lstrip().startswith("import .") or block[0][0].lstrip().startswith("from .")):
                code = block[0][0]
                p = path(self.filepath)
                dot_number = len(code.split()[1]) - len(code.split()[1].lstrip("."))
                for _ in range(dot_number - 1):
                    p = p.parent()
                if "__init__.py" not in [t[-1] for t in p.ls()]:
                    temp = code[:code.index(".")] + code[code.index(".")+dot_number:]
                else:
                    extra = ""
                    while p and "__init__.py" in [t[-1] for t in p.ls()]:
                        extra = p.name + ("." if extra else "") + extra
                        p = p.parent
                    temp = code[:code.index(".")] + extra + ("." if not code[code.index(".") + dot_number:].startswith(" ") else "") + code[code.index(".") + dot_number:]
                self.blocks[index] = ([temp], self.blocks[index][1])

    def tructcomments(self, line):
        doublecomment = False
        singlecomment = False
        index = 0
        while index < len(line):
            if doublecomment:
                if line[index] == "\\":
                    index += 2
                    continue
                if line[index] == '"':
                    doublecomment = False
            elif singlecomment:
                if line[index] == "\\":
                    index += 2
                    continue
                if line[index] == "'":
                    singlecomment = False
            elif line[index] == '"':
                doublecomment = True
            elif line[index] == "'":
                singlecomment = True
            elif line[index] == "#":
                return line[:index].rstrip()
            index += 1
        return line

    def removecomments(self):
        newrawcontents = list()
        i = 0
        multi_indent = replpython.getpythonindent_multiline(self.rawcontents)
        while i < len(self.rawcontents):
            if i == 0:
                indentlevel, finishflag, unfinishtype = (0, False, -1)
            else:
                indentlevel, finishflag, unfinishtype = multi_indent[i - 1]
            if unfinishtype in {UnfinishType.DOUBLEQUOTE, UnfinishType.SINGLEQUOTE, UnfinishType.LONGSTRING, UnfinishType.COMMENT, UnfinishType.RAWCOMMENT, UnfinishType.RAWLONGSTRING}:
                newrawcontents.append(self.rawcontents[i])
                i += 1
                continue
            if self.rawcontents[i].strip().startswith("#"):
                i += 1
                continue
            if finishflag and self.rawcontents[i].strip().startswith(THREE_DOUBLEQUOTE):
                for j in range(i, len(self.rawcontents)):
                    j_indentlevel, j_finishflag, j_unfinishtype = replpython.getpythonindent(self.rawcontents[i:j+1])
                    if j_finishflag == True:
                        break
                i = j + 1
                continue
            newrawcontents.append(self.tructcomments(self.rawcontents[i]))
            i += 1
        self.rawcontents = newrawcontents

    def mergeunfinishline(self):
        tempcodeindent = replpython.getpythonindent_multiline(self.rawcontents)
        newrawcontents = list()
        i = 0
        while i < len(self.rawcontents):
            tempcodeline = ""
            j = i
            while j < len(self.rawcontents):
                tobeadded = self.rawcontents[j]
                Flag_NeedMerge = not tempcodeindent[j][1]
                if j != i and tempcodeindent[j-1][2] not in {UnfinishType.DOUBLEQUOTE, UnfinishType.SINGLEQUOTE, UnfinishType.LONGSTRING, UnfinishType.COMMENT, UnfinishType.RAWLONGSTRING}:
                    tobeadded = tobeadded.lstrip()
                if tempcodeindent[j][2] not in {UnfinishType.LONGSTRING, UnfinishType.COMMENT, UnfinishType.RAWCOMMENT, UnfinishType.RAWLONGSTRING}:
                    tobeadded = tobeadded.rstrip()
                if tempcodeindent[j][2] in {UnfinishType.LONGSTRING, UnfinishType.COMMENT}:
                    tobeadded = tobeadded + "\\n"
                    Flag_NeedMerge = True
                if tempcodeindent[j][2] in {UnfinishType.RAWCOMMENT}:
                    tobeadded = tobeadded + THREE_DOUBLEQUOTE + ' "\\n" ' + THREE_DOUBLEQUOTE
                    Flag_NeedMerge = True
                if tempcodeindent[j][2] in {UnfinishType.RAWLONGSTRING}:
                    tobeadded = tobeadded + THREE_SINGLEQUOTE + ' "\\n" ' + THREE_SINGLEQUOTE
                    Flag_NeedMerge = True
                if tempcodeindent[j][2] not in {UnfinishType.LONGSTRING, UnfinishType.COMMENT, UnfinishType.RAWCOMMENT, UnfinishType.RAWLONGSTRING} and self.rawcontents[j][-1] == "\\":
                    if tempcodeindent[j][2] not in {UnfinishType.DOUBLEQUOTE, UnfinishType.SINGLEQUOTE}:
                        tobeadded = tobeadded[:-1] + " "
                    else:
                        tobeadded = tobeadded[:-1]
                    Flag_NeedMerge = True
                tempcodeline += tobeadded
                if Flag_NeedMerge:
                    j = j + 1
                else:
                    break
            i = j + 1
            newrawcontents.append(tempcodeline)
        self.rawcontents = newrawcontents

        return self

    def getindentlevel(self, line):
        return len(line) - len(line.lstrip())

    def analysepythonindent(self):
        self.codeindent = replpython.getpythonindent_multiline(self.rawcontents)

    def isstartofline(self, index):
        if index == 0:
            return True
        else:
            return self.codeindent[index-1][1]

    def canbestartofblock(self, index):
        if not self.isstartofline(index):
            return False
        line = self.rawcontents[index].strip()
        if line.startswith("else:"):
            return False
        elif line.startswith("except "):
            return False
        elif line.startswith("except:"):
            return False
        elif line.startswith("elif "):
            return False
        else:
            return True

    def seperateintoblocks(self):
        index = 0
        self.blocks = list()
        while index < len(self.rawcontents):
            indentlevel = self.getindentlevel(self.rawcontents[index])
            blockend = next((i for i in range(index + 1, len(self.rawcontents))
                             if self.canbestartofblock(i) and self.getindentlevel(self.rawcontents[i]) <= indentlevel),
                             len(self.rawcontents))
            self.blocks.append((self.rawcontents[index:blockend], list(range(index, blockend))))
            index = blockend

    def trunctindent(self):
        for i in range(len(self.blocks)):
            indentlevel = self.getindentlevel(self.blocks[i][0][0])
            temp = list()
            for j in range(len(self.blocks[i][0])):
                if self.isstartofline(self.blocks[i][1][j]):
                    temp.append(self.blocks[i][0][j][indentlevel:])
                else:
                    temp.append(self.blocks[i][0][j])
            self.blocks[i] = (temp, self.blocks[i][1])

    def addbackspace(self):
        def AutoStop(line):
            line = line.lstrip()
            if self.replprogram == "ptpython":
                if line.startswith("pass "):
                    return True
                else:
                    return False
            elif self.replprogram == "ipython":
                if self.version[0] == "7" and self.version != "7.0":
                    return False
                if line.startswith("pass ") or line.startswith("return ") or line.startswith("raise ") or line.startswith("continue ") or line.startswith("break "):
                    return True
                else:
                    return False
            else:
                return False
        if self.replprogram == "ipython":
            for i in range(len(self.blocks)):
                temp = list()
                block = self.blocks[i][0]
                # print(block)
                lastline = 0
                lastback = 0
                for j in range(len(block)):
                    if j == 0:
                        currentindent = -1
                        temp.append(block[j].strip())
                        continue
                    elif self.isstartofline(self.blocks[i][1][j]):
                        lastline = j
                        p = j - 1
                        # while not self.isstartofline(self.blocks[i][1][p]) or not self.codeindent[self.blocks[i][1][p]][1]:
                        while not self.isstartofline(self.blocks[i][1][p]):
                            p -= 1
                        previousindent = self.codeindent[self.blocks[i][1][p]][0]
                        currentindent = self.codeindent[self.blocks[i][1][j]][0]
                        # print(j, previousindent, currentindent)
                        if previousindent > currentindent:
                            temp.append(''.join(["\b" * (previousindent - currentindent - 4 * AutoStop(block[p]))]) + block[j].strip())
                            lastback = previousindent - currentindent - 4 * AutoStop(block[p])
                        else:
                            temp.append(block[j].strip())
                            lastback = 0
                    else:
                        if self.codeindent[self.blocks[i][1][j-1]][2] in {UnfinishType.DOUBLEQUOTE, UnfinishType.SINGLEQUOTE, UnfinishType.LONGSTRING, UnfinishType.COMMENT}:
                            temp.append(block[j])
                        else:
                            if self.version == "6" and self.isstartofline(self.blocks[i][1][j - 1]):
                                temp.append(''.join(["\b" * lastback]) + block[j].strip())
                            else:
                                temp.append(block[j].strip())
                # print("temp", temp)

                if i == len(self.blocks) - 1 and self.codeindent[self.blocks[i][1][-1]][1] == False:
                    pass
                else:
                    if self.blocks[i][0][0].startswith('def '):
                        if currentindent - 4 * AutoStop(block[lastline]) == 0:
                            temp += ["", ""]
                        else:
                            temp += [""]
                    elif self.blocks[i][0][0].startswith('async def '):
                        if currentindent - 4 * AutoStop(block[lastline]) == 0:
                            temp += ["", ""]
                        else:
                            temp += [""]
                    elif self.blocks[i][0][0].startswith('class '):
                        if currentindent - 4 * AutoStop(block[lastline]) == 0:
                            temp += ["", ""]
                        else:
                            temp += [""]
                    elif self.blocks[i][0][0].startswith('for '):
                        if currentindent - 4 * AutoStop(block[lastline]) == 0:
                            temp += ["", ""]
                        else:
                            temp += [""]
                    elif self.blocks[i][0][0].startswith('while '):
                        if currentindent - 4 * AutoStop(block[lastline]) == 0:
                            temp += ["", ""]
                        else:
                            temp += [""]
                    elif self.blocks[i][0][0].startswith('try:'):
                        if currentindent - 4 * AutoStop(block[lastline]) == 0:
                            temp += ["", ""]
                        else:
                            temp += [""]
                    elif self.blocks[i][0][0].startswith('if '):
                        if currentindent - 4 * AutoStop(block[lastline]) == 0:
                            temp += ["", ""]
                        else:
                            temp += [""]
                    elif self.blocks[i][0][0].startswith('with '):
                        if currentindent - 4 * AutoStop(block[lastline]) == 0:
                            temp += ["", ""]
                        else:
                            temp += [""]
                # print(temp)
                self.blocks[i] = (temp, self.blocks[i][1])
        elif self.replprogram == "ptpython":
            for i in range(len(self.blocks)):
                temp = list()
                block = self.blocks[i][0]
                # print(block)
                lastline = 0
                for j in range(len(block)):
                    if j == 0:
                        currentindent = -1
                        temp.append(block[j].strip())
                        continue
                    elif self.isstartofline(self.blocks[i][1][j]):
                        lastline = j
                        p = j - 1
                        while not self.isstartofline(self.blocks[i][1][p]):
                            p -= 1
                        previousindent = self.codeindent[self.blocks[i][1][p]][0]
                        currentindent = self.codeindent[self.blocks[i][1][j]][0]
                        # print(j, previousindent, currentindent)
                        if previousindent > currentindent:
                            temp.append(''.join(["\b" * (previousindent - currentindent - 4 * AutoStop(block[p]))]) + block[j].strip())
                        else:
                            temp.append(block[j].strip())
                    else:
                        if self.codeindent[self.blocks[i][1][j-1]][2] in {UnfinishType.DOUBLEQUOTE, UnfinishType.SINGLEQUOTE, UnfinishType.LONGSTRING, UnfinishType.COMMENT}:
                            temp.append(block[j])
                        else:
                            temp.append(block[j].strip())
                if i == len(self.blocks) - 1 and self.codeindent[self.blocks[i][1][-1]][1] == False:
                    pass
                else:
                    if self.blocks[i][0][0].startswith('def '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('async def '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('class '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('for '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('while '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('try:'):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('if '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('with '):
                        temp += [""]
                # print(temp)

                self.blocks[i] = (temp, self.blocks[i][1])
        elif self.replprogram == "python":
            for i in range(len(self.blocks)):
                if i == len(self.blocks) - 1 and self.codeindent[self.blocks[i][1][-1]][1] == False:
                    continue
                temp = list()
                temp = self.blocks[i][0]
                if i == len(self.blocks) - 1 and self.codeindent[self.blocks[i][1][-1]][1] == False:
                    pass
                else:
                    if self.blocks[i][0][0].startswith('def '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('async def '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('class '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('for '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('while '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('try:'):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('if '):
                        temp += [""]
                    elif self.blocks[i][0][0].startswith('with '):
                        temp += [""]

                self.blocks[i] = (temp, self.blocks[i][1])

    def generatecodes(self):
        newcode = list()
        if len(self.rawcontents) == 0:
            return newcode
        self.addbackspace()
        for i in range(len(self.blocks)):
            newcode += self.blocks[i][0]
        return newcode

def format_to_repl(codes, pythonprogram = "ipython", mergeunfinishline=False, version="", filepath=""):
    pc = pythoncodes(replprogram=pythonprogram, flag_mergefinishline=mergeunfinishline, version=version, filepath=filepath)
    pc.getcode(codes)
    # print(pc.generatecodes())
    return pc.generatecodes()

class testreplpython:
    def __init__(self):
        self.pc = pythoncodes()
        self.pc_merge = pythoncodes(flag_mergefinishline = True)

    def test1(self):
        code = ["a = b + 1", "", "return"]
        self.pc.getcode(code)
        assert len(self.pc.blocks) == 2
        assert self.pc.rawcontents == ["a = b + 1", "return"]

    def test2(self):
        code = ["def f(a, b):", '    """', '    this is a test function',
                '    """', '    return a+b']
        self.pc.getcode(code)
        assert len(self.pc.blocks) == 1
        assert self.pc.rawcontents == ["def f(a, b):", "    return a+b"]

    def testcodeandnewcode(self, code, newcode):
        code = code.split("\n")[1:-1]
        newcode = newcode.split("\n")[1:-1]
        assert self.pc.getcode(code).rawcontents == newcode

    def testcodeandnewcode_merge(self, code, newcode):
        code = code.split("\n")[1:-1]
        newcode = newcode.split("\n")[1:-1]
        assert self.pc_merge.getcode(code).rawcontents == newcode

    def test3(self):
        code = """
def f(a, b):
    # this is a test of function
    c = a + b

    return c
        """
        newcode = """
def f(a, b):
    c = a + b
    return c
        """
        self.testcodeandnewcode(code, newcode)

    # def test4(self):
    #     code = """
# def f(a,
# # this is a test
# b
# ):
    # return a + b
    #     """


    #     newcode = """
# def f(a,
# b
# ):
    # return a + b
    #     """

    #     newcode_merge = """
# def f(a,b):
    # return a + b
    #     """

    #     self.testcodeandnewcode(code, newcode)
    #     self.testcodeandnewcode_merge(code, newcode_merge)

    def test4(self):
        code = ["if a:", "    b = 1", "else:", "    b = 2"]
        newcode = ["if a:", "b = 1", "\b\b\b\belse:", "b = 2", ""]
        assert format_to_repl(code) == newcode

    def test5(self):
        code = ["def f(a, b):", "    if a:", "        return", "    else:", "        b = 2"]
        newcode = ["def f(a, b):", "if a:", "return", "else:", "b = 2", ""]
        assert format_to_repl(code) == newcode

    def test6(self):
        code = ["if 'lon\\", "        g sentence':", "    print('hello')"]
        newcode = ["if 'lon\\", "        g sentence':", "print('hello')", ""]
        assert format_to_repl(code) == newcode

    def test7(self):
        code = ['def train(self):',
 '    if 1:',
 '        2',
 '    f(1,',
 '            2)',
 '    mean_acc = list()',
 '    return 1']
        newcode = ['def train(self):',
 'if 1:',
 '2',
 '\b\b\b\bf(1,',
 '\b\b\b\b2)',
 'mean_acc = list()',
 'return 1', '', '']
        assert format_to_repl(code) == newcode

    def test8(self):
        code = ["def f(a, b):", "    if a:", "        return", "    else:", "        b = 2"]
        newcode = ["def f(a, b):", "if a:", "return", "\b\b\b\belse:", "b = 2", ""]
        assert format_to_repl(code, pythonprogram="ptpython") == newcode

    def test9(self):
        code = ["def f(a, b):", "    if a:", "        return", "    else:", "        b = 2"]
        newcode = ["def f(a, b):", "if a:", "return", "\b\b\b\belse:", "b = 2", ""]
        assert format_to_repl(code, pythonprogram="ipython", version="7") == newcode

    def test(self):
        self.test1()
        self.test2()
        self.test3()
        self.test4()
        self.test5()
        self.test6()
        self.test7()
        self.test8()
        self.test9()
        print("All test unit are successfully passed!")

def test_speed():
    infile = open("./testspeedrawcode.txt", "r")
    code = infile.readlines()
    code = [line[:-1] for line in code]
    format_to_repl(code)

def main():
    test = testreplpython()
    test.test()

if __name__ == "__main__":
    main()
    # test_speed()
