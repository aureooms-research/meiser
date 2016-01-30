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

