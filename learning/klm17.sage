#!/usr/bin/env sage

from math import e
from math import log
from math import ceil
from random import random
from random import sample
from functools import total_ordering
from sage.numerical.mip import MIPSolverException

def H(k, n):
    """
        Yields the k-SUM hyperplanes coefficients for a k-SUM instance of size
        n.

        >>> list(H(2,3))
        [(0, 1, 1), (1, 0, 1), (1, 1, 0)]

        >>> from math import factorial
        >>> binom = lambda n , k : factorial(n)/factorial(k)/factorial(n-k)
        >>> len(list(H(4,10))) == binom(10,4)
        True

        >>> isinstance(next(H(2,3)), tuple)
        True

    """

    if k > n:
        return

    if k == 0:
        yield (0,) * n
        return

    for h in H(k, n - 1):

        yield (0,) + h

    for h in H(k - 1, n - 1):

        yield (1,) + h

def q(n):
    """
        Generates a random input of size n.

        >>> len(q(0)) == 0
        True

        >>> len(q(4187)) == 4187
        True

        >>> isinstance(q(10), tuple)
        True

    """

    return tuple(random() - 0.5 for i in range(n))


@total_ordering
class Label (object):

    # should cache queries to make sure we do not overcount
    # can use bitvector as description of query

    def __init__(self, oracle, value):

        self._oracle = oracle
        self._value = value
        self._sign = None

    def sign(self):

        if self._sign is None:
            self._oracle.label_queries += 1
            self._sign = sign(self._value)

        return self._sign

    def __hash__(self):
        return hash(self.sign())

    def __eq__(self, x):

        if isinstance(x, int):

            if x != -1 and x != 0 and x != 1:
                return self.sign() == x
            else:
                raise NotImplementedError('Can only get sign of a label.')

        elif isinstance(x, Label):

            self._oracle.comparison_queries += 1
            return self._value == x._value

        else:
            return NotImplemented

    def __lt__(self, x):

        if isinstance(x, int):

            if x != -1 and x != 0 and x != 1:
                return self.sign() < x
            else:
                raise NotImplementedError('Can only compare sign of a label.')

        elif isinstance(x, Label):

            self._oracle.comparison_queries += 1
            return self._value < x._value

        else:
            return NotImplemented


class Oracle (object):

    def __init__(self, q):

        self._q = q
        self.label_queries = 0
        self.comparison_queries = 0

    def label(self, h):

        return Label(self, self._q * h) # dot product


def A(O, H):

    return {h: O.label(h).sign() for h in H}


class S (object):

    def __init__(self, O, H, m):

        self.sample = set(sample(H, m))
        self.v = A(O, self.sample)

        self._ = [[], [], []]
        for key, val in self.v.items():
            self._[1 + val].append(key)

    def infer(self, H):

        Si = max(self._, key=len)
        _sign = self._.index(Si) - 1

        if _sign == 0:
            _sorted = Si
            h1 = _sorted[0]

        elif _sign == 1:
            _sorted = sorted(Si, key = O.label)
            h1 = _sorted[0]

        else:
            _sorted = list(reversed(sorted(Si, key = O.label)))
            h1 = _sorted[0]


        delta = [ b - a for (a,b) in zip(_sorted,_sorted[1:]) ]

        A = matrix(delta).transpose()

        for h in H:

            if h in self.sample:
                yield h

            elif isnonnegativelinearcombination(h-h1, A):
                yield h

def isnonnegativelinearcombination( b , A ) :

    p = MixedIntegerLinearProgram(solver = "GLPK")
    # p = MixedIntegerLinearProgram(solver = "PPL")
    x = p.new_variable(nonnegative=True, real=True)
    p.add_constraint(A*x == b)
    p.set_objective(None) #just looking for feasible solution

    try:
        sol = p.solve()
        print('BINGO!!!')
        return True

    except MIPSolverException as e:
        print(e)
        return False

def KLM17(O, H, d):
    """
        Parameters
        ----------
        O : Oracle
            The oracle.

        H : list
            The points to classify.

        d : int
            The inference dimension of H.

    """

    print('KLM17({},{})'.format(len(H), d))

    if len(H) <= 2 * d:
        return A(O, H)

    _S = S(O, H, 2 * d)
    infer = set(_S.infer(H))
    out = { h : O.label(h) for h in infer }
    out.update(KLM17(O, H.difference(infer), d))
    return out

def pigeonhole(m,n,w):

    return 2**(m-1) > ((2*e*(2*w+1)*m)/n)**n

def M (c, n, w):
    return int(ceil(c * n * log(w,2)))

if __name__ == '__main__':

    import sys
    args = sys.argv[1:]

    k = int(args[0])
    n = int(args[1])
    w = k
    # inference dimension
    c = 1
    lb = 1
    while True:
        m = M(c,n,w)
        if pigeonhole(m,n,w):
            ub = c
            break
        lb = c
        c *= 2

    while lb < ub:
        c = (lb + ub)//2
        m = M(c,n,w)
        if pigeonhole(m,n,w):
            ub = c
        else:
            lb = c+1

    c = ub
    m = M(c,n,w)
    d = 2*m+n

    _q = vector(q(n))
    _q.set_immutable()
    O = Oracle(_q)

    _Hl = list(map(vector,H(k, n)))
    for v in _Hl: v.set_immutable()
    _H = set(_Hl)

    print('n', n)
    print('k', k)
    print('w', w)
    print('c', c)
    print('m', m)
    print('d', d)
    print('2d', 2*d)
    print('|H|', len(_H))
    print('q', O._q)

    A = KLM17(O, _H, d)
    print('# label queries:', O.label_queries)
    print('# comparison queries:', O.comparison_queries)
    print('n log^2 n', n*log(n,2)**2)
    print('{} n log^2 n'.format( (O.label_queries + O.comparison_queries) / (n*log(n,2)**2) ) )
    # print('A', A )
