# Learning

## How to

### Download

    git clone https://github.com/aureooms-research/meiser
    cd meiser/learning

### Help

    $ sage klm17.sage -h
    usage: klm17.sage.py [-h] -n N [-v] [-c] [-t]
                         [-s {GLPK,GLPK/exact,Coin,CPLEX,CVXOPT,Gurobi,PPL,InteractiveLP}]
                         (--ksum k | --xy)
    
    Solves a random k-SUM-like instance using the algorithm in [KLM17].
    
    optional arguments:
      -h, --help            show this help message and exit
      -n N                  Input size.
      -v, --verbose         Be verbose.
      -c, --check           Check solution.
      -t, --trace           Output trace of the algorithm as JSON.
      -s {GLPK,GLPK/exact,Coin,CPLEX,CVXOPT,Gurobi,PPL,InteractiveLP}, --solver {GLPK,GLPK/exact,Coin,CPLEX,CVXOPT,Gurobi,PPL,InteractiveLP}
                            Use GLPK for (fast) float solution and PPL for exact
                            rational solution. Default is GLPK
      --ksum k              Try with a random k-SUM instance. Needs one argument
                            for `k`.
      --xy                  Try with a random sorting X+Y instance.

### Example

	$ sage klm17.sage --check --verbose --xy -n 20 --trace > trace-xy-20.json
	INFO:root:n 20
	INFO:root:w 4
	INFO:root:c 5
	INFO:root:m 200
	INFO:root:d 420
	INFO:root:2d 840
	INFO:root:|H| 2025
	INFO:root:q (-0.955677783278301, -0.703685096792140, -0.629242484273609, -0.519660747606316, -0.515086520987002, -0.293460386770847, 0.214510873932553, 0.370754355276739, 0.429813761614144, 0.550562577562562, -0.977917892402098, -0.960507569960311, -0.747810217662566, -0.471663330550513, -0.235508097948501, -0.146379156017681, -0.123059907051098, -0.118631975194686, -0.0371636372444963, 0.960820309378978)
	DEBUG:root:GLPK: Problem has no feasible solution
	DEBUG:root:BINGO!!!
	DEBUG:root:BINGO!!!
	...

### Trace format

	$ jq < trace.json '. | keys'
	[
	  "argv",
	  "trace"
	]

#### `.argv`

	$ jq < trace.json '.argv'
	[
	  "klm17.sage.py",
	  "--check",
	  "--verbose",
	  "--xy",
	  "-n",
	  "20",
	  "--trace"
	]

#### `.trace`

	$ jq < trace.json '.trace'
	[ ... ]

#### Steps (`.trace[i]`)

##### General case

	$ jq < trace.json '.trace[0]'
	{ ... }

	$ jq < trace.json '.trace[0] | keys'
	[
	  "H",
	  "S",
	  "S+",
	  "S-",
	  "S0",
	  "case",
	  "d",
	  "n",
	  "q",
	  "queries",
	  "side",
	  "signs",
	  "sorted"
	]

	$ jq < trace.json '.trace[0].case'
	"general"

##### Base case

	$ jq < trace.json '.trace[1]'
	{ ... }

	$ jq < trace.json '.trace[1] | keys'
	[
	  "H",
	  "case",
	  "d",
	  "n",
	  "q",
	  "queries",
	  "signs"
	]

	$ jq < trace.json '.trace[1].case'
	"base"


##### `.trace[i].queries`

	$ jq < trace.json '.trace[0].queries'
	{
	  "comparison": 3663,
	  "total": 4503,
	  "label": 840
	}

##### `.trace[i].d`

	$ jq < trace.json '.trace[0].d'
	420

##### `.trace[i].n`

	$ jq < trace.json '.trace[0].n'
	20

##### `.trace[i].q`

	$ jq < trace.json '.trace[0].q'
	[
	  -0.9556777832783008,
	  -0.7036850967921402,
	  -0.6292424842736086,
	  -0.519660747606316,
	  -0.5150865209870021,
	  -0.2934603867708474,
	  0.21451087393255253,
	  0.3707543552767387,
	  0.429813761614144,
	  0.5505625775625616,
	  -0.9779178924020984,
	  -0.960507569960311,
	  -0.7478102176625656,
	  -0.4716633305505129,
	  -0.23550809794850092,
	  -0.1463791560176808,
	  -0.12305990705109848,
	  -0.11863197519468605,
	  -0.03716363724449634,
	  0.9608203093789778
	]

##### `.trace[i].H`

	$ jq < trace.json '.trace[0].H'
	[
	  [ 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, -1, 0, 0 ],
	  ...
	]

##### `.trace[i].signs`

	$ jq < trace.json '.trace[0].signs'
	[
	  [
		[ 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, -1, 0, 0 ],
		{
		  "reason": "REASON_IN_SAMPLE",
		  "sign": -1
		}
	  ],
	  ...,
	  [
		[ 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 0 ],
		{
		  "reason": "REASON_IS_INFERRED",
		  "coefficients": [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0.33333333333333337, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0.16666666666666669, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.8333333333333333, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.583333333333333, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.16666666666666669, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.08333333333333336, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.4166666666666666, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.25, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.5, 0,
	1.4166666666666665, 0, 0, 0, 0, 0, 0, 0.8333333333333333, 1.5, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0.33333333333333337, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 1.75, 0, 0, 0, 3.5, 0, 0, 0, 3.583333333333333,
	3.083333333333333 ],
		  "sign": 1
		}
	  ],
	  ...
	]

##### `.trace[i].S`

	$ jq < trace.json '.trace[0].S'
	[
	  [ 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, -1, 0 ],
	  ...
	]

##### `.trace[i]["S-"]`

	$ jq < trace.json '.trace[0]["S-"]'
	[
	  [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1 ],
	  ...
	]

##### `.trace[i]["S0"]`

	$ jq < trace.json '.trace[0]["S0"]'
	[]

##### `.trace[i]["S+"]`

	$ jq < trace.json '.trace[0]["S+"]'
	[
	  [ 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0 ],
	  ...
	]

##### `.trace[i].side`

	$ jq < trace.json '.trace[0].side'
	1

##### `.trace[i].sorted`

	$ jq < trace.json '.trace[0].sorted
	[
	  [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, 0 ],
	  ...
	]


### Use trace with python

#### Load data

```py
with open('trace.json') as f :
    data = json.load(f)
trace = data['trace']
```

#### `.trace[i].case == "general"`

##### Get sample

```py
S = set(map(tuple, trace[0]['S']))
```

##### Get signs

```py
signs = { tuple(h) : s['sign'] for ( h , s ) in trace[0]['signs'].iteritems() }
```

##### Get inferred set minus sample

```py
I = set(filter( lambda h : signs[h]['reason'] == 'REASON_IS_INFERRED' , signs.iterkeys() ))
```

##### Build pairs of consecutive vectors in sorted order of `Si-Si`

```py
delta = list(zip(trace[0]['sorted'], trace[0]['sorted'][1:]))
```

##### Determine which pairs infer a given `h` in `I` (might be sensitive to solver's precision)

```py
h = next(iter(I))
h_is_inferred_by = set( map( lambda x : x[0] , filter( lambda x : x[1] != 0 , zip( delta , signs[h]['coefficients'] ) ) ) )
```

#### Construct solution

```py
solution = dict( )
for step in trace :
    solution.update( { tuple(h) : s['sign'] for ( h , s ) in step['signs'].iteritems() } )
```
