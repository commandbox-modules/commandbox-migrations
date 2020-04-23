/**
* Uninstalls the cfmigrations table from your database.
*
* The cfmigrations table keeps track of the migrations ran against your database.
* Uninstall it when you are removing cfmigrations from your application.
*/
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
    * @migrationsDirectory Override the default relative location of the migration files
    * @verbose             If true, errors output a full stack trace
    * @force               If true, will not wait for confirmation to uninstall cfmigrations.
    */
    function run(
        string migrationsDirectory = "",
        boolean verbose = false,
        boolean force = false
    ) {
        setup();
        pagePoolClear();
        if ( len(arguments.migrationsDirectory) )
            setMigrationPath( migrationsDirectory );

        try {
            if ( ! migrationService.isMigrationTableInstalled() ) {
                print.line( "No Migration table detected" );
                return;
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

            return error( e.message, e.detail );
        }
    }

}
