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

def Shrep( A , n , S ) :
    """
    output: H-representation of simplex S
    """
	assert( len( S ) >= 1 )
	assert( len( S ) <= n + 1 )

	pv = { }
	X = frozenset( S )
	r = len( S )

	if r < n + 1 :
		# if simplex is not full dimensional we need to add some artificial
		# vertices (e_i vectors spawned from an arbitrary vertex S[0])
		G = frozenset( S )
		H = ( vadd( S[0] , [ 0 ] * i + [ 1 ] + [ 0 ] * ( n - i - 1 ) ) for i in range( n ) )
		O = _maxindset( A , G , H )
		S.extend( O )

	# hyperplanes that do not contain all vertices of S
	# spawn inequality constraints
    for i in range( r ) :
		h = Hhrep( A , n , S[:i] + S[i+1:] )
        pv[h] = pos( tuple( h.coefficients( ) ) , S[i] )

	# hyperplanes that contain all vertices of S
	# spawn equality constraints
	for i in range( r + 1 , n + 1 ) :
		h = Hhrep( A , n , S[:i] + S[i+1:] )
		pv[h] = 0

	return pv

Shrep( H , n , ( ( 0 , 0 , 0 ) , ( 1 , 0 , 0 ) , ( 0 , 1 , 0 ) , ( 0 , 0 , 1 ) ) )
Shrep( H , n , ( ( 1 , 1 , 1 ) , ( 1 , 0 , 0 ) , ( 0 , 1 , 0 ) , ( 0 , 0 , 1 ) ) )
Shrep( H , n , ( ( 0 , 0 , 0 ) , ( 1 , 0 , 0 ) ) )
Shrep( H , n , ( ( 0 , 0 , 0 ) ) )
