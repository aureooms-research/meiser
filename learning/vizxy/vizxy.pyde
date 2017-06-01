import json

width = 800
height = width

DRAW_H = True
DRAW_S = True
DRAW_I = True

def convert(q,v):
    
    i1=v.index(1)
    j1=v.index(1,i1+1)
    i2=v.index(-1)
    j2=v.index(-1,i2+1)
    return (q[j1], q[i1]), (q[j2], q[i2])

def myline(s):
    p,q = s
    (x1,y1)=p
    (x2,y2)=q
    line(width*(1+x1)/2,height*(1-(1+y1)/2),width*(1+x2)/2,height*(1-(1+y2)/2))

def setup():
    
    global data, step1
    with open("../traces/_xy.json") as f:
        data = json.load(f)
        
    step1 = data['trace'][0]
        
    size(width,height)
    pixelDensity(displayDensity())
    noLoop()
    background(245)


def draw():
    
    for k, v in step1.iteritems():
        if isinstance(v,(int, str, unicode)) :
            print(k, type(v), v)
        else:
            print(k,type(v),len(v))
            
    d=step1["d"]
    H=step1["H"]
    queries=step1["queries"]
    n=step1["n"]
    q=step1["q"]
#    infer=D["infer(S,x)"]
    signs = { tuple(h) : s for ( h , s ) in step1['signs'] }
    S=step1["sorted"]
    print("d",d)
    print("n",n)
    print("q",q)
    I = set(filter( lambda h : signs[h]['reason'] == 'REASON_IS_INFERRED' , signs.iterkeys() ))

    strokeWeight(1)
    
    if DRAW_H:
        print("-------H---------")
        for h in H:
            stroke(20,20,20)
            myline(convert(q,h))
            
    strokeWeight(2)
    
    if DRAW_S:
        print("-------S---------")
        for h in S:
            stroke(255,60,60)
            myline(convert(q,h))
            
    if DRAW_I:
        print("-------infer---------")
        for h in I:
            stroke(60,255,60)
            myline(convert(q,h))