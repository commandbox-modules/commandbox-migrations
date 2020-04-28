/**
* Rollback one or all of the migrations already ran against your database.
*/
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
    * @once                Only rollback a single migration.
    * @migrationsDirectory Override the default relative location of the migration files
    * @verbose             If true, errors output a full stack trace
    */
    function run(
        boolean once = false,
        string migrationsDirectory = "",
        boolean verbose = false
    ) {
        setup();
        pagePoolClear();
        if ( len(arguments.migrationsDirectory) )
            setMigrationPath( arguments.migrationsDirectory );

        try {
            checkForInstalledMigrationTable();

            if ( ! migrationService.hasMigrationsToRun( "down" ) ) {
                print.line().yellowLine( "No migrations to rollback." ).line();
            }
            else if ( once ) {
                migrationService.runNextMigration( "down", function( migration ) {
                    print.line( "#migration.componentName# rolled back successfully!" );
                } );
            }
            else {
                migrationService.runAllMigrations( "down", function( migration ) {
                    print.line( "#migration.componentName# rolled back successfully!" );
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
