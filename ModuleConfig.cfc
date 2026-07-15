/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 */
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

    /**
     * Fired when the module is registered and activated. When the active
     * runtime is BoxLang, eagerly loads any JDBC driver modules already
     * present in `<moduleRoot>/boxlang_modules/` so migrations can be
     * executed without a second restart.
     *
     * Loading is a no-op when:
     *   - the runtime is not BoxLang
     *   - the `boxlang_modules` directory does not yet exist
     *   - the BoxRuntime singleton cannot be reached
     *
     * `loadModules(Path)` is idempotent — already-registered modules are
     * skipped — so it is safe to call from both this hook and the
     * `BaseMigrationCommand` install path.
     */
    public void function onLoad() {
        if ( !structKeyExists( server, "boxlang" ) ) {
            return
        }

        var modulesDir = variables.modulePath & "/boxlang_modules";

        if ( !directoryExists( modulesDir ) ) {
            return
        }

        var paths = createObject( "java", "java.nio.file.Paths" );
        getBoxRuntime()
            .getModuleService()
            .loadModules( paths.get( modulesDir ) )
    }

}
