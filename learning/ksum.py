
def tuples(k, n):
    """
        Yields the k-SUM hyperplanes coefficients for a k-SUM instance of size
        n.

        >>> list(tuples(2,3))
        [(0, 1, 1), (1, 0, 1), (1, 1, 0)]

        >>> from math import factorial
        >>> binom = lambda n , k : factorial(n)/factorial(k)/factorial(n-k)
        >>> len(list(tuples(4,10))) == binom(10,4)
        True

        >>> isinstance(next(tuples(2,3)), tuple)
        True

    """

    if k > n:
        return

    if k == 0:
        yield (0,) * n
        return

    for h in tuples(k, n - 1):

        yield (0,) + h

    for h in tuples(k - 1, n - 1):

        yield (1,) + h
