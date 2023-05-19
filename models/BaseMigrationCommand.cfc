component {

    property name="fileSystemUtil" inject="FileSystem";
    property name="packageService" inject="PackageService";
    property name="JSONService" inject="JSONService";
    property name="sqlHighlighter" inject="sqlHighlighter";
	property name="systemSettings" inject="SystemSettings";
    property name="sqlFormatter" inject="Formatter@sqlFormatter";

    function setup( required string manager, boolean setupDatasource = true ) {
        var config = getCFMigrationsInfo();
        if ( !config.keyExists( arguments.manager ) ) {
            error( "No manager found named [#arguments.manager#]. Available managers are: #config.keyList( ", " )#" );
        }
        var settings = config[ arguments.manager ];
        if ( len( trim( settings.migrationsDirectory ) ) ) {
            settings.migrationsDirectory = fileSystemUtil.makePathRelative(
                fileSystemUtil.resolvePath( settings.migrationsDirectory )
            );
        }
        if ( settings.keyExists( "seedsDirectory" ) && len( trim( settings.seedsDirectory ) ) ) {
            
            print.line( 'before make relative '& settings.seedsDirectory )
            settings.seedsDirectory = fileSystemUtil.makePathRelative(
                fileSystemUtil.resolvePath( settings.seedsDirectory )
            );
            
            print.line( 'fileSystemUtil.resolvePath( settings.seedsDirectory ) '& fileSystemUtil.resolvePath( settings.seedsDirectory ) )
            print.line( settings.seedsDirectory )
             if ( !directoryExists( expandPath( settings.seedsDirectory ) ) ) {
                 directoryCreate( expandPath( settings.seedsDirectory ) );
                 print.line( "Created seeds directory" )
             }
             print.line( expandPath( settings.seedsDirectory ) )
        }
        if ( arguments.setupDatasource ) {
            param settings.properties = {};
            if ( settings.properties.keyExists( "connectionInfo" ) ) {
                var datasource = installDatasource( settings.properties.connectionInfo );
                settings.properties.delete( "connectionInfo" );
                settings.properties[ "datasource" ] = datasource;
            }
        }
        variables.migrationService = getInstance(
            name = "MigrationService@cfmigrations",
            initArguments = settings
        );
    }

    function installDatasource( required struct connectionInfo, string datasourceName = "cfmigrations" ) {
        var datasources = getApplicationSettings().datasources ?: {};
        if ( left( shell.getVersion(), 1 ) GTE 5 ) {
            if ( !JSONService.check( arguments.connectionInfo, "bundleName" ) ) {
                return error( "There is no `bundleName` key in your connectionInfo. Please create one with the necessary values. See https://github.com/commandbox-modules/commandbox-migrations" );
            }
            if ( !JSONService.check( arguments.connectionInfo, "bundleVersion" ) ) {
                return error( "There is no `bundleVersion` key in your connectionInfo. Please create one with the necessary values. See https://github.com/commandbox-modules/commandbox-migrations" );
            }
        }
        datasources[ "cfmigrations" ] = arguments.connectionInfo;
        application action='update' datasources=datasources;
        application action='update' datasource='#arguments.datasourceName#';
        return arguments.datasourceName;
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
        if ( ! variables.migrationService.isReady() ) {
            if ( confirm( "Migration table not installed.  Do you want to install it now? [y\n]" ) ) {
                variables.migrationService.install();
            } else {
                error( "Aborting migration.  Please install the migration table and try again." );
            }
        }
    }

    private struct function getCFMigrationsInfo() {
        var cfmigrationsInfoType = "boxJSON";

        var directory = getCWD();

        // Check and see if a .cfmigrations.json file exists
        if ( fileExists( "#directory#/.cfmigrations.json" ) ) {
            var cfmigrationsInfo = deserializeJSON( fileRead( "#directory#/.cfmigrations.json" ) );
            variables.systemSettings.expandDeepSystemSettings( cfmigrationsInfo );
            cfmigrationsInfoType = "cfmigrations";
            return cfmigrationsInfo;
        }

        // Check and see if box.json exists
        if( !packageService.isPackage( directory ) ) {
            return error( "File [#packageService.getDescriptorPath( directory )#] does not exist." );
        }

        print.boldUnderscoredYellowLine( "Storing cfmigrations information in box.json has been deprecated in v4 and will be removed in v5." );
        print.line( "Please refer to the migration guide at https://github.com/commandbox-modules/commandbox-migrations to upgrade." );
        print.line();

        var boxJSON = packageService.readPackageDescriptor( directory );
        var boxJSONMigrationsInfo = JSONService.show( boxJSON, "cfmigrations", {} );

        if ( boxJSONMigrationsInfo.keyExists( "managers" ) ) {
            var cfmigrationsInfo = boxJSONMigrationsInfo;
            variables.systemSettings.expandDeepSystemSettings( cfmigrationsInfo );
            cfmigrationsInfoType = "cfmigrations";
            return cfmigrationsInfo;
        }

        print.boldUnderscoredYellowLine( "The format of the migrations configuration has changed in v4." );
        print.line( "We will convert your configuration to the new format. This auto-conversion will be dropped in v5." );
        print.line( "Please refer to the migration guide at https://github.com/commandbox-modules/commandbox-migrations to upgrade." );
        print.line();

        param boxJSONMigrationsInfo.migrationsDirectory = "resources/database/migrations";
        param boxJSONMigrationsInfo.defaultGrammar = "AutoDiscover@qb";

        var properties = {
            "connectionInfo": boxJSONMigrationsInfo.connectionInfo,
            "defaultGrammar": boxJSONMigrationsInfo.defaultGrammar
        };
        if ( boxJSONMigrationsInfo.keyExists( "schema" ) ) {
            properties[ "schema" ] = boxJSONMigrationsInfo.schema;
        }

        var cfmigrationsInfo = {
            "default": {
                "manager": "cfmigrations.models.QBMigrationManager",
                "migrationsDirectory": boxJSONMigrationsInfo.migrationsDirectory,
                "properties": properties
            }
        };

        variables.systemSettings.expandDeepSystemSettings( cfmigrationsInfo );
        return cfmigrationsInfo;
    }

    private string function getCFMigrationsType() {
        var directory = getCWD();

        // Check and see if a .cfmigrations.json file exists
        if ( fileExists( "#directory#/.cfmigrations.json" ) ) {
            return "cfmigrations";
        }

        // Check and see if box.json exists
        if( !packageService.isPackage( directory ) ) {
            return error( "File [#packageService.getDescriptorPath( directory )#] does not exist." );
        }

        var boxJSON = packageService.readPackageDescriptor( directory );
        var boxJSONMigrationsInfo = JSONService.show( boxJSON, "cfmigrations", {} );

        if ( boxJSONMigrationsInfo.keyExists( "managers" ) ) {
            return "cfmigrations";
        }

        return "boxJSON";
    }

    function completeManagers( string paramSoFar ) {
        var type = getCFMigrationsType();
        if ( type == "boxJSON" ) {
            return [];
        }
        return getCFMigrationsInfo().keyArray()
            .filter( ( manager ) => startsWith( manager, paramSoFar ) )
            .map( ( manager ) => ( { "name": manager, "group": "Managers" } ) );
    }

    private string function startsWith( required string word, required string substring ) {
        if ( len( arguments.substring ) == 0 ) {
            return true;
        }

        return left( arguments.word, len( arguments.substring ) ) == arguments.substring;
    }

}
