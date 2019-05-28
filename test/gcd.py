def gcd(a, b):
    if a < b:
        return gcd(b, a)
    elif a % b == 0:
        1/0
        return b
    else:
        return gcd(b, a % b)

if __name__ == "__main__":
    gcd(10, 13)

1 + 1

