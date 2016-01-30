# A2: Meiser with epsilon = O(1)
#   > T2(n,H) = O(n|H|)
#   > Q2(n,H) = O(n^3 log^2 n log |H|)


def A2(A, n, BB, H, q, epsilon=1 / 2, delta=1):
    """
    Runs in time O( n|H| ) and asks O(n^3 log^2 n log |H|) queries.
    """

    yield EVENT_ENTER , 'A2'

    # delta is a constant factor that increases the probability for N
    # to be an e-net
    enetsize = ceil(delta * (n**2 / epsilon * math.log(n / epsilon)**2))

    # base case of the recursion
    # |H| decreases geometrically
    # there are thus O(log|H|) recursive steps
    if enetsize >= len(H):
        AH = A(*H)
        yield EVENT_PV, {h: s for (h, s) in zip(AH.hyperplanes(), AH.sign_vector(q))}
        return

    # N is an e-net with probability ...
    N = frozenset(sample(H, enetsize))
    AN = A(*N)

    # compute the position of q relatively to the hyperplanes of N
    # this costs O(|N|) queries and time
    pv = ChainMap({h: s for (h, s) in zip(
        AN.hyperplanes(), AN.sign_vector(q))}, BB)

    # compute a simplex with A1
    I = frozenset(h for h in N if pv(h) != 0) | BB.keys()
    E = maxindset(A, n, frozenset(), N - I)

    for event in A1(A, n, I, E, pv, q) :
        event_type , data = event
        if event_type == EVENT_SIMPLEX :
            S = data
        else :
            yield event

    yield EVENT_SIMPLEX, S

    # compute the position of the vertices of S relatively to the hyperplanes
    # of H - N
    H_N = H - N
    AH_N = A(*H_N)
    pvS = {v: {h: s for (h, s) in zip(AH_N.hyperplanes(),
                                      AH_N.sign_vector(v))} for v in S}

    # for any hyperplane h that contains S, set pv(h) = 0
    # for any hyperplane h that is above S, set pv(h) = +1
    # for any hyperplane h that is below S, set pv(h) = -1

    for h in H_N:
        if all(pvS[v][h] == 0 for v in S):
            pv[h] = 0
        elif all(pvS[v][h] >= 0 for v in S):
            pv[h] = 1
        elif all(pvS[v][h] <= 0 for v in S):
            pv[h] = -1

    # recurse on the other hyperplanes
    # that is, the hyperplanes for which we do not
    # know pv(h)
    # there are at most epsilon|H| such hyperplanes
    _H = H_N - pv.keys()
    for event in A2(A, n, BB, _H, q, epsilon, delta):
        event_type, data = event
        if event_type == EVENT_SIMPLEX:
            yield event
        elif event_type == EVENT_PV:
            yield EVENT_PV, ChainMap(data, pv)
        else:
            yield event

    yield EVENT_EXIT , 'A2'

