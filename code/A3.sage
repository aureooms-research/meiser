# A3: algorithm for double k-SUM
#   > T3(n,H) = ?
#   > Q3(n,H) = ?


def A3(A, n, k, v1, v2):

    yield EVENT_ENTER , 'A3'

    # handles k even or odd
    ckt = ceil(k / 2)
    fkt = floor(K / 2)

    M = n**ckt
    N = n**fkt

    # kSUM k/2-tuples
    X = list(product(range(n), ckt))
    Y = list(product(range(n), fkt))

    # sums in v1 and v2
    SX1 = {t: sum(v1[i] for i in t) for t in X}
    SY1 = {t: sum(v1[i] for i in t) for t in Y}
    SX2 = {t: sum(v2[i] for i in t) for t in X}
    SY2 = {t: sum(v2[i] for i in t) for t in Y}

    # sort sums
    PX1 = sorted(X, key=lambda t: SX1[t])
    PY1 = sorted(Y, key=lambda t: SY1[t])
    PX2 = sorted(X, key=lambda t: SX2[t])
    PY2 = sorted(Y, key=lambda t: SY2[t])

    # follow the + path in M1
    # M1
    #    - - - 0
    #    - - 0
    #    - - 0
    #    0 0 0
    #    0
    #  i +
    #    +
    bst = BalancedBST()  # must use order PX2
    i = M - 1
    j = 0

    while j < N:
        # go up
        while i >= 0 and SX1[PX1[i]] + SY1[PY1[j]] > 0:
            t = PX1[i]
            bst.insert(SX2[t], t)
            i -= 1

        target = -SY2[PY1[j]]
        for u in bst.lt(target):
            yield EVENT_TUPLE , u + PY1[j]

        # go right
        j += 1

    # do the symmetric case with + path in M2
    # THIS IS NOT IN THE PAPER

    bst = BalancedBST()  # must use order PX1
    i = M - 1
    j = 0

    while j < N:
        # go up
        while i >= 0 and SX2[PX2[i]] + SY2[PY2[j]] > 0:
            t = PX2[i]
            bst.insert(SX2[t], t)
            i -= 1

        target = -SY1[PY2[j]]
        for u in bst.lt(target):
            yield EVENT_TUPLE , u + PY2[j]

        # go right
        j += 1

    yield EVENT_EXIT , 'A3'
