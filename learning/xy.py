import ksum

def tuples(n):
    """
        Yields the X+Y hyperplanes coefficients for a sorting X+Y instance of size
        n.

        >>> list(tuples(4))
        [(-1, 1, -1, 1), (-1, 1, 1, -1), (1, -1, -1, 1), (1, -1, 1, -1)]

        >>> from math import factorial
        >>> binom = lambda n , k : factorial(n)/factorial(k)/factorial(n-k)
        >>> len(list(tuples(8))) == (2*binom(4,2))**2
        True

        >>> isinstance(next(tuples(4)), tuple)
        True

    """

    assert n % 2 == 0

    for left in pairs(n//2) :

        for right in pairs(n//2) :

            yield left + right

def pairs(n):

    for pair in ksum.tuples(2,n) :

        i = pair.index(1)
        yield pair[:i] + (-1,) + pair[i+1:]

        j = pair.index(1, i+1)
        yield pair[:j] + (-1,) + pair[j+1:]
