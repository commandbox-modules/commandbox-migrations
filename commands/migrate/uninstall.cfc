component extends="commandbox-migrations.models.BaseMigrationCommand" {

    function run( string migrationsDirectory = "resources/database/migrations" ) {
        migrationService.setMigrationsDirectory( "#getCWD()#/#arguments.migrationsDirectory#" );

        if ( ! migrationService.isMigrationTableInstalled() ) {
            return error( "No Migration table detected." );
        }

        migrationService.uninstall();
        print.line( "Migration table uninstalled!" ).line();
    }

}
