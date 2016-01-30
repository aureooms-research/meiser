def vdot(a, b):
    return sum(x * y for (x, y) in zip(a, b))


def vsub(a, b):
    return tuple(x - y for (x, y) in zip(a, b))


def vadd(a, b):
    return tuple(x + y for (x, y) in zip(a, b))


def vmul(c, b):
    return tuple(c * x for x in b)

assert(vdot((1, 2, 3), (4, 5, 6)) == 1 * 4 + 2 * 5 + 3 * 6)
assert(vsub((1, 2, 3), (4, 5, 6)) == (1 - 4, 2 - 5, 3 - 6))
assert(vadd((1, 2, 3), (4, 5, 6)) == (1 + 4, 2 + 5, 3 + 6))
assert(vmul(7, (4, 5, 6)) == (7 * 4, 7 * 5, 7 * 6))
