def randomkSUMTuple(n, k):
    # IT IS NOT UNIFORM, IT SHOULD BE
    return tuple(randint(0, n - 1) for i in range(k))


def tupleToHyperplane(V, n, t):
    # input: t is a tuple of indices ( i1 , i2 , ... , in )
    # output: xi1 + xi2 + ... + xin = 0
    c = Counter(t)
    return V([0] + [c[i] for i in range(n)])


def randomkSUMHyperplane(V, n, k):
    return tupleToHyperplane(V, n, randomkSUMTuple(n, k))

n = 3
k = 2
A = HyperplaneArrangements(QQ, ("x", "y", "z"))
V = A.ambient_space()
randomkSUMHyperplane(V, n, k)
