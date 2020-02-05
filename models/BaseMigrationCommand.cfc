component {

    property name="migrationService" inject="MigrationService@cfmigrations";
    property name="fileSystemUtil" inject="FileSystem";
    property name="packageService" inject="PackageService";
    property name="JSONService" inject="JSONService";

    function setup() {
        variables.cfmigrationsInfo = getCFMigrationsInfo();
        var appSettings = getApplicationSettings();
        var dsources = appSettings.datasources ?: {};
        dsources[ "cfmigrations" ] = cfmigrationsInfo.connectionInfo;
        application action='update' datasources=dsources;
        application action='update' datasource='cfmigrations';
        migrationService.setDefaultGrammar( cfmigrationsInfo.defaultGrammar );
        migrationService.setDatasource( "cfmigrations" );
        param cfmigrationsInfo.schema = "";
        migrationService.setSchema( cfmigrationsInfo.schema );
    }

    private function checkForInstalledMigrationTable() {
        if ( ! migrationService.isMigrationTableInstalled() ) {
            if ( confirm( "Migration table not installed.  Do you want to install it now? [y\n]" ) ) {
                migrationService.install();
            }
            else {
                error( "Aborting migration.  Please install the migration table and try again." );
            }
        }
    }

    private function getCFMigrationsInfo() {
        var directory = getCWD();

        // Check and see if box.json exists
        if( ! packageService.isPackage( directory ) ) {
            return error( "File [#packageService.getDescriptorPath( directory )#] does not exist." );
        }

        var boxJSON = packageService.readPackageDescriptor( directory );

        if ( ! JSONService.check( boxJSON, "cfmigrations" ) ) {
            return error( "There is no `cfmigrations` key in your box.json. Please create one with the necessary values. See https://github.com/commandbox-modules/commandbox-migrations" );
        }

        return JSONService.show( boxJSON, "cfmigrations" );
    }

}
