/**
 * Create a new migration CFC in an existing application.
 * Make sure you are running this command in the root of your app.
 *
 * It prepends the date at the beginning of the file name so
 * you can keep your migrations in the correct order.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @name.hint          Name of the migration to create without the .cfc.
     * @manager.hint       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @open.hint          Open the file once generated.
     */
    function run( required string name, string manager = "default", boolean open = false ) {
        setup( manager = arguments.manager, setupDatasource = false );

        var migrationsDirectory = expandPath( variables.migrationService.getMigrationsDirectory() );

        // Validate migrationsDirectory
        if ( !directoryExists( migrationsDirectory ) ) {
            directoryCreate( migrationsDirectory );
        }

        var timestamp = dateTimeFormat( now(), "yyyy_mm_dd_HHnnss" );
        var migrationPath = "#migrationsDirectory##timestamp#_#arguments.name#.cfc";

        var migrationContent = fileRead( "/commandbox-migrations/templates/Migration.txt" );

        file action="write" file="#migrationPath#" mode="777" output="#trim( migrationContent )#";

        print.greenLine( "Created #migrationPath#" );

        // Open file?
        if ( arguments.open ) {
            openPath( migrationPath );
        }

        return;
    }

}
