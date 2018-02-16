/**
* Apply one or all pending migrations against your database.
*/
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
    * @once                Only apply a single migration.
    * @migrationsDirectory Specify the relative location of the migration files
    * @verbose             If true, errors output a full stack trace
    */
    function run(
        boolean once = false,
        string migrationsDirectory = "resources/database/migrations",
        boolean verbose = false
    ) {
        pagePoolClear();
        var relativePath = fileSystemUtil.makePathRelative(
            fileSystemUtil.resolvePath( migrationsDirectory )
        );
        migrationService.setMigrationsDirectory( relativePath );

        try {
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
        }
        catch ( any e ) {
            if ( verbose ) {
                rethrow;
            }

            switch ( e.type ) {
                case "expression":
                    return error( e.message, e.detail );
                case "database":
                    var migration = e.tagContext[ 4 ];
                    var templateName = listLast( migration.template, "/" );
                    var newline = "#chr(10)##chr(13)#";
                    return error( e.detail, "#templateName##newline##e.queryError#" );
                default:
                    rethrow;
            }
        }

        print.line();
    }

}
