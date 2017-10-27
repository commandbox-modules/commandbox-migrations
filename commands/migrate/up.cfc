component extends="cfmigrations-commands.models.BaseMigrationCommand" {

    function run( boolean once = false, string migrationsDirectory = "resources/database/migrations" ) {
        migrationService.setMigrationsDirectory( "#getCWD()#/#arguments.migrationsDirectory#" );

        checkForInstalledMigrationTable();

        if ( ! migrationService.hasMigrationsToRun( "up" ) ) {
            print.line().yellowLine( "No migrations to run." ).line();
        }
        else if ( once ) {
            migrationService.runNextMigration( "up", function( migration ) {
                print.whiteLine( "#migration.componentName# migrated successfully!" );
            } );
        }
        else {
            migrationService.runAllMigrations( "up", function( migration ) {
                print.whiteLine( "#migration.componentName# migrated successfully!" );
            } );
        }

        print.line();
    }

}
