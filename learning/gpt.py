from itertools import combinations

def tuples(n):
    """
        Yields the GPT hyperplanes coefficients for a GPT instance of size
        n.

        >>> list(tuples(3))
        [(0, 1, -1, -1, 0, 1, 1, -1, 0)]

        >>> from math import factorial
        >>> binom = lambda n , k : factorial(n)/factorial(k)/factorial(n-k)
        >>> len(list(tuples(10))) == binom(10,3)
        True

        >>> isinstance(next(tuples(3)), tuple)
        True

    """

    for i, j, k in combinations(range(n), 3) :

        ones = [(i*n+j, 1), (j*n+i, -1), (k*n+i, 1), (i*n+k, -1), (j*n+k, 1), (k*n+j, -1)]

        o = sorted(ones)

        yield (0,) * (        o[0][0]        ) + (o[0][1],) +\
              (0,) * ( o[1][0] - o[0][0] - 1 ) + (o[1][1],) +\
              (0,) * ( o[2][0] - o[1][0] - 1 ) + (o[2][1],) +\
              (0,) * ( o[3][0] - o[2][0] - 1 ) + (o[3][1],) +\
              (0,) * ( o[4][0] - o[3][0] - 1 ) + (o[4][1],) +\
              (0,) * ( o[5][0] - o[4][0] - 1 ) + (o[5][1],) +\
              (0,) * (    n**2 - o[5][0] - 1 )
