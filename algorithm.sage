# useful tools
from itertools import chain , product , combinations
from bisect import bisect_right, bisect_left
from collections import Counter
assert( list(chain(range(1,3),range(3,6))) == [ 1,2,3,4,5] )
assert( Counter( chain( range( 5 ) , range( 9 ) ) )[1] == 2 )
assert( Counter( chain( range( 5 ) , range( 9 ) ) )[6] == 1 )
assert( Counter( chain( range( 5 ) , range( 9 ) ) )[9] == 0 )
assert( bisect_left( range( 15 ) , 7 ) == 7 )
assert( bisect_right( range( 15 ) , 7 ) == 8 )
assert( tuple(product("AB","CD")) == (('A', 'C'), ('A', 'D'), ('B', 'C'), ('B', 'D')) )
assert( tuple(product("AB" , repeat = 2 )) == (('A', 'A'), ('A', 'B'), ('B', 'A'), ('B', 'B')) )
assert( tuple(combinations("ABC" , 2 )) == (('A', 'B'), ('A', 'C'), ('B', 'C')) )
# not available, using a fake implementation
# from collections import ChainMap
def ChainMap ( a , b ) :
    # a overwrites b
    c = b.copy()
    c.update( a )
    return c
m = ChainMap( { "a" : 2 , "c" : 2 } , { "a" : 1 , "b" : 1 } )
assert( m["a"] == 2 )
assert( m["b"] == 1 )
assert( m["c"] == 2 )
class BalancedBST ( object ) :

    """faking it"""

    def __init__ ( self ) :
        self._keys = [ ]
        self._vals = [ ]

    def insert ( self , key , val ) :
        # O(log n) in a real balanced BST
        i = bisect_right( self._keys , key )
        self._keys.insert( i , key )
        self._vals.insert( i , val )

    def lt ( self , key ) :
        # O(log n + t) in a real balanced BST (t is the output size)
        i = bisect_left( self._keys , key )
        return tuple( self._vals[:i] )
bst = BalancedBST()
bst.insert( 23 , "me" )
bst.insert( 57 , "dad" )
bst.insert( 19 , "bro" )
bst.insert( 51 , "mom" )
assert( bst.lt( 26 ) == ( 'bro' , 'me' ) )
assert( bst.lt( 23 ) == ( 'bro' , ) )
def vdot ( a , b ) :
    return sum( x * y for ( x , y ) in zip( a , b ) )
assert( vdot( ( 1 , 2 , 3 ) , ( 4 , 5 , 6 ) ) == 1 * 4 + 2 * 5 + 3 * 6 )
def vsub ( a , b ) :
    return tuple( x - y for ( x , y ) in zip( a , b ) )
assert( vsub( ( 1 , 2 , 3 ) , ( 4 , 5 , 6 ) ) == ( 1 - 4 , 2 - 5 , 3 - 6 ) )
def vadd ( a , b ) :
    return tuple( x + y for ( x , y ) in zip( a , b ) )
assert( vadd( ( 1 , 2 , 3 ) , ( 4 , 5 , 6 ) ) == ( 1 + 4 , 2 + 5 , 3 + 6 ) )
def vmul( c , b ) :
    return tuple( c * x for x in b )
assert( vmul( 7 , ( 4 , 5 , 6 ) ) == ( 7 * 4 , 7 * 5 , 7 * 6 ) )
def _box ( A , n ) :
    """
    output: hyperplanes that define the bounding box
    """
    V = A.ambient_space( )
    pv = { }
    for i in range( n ) :
        yield V([+1] + [0]*i + [1] + [0]*(n-i-1))
        yield V([-1] + [0]*i + [1] + [0]*(n-i-1))

def box ( A , n ) :
    """
    output: hyperplanes that define the bounding box
    with position vector for a point that is inside
    """
    AH = A(*tuple(_box(A,n)))
    origin = (0,)*n
    pv = { h : s for ( h , s ) in zip( AH.hyperplanes( ) , AH.sign_vector( origin ) ) }
    return pv
