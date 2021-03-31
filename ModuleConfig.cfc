component {

    this.dependencies = [ "cfmigrations" ];

    function configure() {
        var sqlHighlighter = {
            "highlight": ( str ) => ( {
                "toAnsi": () => str
            } )
        };
        
        try {
            sqlHighlighter = createObject( "java", "org.jline.builtins.Nano$SyntaxHighlighter" ).build(
                createObject( "java", "java.io.File" )
                    .init( expandPath( "/commandbox-migrations/lib/sql.nanorc" ) )
                    .toURI()
                    .toURL()
                    .toString()
            );
        } catch ( any e ) {
            log.warn( "Could not create the jLine SyntaxHighlighter.  Falling back to no highlighting", e );
        }

        binder
            .map( "SqlHighlighter" )
            .asSingleton()
            .toValue( sqlHighlighter );
    }

}
