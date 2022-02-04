/**
 * Rollback all committed migrations and then apply all migrations in order.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager.hint       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @seed.hint          If true, runs all seeders for the manager after creating a fresh database.
     * @verbose.hint       If true, errors output a full stack trace
     */
    function run( string manager = "default", boolean seed = false, boolean verbose = false ) {
        setup( arguments.manager );

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cfmigrations info:" );
            print.line( variables.cfmigrationsInfo ).line();
        }

        pagePoolClear();

        command( "migrate down" ).params( argumentCollection = arguments ).run();
        command( "migrate up" ).params( argumentCollection = arguments ).run();
    }

}
