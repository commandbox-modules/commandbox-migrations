/**
 * Create a new seeder CFC in an existing application.
 * Make sure you are running this command in the root of your app.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @name.hint          Name of the seeder to create without the .cfc.
     * @manager.hint       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @open.hint          Open the file once generated.
     */
    function run( required string name, string manager = "default", boolean open = false ) {
        setup( manager = arguments.manager, setupDatasource = false );

        var seedsDirectory = expandPath( variables.migrationService.getSeedsDirectory() );

        // Validate seedsDirectory
        if ( !directoryExists( seedsDirectory ) ) {
            directoryCreate( seedsDirectory );
        }

        var seedPath = "#seedsDirectory##arguments.name#.cfc";

        var seedContent = fileRead( "/commandbox-migrations/templates/seed.txt" );

        file action="write" file="#seedPath#" mode="777" output="#trim( seedContent )#";

        print.greenLine( "Created #seedPath#" );

        // Open file?
        if ( arguments.open ) {
            openPath( seedPath );
        }
    }

}
