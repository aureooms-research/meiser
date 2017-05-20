# not available, using a fake implementation
# from collections import ChainMap


def ChainMap(a, b):
    # a overwrites b
    c = b.copy()
    c.update(a)
    return c

m = ChainMap({"a": 2, "c": 2}, {"a": 1, "b": 1})
assert(m["a"] == 2)
assert(m["b"] == 1)
assert(m["c"] == 2)
