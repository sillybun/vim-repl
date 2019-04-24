#include "Python.h"
#include "string.h"

#define LEFT_PARAENTHESE 1 // (
#define LEFT_BRACE 2 // {
#define LEFT_BRACKET 3 // [
#define DOUBLEQUOTE 4 // "
#define SINGLEQUOTE 5 // '
#define COMMENT 6 // """
#define TYPEHINT 7 // def f(a: int)
#define TYPEALPHA 10
#define DEFAULTVALUE 8 // def f(a=1)
#define DICTVALUE 9 // {1:2}

#define ALPHACASE case 'a':case 'b':case 'c':case 'd':case 'e':case 'f':case 'g':case 'h':case 'i':case 'j':case 'k':case 'l':case 'm':case 'n':case 'o':case 'p':case 'q':case 'r':case 's':case 't':case 'u':case 'v':case 'w':case 'x':case 'y':case 'z':case 'A':case 'B':case 'C':case 'D':case 'E':case 'F':case 'G':case 'H':case 'I':case 'J':case 'K':case 'L':case 'M':case 'N':case 'O':case 'P':case 'Q':case 'R':case 'S':case 'T':case 'U':case 'V':case 'W':case 'X':case 'Y':case 'Z'

#define NUMBERCASE case '0':case '1':case '2':case '3':case '4':case '5':case '6':case '7':case '8':case '9'

#define OPERATORCASE case '+':case '-':case '*':case '/':case '^':case '&':case '|':case '<':case '>':case '%'

class conditionstackclass
{
public:
    int type[1000];
    int rownumber[1000];
    int stacksize;
    conditionstackclass(): stacksize(0) {}
    void push(int _type, int _rownumber)
    {
        type[stacksize] = _type;
        rownumber[stacksize] = _rownumber;
        stacksize++;
    }
    int toptype()
    {
        return type[stacksize - 1];
    }
    void pop()
    {
        stacksize--;
    }
    void clear()
    {
        stacksize = 0;
    }
};

char lastchar(const char * s)
{
    for (int i = strlen(s) - 1; i >= 0; --i)
    {
        if (s[i] != ' ' && s[i] != '\t')
            return s[i];
    }
    return '\0';
}

const char * lstrip(const char * s)
{
    while (*s == ' ')
        s++;
    return s;
}

