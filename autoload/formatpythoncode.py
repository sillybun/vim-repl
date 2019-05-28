import sys
import os

currentpath = os.path.dirname(os.path.abspath(__file__))
sys.path.append(currentpath)
import afpython

class pythoncodes:
    def __init__(self, replprogram = "ipython"):
        self.rawcontents = list()
        self.replprogram = "ipython"

    def getcode(self, code):
        # 仅仅保留非空行
        self.rawcontents = [line for line in code if len(line.strip()) != 0]
        self.analysepythonindent()
        self.seperateintoblocks()
        self.trunctindent()

    def removecomments(self):
        temp = list()
        for i in range(len(self.rawcontents)):


    def getindentlevel(self, line):
        return len(line) - len(line.lstrip())

    def analysepythonindent(self):
        self.codeindent = list()
        for i in range(len(self.rawcontents)):
            indentlevel, finishflag, finishtype = afpython.getpythonindent(self.rawcontents[:(i+1)])
            self.codeindent.append((indentlevel, finishflag, finishtype))

    def isstartofline(self, index):
        if index == 0:
            return True
        else:
            return self.codeindent[index-1][1]

    def canbestartofblock(self, index):
        # 判断第index行有没有可能是一个block的开始
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