n = 3
A = HyperplaneArrangements( QQ , ( "x" , "y" , "z" ) )
for h , s in box( A , n ).items( ) : print( '{} : {}'.format( h , s ) )
def maxindset ( A , n , G , H ) :
    """
    output: a maximally independent set E of hyperplanes such that G \subseteq E and E \subseteq G \cup H
    G will size at most n
    Complexity = |H|n^3 (could be made |H|n^2)
    """

    M = [ g.coefficients( )[1:] for g in G ]
    for h in H :
        _M = M + [ h.coefficients( )[1:] ]
        if matrix( A._base_ring , _M ).rank( ) == len( _M ) :
            M = _M
            G = G | frozenset( [ h ] )

    return G
n = 3
A = HyperplaneArrangements( QQ , ( "x" , "y" , "z" ) )
H = box( A , n ).keys( )
G = frozenset( )
maxindset( A , n , G , H )
def ba ( h ) :
    c = tuple( h.coefficients( ) )
    return c[0] , c[1:]
n = 3
A = HyperplaneArrangements( QQ , ( "x" , "y" , "z" ) )
V = A.ambient_space( )
b , a = ba( V( [ 3 , 2 , 0 , 1 ] ) )
assert( b == 3 )
assert( a == (2,0,1) )
def randomkSUMTuple ( n , k ) :
    # IT IS NOT UNIFORM, IT SHOULD BE
    return tuple( randint(0,n-1) for i in range( k ) )

def tupleToHyperplane ( V , n , t ) :
    # input: t is a tuple of indices ( i1 , i2 , ... , in )
    # output: xi1 + xi2 + ... + xin = 0
    c = Counter( t )
    return V( [ 0 ] + [ c[i] for i in range( n ) ] )

def randomkSUMHyperplane ( V , n , k ) :
    return tupleToHyperplane( V , n , randomkSUMTuple( n , k ) )

n = 3
k = 2
A = HyperplaneArrangements( QQ , ( "x" , "y" , "z" ) )
V = A.ambient_space( )
randomkSUMHyperplane( V , n , k )
# k-SUM algorithms

def _2SUM ( A , B ) :
    # A and B are assumed to be sorted and have unique entries
    # O(|A|+|B|)
    m = len( A )
    n = len( B )
    i = 0
    j = n - 1
    while i < m and j >= 0 :
        if A[i] + B[j] < 0 :
            i += 1
        elif A[i] + B[j] > 0 :
            j -= 1
        else :
            yield A[i] , B[j]
            i += 1
            j -= 1

def _3SUM ( A , B , C ) :
    # A, B, and C are assumed to be sorted and have unique entries
    # O(|C|(|A|+|B|))
    for c in C :
        for a , b in _2SUM( A , tuple( b + c for b in B ) ) :
            yield a , b - c , c

def kSUM ( k , S ) :
    assert( k in ZZ and k > 0 )
    n = len( S )
    # O(n^ceil(k/2) + |O| )
    if k % 2 == 0 :
        mapAB = { }
        for t in product( range( n ) , repeat = k / 2 ) :
            mapAB.setdefault( sum( S[i] for i in t ) , [ ] ).append( t )
        A = B = sorted( mapAB.keys( ) )
        for a , b in _2SUM( A , B ) :
            for t in mapAB[a] :
                for u in mapAB[b] :
                    yield t + u
    else :
        mapAB = { }
        for t in product( range( n ) , repeat = ( k - 1 ) / 2 ) :
            mapAB.setdefault( sum( S[i] for i in t ) , [ ] ).append( t )
        A = B = sorted( mapAB.keys( ) )
        mapC = { }
        for i , c in enumerate( S ) :
            mapC.setdefault( c , [ ] ).append( ( i , ) )
        C = sorted( mapC.keys( ) )
        for a , b , c in _3SUM( A , B , C ) :
            for t in mapAB[a] :
                for u in mapAB[b] :
                    for v in mapC[c] :
                        yield t + u + v

