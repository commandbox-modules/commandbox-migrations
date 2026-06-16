/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Resets the database and runs all migrations up.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @seed          If true, runs all seeders for the manager after creating a fresh database.
     * @verbose       If true, errors output a full stack trace.
     */
    function run( string manager = "default", boolean seed = false, boolean verbose = false ) {
        setup( arguments.manager );

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cfmigrations info:" );
            print.line( getMigrationsInfo() ).line();
        }

        pagePoolClear();

        command( "migrate reset" ).params( argumentCollection = arguments ).run();
        command( "migrate install" ).params( argumentCollection = arguments ).run();
        command( "migrate up" ).params( argumentCollection = arguments ).run();
    }

}
