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
        setupDatasource();

        if ( verbose ) {
            print.blackOnYellowLine( "cfmigrations info:" );
            print.line( variables.cfmigrationsInfo ).line();
        }

        pagePoolClear();
        if ( len( arguments.migrationsDirectory ) ) {
            setMigrationPath( arguments.migrationsDirectory );
        }

        var currentlyRunningMigration = { "componentName": "UNKNOWN Migration" };
        try {
            checkForInstalledMigrationTable();

            if ( ! migrationService.hasMigrationsToRun( "up" ) ) {
                print.line().yellowLine( "No migrations to run." ).line();
            }
            else if ( once ) {
                migrationService.runNextMigration(
                    direction = "up",
                    preProcessHook = ( migration ) => {
                        currentlyRunningMigration = migration;
                        print.yellow( "Migrating: " ).line( migration.componentName );
                    },
                    postProcessHook = ( migration ) => {
                        print.green( "Migrated:  " ).line( migration.componentName );
                    }
                );
            }
            else {
                migrationService.runAllMigrations(
                    direction = "up",
                    preProcessHook = ( migration ) => {
                        currentlyRunningMigration = migration;
                        print.yellow( "Migrating: " ).line( migration.componentName );
                    },
                    postProcessHook = ( migration ) => {
                        print.green( "Migrated:  " ).line( migration.componentName );
                    }
                );
            }
        }
        catch ( any e ) {
            if ( verbose ) {
                if ( structKeyExists( e, "Sql" ) ) {
                    print.whiteOnRedLine( "Error when trying to run #currentlyRunningMigration.componentName#:" );
                    print.line( variables.sqlHighlighter.highlight( variables.sqlFormatter.format( e.Sql ) ).toAnsi() );
                }
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
