# A1: compute simplex
#   > T1(n,H) = O(n^c|H|)
#   > Q1(n,H) = O(n|H|)


def A1(A, n, I, E, pv, q):
    """
    Runs in time O(n^c(|I|+|E|)) and asks O(n|I|) queries
    """

    yield EVENT_ENTER , 'A1'

    assert(len(E) <= n)

    # base case, the subspace E has dimension 0
    if len(E) == n:
        yield EVENT_SIMPLEX , frozenset([q])
        yield EVENT_EXIT , 'A1'
        return

    # pick a random objective function f
    f = [random() for i in range(n)]
    # construct the LP
    lp = MixedIntegerLinearProgram(maximization=True)
    # define the variables x_i
    _x = lp.new_variable(real=True)
    x = [_x[i] for i in range(n)]
    # set the objective function
    lp.set_objective(vdot(f, x))
    # add constraints depending on pv
    for h in I | E:
        b, a = ba(h)
        fn = b + vdot(a, x)
        log( 'c' , pv[h] , h , fn )
        if pv[h] < 0:
            lp.add_constraint(fn <= 0)
        elif pv[h] > 0:
            lp.add_constraint(fn >= 0)
        elif pv[h] == 0 :
            lp.add_constraint(fn == 0)
        else :
            raise Exception( 'should never reach here' )

    # solve the LP
    lp.solve()
    # retrieve v
    _v = lp.get_values(_x)
    v = [_v[i] for i in range(n)]

    # compute lambda for all hyperplanes in I
    # (this can and should be implemented as linear queries)
    L = {h: - (b + vdot(a, v)) / (vdot(a, vsub(q, v))) for (h, b, a)
         in map(lambda h: (h, ) + ba(h), I) if vdot(a, vsub(q, v)) != 0}

    # find minimum > 0
    # (this can and should be implemented as linear queries)
    Lt = min(L[h] for h in I if L[h] > 0)
    Ht = set(h for h in I if L[h] == Lt)

    _I = I - Ht
    _E = maxindset(A, n, E, Ht)
    _pv = ChainMap({h: 0 for h in Ht}, pv)
    _q = vadd(v, vmul(Lt, vsub(q, v)))

    for event in  A1(A, n, _I, _E, _pv, _q) :
        event_type, data = event
        if event_type == EVENT_SIMPLEX:
            S = frozenset([s]) | _S
            yield EVENT_SIMPLEX , S
        else:
            yield event

    yield EVENT_EXIT , 'A1'

