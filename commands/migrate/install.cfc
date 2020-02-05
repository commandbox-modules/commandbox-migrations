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
        if ( verbose ) {
            systemOutput( "cfmigrations info:", true );
            systemOutput( variables.cfmigrationsInfo, true );
        }

        try {
            if ( migrationService.isMigrationTableInstalled() ) {
                print.line( "Migration table already installed." );
                return;
            }

            migrationService.install();
            print.line( "Migration table installed!" ).line();
        }
        catch ( any e ) {
            if ( verbose ) {
                rethrow;
            }

            return error( e.message, e.detail );
        }
    }

}
