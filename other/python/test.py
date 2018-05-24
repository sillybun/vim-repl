import numpy as np

a = np.zeros(10, dtype="int")

temp = 0
for i in range(len(a)):
    temp += a[i]

print(a)
print(temp)
