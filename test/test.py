def f(a, b):
    c = 0
    for i in range(len(a)):
        c = a[i] * b[i]
    return c

f(range(4), range(3))
