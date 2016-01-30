# A4: algorithm for multiple k-SUM
#   > T4(n,H) = ?
#   > Q4(n,H) = ?

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

