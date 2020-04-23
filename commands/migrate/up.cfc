/**
* Apply one or all pending migrations against your database.
*/
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
    * @once                Only apply a single migration.
    * @migrationsDirectory Override the default relative location of the migration files
    * @verbose             If true, errors output a full stack trace
    */
    function run(
        boolean once = false,
        string migrationsDirectory = "",
        boolean verbose = false
    ) {
        setup();

        if ( verbose ) {
            systemOutput( "cfmigrations info:", true );
            systemOutput( variables.cfmigrationsInfo, true );
        }

        pagePoolClear();
        if ( len(arguments.migrationsDirectory) )
            setMigrationPath( migrationsDirectory );

        try {
            checkForInstalledMigrationTable();

            if ( ! migrationService.hasMigrationsToRun( "up" ) ) {
                print.line().yellowLine( "No migrations to run." ).line();
            }
            else if ( once ) {
                migrationService.runNextMigration( "up", function( migration ) {
                    print.line( "#migration.componentName# migrated successfully!" );
                } );
            }
            else {
                migrationService.runAllMigrations( "up", function( migration ) {
                    print.line( "#migration.componentName# migrated successfully!" );
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
                    return error(
                        len( e.detail ) ? e.detail : e.message,
                        "#templateName##newline##e.queryError#"
                    );
                default:
                    rethrow;
            }
        }

        print.line();
    }

}
