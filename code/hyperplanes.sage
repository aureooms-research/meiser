def ba ( h ) :
    c = tuple( h.coefficients( ) )
    return c[0] , c[1:]
n = 3
A = HyperplaneArrangements( QQ , ( "x" , "y" , "z" ) )
V = A.ambient_space( )
b , a = ba( V( [ 3 , 2 , 0 , 1 ] ) )
assert( b == 3 )
assert( a == (2,0,1) )


