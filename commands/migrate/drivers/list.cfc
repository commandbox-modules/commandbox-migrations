component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * List the BoxLang JDBC driver modules installed by commandbox-migrations.
     *
     * {code:bash}
     * migrate drivers list
     * {code}
     * @json If true, outputs the installed drivers and directory as JSON.
     */
    function run( boolean json = false ) {
        var drivers = getInstalledBoxLangDriverSlugs();

        if ( arguments.json ) {
            print.line(
                serializeJSON( {
                    directory: getBoxLangDriversDirectory(),
                    drivers: drivers
                } )
            );
            return;
        }

        print.boldWhiteLine( "Installed BoxLang JDBC drivers" );
        print.line( "Directory: #getBoxLangDriversDirectory()#" );

        if ( !drivers.len() ) {
            print.yellowLine( "No BoxLang JDBC drivers installed." );
            return;
        }

        for ( var driver in drivers ) {
            print.greenLine( "- #driver#" );
        }
    }

}
