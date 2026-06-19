/**
 * Rollback all committed migrations and then apply all migrations in order.
 *
 * This is the equivalent of running `migrate down` followed by `migrate up`.
 * Unlike `migrate fresh`, this uses each migration's `down()` method to
 * reverse changes rather than dropping all database objects directly.
 *
 * {code:bash}
 * ## Roll back all migrations then re-apply them
 * migrate refresh
 *
 * ## Refresh and seed the database
 * migrate refresh --seed
 *
 * ## Refresh a named manager
 * migrate refresh --manager=secondary
 *
 * ## Refresh with verbose error output
 * migrate refresh --verbose
 * {code}
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @seed          If true, runs all seeders for the manager after creating a fresh database.
     * @verbose       If true, errors output a full stack trace
     */
    function run( string manager = "default", boolean seed = false, boolean verbose = false ) {
        setup( arguments.manager );

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cbmigrations info:" );
            print.line( getMigrationsInfo() ).line();
        }

        pagePoolClear();

        command( "migrate down" ).params( argumentCollection = arguments ).run();
        command( "migrate up" ).params( argumentCollection = arguments ).run();
    }

}
