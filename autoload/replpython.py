class PlainData:
    def __init__(self):
        self.tokentype = -1
        self.rownumber = -1

class PlainStack:
    def __init__(self):
        self.size = 0
        self.content = list()

    def top(self):
        if self.size == 0:
            raise ValueError("empty")
        else:
            return self.content[self.size - 1]

    def pop(self):
        if self.size == 0:
            raise ValueError("empty")
        else:
            self.size -= 1

    def push(self, tokentype, rownumber):
        data = PlainData()
        data.tokentype = tokentype
        data.rownumber = rownumber
        if len(self.content) > self.size:
            self.content[self.size] = data
            self.size += 1
        else:
            self.content.append(data)
            self.size += 1

    def clear(self):
        self.size = 0


def indentofline(line):
    index = 0
    while index < len(line) and line[index] == ' ':
        index += 1
    return index

class UnfinishType:
    LEFT_PARAENTHESE = 1 # (
    LEFT_BRACE = 2 # {
    LEFT_BRACKET = 3 # [
    DOUBLEQUOTE = 4 # "
    SINGLEQUOTE = 5 # '
    LONGSTRING = 11 # '''
    COMMENT = 6 # """
    TYPEHINT = 7 # def f(a: int)
    TYPEALPHA = 10
    DEFAULTVALUE = 8 # def f(a=1)
    DICTVALUE = 9 # {1:2}

