# A5: Meiser with epsilon = O(n^(-ak))
#   > T5(n,H) = ?
#   > Q5(n,H) = ?


def A5(A, n, k, q, delta=1):
    """
    Runs in time O( n^(k/2+c) ) and asks O(n^3 log^3 n) queries.
    """

    yield EVENT_ENTER , 'A5'

    # alpha, epsilon
    alpha = 1 / 2
    epsilon = 1 / n**(alpha * k)

    log( 'alpha' , alpha )
    log( 'epsilon' , epsilon )

    # delta is a constant factor that increases the probability for N
    # to be an e-net
    enetsize = ceil(delta * (n**2 / epsilon * math.log(n / epsilon)**2))

    log( 'enetsize' , enetsize )

    # N is an e-net with probability ...
    # generate enetsize uniform random hyperplanes (THIS IS NOT UNIFORM???)
    V = A.ambient_space()
    N = frozenset(randomkSUMHyperplane(V, n, k) for i in range(enetsize))
    AN = A(*N)

    # compute the list of simplices with A2
    # this costs O(n^(ak+1)) time and O(n^3 log^3 n) queries
    BB = box(A, n)
    log( 'BB size' ,  len( BB ) )
    simplices = []
    for event in A2(A, n, BB, N, q):
        event_type, data = event
        if event_type == EVENT_SIMPLEX:
            simplices.append(data)
        elif event_type == EVENT_PV:
            pv = data
        else:
            yield event

    # compute a simplex with A1
    # this costs O(n^3 log^3 n) queries and time O(n^(2+c) log^2 n)
    pv = reduce( ChainMap , map(Shrep, simplices) , pv )
    I = frozenset(h for h, s in pv.items() if s != 0)
    E = frozenset(h for h, s in pv.items() if s == 0)
    for event in A1(A, n, I, E, pv, q) :
        event_type , data = event
        if event_type == EVENT_SIMPLEX :
            S = data
        else :
            yield event


    yield EVENT_SIMPLEX, S

    # if |S| < n + 1, use A4 to detect if any k-SUM hyperplane contains S
    if len(S) < n + 1:
        for event in A4(n, k, S):
            event_type, data = event
            if event_type == EVENT_TUPLE:
                yield EVENT_BINGO, data
            else:
                yield event

    # if |S| is not a 0-simplex,
    # use A3 to compute the hyperplanes that intersect S
    # there are at most epsilon|H| such hyperplanes
    if len(S) > 1:
        _H = set( )
        for v1 , v2 in combinations( S , 2 ) :
            for event in A3(A, n, k, v1, v2) :
                event_type, data = event
                if event_type == EVENT_TUPLE:
                    _H.add( tupleToHyperplane( V , n , data ) )
                else:
                    yield event

        for event in A2(A, n, BB, _H, q):
            event_type, data = event
            if event_type == EVENT_PV:
                for h, s in data.items():
                    if s == 0:
                        for t in hyperplaneToTuples( h ) :
                            yield EVENT_BINGO, t
            else:
                yield event


    yield EVENT_EXIT , 'A5'
