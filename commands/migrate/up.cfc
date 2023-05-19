/**
 * Apply one or all pending migrations against your database.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager.hint       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @seed.hint          If true, runs all seeders for the manager after creating a fresh database.
     * @once.hint          Only apply a single migration.
     * @verbose.hint       If true, errors output a full stack trace.
     */
    function run(
        string manager = "default",
        boolean seed = false,
        boolean once = false,
        boolean verbose = false
    ) {
        setup( arguments.manager );

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cfmigrations info:" );
            print.line( getCFMigrationsInfo() ).line();
        }

        pagePoolClear();

        var currentlyRunningMigration = { "componentName": "UNKNOWN Migration" };
        try {
            checkForInstalledMigrationTable();

            if ( !migrationService.hasMigrationsToRun( "up" ) ) {
                print.line().yellowLine( "No migrations to run." ).line();
            } else if ( once ) {
                migrationService.runNextMigration(
                    direction = "up",
                    preProcessHook = ( migration ) => {
                        currentlyRunningMigration = migration;
                        print.yellow( "Migrating: " ).line( migration.componentName ).toConsole();
                    },
                    postProcessHook = ( migration ) => {
                        print.green( "Migrated:  " ).line( migration.componentName ).toConsole();
                    }
                );
            } else {
                migrationService.runAllMigrations(
                    direction = "up",
                    preProcessHook = ( migration ) => {
                        currentlyRunningMigration = migration;
                        print.yellow( "Migrating: " ).line( migration.componentName ).toConsole();
                    },
                    postProcessHook = ( migration ) => {
                        print.green( "Migrated:  " ).line( migration.componentName ).toConsole();
                    }
                );
            }
        } catch ( any e ) {
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
                    var newline = "#chr( 10 )##chr( 13 )#";
                    return error(
                        len( e.detail ) ? e.detail : e.message,
                        "#templateName##newline##variables.sqlHighlighter.highlight( variables.sqlFormatter.format( e.queryError ) ).toAnsi()#"
                    );
                default:
                    rethrow;
            }
        }

        if ( arguments.seed ) {
            print.line();
            command( "migrate seed run" )
                .params( argumentCollection = { manager: arguments.manager, verbose: arguments.verbose } )
                .run();
        }

        print.line();
    }

}