list( kSUM( 5 , ( 17*2 , 1 , -17*3 ) ) )
def _solve ( field , n , A , b ) :
    G = matrix( field , [ list(row) + [d] for row, d in zip( A , b ) ] )
    G.echelonize()
    x = [ ]
    for i in range( n - 1 , -1 , -1 ) :
        x.append( G[i][n] - sum( G[i][j] * x[n-j-1] for j in range( i + 1 , n ) ) )
    return tuple(reversed( x ))
A = [ [ 1 , 3 , 0 ] , [ 1 , 2 , 7 ] , [ 4 , 5 , 6 ] ]
b = [ 3 , 5 , 7 ]
x = _solve( QQ , 3 , A , b )
assert( matrix( QQ , A ) * matrix( QQ , x ).T == matrix( QQ , b ).T )
def Hhrep ( H , n , P ) :
    """
    O(n^4) ?
    output: an hyperplane that contains all points in P
    """

    A = [ list( p ) for p in P ]
    # add independent term to equations
    A = [ [ 1 ] + row for row in A ]

    # check if points are linearly independent
    D = matrix( H._base_ring , A )
    if D.rank( ) < n :
        raise ValueError( 'the subspace is not an hyperplane' )
    # all equations are now of the type a0 + a1 x1 + a2 x2 + ... + an xn = 0
    b = [ 0 ] * n
    for i in range( n + 1 ) :
        # add an arbitrary constraint to only allow one solution, namely ai = -1
        _A = A + [ [ 0 ] * i + [ 1 ] + [ 0 ] * ( n - i ) ]
        D = matrix( H._base_ring , _A )
        if D.rank( ) < n + 1 :
            continue
        _b = b + [ -1 ]
        x = _solve( H._base_ring , n + 1 , _A , _b )
        V = H.ambient_space( )
        return V(x)
    raise Exception( 'should never reach here')
n = 3
H = HyperplaneArrangements( QQ , ( "x" , "y" , "z" ) )
V = H.ambient_space( )
Hhrep( H , n , ( ( 0 , 1 , 1 ) , ( 0 , 1 , 0 ) , ( 0 , 0 , 1 ) ) )
Hhrep( H , n , ( ( 0 , 0 , 0 ) , ( 0 , 1 , 0 ) , ( 0 , 0 , 1 ) ) )
Hhrep( H , n , ( ( 1 , 0 , 0 ) , ( 0 , 1 , 0 ) , ( 0 , 0 , 1 ) ) )
Hhrep( H , n , ( ( 2 , 0 , 0 ) , ( 0 , 1 , 0 ) , ( 0 , 0 , 1 ) ) )
# colinear points in R^3
try:
    Hhrep( H , n , ( ( 0 , 1 , 1 ) , ( 0 , 2 , 0 ) , ( 0 , 0 , 2 ) ) )
    assert(False)
except:
    assert(True)
def Shrep( H , n , S ) :
    """
    output: H-representation of simplex S
    """
    for i in range( n + 1 ) :
        yield Hhrep( H , n , S[:i] + S[i+1:] )
list( Shrep( H , n , ( ( 0 , 0 , 0 ) , ( 1 , 0 , 0 ) , ( 0 , 1 , 0 ) , ( 0 , 0 , 1 ) ) ) )
list( Shrep( H , n , ( ( 1 , 1 , 1 ) , ( 1 , 0 , 0 ) , ( 0 , 1 , 0 ) , ( 0 , 0 , 1 ) ) ) )
# events
EVENT_BINGO = -1
EVENT_SIMPLEX = 0
EVENT_PV = 1
# A1: compute simplex
#   > T1(n,H) = O(n^c|H|)
#   > Q1(n,H) = O(n|H|)

# A2: Meiser with epsilon = O(1)
#   > T2(n,H) = O(n|H|)
#   > Q2(n,H) = O(n^3 log^2 n log |H|)