# @jit(nopython=True, cache=True)
def getpythonindent(codes):
    # conditionstack = Stack()
    if len(codes) == 0:
        return (0, True, -1)

    conditionstack = PlainStack()
    operator = ['+', '-', '*', '/', '&', '^', '%', '<', '>', '|', '!', ':', '=', ',']
    characterinname = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', ' q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C',
                       'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '_', '.']

    LEFT_PARAENTHESE = 1 # (
    LEFT_BRACE = 2 # {
    LEFT_BRACKET = 3 # [
    DOUBLEQUOTE = 4 # "
    SINGLEQUOTE = 5 # '
    LONGSTRING = 11 # '''
    COMMENT = 6 # """
    TYPEHINT = 7 # def f(a: int)
    TYPEALPHA = 10
    DEFAULTVALUE = 8 # def f(a=1)
    DICTVALUE = 9 # {1:2}
    for rownumber in range(len(codes)):
        line = codes[rownumber]
        # flag = True
        col = 0
        # for col in range(len(line)):
        while col < len(line):
            character = line[col]
            col += 1
            if character == ' ':
                continue
            elif character == '\t':
                continue
            elif character in characterinname:
                continue
            elif character in operator:
                continue
            if conditionstack.size == 0:
                if character == '@':
                    continue
                elif character == '#':
                    break
                elif character == '(':
                    conditionstack.push(LEFT_PARAENTHESE, rownumber)
                    continue
                elif character == '[':
                    conditionstack.push(LEFT_BRACKET, rownumber)
                    continue
                elif character == '{':
                    conditionstack.push(LEFT_BRACE, rownumber)
                    continue
                elif character == '"':
                    if col + 1 < len(line) and line[col:col + 2] == '""':
                        col += 2
                        conditionstack.push(COMMENT, rownumber)
                    else:
                        conditionstack.push(DOUBLEQUOTE, rownumber)
                    continue
                elif character == "'":
                    conditionstack.push(SINGLEQUOTE, rownumber)
                    continue
                else:
                    # print("############################")
                    # print("Error found: {}".format(line))
                    # print("############################")
                    continue
            elif conditionstack.top().tokentype == LEFT_PARAENTHESE:
                if character == '(':
                    conditionstack.push(LEFT_PARAENTHESE, rownumber)
                    continue
                elif character == '[':
                    conditionstack.push(LEFT_BRACKET, rownumber)
                    continue
                elif character == '{':
                    conditionstack.push(LEFT_BRACE, rownumber)
                    continue
                elif character == ')':
                    conditionstack.pop()
                    continue
                elif character == '"':
                    if col + 1 < len(line) and line[col:col + 2] == '""':
                        col += 2
                        conditionstack.push(COMMENT, rownumber)
                    else:
                        conditionstack.push(DOUBLEQUOTE, rownumber)
                    continue
                elif character == "'":
                    conditionstack.push(SINGLEQUOTE, rownumber)
                    continue
                elif character == "#":
                    break
                else:
                    # print("############################")
                    # print("Error found: {}".format(line))
                    # print("############################")
                    continue
            elif conditionstack.top().tokentype == LEFT_BRACKET:
                if character == '(':
                    conditionstack.push(LEFT_PARAENTHESE, conditionstack.top().rownumber)
                    continue
                elif character == '[':
                    conditionstack.push(LEFT_BRACKET, conditionstack.top().rownumber)
                    continue
                elif character == '{':
                    conditionstack.push(LEFT_BRACE, conditionstack.top().rownumber)
                    continue
                elif character == ']':
                    conditionstack.pop()
                    continue
                elif character == '"':
                    if col + 1 < len(line) and line[col:col + 2] == '""':
                        col += 2
                        conditionstack.push(COMMENT, conditionstack.top().rownumber)
                    else:
                        conditionstack.push(DOUBLEQUOTE, conditionstack.top().rownumber)
                    continue
                elif character == "'":
                    conditionstack.push(SINGLEQUOTE, conditionstack.top().rownumber)
                    continue
                elif character == "#":
                    break
                else:
                    # print("############################")
                    # print("Error found: {}".format(line))
                    # print("############################")
                    continue
            elif conditionstack.top().tokentype == LEFT_BRACE:
                if character == '(':
                    conditionstack.push(LEFT_PARAENTHESE, conditionstack.top().rownumber)
                    continue
                elif character == '[':
                    conditionstack.push(LEFT_BRACKET, conditionstack.top().rownumber)
                    continue
                elif character == '{':
                    conditionstack.push(LEFT_BRACE, conditionstack.top().rownumber)
                    continue
                elif character == '}':
                    conditionstack.pop()
                    continue
                elif character == '"':
                    if col + 1 < len(line) and line[col:col + 2] == '""':
                        col += 2
                        conditionstack.push(COMMENT, conditionstack.top().rownumber)
                    else:
                        conditionstack.push(DOUBLEQUOTE, conditionstack.top().rownumber)
                    continue
                elif character == "'":
                    if col + 1 < len(line) and line[col: col + 2] == "''":
                        col += 2
                        conditionstack.push(LONGSTRING, conditionstack.top().rownumber)
                    else:
                        conditionstack.push(SINGLEQUOTE, conditionstack.top().rownumber)
                    continue
                elif character == "#":
                    break
                else:
                    # print("############################")
                    # print("Error found: {}".format(line))
                    # print("############################")
                    continue
            elif conditionstack.top().tokentype == DOUBLEQUOTE:
                if character == '\\':
                    col += 1
                    continue
                elif character == '"':
                    conditionstack.pop()
                    continue
                else:
                    continue
            elif conditionstack.top().tokentype == SINGLEQUOTE:
                if character== '\\':
                    col += 1
                    continue
                elif character == '\'':
                    conditionstack.pop()
                    continue
                else:
                    continue
            elif conditionstack.top().tokentype == COMMENT:
                if col + 1 < len(line) and line[col - 1:col + 2] == '"""':
                    conditionstack.pop()
                elif character == '\\':
                    col += 1
                continue
            elif conditionstack.top().tokentype == LONGSTRING:
                if col + 1 < len(line) and line[col - 1:col + 2] == "'''":
                    conditionstack.pop()
                elif character == '\\':
                    col += 1
                continue
        # if conditionstack.size != 0:
        #     if conditionstack.top().tokentype == DOUBLEQUOTE or conditionstack.top().tokentype == SINGLEQUOTE:
        #         conditionstack.clear()
        #         break
    indentlevel = 0
    if conditionstack.size != 0:
        lastrow = codes[conditionstack.top().rownumber]
        indentlevel = indentofline(lastrow)
        finishflag = False
        unfinishedtype = conditionstack.top().tokentype
    else:
        lastrownumber = len(codes) - 1
        while lastrownumber >= 0 and len(codes[lastrownumber]) == 0:
            lastrownumber -= 1
        lastrow = codes[lastrownumber]
        indentlevel = indentofline(lastrow)
        finishflag = True
        unfinishedtype = -1
    return (indentlevel, finishflag, unfinishedtype)


