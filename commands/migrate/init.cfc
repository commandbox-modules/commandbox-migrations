/**
 * Initialize your project to use commandbox-migrations.
 *
 * Creates a `.cbmigrations.json` configuration file in the current working
 * directory with sensible defaults. Edit this file to configure your database
 * connection, migrations directory, seeders directory, and named managers for
 * multi-database support.
 *
 * If a legacy `.cfmigrations.json` file is detected, you will be prompted to
 * rename it to `.cbmigrations.json` instead of creating a new blank config.
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
        var directory     = getCWD()
        var configFileName = ".cbmigrations.json"
        var configPath    = "#directory##configFileName#"
        var legacyPath    = "#directory#.cfmigrations.json"

        // Check and see if the new config file already exists
        if ( fileExists( configPath ) ) {
            print.yellowLine( "#configFileName# already exists." )
            return
        }

        // Detect legacy .cfmigrations.json and offer to migrate it
        if ( fileExists( legacyPath ) ) {
            print.line()
            print.boldYellowLine( "A legacy '.cfmigrations.json' configuration file was detected." )
            print.yellowLine( "The config file has been renamed to '.cbmigrations.json' in this version of Migrations." )
            print.line()

            if ( confirm( "Would you like to rename '.cfmigrations.json' to '.cbmigrations.json' now? [y/n]" ) ) {
                fileMove( legacyPath, configPath )
                print.greenLine( "Renamed '.cfmigrations.json' to '.cbmigrations.json' successfully." )
                print.line()
            } else {
                print.yellowLine( "Skipped rename. Your '.cfmigrations.json' is still in use, but consider renaming it manually." )
                print.line()
                return
            }

            // Open file?
            if ( arguments.open ) {
                openPath( configPath )
            }

            return
        }

        // Create a fresh config from the template
        var configStub = fileRead( "/commandbox-migrations/templates/config.txt" )

        file action="write" file="#configPath#" mode="777" output="#trim( configStub )#";

        print.greenLine( "Created #configFileName# config file." )

        // Open file?
        if ( arguments.open ) {
            openPath( configPath )
        }
    }

}
