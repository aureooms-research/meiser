import json
import math
from itertools import cycle

_width = 800
_height = _width

DRAW_H = False
DRAW_H1 = True
DRAW_S = True
DRAW_I = True

def gaussian(x, a, b, c, d=0):
    return a * math.exp(-(x - b)**2 / (2 * c**2)) + d

def gradient(n) :
    for i in range(n):
        x = i * 603 / (n-1)
        r = int(gaussian(x, 158.8242, 201, 87.0739) + gaussian(x, 158.8242, 402, 87.0739))
        g = int(gaussian(x, 129.9851, 157.7571, 108.0298) + gaussian(x, 200.6831, 399.4535, 143.6828))
        b = int(gaussian(x, 231.3135, 206.4774, 201.5447) + gaussian(x, 17.1017, 395.8819, 39.3148))
        yield (r, g, b)

def convert(v):

    a = v.index(1)
    i = a // n
    j = a % n
    b = v.index(-1, a+1)
    k = b - n*i
    assert 0 <= i < j < k <= n
    return x[i], y[i], x[j], y[j], x[k], y[k]

def tox ( c ) :
    return width*(1+c)/2

def toy ( c ) :
    return height*(1-(1+c)/2)

def myline(x1,y1,x2,y2):
    line(tox(x1), toy(y1), tox(x2), toy(y2))

def mytriangle(v):
    x1, y1, x2, y2, x3, y3 = convert(v)
    triangle(tox(x1), toy(y1), tox(x2), toy(y2), tox(x3), toy(y3))
    

def setup():
    
    global I, _sorted, signs, x, y, n, side, colors
    with open("../traces/_gpt.json") as f:
        data = json.load(f)
        
    step1 = data['trace'][0]
    n = data['meta']['n']
    x = data['meta']['x']
    y = data['meta']['y']
        
    #size(_width,_height)
    fullScreen()
    pixelDensity(displayDensity())
    frameRate(1)

    signs = { tuple(h) : s for ( h , s ) in step1['signs'] }
    side = step1['side']
    assert side in [-1,0,1]
    _sorted=list(map(tuple,step1["sorted"])) # triangles sorted by areas
    I = cycle(filter( lambda h : signs[h]['reason'] == 'REASON_IS_INFERRED' , signs.iterkeys() ))
    
    colorgen = gradient(len(_sorted))
    colors = { h : next(colorgen) for h in _sorted }


def draw():
    
    background(245)
    
    h = next(I)
    h1 = _sorted[0]
    
    if DRAW_S:
        S = set()
        for i, c in enumerate(signs[h]['coefficients']):
            if not -0.01 < c < 0.01:
                # add the two hyperplanes of the difference
                S.add(_sorted[i])
                S.add(_sorted[i+1])
                
        if DRAW_H1:
            S.discard(h1)
    
    if DRAW_H:
        print("-------H---------")
        noFill()
        strokeWeight(1)
        stroke(20,20,20,200)
        for a, b in zip(x,y):
            for c, d in zip(x,y):
                myline(a,b,c,d)
                
    
    if DRAW_S:
        print("-------S---------")
        print("side", side)
        strokeWeight(2)
        for s in S:
            r, g, b = colors[s]
            fill(r,g,b,10)
            stroke(r,g,b,200)
            mytriangle(s)
            
    if DRAW_H1:
        print("-------h1---------")
        fill(30,30,30,40)
        strokeWeight(2)
        stroke(30,30,30,200)
        mytriangle(h1)
        
            
    if DRAW_I:
        print("-------infer---------")
        fill(230,60,60,40)
        strokeWeight(2)
        stroke(230,60,60,200)
        mytriangle(h)