/**
 * Runs one or all seeders for an application against your database.
 * Seeders have no concept of being ran.
 * Running a seeder multiple times will insert data multiple times.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @name.hint          The name of a seed to run. Runs all seeds if left blank.
     * @name.optionsUDF    completeSeedNames
     * @manager.hint       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @verbose.hint       If true, errors output a full stack trace.
     * @pretend.hint       If true, only pretends to run the query.  The SQL that would have been run is printed to the console.
     * @file.hint          If provided, outputs the SQL that would have been run to the file. Only applies when running `pretend`.
     */
    function run(
        string name = "",
        string manager = "default",
        boolean verbose = false,
        boolean pretend = false,
        string file
    ) {
        setup( arguments.manager );

        if ( getCFMigrationsType() == "boxJSON" ) {
            error( "Seeders can only be ran after migrating to the new v4 migrations configuration." );
        }

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cfmigrations info:" );
            print.line( getCFMigrationsInfo() ).line();
        }

        pagePoolClear();

        var statements = [];
        var currentlyRunningSeeder = "UNKNOWN";
        try {
            migrationService.seed(
                seedName = arguments.name == "" ? nullValue() : arguments.name,
                pretend = arguments.pretend,
                preProcessHook = ( seeder ) => {
                    currentlyRunningSeeder = seeder;
                    print.yellow( "Seeding: " ).line( seeder ).toConsole();
                },
                postProcessHook = ( seeder, qb ) => {
                    if ( !pretend ) {
                        print.green( "Seeded:  " ).line( seeder ).toConsole();
                    } else {
                        print.green( "Pretended to seed:  " ).line( seeder ).toConsole();
                        print.line();
                        for ( var q in qb.getQueryLog() ) {
                            var inlineSql = qb.getUtils().replaceBindings( q.sql, q.bindings, true );
                            statements.append( inlineSql );
                            print.line( inlineSql );
                            print.line();
                        }
                    }
                }
            );
        } catch ( any e ) {
            if ( verbose ) {
                if ( structKeyExists( e, "Sql" ) ) {
                    print.whiteOnRedLine( "Error when trying to seed #currentlyRunningSeeder#:" );
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

        if ( currentlyRunningSeeder == "UNKNOWN" ) {
            print.line( "No seeders to run." );
        }

        if ( arguments.pretend && !isNull( arguments.file ) ) {
            file action="write" file="#fileSystemUtil.resolvePath( arguments.file )#" mode="666" output="#trim( statements.toList( ";" & chr( 10 ) & chr( 10 ) ) )#";
            print.whiteOnBlueLine( "Wrote SQL to file: #arguments.file#" );
        }
    }

    function completeSeedNames( string paramSoFar, struct passedNamedParameters ) {
        param passedNamedParameters.manager = "default";
        setup( passedNamedParameters.manager );
        if ( getCFMigrationsType() == "boxJSON" ) {
            return [];
        }
        return variables.migrationService.findSeeds()
            .map( ( seedFile ) => listLast( seedFile.componentPath, "." ) )
            .filter( ( seeder ) => startsWith( seeder, paramSoFar ) )
            .map( ( seeder ) => ( { "name": seeder, "group": "Seeders (#passedNamedParameters.manager#)" } ) );
    }

}
