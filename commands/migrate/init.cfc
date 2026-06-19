/**
 * Initialize your project to use commandbox-migrations.
 *
 * Creates a `.cbmigrations.json` configuration file in the current working
 * directory with sensible defaults. Edit this file to configure your database
 * connection, migrations directory, seeders directory, and named managers for
 * multi-database support.
 *
 * Run this command once when setting up migrations for the first time, then
 * follow up with `migrate install` to create the tracking table in your database.
 *
 * {code:bash}
 * ## Initialize migrations config in the current directory
 * migrate init
 *
 * ## Initialize and immediately open the config file for editing
 * migrate init --open
 * {code}
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * Initialize your project to use commandbox-migrations.
     * Make sure you are running this command in the root of your app.
     *
     * @open Open the config file after it is created.
     */
    function run(
        boolean open = false
    ) {
        var directory = getCWD()
        var configFileName = ".cbmigrations.json"
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
