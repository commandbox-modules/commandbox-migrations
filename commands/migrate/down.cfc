/**
 * Rollback one or all of the migrations already ran against your database.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @once.hint          Only rollback a single migration.
     * @manager.hint       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @verbose.hint       If true, errors output a full stack trace.
     */
    function run( boolean once = false, string manager = "default", boolean verbose = false ) {
        setup( arguments.manager );

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cfmigrations info:" );
            print.line( getCFMigrationsInfo() ).line();
        }

        pagePoolClear();

        var currentlyRunningMigration = { "componentName": "UNKNOWN Migration" };
        try {
            checkForInstalledMigrationTable();

            if ( !variables.migrationService.hasMigrationsToRun( "down" ) ) {
                print.line().yellowLine( "No migrations to rollback." ).line();
            } else if ( arguments.once ) {
                variables.migrationService.runNextMigration(
                    direction = "down",
                    preProcessHook = ( migration ) => {
                        currentlyRunningMigration = migration;
                        print.yellow( "Rolling back: " ).line( migration.componentName ).toConsole();
                    },
                    postProcessHook = ( migration ) => {
                        print.green( "Rolled back:  " ).line( migration.componentName ).toConsole();
                    }
                );
            } else {
                variables.migrationService.runAllMigrations(
                    direction = "down",
                    preProcessHook = ( migration ) => {
                        currentlyRunningMigration = migration;
                        print.yellow( "Rolling back: " ).line( migration.componentName ).toConsole();
                    },
                    postProcessHook = ( migration ) => {
                        print.green( "Rolled back:  " ).line( migration.componentName ).toConsole();
                    }
                );
            }
        } catch ( any e ) {
            if ( arguments.verbose ) {
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
                    var newline = "#chr( 10 )##chr( 13 )#";
                    return error(
                        len( e.detail ) ? e.detail : e.message,
                        "#templateName##newline##variables.sqlHighlighter.highlight( variables.sqlFormatter.format( e.queryError ) ).toAnsi()#"
                    );
                default:
                    rethrow;
            }
        }

        print.line();
    }

}
