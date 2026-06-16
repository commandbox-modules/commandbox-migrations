component {

    this.dependencies = [ "cfmigrations", "sqlFormatter" ];

    /**
     * Module lifecycle method. Registers the SqlHighlighter singleton, falling back
     * to a no-op highlighter if the jLine SyntaxHighlighter can't be built.
     */
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
