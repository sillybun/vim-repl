def gcd(a, b):
    if a < b:
        return gcd(b, a)
    elif a % b == 0:
        return b
    else:
        return gcd(b, a % b)



gcd(10, 13)
gcd(10, 13)
gcd(10, 13)
