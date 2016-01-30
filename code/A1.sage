# A1: compute simplex
#   > T1(n,H) = O(n^c|H|)
#   > Q1(n,H) = O(n|H|)

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
        b , a = ba( h )
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

