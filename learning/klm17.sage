#!/usr/bin/env sage

import ksum
import logging
from math import e
from math import log
from math import ceil
from functools import total_ordering
from sage.numerical.mip import MIPSolverException

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

        self.O = O
        self.sample = set(sample(H, m))
        self.v = A(O, self.sample)

        self._ = [[], [], []]
        for key, val in self.v.iteritems():
            self._[1 + val].append(key)

    def pick_side(self):

        Si = max(self._, key=len)
        _sign = self._.index(Si) - 1

        if _sign == 0:
            _sorted = Si
            h1 = _sorted[0]

        elif _sign == 1:
            _sorted = sorted(Si, key = self.O.label)
            h1 = _sorted[0]

        else:
            _sorted = list(reversed(sorted(Si, key = self.O.label)))
            h1 = _sorted[0]


        delta = [ b - a for (a,b) in zip(_sorted,_sorted[1:]) ]

        A = matrix(delta).transpose()
        A.set_immutable()

        return ( _sign , h1 , A )


    def infer(self, H):

        _sign, h1, A = self.pick_side()

        for h in H:

            s = infer_one(_sign, self.v, h1, A, h)

            if s is not None:

                yield ( h , s )


def infer_one( _sign , S , h1 , A , h ) :

    if h in S :
        return S[h]

    elif isnonnegativelinearcombination(h-h1, A):
        return _sign

    else :
        return None

def isnonnegativelinearcombination( b , A ) :

    p = MixedIntegerLinearProgram(solver = "GLPK")
    # p = MixedIntegerLinearProgram(solver = "PPL")
    x = p.new_variable(nonnegative=True, real=True)
    p.add_constraint(A*x == b)
    p.set_objective(None) #just looking for feasible solution

    try:
        sol = p.solve()
        logging.debug('BINGO!!!')
        return True

    except MIPSolverException as e:
        logging.debug(e)
        return False

def KLM17(q, H, d):
    """
        Parameters
        ----------
        q : vector
            The query point.

        H : set<vector>
            The points to classify.

        d : int
            The inference dimension of H.

    """

    O = Oracle(q)

    if len(H) <= 2 * d:

        signs = A(O, H)
        yield {
            'n' : len(q) ,
            'q' : q ,
            'H' : H ,
            'd' : d ,
            'queries' : {
                'label' : O.label_queries ,
                'comparison' : O.comparison_queries
            } ,
            'S' : H ,
            'infer(S,x)' : H ,
            'signs' : signs
        }

    else :

        _S = S(O, H, 2 * d)
        signs = dict(_S.infer(H))
        infer = signs.keys()

        yield {
            'n' : len(q) ,
            'q' : q ,
            'H' : H ,
            'd' : d ,
            'queries' : {
                'label' : O.label_queries ,
                'comparison' : O.comparison_queries
            } ,
            'S' : _S.sample ,
            'infer(S,x)' : infer ,
            'signs' : signs
        }

        for step in KLM17(q, H.difference(infer), d) :
            yield step

def pigeonhole(m,n,w):
    return 2**(m-1) > ((2*e*(2*w+1)*m)/n)**n

def M (c, n, w):
    return int(ceil(c * n * log(w,2)))


def main ( ) :

    import json
    import argparse

    parser = argparse.ArgumentParser(description='Solves a random k-SUM instance using the algorithm in [KLM17].')
    parser.add_argument('-k', type=int, nargs=1, required=True, help='The `k` in k-SUM.')
    parser.add_argument('-n', type=int, nargs=1, required=True, help='Input size.')
    parser.add_argument('-v', '--verbose', action='store_true', help='Be verbose.')
    parser.add_argument('--check', action='store_true', help='Check solution.')
    parser.add_argument('--trace', action='store_true', help='Output trace of the algorithm as JSON.')

    args = parser.parse_args()

    k = args.k[0]
    n = args.n[0]
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

    q = random_vector(RR,n)
    q.set_immutable()

    _Hl = list(map(vector,ksum.tuples(k, n)))
    for v in _Hl: v.set_immutable()
    _H = set(_Hl)

    if args.verbose:
        logging.info('n %s', n)
        logging.info('k %s', k)
        logging.info('w %s', w)
        logging.info('c %s', c)
        logging.info('m %s', m)
        logging.info('d %s', d)
        logging.info('2d %s', 2*d)
        logging.info('|H| %s', len(_H))
        logging.info('q %s', q)

    trace = list( KLM17(q, _H, d) )
    solution = dict( )
    for step in trace :
        solution.update( step['signs'] )

    if args.verbose:
        label_queries = sum( step['queries']['label'] for step in trace )
        comparison_queries = sum( step['queries']['comparison'] for step in trace )
        logging.info('# label queries: %s', label_queries)
        logging.info('# comparison queries: %s', comparison_queries)
        logging.info('n log^2 n: %s', n*log(n,2)**2)
        logging.info('%s n log^2 n' , (label_queries + comparison_queries) / (n*log(n,2)**2) )

    if args.check :
        O = Oracle(q)
        expected = { h : O.label(h).sign() for h in _H }
        logging.info('OK %s', solution == expected )

    if args.trace :

        import sys
        import json

        serializable = []
        for step in trace :

            stepcopy = copy(step)

            stepcopy['n'] = int(stepcopy['n'])
            stepcopy['q'] = list(map(float,stepcopy['q']))
            stepcopy['H'] = list( list(map(int,h)) for h in stepcopy['H'] )
            stepcopy['d'] = int(stepcopy['d'])
            stepcopy['queries']['label'] = int(stepcopy['queries']['label'])
            stepcopy['queries']['comparison'] = int(stepcopy['queries']['comparison'])
            stepcopy['S'] = list( list(map(int,h)) for h in stepcopy['S'] )
            stepcopy['infer(S,x)'] = list( list(map(int,h)) for h in stepcopy['infer(S,x)'] )
            stepcopy['signs'] = [ [ list(map(int,h)) , int(s) ] for (h,s) in stepcopy['signs'].iteritems() ]

            serializable.append(stepcopy)

        json.dump(serializable, sys.stdout)


if __name__ == '__main__':

    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
    main()

