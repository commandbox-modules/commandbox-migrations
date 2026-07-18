component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * Remove one or all BoxLang JDBC driver modules installed by commandbox-migrations.
     *
     * {code:bash}
     * migrate drivers remove
     * migrate drivers remove mysql
     * migrate drivers remove --force
     * {code}
     * @driverName Optional driver name or slug. If omitted, all managed drivers are removed.
     * @force  If true, skips the confirmation prompt.
     */
    function run( string driverName = "", boolean force = false ) {
        var drivers = getInstalledBoxLangDriverSlugs();

        if ( len( trim( arguments.driverName ) ) ) {
            var requestedDriver = lCase( trim( arguments.driverName ) );
            var requestedSlug = left( requestedDriver, 3 ) == "bx-"
                ? requestedDriver
                : detectBoxLangDriverSlug( { type: requestedDriver } );

            if ( !len( requestedSlug ) ) {
                return error( "Unsupported BoxLang JDBC driver [#arguments.driverName#]." );
            }

            if ( !arrayFindNoCase( drivers, requestedSlug ) ) {
                print.yellowLine( "BoxLang JDBC driver [#requestedSlug#] is not installed." );
                return;
            }

            if ( !arguments.force && !confirm(
                "Remove BoxLang JDBC driver [#requestedSlug#]? [y/n]"
            ) ) {
                print.yellowLine( "Aborting driver removal." );
                return;
            }

            removeBoxLangDriver( requestedSlug );
            print.greenLine( "Removed BoxLang JDBC driver [#requestedSlug#]." );
            return;
        }

        if ( !drivers.len() ) {
            print.yellowLine( "No BoxLang JDBC drivers installed." );
            return;
        }

        if ( !arguments.force && !confirm(
            "Remove all installed BoxLang JDBC drivers? [y/n]"
        ) ) {
            print.yellowLine( "Aborting driver removal." );
            return;
        }

        removeAllBoxLangDrivers();
        print.greenLine( "Removed #drivers.len()# BoxLang JDBC driver(s)." );
    }

}
