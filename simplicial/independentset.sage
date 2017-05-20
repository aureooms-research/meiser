
def _maxindset(A, G, H):

    O = frozenset()
    M = [g for g in G]
    for h in H:
        _M = M + [h]
        if matrix(A._base_ring, _M).rank() == len(_M):
            M = _M
            O = O | frozenset([h])

    return O


def maxindset(A, n, G, H):
    """
    output: a maximally independent set E of hyperplanes such that G \subseteq E and E \subseteq G \cup H
    G will size at most n
    Complexity = |H|n^3 (could be made |H|n^2)
    """

    M = [g.coefficients()[1:] for g in G]
    for h in H:
        _M = M + [h.coefficients()[1:]]
        if matrix(A._base_ring, _M).rank() == len(_M):
            M = _M
            G = G | frozenset([h])

    return G
n = 3
A = HyperplaneArrangements(QQ, ("x", "y", "z"))
H = box(A, n).keys()
G = frozenset()
assert( len(maxindset(A, n, G, H)) == 3 )
