
from itertools import chain , product , combinations
from bisect import bisect_right, bisect_left
from collections import Counter

load( 'chainmap.sage' )
load( 'bst.sage' )
load( 'linearalgebra.sage' )
load( 'boundingbox.sage' )
load( 'independentset.sage' )
load( 'hyperplanes.sage' )
load( 'ksumtuples.sage' )
load( 'ksumalgorithms.sage' )
load( 'solve.sage' )
load( 'hrep.sage' )
load( 'event.sage' )
load( 'A1.sage' )
load( 'A2.sage' )
load( 'A3.sage' )
load( 'A4.sage' )
load( 'A5.sage' )

# test
k = 3
#q = ( -1/2 , 1/2 , 1 , -1 , 10 , 17 , 31 , 49 , 64 , -34 , -34 )
q = ( 1/2,1/3,1/4,1/8,-1/4)
# parameters
field = QQ
n = len( q )
variables = tuple( 'x' + str( i ) for i in range( 1 , n + 1 ) )
A = HyperplaneArrangements( field , variables )
# next( filter( lambda e : e[0] == EVENT_BINGO , A5( A , n , k , q ) ) )
for event in A5( A , n , k , q ) : print( event )













