
import sys
from itertools import chain, product, combinations
from bisect import bisect_right, bisect_left
from collections import Counter

load('log.sage')
load('chainmap.sage')
load('bst.sage')
load('linearalgebra.sage')
load('boundingbox.sage')
load('independentset.sage')
load('hyperplanes.sage')
load('permutations.sage')
load('ksumtuples.sage')
load('ksumalgorithms.sage')
load('solve.sage')
load('position.sage')
load('hrep.sage')
load('event.sage')
load('A1.sage')
load('A2.sage')
load('A3.sage')
load('A4.sage')
load('A5.sage')

args = sys.argv[1:]

if len( args ) < 2 :
    print( '  usage: time sage main.sage <k> <input>')
    print( 'example: time sage main.sage 3 \'(1/2,-1/3,-1/6)\'')
    sys.exit( 1 )

k = int(args[0])
q = sage_eval( args[1] )
# parameters
field = QQ
n = len(q)
variables = tuple('x' + str(i) for i in range(1, n + 1))
A = HyperplaneArrangements(field, variables)

# get first solution
# next( filter( lambda e : e[0] == EVENT_BINGO , A5( A , n , k , q ) ) )[1]

# trace algorithm
for event_type , data in A5(A, n, k, q):
    if event_type == EVENT_ENTER :
        log( 'entering ' + data )
        log.inc()
    elif event_type == EVENT_EXIT :
        log.dec()
        log( 'exiting ' + data )
    elif event_type == EVENT_BINGO :
        log( 'BINGO' , data , ' + '.join( map( str , ( q[i] for i in data ) ) )
                + ' = ' + str(sum( q[i] for i in data ))  )
    else :
        log( event_type , data )
