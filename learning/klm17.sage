#!/usr/bin/env sage
import sys
import json
import argparse
import logging

import xy
import ksum
from math import e
from math import log
from math import ceil
from functools import total_ordering
from itertools import islice
from sage.numerical.mip import MIPSolverException

SOLVERS = [
    "GLPK" ,
    "GLPK/exact" ,
    "Coin" ,
    "CPLEX" ,
    "CVXOPT" ,
    "Gurobi" ,
    "PPL" ,
    "InteractiveLP"
]

serialize_int_vector = lambda v : list(map(int,v))
serialize_float_vector = lambda v : list(map(float,v))
def serialize_sign ( s ) :

    scopy = {
        'sign' : int(s['sign']) ,
        'reason' : s['reason']
    }

    if s['reason'] == REASON_IS_INFERRED :
        scopy['coefficients'] = serialize_float_vector(vector(s['coefficients']))

    return scopy

REASON_IN_SAMPLE = 'REASON_IN_SAMPLE'
REASON_IS_INFERRED = 'REASON_IS_INFERRED'
REASON_BASE_CASE = 'REASON_BASE_CASE'

DEFAULT_SOLVER = 'GLPK'

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

        self._side = None
        self._sorted = None

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

        self._sorted = _sorted
        self._side = _sign

        delta = [ b - a for (a,b) in zip(_sorted,_sorted[1:]) ]

        A = matrix(delta).transpose()
        A.set_immutable()

        return ( _sign , h1 , A )


    def infer(self, H, solver=DEFAULT_SOLVER):

        _sign, h1, A = self.pick_side()


        for h in H:

            s = infer_one(_sign, self.v, h1, A, h, solver=solver)

            if s is not None:

                yield ( h , s )


def infer_one( _sign , S , h1 , A , h , solver=DEFAULT_SOLVER ) :

    if h in S :
        return {
            'sign' : S[h] ,
            'reason' : REASON_IN_SAMPLE
        }

    yes , coefficients = isnonnegativelinearcombination(h-h1, A, solver=solver)

    if yes:
        return {
            'sign' : _sign ,
            'reason' : REASON_IS_INFERRED ,
            'coefficients' : coefficients
        }

    else :
        return None

def isnonnegativelinearcombination( b , A , solver = DEFAULT_SOLVER ) :

    p = MixedIntegerLinearProgram(solver=solver)
    x = p.new_variable(nonnegative=True, real=True)
    p.add_constraint(A*x == b)
    p.set_objective(None) #just looking for feasible solution

    try:
        sol = p.solve()
        logging.debug('BINGO!!!')
        coefficients = dict( p.get_values(x).iteritems() )
        return ( True , coefficients )

    except MIPSolverException as e:
        logging.debug(e)
        return ( False , None )

def KLM17(q, H, d, solver = DEFAULT_SOLVER):
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

    logging.info('KLM17( %s, %s, %d, solver=%s)', len(q), len(H), d, solver)

    O = Oracle(q)

    if len(H) <= 2 * d:

        signs = A(O, H)
        yield {
            'case' : 'base' ,
            'n' : len(q) ,
            'q' : q ,
            'H' : H ,
            'd' : d ,
            'queries' : {
                'label' : O.label_queries ,
                'comparison' : O.comparison_queries ,
                'total' : O.label_queries + O.comparison_queries
            } ,
            'signs' : { h : {
                'sign' : s ,
                'reason' : REASON_BASE_CASE
            } for h , s in signs.iteritems() }
        }

    else :

        _S = S(O, H, 2 * d)
        signs = dict(_S.infer(H, solver=solver))

        _s = len(_S._sorted) + 1
        _i = len(signs) - 2*d
        logging.info('inferred %s things from %s', _i , _s)

        yield {
            'case' : 'general' ,
            'n' : len(q) ,
            'q' : q ,
            'H' : H ,
            'd' : d ,
            'queries' : {
                'label' : O.label_queries ,
                'comparison' : O.comparison_queries ,
                'total' : O.label_queries + O.comparison_queries
            } ,
            'signs' : signs ,
            'S' : _S.sample ,
            'S-' : _S._[0] ,
            'S0' : _S._[1] ,
            'S+' : _S._[2] ,
            'side' : _S._side ,
            'sorted' : _S._sorted
        }

        infer = signs.keys()

        for step in KLM17(q, H.difference(infer), d, solver=solver) :
            yield step

def pigeonhole(m,n,w):
    return 2**(m-1) > ((2*e*(2*w+1)*m)/n)**n

def M (c, n, w):
    return int(ceil(c * n * log(w,2)))


