/**
* Initialize your project to use commandbox-migrations
* Make sure you are running this command in the root of your app.
*
* This will ensure the correct values are set in your box.json.
*/
component {

    property name="packageService" inject="PackageService";
    property name="JSONService" inject="JSONService";

    function run() {
        var directory = getCWD();
        // Check and see if box.json exists
        if( ! packageService.isPackage( directory ) ) {
            return error( "File [#packageService.getDescriptorPath( directory )#] does not exist." );
        }

        // Read without defaulted values
		var boxJSON = packageService.readPackageDescriptorRaw( directory );

        if ( JSONService.check( boxJSON, "cfmigrations" ) ) {
            print.yellowLine( "cfmigrations already configured for this project." );
            return;
        }

		JSONService.set( boxJSON, {
            "cfmigrations.defaultGrammar": "AutoDiscover",
            "cfmigrations.schema": "${DB_DATABASE}",
            "cfmigrations.connectionInfo.class": "${DB_CLASS}",
            "cfmigrations.connectionInfo.connectionString": "${DB_CONNECTIONSTRING}",
            "cfmigrations.connectionInfo.username": "${DB_USER}",
            "cfmigrations.connectionInfo.password": "${DB_PASSWORD}"
        }, false );

		// Write the file back out.
        PackageService.writePackageDescriptor( boxJSON, directory );
        print.greenLine( "cfmigrations configured!" );
    }

}
