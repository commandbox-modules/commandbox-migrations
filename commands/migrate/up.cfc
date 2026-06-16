/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Apply one or all pending migrations against your database.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @seed          If true, runs all seeders for the manager after creating a fresh database.
     * @once          Only apply a single migration.
     * @verbose       If true, errors output a full stack trace.
     * @pretend       If true, only pretends to run the query.  The SQL that would have been run is printed to the console.
     * @file          If provided, outputs the SQL that would have been run to the file. Only applies when running `pretend`.
     */
    function run(
        string manager = "default",
        boolean seed = false,
        boolean once = false,
        boolean verbose = false,
        boolean pretend = false,
        string file
    ) {
        setup( arguments.manager );

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cbmigrations info:" );
            print.line( getMigrationsInfo() ).line();
        }

        pagePoolClear();

        var currentlyRunningMigration = { "componentName": "UNKNOWN Migration" };
        try {
            var statements = [];
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
                    postProcessHook = ( migration, schema, qb ) => {
                        if (!pretend) {
                            print.green( "Migrated:  " ).line( migration.componentName ).toConsole();
                        } else {
                            print.green( "Pretended to migrate:  " ).line( migration.componentName ).toConsole();
                            print.line();
                            for ( var q in schema.getQueryLog() ) {
                                var inlineSql = qb.getUtils().replaceBindings( q.sql, q.bindings, true );
                                statements.append( inlineSql );
                                print.line( inlineSql );
                                print.line();
                            }
                            for ( var q in qb.getQueryLog() ) {
                                var inlineSql = qb.getUtils().replaceBindings( q.sql, q.bindings, true );
                                statements.append( inlineSql );
                                print.line( inlineSql );
                                print.line();
                            }
                        }
                    },
                    pretend = arguments.pretend
                );
            } else {
                migrationService.runAllMigrations(
                    direction = "up",
                    preProcessHook = ( migration ) => {
                        currentlyRunningMigration = migration;
                        print.yellow( "Migrating: " ).line( migration.componentName ).toConsole();
                    },
                    postProcessHook = ( migration, schema, qb ) => {
                        if (!pretend) {
                            print.green( "Migrated:  " ).line( migration.componentName ).toConsole();
                        } else {
                            print.green( "Pretended to migrate:  " ).line( migration.componentName ).toConsole();
                            print.line();
                            for ( var q in schema.getQueryLog() ) {
                                var inlineSql = qb.getUtils().replaceBindings( q.sql, q.bindings, true );
                                statements.append( inlineSql );
                                print.line( qb.getUtils().replaceBindings( q.sql, q.bindings, true ) );
                                print.line();
                            }
                            for ( var q in qb.getQueryLog() ) {
                                var inlineSql = qb.getUtils().replaceBindings( q.sql, q.bindings, true );
                                statements.append( inlineSql );
                                print.line( qb.getUtils().replaceBindings( q.sql, q.bindings, true ) );
                                print.line();
                            }
                        }
                    },
                    pretend = arguments.pretend
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

        if ( arguments.pretend && !isNull( arguments.file ) ) {
            file action="write" file="#fileSystemUtil.resolvePath( arguments.file )#" mode="666" output="#trim( statements.toList( ";" & chr( 10 ) & chr( 10 ) ) )#";
            print.whiteOnBlueLine( "Wrote SQL to file: #arguments.file#" );
        }

        print.line();
    }

}
