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
     */
    function run( string name = "", string manager = "default", boolean verbose = false ) {
        setup( arguments.manager );

        if ( variables.cfmigrationsInfoType == "boxJSON" ) {
            error( "Seeders can only be ran after migrating to the new v4 migrations configuration." );
        }

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cfmigrations info:" );
            print.line( variables.cfmigrationsInfo ).line();
        }

        pagePoolClear();

        var currentlyRunningSeeder = "UNKNOWN";
        try {
            migrationService.seed(
                seedName = arguments.name == "" ? nullValue() : arguments.name,
                preProcessHook = ( seeder ) => {
                    currentlyRunningSeeder = seeder;
                    print.yellow( "Seeding: " ).line( seeder ).toConsole();
                },
                postProcessHook = ( seeder ) => {
                    print.green( "Seeded:  " ).line( seeder ).toConsole();
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
    }

    function completeSeedNames( string paramSoFar, struct passedNamedParameters ) {
        param passedNamedParameters.manager = "default";
        setup( passedNamedParameters.manager );
        if ( variables.cfmigrationsInfoType == "boxJSON" ) {
            return [];
        }
        return variables.migrationService.findSeeds()
            .map( ( seedFile ) => listLast( seedFile.componentPath, "." ) )
            .filter( ( seeder ) => startsWith( seeder, paramSoFar ) )
            .map( ( seeder ) => ( { "name": seeder, "group": "Seeders (#passedNamedParameters.manager#)" } ) );
    }

}
