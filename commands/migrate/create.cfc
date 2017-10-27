/**
* Create a new migration CFC in an existing application.
* Make sure you are running this command in the root of your app.
*
* It prepends the date at the beginning of the file name so
* you can keep your migrations in the correct order.
*/
component {

    /**
    * @name Name of the migration to create without the .cfc.
    * @directory The base directory to create your migration in. Creates the directory if it does not exist.
    * @open Open the file once generated
    */
    function run(
        required string name,
        string directory = "resources/database/migrations",
        boolean open = false
    ) {
        // This will make each directory canonical and absolute
        arguments.directory = fileSystemUtil.resolvePath( arguments.directory );

        // Validate directory
        if( !directoryExists( arguments.directory ) ) {
            directoryCreate( arguments.directory );
        }

        var timestamp = dateTimeFormat( now(), "yyyy_mm_dd_hhnnss" );
        var migrationPath = "#arguments.directory#/#timestamp#_#arguments.name#.cfc";

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
