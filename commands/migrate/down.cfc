component extends="cfmigrations-commands.models.BaseMigrationCommand" {

    function run( boolean once = false, string migrationsDirectory = "resources/database/migrations" ) {
        migrationService.setMigrationsDirectory( "#getCWD()#/#arguments.migrationsDirectory#" );

        checkForInstalledMigrationTable();

        if ( ! migrationService.hasMigrationsToRun( "down" ) ) {
            print.line().yellowLine( "No migrations to rollback." ).line();
        }
        else if ( once ) {
            migrationService.runNextMigration( "down", function( migration ) {
                print.whiteLine( "#migration.componentName# rolled back successfully!" );
            } );
        }
        else {
            migrationService.runAllMigrations( "down", function( migration ) {
                print.whiteLine( "#migration.componentName# rolled back successfully!" );
            } );
        }

        print.line();
    }

}
