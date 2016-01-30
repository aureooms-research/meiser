from bisect import bisect_right, bisect_left

class BalancedBST ( object ) :

    """faking it"""

    def __init__ ( self ) :
        self._keys = [ ]
        self._vals = [ ]

    def insert ( self , key , val ) :
        # O(log n) in a real balanced BST
        i = bisect_right( self._keys , key )
        self._keys.insert( i , key )
        self._vals.insert( i , val )

    def lt ( self , key ) :
        # O(log n + t) in a real balanced BST (t is the output size)
        i = bisect_left( self._keys , key )
        return tuple( self._vals[:i] )

bst = BalancedBST()
bst.insert( 23 , "me" )
bst.insert( 57 , "dad" )
bst.insert( 19 , "bro" )
bst.insert( 51 , "mom" )
assert( bst.lt( 26 ) == ( 'bro' , 'me' ) )
assert( bst.lt( 23 ) == ( 'bro' , ) )

