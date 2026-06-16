/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Create a new seeder CFC in an existing application.
 * Make sure you are running this command in the root of your app.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @name          Name of the seeder to create without the extension.
     * @manager       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @open          Open the file once generated.
     * @boxlang       Create a .bx file instead of a .cfc. Defaults to auto-detection based on your server/box.json.
     */
    function run(
        required string name,
        string manager = "default",
        boolean open = false,
        boolean boxlang = isBoxLangProject( getCWD() )
    ) {
        setup( manager = arguments.manager, setupDatasource = false )

        var seedsDirectory = expandPath( variables.migrationService.getSeedsDirectory() )

        // Validate seedsDirectory
        if ( !directoryExists( seedsDirectory ) ) {
            directoryCreate( seedsDirectory )
        }

        var extension = arguments.boxlang ? "bx" : "cfc"
        var seedPath = "#seedsDirectory##arguments.name#.#extension#"
        var seedContent = fileRead( "/commandbox-migrations/templates/seed#arguments.boxlang ? "BX" : ""#.txt" )

        file action="write" file="#seedPath#" mode="777" output="#trim( seedContent )#";

        print.greenLine( "Created #seedPath#" )

        // Open file?
        if ( arguments.open ) {
            openPath( seedPath )
        }
    }

}
