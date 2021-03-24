%%timeit
mean, var = 0., 0.
for i in range(1000000):
    x = np.random.randn()
    a = np.random.randn()
    z = np.random.randn()
    m = np.random.randn()
    y = x * a * z * m
    mean += y
    var += y**2
mean / 1000000, math.sqrt(var / 1000000)
