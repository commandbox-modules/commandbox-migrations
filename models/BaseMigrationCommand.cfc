component {

    property name="migrationService" inject="MigrationService@cfmigrations";
    property name="fileSystemUtil" inject="FileSystem";
    property name="packageService" inject="PackageService";
    property name="JSONService" inject="JSONService";
    property name="sqlHighlighter" inject="sqlHighlighter";
    property name="sqlFormatter" inject="java:org.hibernate.jdbc.util.DDLFormatterImpl";

    function setup() {
        var cfmigrationsInfo = getCFMigrationsInfo();
        param cfmigrationsInfo.defaultGrammar = "AutoDiscover@qb";
        migrationService.setDefaultGrammar( cfmigrationsInfo.defaultGrammar );
        param cfmigrationsInfo.schema = "";
        migrationService.setSchema( cfmigrationsInfo.schema );
        param cfmigrationsInfo.migrationsDirectory = "resources/database/migrations";
        setMigrationPath( cfmigrationsInfo.migrationsDirectory );
    }

    function setupDatasource() {
        var cfmigrationsInfo = getCFMigrationsInfo();
        var appSettings = getApplicationSettings();
        var dsources = appSettings.datasources ?: {};
        if ( !cfmigrationsInfo.keyExists( "connectionInfo" ) ) {
            return error( "There is no connectionInfo struct defined.  Please add one with the your Lucee-compatible database connection information." );
        }
        if ( left( shell.getVersion(), 1 ) GTE 5 ) {
            if ( !JSONService.check( cfmigrationsInfo.connectionInfo, "bundleName" ) ) {
                return error( "There is no `bundleName` key in your box.json. Please create one with the necessary values. See https://github.com/commandbox-modules/commandbox-migrations" );
            }
            if ( !JSONService.check( cfmigrationsInfo.connectionInfo, "bundleVersion" ) ) {
                return error( "There is no `bundleVersion` key in your box.json. Please create one with the necessary values. See https://github.com/commandbox-modules/commandbox-migrations" );
            }
        }
        dsources[ "cfmigrations" ] = cfmigrationsInfo.connectionInfo;
        application action='update' datasources=dsources;
        application action='update' datasource='cfmigrations';
        migrationService.setDatasource( "cfmigrations" );
    }

    public void function setMigrationPath( required migrationsDirectory ) {
        var relativePath = fileSystemUtil.makePathRelative(
            fileSystemUtil.resolvePath( migrationsDirectory )
        );
        migrationService.setMigrationsDirectory( relativePath );
    }

    public string function getMigrationPath () {
        return migrationService.getMigrationsDirectory();
    }

    private void function checkForInstalledMigrationTable() {
        if ( ! migrationService.isMigrationTableInstalled() ) {
            if ( confirm( "Migration table not installed.  Do you want to install it now? [y\n]" ) ) {
                migrationService.install();
            }
            else {
                error( "Aborting migration.  Please install the migration table and try again." );
            }
        }
    }

    private struct function getCFMigrationsInfo() {
        if ( variables.keyExists( "cfmigrationsInfo" ) ) {
            return variables.cfmigrationsInfo;
        }

        var directory = getCWD();

        // Check and see if box.json exists
        if( !packageService.isPackage( directory ) ) {
            return error( "File [#packageService.getDescriptorPath( directory )#] does not exist." );
        }

        var boxJSON = packageService.readPackageDescriptor( directory );

        variables.cfmigrationsInfo = JSONService.show( boxJSON, "cfmigrations", {} );

        return variables.cfmigrationsInfo;
    }

}
