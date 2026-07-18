component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * Force-install one or all supported BoxLang JDBC driver modules.
     * Without a driver or --all, the driver is detected from the selected
     * migration manager's connectionInfo.
     *
     * {code:bash}
     * migrate drivers install
     * migrate drivers install mysql
     * migrate drivers install --all
     * {code}
     * @driver  Optional driver name or slug, such as `mysql` or `bx-mysql`.
     * @manager Migration manager used to detect the driver when no driver is supplied.
     * @all     If true, force-installs every supported BoxLang JDBC driver.
     */
    function run(
        string driver = "",
        string manager = "default",
        boolean all = false
    ) {
        var drivers = [];

        if ( arguments.all ) {
            drivers = getSupportedBoxLangDriverSlugs();
        } else if ( len( trim( arguments.driver ) ) ) {
            var requestedDriver = lCase( trim( arguments.driver ) );
            var requestedSlug = left( requestedDriver, 3 ) == "bx-"
                ? requestedDriver
                : detectBoxLangDriverSlug( { type: requestedDriver } );

            if ( !len( requestedSlug ) ) {
                return error( "Unsupported BoxLang JDBC driver [#arguments.driver#]." );
            }
            drivers = [ requestedSlug ];
        } else {
            var config = getMigrationsInfo();
            if ( !config.keyExists( arguments.manager ) ) {
                return error( "No manager found named [#arguments.manager#]." );
            }

            var managerConfig = config[ arguments.manager ];
            var connectionInfo = managerConfig.keyExists( "properties" )
                ? ( managerConfig.properties.connectionInfo ?: {} )
                : {};
            var detectedDriver = detectBoxLangDriverSlug( connectionInfo );

            if ( !len( detectedDriver ) ) {
                return error(
                    "Could not detect a BoxLang JDBC driver from manager [#arguments.manager#]. Pass a driver name or --all."
                );
            }
            drivers = [ detectedDriver ];
        }

        for ( var slug in drivers ) {
            print.line( "Force-installing #slug#..." );
            installBoxLangDriver( slug, true );
        }

        print.greenLine( "Installed #drivers.len()# BoxLang JDBC driver(s)." );
    }

}