static PyObject * getpythonindent(PyObject * self, PyObject * args)
{
    conditionstackclass conditionstack;
    PyObject * object;
    if (!PyArg_ParseTuple(args, "O", &object))
        return NULL;
    long totallinenumber = PyList_Size(object);
    int lasttype = -1, lastrow = -1;
    int unfinishedtype = -1;
    int toplinenumber = totallinenumber;
    while (toplinenumber - 1 > 0)
    {
        PyObject* temp = PyList_GetItem(object, toplinenumber - 2);
        const char * line = PyUnicode_AsUTF8(temp);
        if (lastchar(line) == '\\')
        {
            toplinenumber--;
            continue;
        }
        break;
    }
    for (int row = 0; row < totallinenumber; ++row)
    {
        if (row == totallinenumber - 1 && conditionstack.stacksize != 0)
        {
            lasttype = conditionstack.type[conditionstack.stacksize - 1];
            switch(conditionstack.toptype()) {
                case TYPEHINT:
                case TYPEALPHA:
                case DICTVALUE:
                case DEFAULTVALUE:
                    lastrow = conditionstack.rownumber[conditionstack.stacksize - 2];
                    break;
                default:
                    lastrow = conditionstack.rownumber[conditionstack.stacksize - 1];
                    break;

            }
        }
        PyObject* temp = PyList_GetItem(object, row);
        const char * line = PyUnicode_AsUTF8(temp);
        int lengthofline = strlen(line);
        if (lengthofline == 0)
            continue;
        bool flag = true;
        for (int col = 0; col < lengthofline and flag; ++col)
        {
            if (conditionstack.stacksize == 0)
            {
                switch (line[col])
                {
                case '(':
                    conditionstack.push(LEFT_PARAENTHESE, row);
                    break;
                case '[':
                    conditionstack.push(LEFT_BRACKET, row);
                    break;
                case '{':
                    conditionstack.push(LEFT_BRACE, row);
                    break;
                case '"':
                    if (col + 2 < lengthofline && line[col + 1] == '"' && line[col + 2] == '"')
                    {
                        col += 2;
                        conditionstack.push(COMMENT, row);
                    }
                    else
                        conditionstack.push(DOUBLEQUOTE, row);
                    break;
                case '\'':
                    conditionstack.push(SINGLEQUOTE, row);
                    break;
                case '#':
                    flag = false;
                    break;
ALPHACASE:
OPERATORCASE:
                case '_':
                case '.':
                case ',':
NUMBERCASE:
                case ' ':
                case '\t':
                case '@':
                case '=':
                    break;
                default:
                    conditionstack.clear();
                    flag = false;
                    break;
                }

            }
            else if (conditionstack.toptype() == LEFT_PARAENTHESE)
            {
                switch (line[col])
                {
                case '(':
                    conditionstack.push(LEFT_PARAENTHESE, row);
                    break;
                case '[':
                    conditionstack.push(LEFT_BRACKET, row);
                    break;
                case '{':
                    conditionstack.push(LEFT_BRACE, row);
                    break;
                case ')':
                    conditionstack.pop();
                    break;
                case '"':
                    if (col + 2 < lengthofline && line[col + 1] == '"' && line[col + 2] == '"')
                    {
                        col += 2;
                        conditionstack.clear();
                        flag = false;
                    }
                    else
                        conditionstack.push(DOUBLEQUOTE, row);
                    break;
                case '\'':
                    conditionstack.push(SINGLEQUOTE, row);
                    break;
                case '#':
                    flag = false;
                    break;
                case ';':
                    conditionstack.clear();
                    break;
                case ':':
                    conditionstack.push(TYPEHINT, row);
                    break;
                case '=':
                    conditionstack.push(DEFAULTVALUE, row);
                    break;
ALPHACASE:
OPERATORCASE:
                case '_':
                case '.':
NUMBERCASE:
                case ',':
                case ' ':
                case '\t':
                    break;
                default:
                    conditionstack.clear();
                    flag = false;
                    break;
                }
            }
            else if (conditionstack.toptype() == LEFT_BRACKET)
            {
                switch (line[col])
                {
                case '(':
                    conditionstack.push(LEFT_PARAENTHESE, row);
                    break;
                case '[':
                    conditionstack.push(LEFT_BRACKET, row);
                    break;
                case '{':
                    conditionstack.push(LEFT_BRACE, row);
                    break;
                case ']':
                    conditionstack.pop();
                    break;
                case '"':
                    if (col + 2 < lengthofline && line[col + 1] == '"' && line[col + 2] == '"')
                    {
                        col += 2;
                        conditionstack.clear();
                        flag = false;
                    }
                    else
                        conditionstack.push(DOUBLEQUOTE, row);
                    break;
                case '\'':
                    conditionstack.push(SINGLEQUOTE, row);
                    break;
                case '#':
                    flag = false;
                    break;
                case '=':
                    if (col + 1 < lengthofline  && line[col + 1] == '=')
                    {
                        col += 1;
                    }
                    else
                    {
                        flag = false;
                        conditionstack.clear();
                    }
                    break;
ALPHACASE:
OPERATORCASE:
                case '_':
                case '.':
NUMBERCASE:
                case ',':
                case ' ':
                case '\t':
                case ':':
                    break;
                default:
                    conditionstack.clear();
                    flag = false;
                    break;
                }
            }
            else if (conditionstack.toptype() == LEFT_BRACE)
            {
                switch (line[col])
                {
                case '(':
                    conditionstack.push(LEFT_PARAENTHESE, row);
                    break;
                case '[':
                    conditionstack.push(LEFT_BRACKET, row);
                    break;
                case '{':
                    conditionstack.push(LEFT_BRACE, row);
                    break;
                case '}':
                    conditionstack.pop();
                    break;
                case '"':
                    if (col + 2 < lengthofline && line[col + 1] == '"' && line[col + 2] == '"')
                    {
                        col += 2;
                        conditionstack.clear();
                        flag = false;
                    }
                    else
                        conditionstack.push(DOUBLEQUOTE, row);
                    break;
                case '\'':
                    conditionstack.push(SINGLEQUOTE, row);
                    break;
                case '#':
                    flag = false;
                    break;
                case '=':
                    if (col + 1 < lengthofline  && line[col + 1] == '=')
                    {
                        col += 1;
                    }
                    else
                    {
                        flag = false;
                        conditionstack.clear();
                    }
                    break;
                case ':':
                    conditionstack.push(DICTVALUE, row);
                    break;
ALPHACASE:
OPERATORCASE:
                case '_':
                case '.':
NUMBERCASE:
                case ',':
                case ' ':
                case '\t':
                    break;
                default:
                    conditionstack.clear();
                    flag = false;
                    break;
                }
            }
            else if (conditionstack.toptype() == TYPEHINT)
            {
                switch (line[col])
                {
                case '#':
                    flag = false;
                    break;
ALPHACASE:
                case '_':
                    col--;
                    conditionstack.pop();
                    conditionstack.push(TYPEALPHA, row);
                    break;
                case ' ':
                case '\t':
                    break;
                default:
                    conditionstack.clear();
                    flag = false;
                    break;
                }
            }
            else if (conditionstack.toptype() == TYPEALPHA)
            {
                switch (line[col])
                {
                case '[':
                    conditionstack.push(LEFT_BRACKET, row);
                    break;
                case '#':
                    flag = false;
                    break;
                case ':':
                    conditionstack.push(TYPEHINT, row);
                    break;
                case '=':
                    conditionstack.pop();
                    col --;
                    break;
ALPHACASE:
                case '_':
                case '.':
NUMBERCASE:
                    break;
                case ',':
                case ' ':
                case '\t':
                    conditionstack.pop();
                    break;
                default:
                    conditionstack.clear();
                    flag = false;
                    break;
                }
            }
            else if (conditionstack.toptype() == DEFAULTVALUE)
            {
                switch (line[col])
                {
                case '(':
                    conditionstack.push(LEFT_PARAENTHESE, row);
                    break;
                case '[':
                    conditionstack.push(LEFT_BRACKET, row);
                    break;
                case '{':
                    conditionstack.push(LEFT_BRACE, row);
                    break;
                case '"':
                    if (col + 2 < lengthofline && line[col + 1] == '"' && line[col + 2] == '"')
                    {
                        flag = false;
                        conditionstack.pop();
                        break;
                    }
                    else
                        conditionstack.push(DOUBLEQUOTE, row);
                    break;
                case '\'':
                    conditionstack.push(SINGLEQUOTE, row);
                    break;
                case '#':
                    flag = false;
                    break;
                case ',':
                    conditionstack.pop();
                    break;
                case ')':
                    conditionstack.pop();
                    col --;
                    break;
                case '=':
                    if (col + 1 < lengthofline  && line[col + 1] == '=')
                    {
                        col += 1;
                    }
                    else
                    {
                        flag = false;
                        conditionstack.clear();
                    }
                    break;
ALPHACASE:
OPERATORCASE:
                case '_':
                case '.':
NUMBERCASE:
                case ' ':
                case '\t':
                    break;
                default:
                    conditionstack.clear();
                    flag = false;
                    break;
                }
            }
            else if (conditionstack.toptype() == DICTVALUE)
            {
                switch (line[col])
                {
                case '(':
                    conditionstack.push(LEFT_PARAENTHESE, row);
                    break;
                case '[':
                    conditionstack.push(LEFT_BRACKET, row);
                    break;
                case '{':
                    conditionstack.push(LEFT_BRACE, row);
                    break;
                case '"':
                    if (col + 2 < lengthofline && line[col + 1] == '"' && line[col + 2] == '"')
                    {
                        flag = false;
                        conditionstack.pop();
                        break;
                    }
                    else
                        conditionstack.push(DOUBLEQUOTE, row);
                    break;
                case '\'':
                    conditionstack.push(SINGLEQUOTE, row);
                    break;
                case '#':
                    flag = false;
                    break;
                case ',':
                    conditionstack.pop();
                    break;
                case '}':
                    conditionstack.pop();
                    col --;
                    break;
                case '=':
                    if (col + 1 < lengthofline  && line[col + 1] == '=')
                    {
                        col += 1;
                    }
                    else
                    {
                        flag = false;
                        conditionstack.clear();
                    }
                    break;
ALPHACASE:
OPERATORCASE:
                case '_':
                case '.':
NUMBERCASE:
                case ' ':
                case '\t':
                    break;
                default:
                    conditionstack.clear();
                    flag = false;
                    break;
                }
            }
            else if (conditionstack.toptype() == DOUBLEQUOTE)
            {
                if (line[col] == '\\')
                {
                    col ++;
                }
                else if (line[col] == '"')
                {
                    conditionstack.pop();
                }
            }
            else if (conditionstack.toptype() == SINGLEQUOTE)
            {
                if (line[col] == '\\')
                {
                    col ++;
                }
                else if (line[col] == '\'')
                {
                    conditionstack.pop();
                }
            }
            else if (conditionstack.toptype() == COMMENT)
            {
                if (col + 2 < lengthofline && line[col] == '"' && line[col + 1] == '"' && line[col + 2] == '"')
                {
                    conditionstack.pop();
                }
                else if (line[col] == '\\')
                {
                    col ++;
                }
            }
        }
        if(conditionstack.stacksize!=0)
        {
            switch(conditionstack.toptype()) {
                case DOUBLEQUOTE:
                case SINGLEQUOTE:
                    conditionstack.clear();
                    break;
                case TYPEALPHA:
                    conditionstack.pop();
                    break;
            }
        }
    }
    int indentlevel = 0;
    if (lasttype == -1)
    {
        PyObject* temp = PyList_GetItem(object, toplinenumber - 1);
        const char * line = PyUnicode_AsUTF8(temp);
        const char * extra = lstrip(line);
        indentlevel = (extra - line) / 4;
    }
    else
    {
        PyObject* temp = PyList_GetItem(object, lastrow);
        const char * line = PyUnicode_AsUTF8(temp);
        const char * extra = lstrip(line);
        indentlevel = (extra - line) / 4;
        unfinishedtype = lasttype;
    }
    int finishflag = 1;
    PyObject* temp = PyList_GetItem(object, totallinenumber-1);
    const char * line = PyUnicode_AsUTF8(temp);
    if (conditionstack.stacksize !=0) {
        unfinishedtype = conditionstack.toptype();
    }
    if (conditionstack.stacksize != 0 || lastchar(line) == '\\')
        finishflag = 0;
    return Py_BuildValue("(iii)", indentlevel, finishflag, unfinishedtype);
}


static char getpythonindent_docs[] =
    "get current indent for the python file";

static PyMethodDef getpythonindent_func[] =
{
    {"getpythonindent", (PyCFunction)getpythonindent, METH_VARARGS, getpythonindent_docs},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef afpythonmodule =
{
    PyModuleDef_HEAD_INIT,
    "afpython",
    "Used by Autoformat vim plugin. By Zhang Yiteng, Fudan university.",
    -1,
    getpythonindent_func
};

PyMODINIT_FUNC PyInit_afpython(void)
{
    return PyModule_Create(&afpythonmodule);
}
