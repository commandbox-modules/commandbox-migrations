component {

    this.dependencies = [ "cfmigrations" ];

    function configure() {
        var sqlHighlighter = createObject( "java", "org.jline.builtins.Nano$SyntaxHighlighter" ).build(
            createObject( "java", "java.io.File" )
                .init( expandPath( "/commandbox-migrations/lib/sql.nanorc" ) )
                .toURI()
                .toURL()
                .toString()
        );
        binder
            .map( "SqlHighlighter" )
            .asSingleton()
            .toValue( sqlHighlighter );
    }

}