# A3: algorithm for double k-SUM
#   > T3(n,H) = ?
#   > Q3(n,H) = ?

# A4: algorithm for multiple k-SUM
#   > T4(n,H) = ?
#   > Q4(n,H) = ?

# A5: Meiser with epsilon = O(n^(-ak))
#   > T5(n,H) = ?
#   > Q5(n,H) = ?


def A1 ( A , n , I , E , pv , q , C = None ) :

    """
    Runs in time O(n^c(|I|+|E|+|C|)) and asks O(n|I|) queries
       - C is an optional parameter that restrict the search for the simplex to a subspace,
         C a list of simplices that contain q.
    """
    if C is None : r = n
    else :
        # we need to compute the rank of the matrix defined by convex combination
        # constraints of the simplices that are not fully dimensional.
        # an Stores the number of variables added for each simplex.
        # SIMPLICES contain q in their interior so the intersection of two d-simplices
        # lying on the same d-flat is d-dimensional.
        an = sum( len( S ) for S in C )
        M = [ ]
        i = 0
        for S in C :
            d = len( S )
            # a1 + a2 + ... + a3 = 1
            M.append( [ 0 ] * n + [ 0 ] * i + [ 1 ] * d + [ 0 ] * ( an - i - d ) + [ 1 ] )
            for j in range( n ) :
                # a1 v11 + a2 v21 + ... + a3 v31 = x1
                # a1 v12 + a2 v22 + ... + a3 v32 = x2
                # .. ... + .. ... + ... + .. ... = ..
                # a1 v1n + a2 v2n + ... + a3 v3n = xn
                M.append( [ 0 ] * ( j ) + [ -1 ] + [ 0 ] * ( n - j - 1 ) + [ 0 ] * i + [ v[j] for v in S ] + [ 0 ] * ( an - i - d ) + [ 0 ] )
            i += d

        r = matrix( A._base_ring , M ).rank( )

    # base case, the subspace E has dimension 0
    assert( len( E ) <= r )
    if len( E ) == r :
        return frozenset( [ q ] )

    # pick a random objective function f
    f = [ random( ) for i in range( n ) ]
    # construct the LP
    lp = MixedIntegerLinearProgram( maximization = True )
    # define the variables x_i
    _x = lp.new_variable( real = True )
    x = [ _x[i] for i in range( n ) ]
    # set the objective function
    lp.set_objective( vdot( f , x ) )
    # add constraints depending on pv
    for h in I | E :
        c = h.coefficients( )
        b , a = c[0] , c[1:]
        fn = b + vdot( a , x )
        if pv[h] < 0 : lp.add_constraint( fn <= 0 )
        elif pv[h] > 0 : lp.add_constraint( fn >= 0 )
        else : lp.add_constraint( fn == 0 )

    if C is not None :
        # define the variables a_i
        _a = lp.new_variable( real = True )
        _a.set_min( 0 ) # convex combination
        a = [ _a[i] for i in range( an ) ]
        for row in M :
            lp.add_constraint( vdot( row[0:n] , x ) + vdot( row[n:n+an] , a ) == row[-1] )

    # solve the LP
    lp.solve( )
    # retrieve v
    _v = lp.get_values( _x )
    v = [ _v[i] for i in range( n ) ]

    # compute lambda for all hyperplanes in I
    # (this can and should be implemented as linear queries)
    L = { h : - ( b + vdot( a , v ) ) / ( vdot( a , vsub( q , v ) ) ) for ( h , b , a ) in map( lambda h : ( h , ) + ba(h) , I ) if vdot( a , vsub( q , v ) ) != 0 }

    # find minimum > 0
    # (this can and should be implemented as linear queries)
    Lt = min( L[h] for h in I if L[h] > 0 )
    Ht = set( h for h in I if L[h] == Lt )

    _I = I - Ht
    _E = maxindset( A , n , E , Ht )
    _pv = ChainMap( { h : 0 for h in Ht } , pv )
    _q = vadd( v , vmul( Lt , vsub( q , v ) ) )
    _S = A1( A , n , _I , _E , _pv , _q )

    return frozenset( [ s ] ) | _S


