#!/usr/bin/env python3

import argparse
from random import random, choice, shuffle, sample
from math import log, ceil, sqrt
from itertools import count, combinations
from collections import Counter
from fractions import Fraction
from operator import mul
from functools import reduce

parser = argparse.ArgumentParser(description='k-SUM vertical decomposition analysis.')
# parser.add_argument('n', type=int, help='Dimension.')
parser.add_argument('k', type=int, help='k.')

args = parser.parse_args()

# n = args.n
k = args.k

# old implementation
# def vadd(a,b):
    # return tuple(map(sum,zip(a,b)))

# def vmul(a,s):
    # return tuple(x*s for x in a)

# def project(a,b,i):
    # '''
        # Project a on b in the i^th dimension.
    # '''
    # return vadd(a, vmul(b, -a[i]/b[i]))

# def altitude(i, q, h):
    # return sum(-q[j] * h[j] for j in range(i))

def rayshoot ( i , q , H ) :

    # TODO here we should not assume that the input does not lie on a
    # hyperplane
    # TODO here we should not assume that the rayshooting has a single floor or
    # ceiling
    altitudes = [( h , h.altitude(i, q)) for h in H]
    _floor   = max(filter(lambda x : x[1] <= q[i], altitudes), key=lambda x: x[1], default=(None, None))
    _ceiling = min(filter(lambda x : x[1] >= q[i], altitudes), key=lambda x: x[1], default=(None, None))

    floor   = _floor[0]
    ceiling = _ceiling[0]

    return floor, ceiling


def locate ( q , H , dimensions ) :

    while dimensions :

        # print(q,H,dimensions)

        # greedily pick dimension
        # table = [(j, sum(map(lambda h: h[j] != 0, H))) for j in dimensions]
        # print(table)
        table = ((j, sum(map(lambda h: h[j] != 0, H))) for j in dimensions)
        i = min(table, key=lambda x:x[1])[0]
        # OR random choice
        # i = choice(list(dimensions))

        candidates = set(filter(lambda h : h[i] != 0, H))

        if not candidates :
            dimensions.remove(i)
            continue

        comparisons = len(candidates)
        # print(d, comparisons)
        if len(candidates) <= 2 :
            # TODO should probably also add the projections of the floor on the ceiling
            # in vice versa
            H.difference_update(candidates)
            dimensions.remove(i)
            yield comparisons
            continue

        floor, ceiling = rayshoot(i, q, candidates)

        if floor is None: floor = ceiling
        if ceiling is None: ceiling = floor

        if floor is None:
            raise Exception('should never happen because candidates > 0')

        # this is where we should keep one of each pair of projections for each
        # candidate
        # TODO should probably also add the projections of the floor on the ceiling
        # in vice versa
        for h in candidates - {floor, ceiling}:
            h.project(i, choice([floor,ceiling]))

        H.discard(floor)
        H.discard(ceiling)
        dimensions.remove(i)
        yield comparisons

def countermul(counter, multiplier):
    return { key: value * multiplier for key, value in counter.items() }

class Hyperplane(Counter):

    def __init__(self, ones):
        # remember our hyperplanes are sparse
        self._id = ones
        self.update({i:Fraction(1) for i in ones})

    def project(self, i, other):
        '''
            Project self on other in the i^th dimension.
            Will probably cause a problem when we will need to compute which
            projection to keep. Needs FAST persistence.
        '''
        eliminant = -self[i]/other[i]
        self.update(countermul(other, eliminant))
        zero = Fraction(0)
        zeroes = [i for i in self if self[i] == zero]
        for i in zeroes:
            del self[i]

    def __hash__(self):
        return hash(self._id)

    def scale(self,s):
        return Hyperplane(countermul(self,s))

    def altitude(self, i, q):
        '''
            Compute the ith coordinate of the projection of q on self in the ith
            vertical direction.
        '''
        return -sum(q[j] * self[j] for j in self if j != i)/self[i]

# display increase in the number of variables

if __name__ == '__main__' :

    base = 2

    comparisons = []
    p = [1]
    r = []

    for i in count(1):

        n = base**i

        if n < k:
            continue

        C = 10

        # print('build n-dimensional k-SUM hyperplanes')
        ksumhyperplanes = list(combinations(range(n),k))
        enetsize = max(1,min(len(ksumhyperplanes),int(ceil(C * n * log(n)))))

        # hyperplanes = set(tuple(sample((1,)*k + (0,)*(n-k), n)) for i in range(enetsize))

        # seems faster because of the cost of random bits
        # print('sample n-dimensional k-SUM hyperplanes')
        hyperplanes = set(map(Hyperplane,sample(ksumhyperplanes,enetsize)))
        ksumhyperplanes = [] # gc

        # TODO keeep a count of the stuff we manipulate
        # table = [set() for i in range(n)]

        # print('build q')
        q = tuple(sorted(random() for i in range(n)))

        # print('q = {}'.format(q))

        # print('locate q')
        c = sum(locate(q, hyperplanes, set(range(n))))
        comparisons.append(c)

        p.append(c/enetsize)
        if len(comparisons) >= 2:
            r.append(log(comparisons[-1]/comparisons[-2],base))
            print( n, enetsize, c, p[-1], r[-1], reduce(mul, r)**(1/len(r)) )
        else:
            print( n, enetsize, c, p[-1])