def getpythonindent_multiline(codes):
    if len(codes) == 0:
        return [(0, True, -1)]

    multi_indent = list()
    conditionstack = PlainStack()
    operator = ['+', '-', '*', '/', '&', '^', '%', '<', '>', '|', '!', ':', '=', ',']
    characterinname = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', ' q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C',
                       'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '_', '.']

    LEFT_PARAENTHESE = 1 # (
    LEFT_BRACE = 2 # {
    LEFT_BRACKET = 3 # [
    DOUBLEQUOTE = 4 # "
    SINGLEQUOTE = 5 # '
    LONGSTRING = 11 # '''
    COMMENT = 6 # """
    TYPEHINT = 7 # def f(a: int)
    TYPEALPHA = 10
    DEFAULTVALUE = 8 # def f(a=1)
    DICTVALUE = 9 # {1:2}
    for rownumber in range(len(codes)):
        line = codes[rownumber]
        # flag = True
        col = 0
        # for col in range(len(line)):
        while col < len(line):
            character = line[col]
            col += 1
            if character == ' ':
                continue
            elif character == '\t':
                continue
            elif character in characterinname:
                continue
            elif character in operator:
                continue
            if conditionstack.size == 0:
                if character == '@':
                    continue
                elif character == '#':
                    break
                elif character == '(':
                    conditionstack.push(LEFT_PARAENTHESE, rownumber)
                    continue
                elif character == '[':
                    conditionstack.push(LEFT_BRACKET, rownumber)
                    continue
                elif character == '{':
                    conditionstack.push(LEFT_BRACE, rownumber)
                    continue
                elif character == '"':
                    if col + 1 < len(line) and line[col:col + 2] == '""':
                        col += 2
                        conditionstack.push(COMMENT, rownumber)
                    else:
                        conditionstack.push(DOUBLEQUOTE, rownumber)
                    continue
                elif character == "'":
                    conditionstack.push(SINGLEQUOTE, rownumber)
                    continue
                else:
                    # print("############################")
                    # print("Error found: {}".format(line))
                    # print("############################")
                    continue
            elif conditionstack.top().tokentype == LEFT_PARAENTHESE:
                if character == '(':
                    conditionstack.push(LEFT_PARAENTHESE, rownumber)
                    continue
                elif character == '[':
                    conditionstack.push(LEFT_BRACKET, rownumber)
                    continue
                elif character == '{':
                    conditionstack.push(LEFT_BRACE, rownumber)
                    continue
                elif character == ')':
                    conditionstack.pop()
                    continue
                elif character == '"':
                    if col + 1 < len(line) and line[col:col + 2] == '""':
                        col += 2
                        conditionstack.push(COMMENT, rownumber)
                    else:
                        conditionstack.push(DOUBLEQUOTE, rownumber)
                    continue
                elif character == "'":
                    conditionstack.push(SINGLEQUOTE, rownumber)
                    continue
                elif character == "#":
                    break
                else:
                    # print("############################")
                    # print("Error found: {}".format(line))
                    # print("############################")
                    continue
            elif conditionstack.top().tokentype == LEFT_BRACKET:
                if character == '(':
                    conditionstack.push(LEFT_PARAENTHESE, conditionstack.top().rownumber)
                    continue
                elif character == '[':
                    conditionstack.push(LEFT_BRACKET, conditionstack.top().rownumber)
                    continue
                elif character == '{':
                    conditionstack.push(LEFT_BRACE, conditionstack.top().rownumber)
                    continue
                elif character == ']':
                    conditionstack.pop()
                    continue
                elif character == '"':
                    if col + 1 < len(line) and line[col:col + 2] == '""':
                        col += 2
                        conditionstack.push(COMMENT, conditionstack.top().rownumber)
                    else:
                        conditionstack.push(DOUBLEQUOTE, conditionstack.top().rownumber)
                    continue
                elif character == "'":
                    conditionstack.push(SINGLEQUOTE, conditionstack.top().rownumber)
                    continue
                elif character == "#":
                    break
                else:
                    # print("############################")
                    # print("Error found: {}".format(line))
                    # print("############################")
                    continue
            elif conditionstack.top().tokentype == LEFT_BRACE:
                if character == '(':
                    conditionstack.push(LEFT_PARAENTHESE, conditionstack.top().rownumber)
                    continue
                elif character == '[':
                    conditionstack.push(LEFT_BRACKET, conditionstack.top().rownumber)
                    continue
                elif character == '{':
                    conditionstack.push(LEFT_BRACE, conditionstack.top().rownumber)
                    continue
                elif character == '}':
                    conditionstack.pop()
                    continue
                elif character == '"':
                    if col + 1 < len(line) and line[col:col + 2] == '""':
                        col += 2
                        conditionstack.push(COMMENT, conditionstack.top().rownumber)
                    else:
                        conditionstack.push(DOUBLEQUOTE, conditionstack.top().rownumber)
                    continue
                elif character == "'":
                    if col + 1 < len(line) and line[col: col + 2] == "''":
                        col += 2
                        conditionstack.push(LONGSTRING, conditionstack.top().rownumber)
                    else:
                        conditionstack.push(SINGLEQUOTE, conditionstack.top().rownumber)
                    continue
                elif character == "#":
                    break
                else:
                    # print("############################")
                    # print("Error found: {}".format(line))
                    # print("############################")
                    continue
            elif conditionstack.top().tokentype == DOUBLEQUOTE:
                if character == '\\':
                    col += 1
                    continue
                elif character == '"':
                    conditionstack.pop()
                    continue
                else:
                    continue
            elif conditionstack.top().tokentype == SINGLEQUOTE:
                if character== '\\':
                    col += 1
                    continue
                elif character == '\'':
                    conditionstack.pop()
                    continue
                else:
                    continue
            elif conditionstack.top().tokentype == COMMENT:
                if col + 1 < len(line) and line[col - 1:col + 2] == '"""':
                    conditionstack.pop()
                elif character == '\\':
                    col += 1
                continue
            elif conditionstack.top().tokentype == LONGSTRING:
                if col + 1 < len(line) and line[col - 1:col + 2] == "'''":
                    conditionstack.pop()
                elif character == '\\':
                    col += 1
                continue


        indentlevel = 0
        if conditionstack.size != 0:
            lastrow = codes[conditionstack.top().rownumber]
            indentlevel = indentofline(lastrow)
            finishflag = False
            unfinishedtype = conditionstack.top().tokentype
        else:
            lastrownumber = rownumber
            while lastrownumber >= 0 and len(codes[lastrownumber]) == 0:
                lastrownumber -= 1
            lastrow = codes[lastrownumber]
            indentlevel = indentofline(lastrow)
            finishflag = True
            unfinishedtype = -1
        multi_indent.append((indentlevel, finishflag, unfinishedtype))
    return multi_indent

def main():
    code = ["if a:", "    b = 1", "else:", "    b = 2"]
    print(getpythonindent_multiline(code))

if __name__ == "__main__":
    main()
