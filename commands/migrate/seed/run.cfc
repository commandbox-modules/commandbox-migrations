/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Run one or all database seeders for an application.
 *
 * Seeders populate your database with initial or sample data. They are
 * typically used to provide development fixtures or default application data.
 *
 * Unlike migrations, seeders have no tracking — they can be run as many times
 * as needed and each run will insert data again. Be careful running seeders
 * against a database that already contains data.
 *
 * {code:bash}
 * ## Run all seeders
 * migrate seed run
 *
 * ## Run a specific seeder by name
 * migrate seed run UserSeeder
 *
 * ## Run seeders for a named manager
 * migrate seed run --manager=secondary
 *
 * ## Run a specific seeder with verbose output
 * migrate seed run UserSeeder --verbose
 * {code}
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @name             The name of a seed to run. Runs all seeds if left blank.
     * @name.optionsUDF  completeSeedNames
     * @manager          The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @verbose          If true, errors output a full stack trace.
     * @installDrivers   If true, auto-install the BoxLang JDBC driver module. Default: true.
     */
    function run(
        string name = "",
        string manager = "default",
        boolean verbose = false,
        boolean installDrivers = true
    ) {
        setup( manager: arguments.manager, installDrivers = arguments.installDrivers );

        if ( getMigrationsConfigType() == "boxJSON" ) {
            error( "Seeders can only be ran after migrating to the new v4 migrations configuration." );
        }

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cbmigrations info:" );
            print.line( getMigrationsInfo() ).line();
        }

        pagePoolClear();

        var currentlyRunningSeeder = "UNKNOWN";
        try {
            migrationService.seed(
                seedName = arguments.name == "" ? nullValue() : arguments.name,
                preProcessHook = ( seeder ) => {
                    currentlyRunningSeeder = seeder;
                    print.yellow( "🌱 Seeding: " ).line( seeder ).toConsole();
                },
                postProcessHook = ( seeder ) => {
                    print.green( "✅ Seeded:  " ).line( seeder ).toConsole();
                }
            );
        } catch ( any e ) {
            if ( arguments.verbose ) {
                if ( structKeyExists( e, "Sql" ) ) {
                    print.whiteOnRedLine( "❌ Error when trying to seed #currentlyRunningSeeder#:" );
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
                        "#templateName##newline##variables.sqlHighlighter.highlight( variables.sqlFormatter.format( e.queryError ?: "" ) ).toAnsi()#"
                    );
            }

            rethrow;
        }

        if ( currentlyRunningSeeder == "UNKNOWN" ) {
            print.yellowLine( "📭 No seeders to run." );
        }
    }

    /**
     * Tab-completion options for the `name` argument, listing seed file names for
     * the passed manager that start with what's been typed so far.
     */
    function completeSeedNames( string paramSoFar, struct passedNamedParameters ) {
        param passedNamedParameters.manager = "default";
        setup( passedNamedParameters.manager );
        if ( getMigrationsConfigType() == "boxJSON" ) {
            return [];
        }
        return variables.migrationService.findSeeds()
            .map( ( seedFile ) => listLast( seedFile.componentPath, "." ) )
            .filter( ( seeder ) => startsWith( seeder, paramSoFar ) )
            .map( ( seeder ) => ( { "name": seeder, "group": "Seeders (#passedNamedParameters.manager#)" } ) );
    }

}