def A2 ( A , n , BB , H , q , epsilon = 1/2 , delta = 1 ) :

    """
    Runs in time O( n|H| ) and asks O(n^3 log^2 n log |H|) queries.
    """

    # delta is a constant factor that increases the probability for N
    # to be an e-net
    enetsize = ceil( delta * ( n**2 / epsilon * log( n / epsilon )**2 ) )

    # base case of the recursion
    # |H| decreases geometrically
    # there are thus O(log|H|) recursive steps
    if enetsize >= len( H ) :
        AH = A(*H)
        yield EVENT_PV , { h : s for ( h , s ) in zip( AH.hyperplanes( ) , AH.sign_vector( q ) ) }
        return

    # N is an e-net with probability ...
    N = frozenset( sample( H , enetsize ) )
    AN = A(*N)

    # compute the position of q relatively to the hyperplanes of N
    # this costs O(|N|) queries and time
    pv = ChainMap( { h : s for ( h , s ) in zip( AN.hyperplanes( ) , AN.sign_vector( q ) ) } , BB )

    # compute a simplex with A1
    I = frozenset( h for h in N if pv( h ) != 0 ) | BB.keys()
    E = maxindset( A , n , frozenset( ) , N - I )
    S = A1( A , n , I , E , pv , q )

    yield EVENT_SIMPLEX , S

    # compute the position of the vertices of S relatively to the hyperplanes of H - N
    H_N = H - N
    AH_N = A(*H_N)
    pvS = { v : { h : s for ( h , s ) in zip( AH_N.hyperplanes( ) , AH_N.sign_vector( v ) ) } for v in S }

    # for any hyperplane h that contains S, set pv(h) = 0
    # for any hyperplane h that is above S, set pv(h) = +1
    # for any hyperplane h that is below S, set pv(h) = -1

    for h in H_N :
        if all( pvS[v][h] == 0 for v in S ) : pv[h] = 0
        elif all( pvS[v][h] >= 0 for v in S ) : pv[h] = 1
        elif all( pvS[v][h] <= 0 for v in S ) : pv[h] = -1

    # recurse on the other hyperplanes
    # that is, the hyperplanes for which we do not
    # know pv(h)
    # there are at most epsilon|H| such hyperplanes
    _H = H_N - pv.keys( )
    for event in A2( A , n , BB , _H , q , epsilon , delta ) :
        event_type , data = event
        if event_type == EVENT_SIMPLEX : yield event
        elif event_type == EVENT_PV : yield EVENT_PV , ChainMap( data , pv )
        else : yield event


def A3 ( A , n , k , v1 , v2 ) :

    # handles k even or odd
    ckt = ceil( k / 2 )
    fkt = floor( K / 2 )

    M = n**ckt
    N = n**fkt

    # kSUM k/2-tuples
    X = list( product( range( n ) , ckt ) )
    Y = list( product( range( n ) , fkt ) )

    # sums in v1 and v2
    SX1 = { t : sum( v1[i] for i in t ) for t in X }
    SY1 = { t : sum( v1[i] for i in t ) for t in Y }
    SX2 = { t : sum( v2[i] for i in t ) for t in X }
    SY2 = { t : sum( v2[i] for i in t ) for t in Y }

    # sort sums
    PX1 = sorted( X , key = lambda t : SX1[t] )
    PY1 = sorted( Y , key = lambda t : SY1[t] )
    PX2 = sorted( X , key = lambda t : SX2[t] )
    PY2 = sorted( Y , key = lambda t : SY2[t] )

    # follow the + path in M1
    # M1
    #    - - - 0
    #    - - 0
    #    - - 0
    #    0 0 0
    #    0
    #  i +
    #    +
    bst = BalancedBST() # must use order PX2
    i = M-1
    j = 0

    while j < N :
        # go up
        while i >= 0 and SX1[PX1[i]] + SY1[PY1[j]] > 0 :
            t = PX1[i]
            bst.insert(SX2[t] , t)
            i -= 1

        target = -SY2[PY1[j]]
        for u in bst.lt( target ) :
            yield u + PY1[j]

        # go right
        j += 1

    # do the symmetric case with + path in M2
    # THIS IS NOT IN THE PAPER

    bst = BalancedBST() # must use order PX1
    i = M-1
    j = 0

    while j < N :
        # go up
        while i >= 0 and SX2[PX2[i]] + SY2[PY2[j]] > 0 :
            t = PX2[i]
            bst.insert(SX2[t] , t)
            i -= 1

        target = -SY1[PY2[j]]
        for u in bst.lt( target ) :
            yield u + PY2[j]

        # go right
        j += 1


