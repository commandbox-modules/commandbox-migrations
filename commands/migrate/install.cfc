/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Installs the migrations table in to your database.
 * The migrations table keeps track of the migrations ran against your database.
 * It must be installed before running any migrations.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @verbose       If true, errors will output a full stack trace.
     */
    function run( string manager = "default", boolean verbose = false ) {
        setup( arguments.manager );

        if ( verbose ) {
            print.blackOnYellowLine( "cbmigrations info:" );
            print.line( getMigrationsInfo() ).line();
        }

        try {
            if ( variables.migrationService.isReady() ) {
                print.line( "Migration table already installed." );
                return;
            }

            variables.migrationService.install();
            print.line( "Migration table installed!" ).line();
        } catch ( any e ) {
            if ( verbose ) {
                if ( structKeyExists( e, "Sql" ) ) {
                    print.whiteOnRedLine( "Error when trying to reset the database:" );
                    print.line( variables.sqlHighlighter.highlight( variables.sqlFormatter.format( e.Sql ) ).toAnsi() );
                }
                rethrow;
            }

            return error( e.message, e.detail );
        }
    }

}
