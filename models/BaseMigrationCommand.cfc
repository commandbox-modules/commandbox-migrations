component {

    property name="fileSystemUtil" inject="FileSystem";
    property name="packageService" inject="PackageService";
    property name="JSONService" inject="JSONService";
    property name="sqlHighlighter" inject="sqlHighlighter";
	property name="systemSettings" inject="SystemSettings";
    property name="sqlFormatter" inject="Formatter@sqlFormatter";
    property name="serverService" inject="ServerService";

    function setup( required string manager, boolean setupDatasource = true ) {
        var config = getMigrationsInfo();
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
            settings.seedsDirectory = fileSystemUtil.makePathRelative(
                fileSystemUtil.resolvePath( settings.seedsDirectory )
            );

            if ( !directoryExists( expandPath( settings.seedsDirectory ) ) ) {
                directoryCreate( expandPath( settings.seedsDirectory ) );
                print.line( "Created seeds directory" )
            }
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

    private string function findMigrationsConfigPath( required string directory ) {
        var candidates = [ ".bxmigrations.json", ".cfmigrations.json" ];
        for ( var candidate in candidates ) {
            var path = "#arguments.directory#/#candidate#";
            if ( fileExists( path ) ) {
                return path;
            }
        }
        return "";
    }

    private boolean function isBoxLangProject( required string directory ) {
        // Detect if the running CommandBox server is BoxLang.
        var serverInfo = variables.serverService.resolveServerDetails( {} ).serverInfo;
        if ( serverInfo.keyExists( "cfengine" ) && serverInfo.cfengine contains "boxlang" ) {
            return true;
        }

        // Detect via box.json's language key.
        if ( packageService.isPackage( arguments.directory ) ) {
            var boxJSON = packageService.readPackageDescriptor( arguments.directory );
            if ( boxJSON.keyExists( "language" ) && boxJSON.language == "boxlang" ) {
                return true;
            }
        }

        return false;
    }

    private struct function getMigrationsInfo() {
        var migrationsInfoType = "boxJSON";

        var directory = getCWD();

        // Check and see if a .bxmigrations.json or .cfmigrations.json file exists
        var configPath = findMigrationsConfigPath( directory );
        if ( len( configPath ) ) {
            var migrationsInfo = deserializeJSON( fileRead( configPath ) );
            variables.systemSettings.expandDeepSystemSettings( migrationsInfo );
            migrationsInfoType = "cfmigrations";
            return migrationsInfo;
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
            var migrationsInfo = boxJSONMigrationsInfo;
            variables.systemSettings.expandDeepSystemSettings( migrationsInfo );
            migrationsInfoType = "cfmigrations";
            return migrationsInfo;
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

        var migrationsInfo = {
            "default": {
                "manager": "cfmigrations.models.QBMigrationManager",
                "migrationsDirectory": boxJSONMigrationsInfo.migrationsDirectory,
                "properties": properties
            }
        };

        variables.systemSettings.expandDeepSystemSettings( migrationsInfo );
        return migrationsInfo;
    }

    private string function getMigrationsConfigType() {
        var directory = getCWD();

        // Check and see if a .bxmigrations.json or .cfmigrations.json file exists
        if ( len( findMigrationsConfigPath( directory ) ) ) {
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
        var type = getMigrationsConfigType();
        if ( type == "boxJSON" ) {
            return [];
        }
        return getMigrationsInfo().keyArray()
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
