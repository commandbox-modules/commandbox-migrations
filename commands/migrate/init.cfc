/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Initialize your project to use commandbox-migrations
 * Make sure you are running this command in the root of your app.
 *
 * This will ensure the correct values are set in your box.json.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * Initialize your project to use commandbox-migrations
     * Make sure you are running this command in the root of your app.
     *
     * @open Open the config file after it is created.
     * @boxlang Create a .bxmigrations.json file instead of .cfmigrations.json. Defaults to auto-detection based on your server/box.json.
     */
    function run(
        boolean open = false,
        boolean boxlang = isBoxLangProject( getCWD() )
    ) {
        var directory = getCWD()
        var configFileName = arguments.boxlang ? ".bxmigrations.json" : ".cfmigrations.json"
        var configPath = "#directory#/#configFileName#"

        // Check and see if the config file already exists
        if ( fileExists( configPath ) ) {
            print.yellowLine( "#configFileName# already exists." )
            return
        }

        var configStub = fileRead( "/commandbox-migrations/templates/config.txt" )

        file action="write" file="#configPath#" mode="777" output="#trim( configStub )#";

        print.greenLine( "Created #configFileName# config file." )

        // Open file?
        if ( arguments.open ) {
            openPath( configPath )
        }
    }

}
