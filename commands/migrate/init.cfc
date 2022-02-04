/**
 * Initialize your project to use commandbox-migrations
 * Make sure you are running this command in the root of your app.
 *
 * This will ensure the correct values are set in your box.json.
 */
component {

    property name="packageService" inject="PackageService";
    property name="JSONService" inject="JSONService";

    function run( boolean open = false ) {
        var directory = getCWD();

        var configPath = "#directory#/.cfmigrations.json";

        // Check and see if a .cfmigrations.json file exists
        if ( fileExists( configPath ) ) {
            print.yellowLine( ".cfmigrations.json already exists." );
            return;
        }

        var configStub = fileRead( "/commandbox-migrations/templates/config.txt" );

        file action="write" file="#configPath#" mode="777" output="#trim( configStub )#";

        print.greenLine( "Created .cfmigrations config file." );

        // Open file?
        if ( arguments.open ) {
            openPath( configPath );
        }
    }

}
