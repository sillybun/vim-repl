from typing import Dict, List, Set, Tuple

class AddBufferContent:

    def __init__(self):
        self.adddict: Dict[int, List[str]] = dict()
        self.removeset: Set[int] = set()
        self.insertdict: Dict[int, Dict[int, List[str]]] = dict()

    def addandwait(self, content: str, linenumber: int):
        if linenumber in self.adddict:
            self.adddict[linenumber].append(content)
        else:
            self.adddict[linenumber] = [content]

    def insertandwait(
        self, content: str, linenumber: int, column: int
    ) -> None:
        if linenumber in self.insertdict:
            if column in self.insertdict[linenumber]:
                self.insertdict[linenumber][column].append(content)
            else:
                self.insertdict[linenumber][column] = [content]
        else:
            self.insertdict[linenumber] = dict()
            self.insertdict[linenumber][column] = [content]

    def insert(self, buffer, content: str, linenumber: int, column: int) -> None:
        tline: str = buffer[linenumber - 1]
        buffer[linenumber - 1] = tline[0:column] + content + tline[column:]

    def removeandwait(self, linenumber: int):
        self.removeset.add(linenumber)

    def remove(self, buffer, linenumber: int):
        del buffer[linenumber - 1]

    def add(self, buffer, content: str, linenumber: int):
        buffer.append(content, linenumber)

    def conduct(self, buffer):
        alreadyadd = 0
        alreadyremove = 0
        for i in sorted(set(self.adddict.keys()).union(self.removeset).\
                 union(set(self.insertdict.keys()))):
            if i in self.removeset:
                self.remove(buffer, i + alreadyadd - alreadyremove)
                alreadyremove += 1
            elif i in self.insertdict:
                alreadyinsert = 0
                for j in sorted(self.insertdict[i].keys()):
                    for content in self.insertdict[i][j]:
                        self.insert(buffer, content, i + alreadyadd - alreadyremove, j + alreadyinsert)
                        alreadyinsert += len(content)
            if i in self.adddict:
                for content in self.adddict[i]:
                    self.add(buffer, content, i + alreadyadd - alreadyremove)
                    alreadyadd += 1
        self.removeset = set()
        self.adddict = dict()


