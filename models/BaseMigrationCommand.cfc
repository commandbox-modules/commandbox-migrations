/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 */
component {

    property name="fileSystemUtil" inject="FileSystem";
    property name="packageService" inject="PackageService";
    property name="JSONService" inject="JSONService";
    property name="sqlHighlighter" inject="sqlHighlighter";
	property name="systemSettings" inject="SystemSettings";
    property name="sqlFormatter" inject="Formatter@sqlFormatter";
    property name="serverService" inject="ServerService";

    /**
     * Resolves the named manager's settings from the migrations config and
     * initializes `variables.migrationService` from them.
     */
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

    /**
     * Registers an on-the-fly application datasource from the given connection info
     * and sets it as the application default, returning the datasource name.
     */
    function installDatasource( required struct connectionInfo, string datasourceName = "cfmigrations" ) {
        var datasources = getApplicationSettings().datasources ?: {};
        datasources[ "cfmigrations" ] = arguments.connectionInfo;
        application action='update' datasources=datasources;
        application action='update' datasource='#arguments.datasourceName#';
        return arguments.datasourceName;
    }

    /**
     * Updates the migration service's migrations directory to the given path,
     * resolved and made relative to the current working directory.
     */
    public void function setMigrationPath( required migrationsDirectory ) {
        var relativePath = fileSystemUtil.makePathRelative(
            fileSystemUtil.resolvePath( migrationsDirectory )
        );
        migrationService.setMigrationsDirectory( relativePath );
    }

    /**
     * Returns the migration service's currently configured migrations directory.
     */
    public string function getMigrationPath () {
        return migrationService.getMigrationsDirectory();
    }

    /**
     * Prompts the user to install the migration table if it hasn't been installed yet,
     * aborting the command if they decline.
     */
    private void function checkForInstalledMigrationTable() {
        if ( ! variables.migrationService.isReady() ) {
            if ( confirm( "Migration table not installed.  Do you want to install it now? [y\n]" ) ) {
                variables.migrationService.install();
            } else {
                error( "Aborting migration.  Please install the migration table and try again." );
            }
        }
    }

    /**
     * Returns the path to the first migrations config file found in the given directory,
     * checking `.bxmigrations.json` before `.cfmigrations.json`, or "" if neither exists.
     */
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

    /**
     * Detects whether the given directory should be treated as a BoxLang project,
     * based on the running CommandBox server's engine or box.json's `language` key.
     *
     * @directory The directory to check for box.json (usually the current working directory).
     *
     * @return True if this is a BoxLang project, false otherwise.
     */
    private boolean function isBoxLangProject( required string directory ) {
        // Detect if the running CommandBox server is BoxLang.
        var serverInfo = variables.serverService.resolveServerDetails( {} ).serverInfo;
        if ( serverInfo.keyExists( "cfengine" ) && serverInfo.cfengine contains "boxlang" ) {
            return true
        }

        // Detect via box.json's language key.
        if ( packageService.isPackage( arguments.directory ) ) {
            var boxJSON = packageService.readPackageDescriptor( arguments.directory );
            if ( boxJSON.keyExists( "language" ) && boxJSON.language == "boxlang" ) {
                return true
            }
        }

        return false
    }

    /**
     * Loads the migrations config: from `.bxmigrations.json`/`.cfmigrations.json` if present,
     * otherwise falls back to the deprecated `cfmigrations` key in box.json (auto-converting
     * the legacy pre-v4 format if needed).
     */
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

    /**
     * Returns "cfmigrations" if a dedicated config file or v4-style box.json config is found,
     * or "boxJSON" if only the legacy pre-v4 box.json format is present.
     */
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

    /**
     * Tab-completion options for the `manager` argument, listing configured manager
     * names that start with what's been typed so far.
     */
    function completeManagers( string paramSoFar ) {
        var type = getMigrationsConfigType();
        if ( type == "boxJSON" ) {
            return [];
        }
        return getMigrationsInfo().keyArray()
            .filter( ( manager ) => startsWith( manager, paramSoFar ) )
            .map( ( manager ) => ( { "name": manager, "group": "Managers" } ) );
    }

    /**
     * Returns true if `word` starts with `substring` (or `substring` is empty).
     */
    private string function startsWith( required string word, required string substring ) {
        if ( len( arguments.substring ) == 0 ) {
            return true;
        }

        return left( arguments.word, len( arguments.substring ) ) == arguments.substring;
    }

}
