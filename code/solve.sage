def _solve(field, n, A, b):
    G = matrix(field, [list(row) + [d] for row, d in zip(A, b)])
    G.echelonize()
    x = []
    for i in range(n - 1, -1, -1):
        x.append(G[i][n] - sum(G[i][j] * x[n - j - 1]
                               for j in range(i + 1, n)))
    return tuple(reversed(x))
A = [[1, 3, 0], [1, 2, 7], [4, 5, 6]]
b = [3, 5, 7]
x = _solve(QQ, 3, A, b)
assert(matrix(QQ, A) * matrix(QQ, x).T == matrix(QQ, b).T)