def A4 ( n , k , v ) :
    d = 1
    for v_i in v :
        for v_ij in v_i :
            d *= Rational( v_ij ).denominator( )

    z = [ [ v_ij * d for v_ij in v_i ] for v_i in v ]
    U = max( map( abs , chain( *z ) ) ) # this is what we need to prove the log is bounded by O(n^c polylog n)
    b = 2*U+1
    S = [ ]
    for j in range( n ) :
        s = 0
        for z_i in z :
            s *= b
            s += z_i[j] # not adding U here is equivalent to adding U and then removing it
        S.append( s )

    for t in  kSUM( k , S ) :
        yield t
def A5 ( A , n , k , q , delta = 1 ) :

    """
    Runs in time O( n^(k/2+c) ) and asks O(n^3 log^3 n) queries.
    """

    # alpha, epsilon
    alpha = 1/2
    epsilon = 1/n**(alpha*k)

    # delta is a constant factor that increases the probability for N
    # to be an e-net
    enetsize = ceil( delta * ( n**2 / epsilon * log( n / epsilon )**2 ) )

    # N is an e-net with probability ...
    # generate enetsize uniform random hyperplanes (THIS IS NOT UNIFORM???)
    V = A.ambient_space( )
    N = frozenset( randomkSUMHyperplane( V , n , k ) for i in range( enetsize ) )
    AN = A(*N)

    # compute the list of simplices with A2
    # this costs O(n^(ak+1)) time and O(n^3 log^3 n) queries
    BB = box( A , n )
    simplices = [ ]
    for event in A2( A , n , BB , N , q ) :
        event_type , data = event
        if event_type == EVENT_SIMPLEX : simplices.append( data )
        elif event_type == EVENT_PV : pv = data
        else : yield event

    # compute a simplex with A1
    # this costs O(n^3 log^3 n) queries and time O(n^(2+c) log^2 n)
    I = frozenset( chain( map( Shrep , S ) for S in simplices if len( S ) == n + 1 ) )
    E = frozenset( )
    C = frozenset( S for S in simplices if len( S ) <= n )
    S = A1( A , n , I , E , { } , q , C )

    yield EVENT_SIMPLEX , S

    # if |S| < n + 1, use A4 to detect if any k-SUM hyperplane contains S
    if len( S ) < n + 1 :
        for t in A4( n , k , S ) :
            yield EVENT_BINGO , t

    # if |S| is not a 0-simplex,
    # use A3 to compute the hyperplanes that intersect S
    # there are at most epsilon|H| such hyperplanes
    if len( S ) > 1 :
        _H = frozenset( chain( *[ A3( A , n , k , v1 , v2 ) for v1 , v2 in combinations( S , 2 ) ] ) )

        for event in A2( A , n , BB , _H , q ) :
            event_type , data = event
            if event_type == EVENT_SIMPLEX : pass
            elif event_type == EVENT_PV : pv = ChainMap( data , pv )
            else : pass

        for h , s in pv.items( ) :
            if s == 0 :
                yield EVENT_BINGO , h

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