def main ( ) :

    parser = argparse.ArgumentParser(description='Solves a random k-SUM-like instance using the algorithm in [KLM17].')
    parser.add_argument('-n', type=int, required=True, help='Input size.')
    parser.add_argument('-v', '--verbosity', type=str, default='ERROR', help='Log level.', choices=[ 'DEBUG' , 'INFO' , 'WARNING' , 'ERROR' , 'CRITICAL'])
    parser.add_argument('-i', '--iterations', type=int, default=sys.maxsize, help='Maximum number of iterations to execute.')
    parser.add_argument('-c', '--check', action='store_true', help='Check solution. Can check partial solution if `iterations` is supplied.')
    parser.add_argument('-d', '--dimension', type=int, help='Override the inference dimension. Allows to pick smaller samples for small instances for example.')
    parser.add_argument('-t', '--trace', action='store_true', help='Output trace of the algorithm as JSON.')
    parser.add_argument('-s', '--solver', type=str, default=DEFAULT_SOLVER,
    help='Use GLPK for (fast) float solution and PPL for exact rational solution. Default is {}'.format(DEFAULT_SOLVER),
    choices=SOLVERS)
    problems = parser.add_mutually_exclusive_group(required=True)
    problems.add_argument('--ksum', type=int, metavar='k', help='Try with a random k-SUM instance. Needs one argument for `k`.')
    problems.add_argument('--xy', action='store_true', help='Try with a random sorting X+Y instance.')

    args = parser.parse_args()

    numeric_level = getattr(logging, args.verbosity.upper(), None)
    logging.basicConfig(stream=sys.stderr, level=numeric_level)

    n = args.n

    q = random_vector(RR,n)

    if args.ksum :
        k = args.ksum
        w = k
        H = ksum.tuples(k, n)
        q = vector(sorted(q)) # sort the input

    if args.xy :
        assert n % 2 == 0
        w = 4
        H = xy.tuples(n)
        q = vector(sorted(list(q)[::2])+sorted(list(q)[1::2])) # sort the input halves

    q.set_immutable()

    if args.dimension is not None :

        d = args.dimension
        c = None
        m = None

    else :

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

    _Hl = list(map(vector,H))
    for v in _Hl: v.set_immutable()
    _H = set(_Hl)

    logging.info('n %s', n)
    logging.info('w %s', w)
    logging.info('c %s', c)
    logging.info('m %s', m)
    logging.info('d %s', d)
    logging.info('2d %s', 2*d)
    logging.info('|H| %s', len(_H))
    logging.info('q %s', q)

    trace = list( islice(KLM17(q, _H, d, solver=args.solver),args.iterations) )

    label_queries = sum( step['queries']['label'] for step in trace )
    comparison_queries = sum( step['queries']['comparison'] for step in trace )
    logging.info('# label queries: %s', label_queries)
    logging.info('# comparison queries: %s', comparison_queries)
    logging.info('n log^2 n: %s', n*log(n,2)**2)
    logging.info('%s n log^2 n' , (label_queries + comparison_queries) / (n*log(n,2)**2) )

    if args.check :

        solution = dict( )
        for step in trace :
            solution.update( { h : s['sign'] for ( h , s ) in step['signs'].iteritems() } )

        O = Oracle(q)
        expected = A(O, _H)

        if solution == expected :
            logging.info('check > Solution is correct and complete.')

        else:

            solved = solution.keys()
            expected = { h : s for h , s in expected.iteritems() if h in solved }

            if solution == expected :
                logging.warning('check > Solution is a subset of the expected solution.')

            else:
                logging.error('check > Solution is incorrect.')

    if args.trace :

        tracecopy = []

        for step in trace :

            stepcopy = copy(step)

            stepcopy['n'] = int(step['n'])
            stepcopy['q'] = serialize_float_vector(step['q'])
            stepcopy['H'] = list(map(serialize_int_vector, step['H'] ))
            stepcopy['d'] = int(step['d'])

            stepcopy['queries'] = {}
            for t in [ 'label' , 'comparison' , 'total' ] :
                stepcopy['queries'][t] = int(step['queries'][t])

            stepcopy['signs'] = [ [ serialize_int_vector(h) , serialize_sign(s) ] for (h,s) in step['signs'].iteritems() ]

            if stepcopy['case'] == 'general' :

                for S in [ 'S' , 'S0' , 'S-' , 'S+' , 'sorted' ] :
                    stepcopy[S] = list(map(serialize_int_vector, step[S]))

                stepcopy['side'] = int(step['side'])

            tracecopy.append(stepcopy)

        json.dump( {
            'argv' : sys.argv ,
            'trace' : tracecopy
        }, sys.stdout)


if __name__ == '__main__':
    main()

