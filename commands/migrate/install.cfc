/**
 * Installs the cfmigrations table in to your database.
 *
 * The cfmigrations table keeps track of the migrations ran against your database.
 * It must be installed before running any migrations.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @verbose If true, errors will output a full stack trace.
     */
    function run( boolean verbose = false ) {
        setup();
        setupDatasource();

        if ( verbose ) {
            print.blackOnYellowLine( "cfmigrations info:" );
            print.line( variables.cfmigrationsInfo ).line();
        }

        try {
            if ( migrationService.isMigrationTableInstalled() ) {
                print.line( "Migration table already installed." );
                return;
            }

            migrationService.install();
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
