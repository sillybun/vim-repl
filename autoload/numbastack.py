from __future__ import print_function, absolute_import
from collections import OrderedDict
from numba import njit
from numba import jitclass
from numba import deferred_type, intp, optional
from numba.runtime import rtsys

tokenspec = [
    ('tokentype', intp),               # a simple scalar field
    ('rownumber', intp),          # an array field
]

@jitclass(tokenspec)
class tokenrepl(object):
    def __init__(self, _tokentype, _rownumber):
        self.tokentype = _tokentype
        self.rownumber = _rownumber

linkednode_spec = OrderedDict()
linkednode_type = deferred_type()
# linkednode_spec['data'] = data_type = deferred_type()
linkednode_spec['data'] = tokenrepl.class_type.instance_type
linkednode_spec['next'] = optional(linkednode_type)


@jitclass(linkednode_spec)
class LinkedNode(object):
    def __init__(self, data):
        self.data = data
        self.next = None


linkednode_type.define(LinkedNode.class_type.instance_type)

stack_spec = OrderedDict()
stack_spec['head'] = optional(linkednode_type)
stack_spec['size'] = intp


@jitclass(stack_spec)
class Stack(object):
    def __init__(self):
        self.head = None
        self.size = 0

    # def push(self, data):
    #     new = LinkedNode(data)
    #     new.next = self.head
    #     self.head = new
    #     self.size += 1

    def push(self, tokentype, rownumber):
        data = tokenrepl(tokentype, rownumber)
        new = LinkedNode(data)
        new.next = self.head
        self.head = new
        self.size += 1

    def pop(self):
        old = self.head
        if old is None:
            raise ValueError("empty")
        else:
            self.head = old.next
            self.size -= 1
            return old.data

    def top(self):
        if self.head is None:
            raise ValueError("empty")
        else:
            return self.head.data

    def clear(self):
        self.head = None
        self.size = 0


# data_type.define(intp)


@njit
def pushpop(size):
    """
    Creates a list of decending numbers from size-1 to 0.
    """
    stack = Stack()

    for i in range(size):
        stack.push(i)

    out = []
    while stack.size > 0:
        out.append(stack.pop())

    return out


def test_pushpop(size):
    """
    Test basic push pop operation on a Stack object
    """
    result = pushpop(size)
    print("== Result ==")
    print(result)
    assert result == list(reversed(range(size)))


def test_exception():
    """
    Test exception raised from a jit method
    """
    stack = Stack()
    stack.push(1)
    assert 1 == stack.pop()
    try:
        # Unfortunately, numba will leak when an exception is thrown.
        stack.pop()
    except ValueError as e:
        assert 'empty' == str(e)


def runme():
    size = 24
    test_pushpop(size)
    test_exception()


if __name__ == '__main__':
    runme()
    print("== Print memory allocation information == ")
    print(rtsys.get_allocation_stats())
