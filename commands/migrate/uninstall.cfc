/**
* Uninstalls the cfmigrations table from your database.
*
* The cfmigrations table keeps track of the migrations ran against your database.
* Uninstall it when you are removing cfmigrations from your application.
*/
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
    * @verbose If true, errors will output a full stack trace.
    */
    function run( boolean verbose = false ) {
        try {
            if ( ! migrationService.isMigrationTableInstalled() ) {
                return error( "No Migration table detected." );
            }

            migrationService.uninstall();
            print.line( "Migration table uninstalled!" ).line();
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
