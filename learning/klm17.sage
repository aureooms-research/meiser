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

        >>> type(q(10))
        <class 'tuple'>

    """

    return tuple(random() - 0.5 for i in range(n))

def vsub(a, b):

    return tuple( x - y for (x,y) in zip(a,b) )

def vdot(a, b):
    """
        Computes the dot product of two vectors.

        >>> vdot((1, 3, -5), (4, -2, -1))
        3

    """

    return sum(ai * bi for (ai, bi) in zip(a, b))


def sign(x):
    """
        Parameters
        ----------
        x : int
            The number you want to get the sign of.

        >>> sign( 17 )
        1
        >>> sign( -3 )
        -1
        >>> sign( 0 )
        0
        >>> sign( -0.0 )
        0

    """

    return 1 if x > 0 else -1 if x < 0 else 0


@total_ordering
class Label (object):

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

        return Label(self, vdot(self._q, h))


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


        delta = [ vsub(b, a) for (a,b) in zip(_sorted,_sorted[1:]) ]

        for h in H:

            if h in self.sample:
                yield h

            elif isnonnegativelinearcombination(vsub(h,h1), delta):
                yield h

def isnonnegativelinearcombination( v , U ) :

    p = MixedIntegerLinearProgram(maximization=False, solver = "GLPK")
    # p = MixedIntegerLinearProgram(maximization=False, solver = "PPL")
    a = p.new_variable(nonnegative=True, real=True)
    for j, hj in enumerate(v):
        p.add_constraint(p.sum(a[i]*Ui[j] for (i, Ui) in enumerate(U)), min=hj, max=hj)

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


if __name__ == '__main__':

    n = 20
    k = 3
    w = k
    # inference dimension
    c = 1
    while True:
        m = int(ceil(c * n * log(w,2)))
        if 2**(m-1) > ((2*e*(2*w+1)*m)/n)**n:
            break
        c *= 2

    d = 2*m+n

    O = Oracle(q(n))

    _H = set(H(k, n))


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
    print('A', A )
