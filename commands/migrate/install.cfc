component extends="commandbox-migrations.models.BaseMigrationCommand" {

    function run( string migrationsDirectory = "resources/database/migrations" ) {
        migrationService.setMigrationsDirectory( "#getCWD()#/#arguments.migrationsDirectory#" );

        if ( migrationService.isMigrationTableInstalled() ) {
            return error( "Migration table already installed." );
        }

        migrationService.install();
        print.line( "Migration table installed!" ).line();
    }

}
