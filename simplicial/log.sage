

class Log ( object ) :

    def __init__ ( self ) :

        self.indent = 0


    def inc ( self ) :

        self.indent += 4

    def dec ( self ) :

        self.indent -= 4
        assert( self.indent >= 0 )

    def __call__ ( self , *msg ) :

        print( ' ' * self.indent + ' '.join( map( str , msg ) ) )

log = Log( )
