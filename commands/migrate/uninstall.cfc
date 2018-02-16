/**
* Uninstalls the cfmigrations table from your database.
*
* The cfmigrations table keeps track of the migrations ran against your database.
* Uninstall it when you are removing cfmigrations from your application.
*/
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
    * @migrationsDirectory Specify the relative location of the migration files
    * @verbose             If true, errors output a full stack trace
    * @force               If true, will not wait for confirmation to uninstall cfmigrations.
    */
    function run(
        string migrationsDirectory = "resources/database/migrations",
        boolean verbose = false,
        boolean force = false
    ) {
        pagePoolClear();
        var relativePath = fileSystemUtil.makePathRelative(
            fileSystemUtil.resolvePath( migrationsDirectory )
        );
        migrationService.setMigrationsDirectory( relativePath );

        try {
            if ( ! migrationService.isMigrationTableInstalled() ) {
                return error( "No Migration table detected." );
            }

            if ( force || confirm( "Uninstalling cfmigrations will also run all your migrations down. Are you sure you want to continue? [y/n]" ) ) {
                migrationService.uninstall();
                print.line( "Migration table uninstalled!" ).line();
            }
            else {
                print.line( "Aborting uninstall process." );
            }
        }
        catch ( any e ) {
            if ( verbose ) {
                rethrow;
            }

            switch ( e.type ) {
                case "expression":
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
