/**
 * Resets the database by clearing out all objects
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager.hint       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @verbose.hint       If true, errors output a full stack trace.
     */
    function run( string manager = "default", boolean verbose = false ) {
        setup( arguments.manager );

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cfmigrations info:" );
            print.line( getCFMigrationsInfo() ).line();
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
