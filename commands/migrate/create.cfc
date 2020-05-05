/**
* Create a new migration CFC in an existing application.
* Make sure you are running this command in the root of your app.
*
* It prepends the date at the beginning of the file name so
* you can keep your migrations in the correct order.
*/
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
    * @name Name of the migration to create without the .cfc.
    * @migrationsDirectory The base migrationsDirectory to create your migration in. Creates the migrationsDirectory if it does not exist.
    * @open Open the file once generated
    */
    function run(
        required string name,
        string migrationsDirectory = "",
        boolean open = false
    ) {
        setup();

        if ( len(arguments.migrationsDirectory) )
            setMigrationPath( arguments.migrationsDirectory );

        arguments.migrationsDirectory = getMigrationPath();

        // Validate migrationsDirectory
        if( !directoryExists( arguments.migrationsDirectory ) ) {
            directoryCreate( arguments.migrationsDirectory );
        }

        var timestamp = dateTimeFormat( now(), "yyyy_mm_dd_HHnnss" );
        var migrationPath = "#arguments.migrationsDirectory#/#timestamp#_#arguments.name#.cfc";

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
