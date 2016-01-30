
def pos ( h , p ) :
	return sgn( h[0] + vdot( h[1:] , p ) )

assert( pos( [ 1 , 2 ] , [ 4 ] ) == 1 )
assert( pos( [ 1 , 2 ] , [ -1/2 ] ) == 0 )
assert( pos( [ 1 , 2 ] , [ -4 ] ) == -1 )
