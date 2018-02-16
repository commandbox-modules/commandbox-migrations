/**
 * Resets the database by clearing out all objects
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
    * @migrationsDirectory Specify the relative location of the migration files
    * @verbose             If true, errors output a full stack trace
    */
    function run(
        string migrationsDirectory = "resources/database/migrations",
        boolean verbose = false
    ) {
        pagePoolClear();
        var relativePath = fileSystemUtil.makePathRelative(
            fileSystemUtil.resolvePath( migrationsDirectory )
        );
        migrationService.setMigrationsDirectory( relativePath );

        try {
            migrationService.reset();
            print.greenLine( "Database reset!" );
        }
        catch ( any e ) {
            if ( verbose ) {
                rethrow;
            }

            switch ( e.type ) {
                case "expression":
                case "OperationNotSupported":
                    return error( e.message, e.detail );
                case "database":
                    var migration = e.tagContext[ 4 ];
                    var templateName = listLast( migration.template, "/" );
                    var newline = "#chr(10)##chr(13)#";
                    return error( e.detail, "#templateName##newline##e.queryError#" );
                default:
                    rethrow;
            }
        }
    }

}
