/**
 * Resets the database by clearing out all objects
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @migrationsDirectory Override the default relative location of the migration files
     * @verbose             If true, errors output a full stack trace
     */
    function run( string migrationsDirectory = "", boolean verbose = false ) {
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

        try {
            migrationService.reset();
            print.greenLine( "Database reset!" );
        } catch ( any e ) {
            if ( verbose ) {
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