def getcurrentindent(buffer, linenumber: int) -> Tuple[int, bool]:
    import afpython
    lines = [buffer[row] for row in range(linenumber)]
    return afpython.getpythonindent(lines)

    # start, peek = linenumber - 1, linenumber - 1
    # while peek >= 0:
    #     if buffer[peek] == "" or buffer[peek].strip() == "":
    #         peek -= 1
    #         continue
    #     elif buffer[peek].strip().startswith("def "):
    #         start = peek
    #     elif buffer[peek].strip().startswith("class "):
    #         start = peek
    #     elif buffer[peek].strip().startswith("while "):
    #         start = peek
    #     elif buffer[peek].strip().startswith("from "):
    #         start = peek
    #     elif buffer[peek].strip().startswith("import "):
    #         start = peek
    #     else:
    #         peek -= 1
    #         continue
    #     break
    # # print(start, linenumber)
    # conditionstake: List[Tuple[str, int]] = list()
    # tempcs = None
    # toplinenumber = linenumber
    # while(toplinenumber - 1 > 0 and buffer[toplinenumber - 2].endswith("\\")):
    #     toplinenumber -= 1
    # for row in range(start, linenumber):
    #     line = buffer[row].strip()
    #     col = 0
    #     # if __name__ == "__main__":
    #     #     print(line, row)
    #     # if len(conditionstake) != 0 and row == linenumber - 1:
    #     #     break
    #     if row == toplinenumber - 1 and len(conditionstake) > 0:
    #         tempcs = conditionstake[-1]
    #     while(col < len(line)):
    #         # if line[col] == ";" and len(conditionstake) != 0:
    #         #     if conditionstake[-1][0] != "'" and '"' not in conditionstake:
    #         #         conditionstake = list()
    #         # if line[col] == "=" and len(conditionstake) != 0:
    #         #     if conditionstake[-1][0] != "'" and\
    #         #         '"' not in conditionstake[-1] and\
    #         #             conditionstake[-1][0] != "(":
    #         #         conditionstake = list()
    #         # if line[col] == ":" and len(conditionstake) != 0:
    #         #     if conditionstake[-1][0] != "'" and\
    #         #         '"' not in conditionstake[-1] and\
    #         #         conditionstake[-1][0] != "{" and\
    #         #             conditionstake[-1][0] != "(":
    #         #         conditionstake = list()
    #         if len(conditionstake) == 0:
    #             if line[col] == "(":
    #                 conditionstake.append(("(", row))
    #             elif line[col] == "[":
    #                 conditionstake.append(("[", row))
    #             elif line[col] == "{":
    #                 conditionstake.append(("{", row))
    #             elif line[col] == '"':
    #                 if line[col:].startswith('"""'):
    #                     col += 2
    #                     conditionstake.append(('"""', row))
    #                 else:
    #                     conditionstake.append(('"', row))
    #             elif line[col] == "'":
    #                 conditionstake.append(("'", row))
    #             elif line[col] == "#":
    #                 break
    #             col += 1
    #         elif conditionstake[-1][0] == "(":
    #             if line[col] == "(":
    #                 conditionstake.append(("(", row))
    #             elif line[col] == "[":
    #                 conditionstake.append(("[", row))
    #             elif line[col] == "{":
    #                 conditionstake.append(("{", row))
    #             elif line[col] == '"':
    #                 conditionstake.append(('"', row))
    #             elif line[col] == "'":
    #                 conditionstake.append(("'", row))
    #             elif line[col] == ")":
    #                 conditionstake.pop()
    #             elif line[col] == "#":
    #                 break
    #             elif line[col] == ";":
    #                 conditionstake = list()
    #             elif line[col] == ":":
    #                 conditionstake.append(("type:", row))
    #             elif line[col] == "=":
    #                 conditionstake.append(("func=", row))
    #             elif line[col] == "]":
    #                 conditionstake = list()
    #             elif line[col] == "}":
    #                 conditionstake = list()
    #             col += 1
    #         elif conditionstake[-1][0] == "[":
    #             if line[col] == "(":
    #                 conditionstake.append(("(", row))
    #             elif line[col] == "[":
    #                 conditionstake.append(("[", row))
    #             elif line[col] == "{":
    #                 conditionstake.append(("{", row))
    #             elif line[col] == '"':
    #                 conditionstake.append(('"', row))
    #             elif line[col] == "'":
    #                 conditionstake.append(("'", row))
    #             elif line[col] == "]":
    #                 conditionstake.pop()
    #             elif line[col] == "#":
    #                 break
    #             elif line[col] == ";":
    #                 conditionstake = list()
    #             elif line[col] == "=":
    #                 conditionstake = list()
    #             elif line[col] == ")":
    #                 conditionstake = list()
    #             elif line[col] == "}":
    #                 conditionstake = list()
    #             col += 1
    #         elif conditionstake[-1][0] == "{":
    #             if line[col] == "(":
    #                 conditionstake.append(("(", row))
    #             elif line[col] == "[":
    #                 conditionstake.append(("[", row))
    #             elif line[col] == "{":
    #                 conditionstake.append(("{", row))
    #             elif line[col] == '"':
    #                 conditionstake.append(('"', row))
    #             elif line[col] == "'":
    #                 conditionstake.append(("'", row))
    #             elif line[col] == "}":
    #                 conditionstake.pop()
    #             elif line[col] == ")":
    #                 conditionstake = list()
    #             elif line[col] == "]":
    #                 conditionstake = list()
    #             elif line[col] == "#":
    #                 break
    #             elif line[col] == ";":
    #                 conditionstake = list()
    #             elif line[col] == ":":
    #                 conditionstake.append(("dict:", row))
    #             elif line[col] == "=":
    #                 conditionstake = list()
    #             col += 1
    #         elif conditionstake[-1][0] == "type:":
    #             if line[col] == "(":
    #                 conditionstake = list()
    #             elif line[col] == "[":
    #                 conditionstake = list()
    #             elif line[col] == "{":
    #                 conditionstake = list()
    #             elif line[col] == '"':
    #                 conditionstake = list()
    #             elif line[col] == "'":
    #                 conditionstake = list()
    #             elif line[col] == ",":
    #                 conditionstake = list()
    #             elif line[col] == ")":
    #                 conditionstake = list()
    #             elif line[col] == "]":
    #                 conditionstake = list()
    #             elif line[col] == "}":
    #                 conditionstake = list()
    #             elif line[col] == "=":
    #                 conditionstake = list()
    #                 continue
    #             elif line[col] == "#":
    #                 break
    #             elif line[col] == ";":
    #                 conditionstake = list()
    #             elif line[col].isalpha():
    #                 conditionstake.append(("type:alpha", row))
    #                 continue
    #             col += 1
    #         elif conditionstake[-1][0] == "type:alpha":
    #             if line[col] == "(":
    #                 conditionstake.append(("(", row))
    #             elif line[col] == "[":
    #                 conditionstake.append(("[", row))
    #             elif line[col] == "{":
    #                 conditionstake.append(("{", row))
    #             elif line[col] == '"':
    #                 conditionstake = list()
    #             elif line[col] == "'":
    #                 conditionstake = list()
    #             elif line[col] == ",":
    #                 conditionstake.pop()
    #             elif line[col] == " ":
    #                 conditionstake.pop()
    #             elif line[col] == "\\":
    #                 conditionstake.pop()
    #                 break
    #             elif line[col] == ")":
    #                 conditionstake = list()
    #             elif line[col] == "]":
    #                 conditionstake = list()
    #             elif line[col] == "}":
    #                 conditionstake = list()
    #             elif line[col] == "=":
    #                 conditionstake.pop()
    #                 continue
    #             elif line[col] == "#":
    #                 break
    #             elif line[col] == ";":
    #                 conditionstake = list()
    #             elif col == len(line) - 1:
    #                 conditionstake.pop()
    #             col += 1
    #         elif conditionstake[-1][0] == "func=":
    #             if line[col] == "(":
    #                 conditionstake.append(("(", row))
    #             elif line[col] == "[":
    #                 conditionstake.append(("[", row))
    #             elif line[col] == "{":
    #                 conditionstake.append(("{", row))
    #             elif line[col] == '"':
    #                 conditionstake.append(('"', row))
    #             elif line[col] == "'":
    #                 conditionstake.append(("'", row))
    #             elif line[col] == ",":
    #                 conditionstake.pop()
    #             elif line[col] == ")":
    #                 conditionstake.pop()
    #                 continue
    #             elif line[col] == "=":
    #                 conditionstake = list()
    #             elif line[col] == ":":
    #                 conditionstake = list()
    #             elif line[col] == "#":
    #                 break
    #             elif line[col] == ";":
    #                 conditionstake = list()
    #             col += 1
    #         elif conditionstake[-1][0] == "dict:":
    #             if line[col] == "(":
    #                 conditionstake.append(("(", row))
    #             elif line[col] == "[":
    #                 conditionstake.append(("[", row))
    #             elif line[col] == "{":
    #                 conditionstake.append(("{", row))
    #             elif line[col] == '"':
    #                 conditionstake.append(('"', row))
    #             elif line[col] == "'":
    #                 conditionstake.append(("'", row))
    #             elif line[col] == ",":
    #                 conditionstake.pop()
    #             elif line[col] == "=":
    #                 conditionstake = list()
    #             elif line[col] == "#":
    #                 break
    #             elif line[col] == ";":
    #                 conditionstake = list()
    #             col += 1
    #         elif conditionstake[-1][0] == "'":
    #             if line[col] == "\\":
    #                 col += 1
    #             elif line[col] == "'":
    #                 conditionstake.pop()
    #             col += 1
    #         elif conditionstake[-1][0] == '"':
    #             if line[col] == "\\":
    #                 col += 1
    #             elif line[col] == '"':
    #                 conditionstake.pop()
    #             col += 1
    #         elif conditionstake[-1][0] == '"""':
    #             if line[col:].startswith('"""'):
    #                 conditionstake.pop()
    #                 col += 3
    #             elif line[col] == "\\":
    #                 col += 2
    #             else:
    #                 col += 1
    #     # if __name__ == "__main__":
    #     #     print(conditionstake)
    # # print("Time consumed is:", time.time() - starttime)
    # # print(toplinenumber, linenumber)
    # if tempcs is None:
    #     line = buffer[toplinenumber - 1]
    #     extra = line.lstrip()
    #     indentlevel = (len(line) - len(extra)) // 4
    # else:
    #     line = buffer[tempcs[1]]
    #     extra = line.lstrip()
    #     indentlevel = (len(line) - len(extra)) // 4

    # if len(conditionstake) != 0 or\
    #         buffer[linenumber - 1].strip().endswith("\\"):
    #     finishflag = False
    # else:
    #     finishflag = True

    # return indentlevel, finishflag



def main():
    source = """1 + 2\
    3
""".split("\n")
    print(getcurrentindent(source, 2))

if __name__ == "__main__":
    main()
