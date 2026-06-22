/**
 * Reset the database by dropping all tables, views, and other schema objects.
 *
 * WARNING: This is a destructive operation! All schema objects will be dropped.
 * No migration `down()` methods are called — the database is wiped directly.
 *
 * This command is used internally by `migrate fresh`. You can run it standalone
 * when you want to clear the database without immediately re-running migrations.
 *
 * {code:bash}
 * ## Drop all database objects
 * migrate reset
 *
 * ## Reset a named manager's database
 * migrate reset --manager=secondary
 *
 * ## Reset with verbose error output
 * migrate reset --verbose
 * {code}
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager          The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @verbose          If true, errors output a full stack trace.
     * @installDrivers   If true, auto-install the BoxLang JDBC driver module. Default: true.
     */
    function run( string manager = "default", boolean verbose = false, boolean installDrivers = true ) {
        setup( manager: arguments.manager, installDrivers = arguments.installDrivers );

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cbmigrations info:" );
            print.line( getMigrationsInfo() ).line();
        }

        try {
            variables.migrationService.reset();
            print.greenLine( "Database reset!" );
        } catch ( any e ) {
            if ( arguments.verbose ) {
                if ( structKeyExists( e, "Sql" ) ) {
                    print.whiteOnRedLine( "Error when trying to reset the database:" );
                    print.line( variables.sqlHighlighter.highlight( variables.sqlFormatter.format( e.Sql ) ).toAnsi() );
                }
                rethrow;
            }

            switch ( e.type ) {
                case "expression":
                case "OperationNotSupported":
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
    }

}
