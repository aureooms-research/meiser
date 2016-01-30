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

