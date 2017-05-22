
from argparse import ArgumentParser
from itertools import count
from math import log, floor

parser = ArgumentParser('How many comparisons dude')
parser.add_argument('k', type=int, help='k.')

args = parser.parse_args()

k = args.k

def locate(n,k):

    s = k

    O = 10
    r = min(O * n * log(n,2),n**k)

    while n > 0:

        p = max(1, floor(n / s))

        # number of comparisons
        yield p * s * r / n

        n -= p
        s = min(2 * s - 2, n)
        r -= 2



for n in count(2):

    c = sum(locate(n,k))
    print(k,n,c,c/n**2/log(n,2)**2)
