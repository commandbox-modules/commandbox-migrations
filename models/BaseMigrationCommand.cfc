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
    property name="moduleConfig"         inject="box:moduleconfig:commandbox-migrations";

    /**
	 * Initialize the BaseCommand
	 */
	function init(){
		return this;
	}

    /**
     * Resolves the named manager's settings from the migrations config and
     * initializes `variables.migrationService` from them.
     *
     * @manager          The Migration Manager to use.
     * @setupDatasource  If true, registers an on-the-fly application datasource from `connectionInfo`.
     * @installDrivers   If true (default) and a BoxLang runtime is active, auto-installs the matching
     *                    `bx-*` JDBC driver module from ForgeBox into `boxlang_modules/`. Pass false
     *                    to skip auto-install (e.g. `--noDriverInstall` from the CLI).
     */
    function setup(
        required string manager,
        boolean setupDatasource = true,
        boolean installDrivers = true
    ) {
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
                print.greenLine( "📁 Created seeds directory" )
            }
        }
        if ( arguments.setupDatasource ) {
            param settings.properties = {};
            if ( settings.properties.keyExists( "connectionInfo" ) ) {
                var datasource = installDatasource(
                    connectionInfo: settings.properties.connectionInfo,
                    installDrivers: arguments.installDrivers
                );
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
     *
     * When running inside a BoxLang runtime AND `installDrivers` is true, the matching
     * `bx-*` JDBC driver module is auto-installed (if missing) and loaded from
     * `boxlang_modules/` so the connection can be established. Set `installDrivers` to
     * false to skip the auto-install (e.g. CI scripts using `--noDriverInstall`).
     *
     * @connectionInfo   The connection info struct to register as a datasource.
     * @datasourceName   The datasource name to register under (default: `cbmigrations`).
     * @installDrivers   If true, auto-installs/loads the matching BoxLang JDBC driver.
     */
    function installDatasource(
        required struct connectionInfo,
        string datasourceName = "cbmigrations",
        boolean installDrivers = true
    ) {
        if ( arguments.installDrivers && isBoxLang() ) {
            var slug = detectBoxLangDriverSlug( arguments.connectionInfo );
            if ( len( slug ) ) {
                ensureBoxLangDriver( slug );
            }
        }

        var datasources = getApplicationSettings().datasources ?: {};
        datasources[ arguments.datasourceName ] = arguments.connectionInfo;
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
     * Detects whether the active runtime is BoxLang (either inside a live BoxLang
     * server engine, or via box.json's `language` key). Used to gate driver
     * auto-install behavior.
     */
    private boolean function isBoxLang() {
        return server.keyExists( "boxlang")
    }

    /**
     * Resolves the BoxLang JDBC driver ForgeBox slug from a connection info struct.
     * Resolution order:
     *   1. `driver` key — the explicit BoxLang driver name (e.g. `bx-mysql`).
     *   2. `type` key — Lucee-style type (`mysql`, `postgresql`, `mssql`, etc.).
     *   3. JDBC `connectionString` URL prefix (`jdbc:mysql:`, `jdbc:postgresql:`, …).
     *
     * Returns the ForgeBox slug (e.g. `bx-postgresql`) or an empty string if no
     * driver could be determined.
     */
    string function detectBoxLangDriverSlug( required struct connectionInfo ) {
        var typeMap = getBoxLangDriverMap();

        // 1. Explicit driver key wins
        if ( arguments.connectionInfo.keyExists( "driver" ) && typeMap.keyExists( arguments.connectionInfo.driver) ) {
            return typeMap[ arguments.connectionInfo.driver ]
        }

        // 2. Lucee-style `type` key (case-insensitive)
        if ( arguments.connectionInfo.keyExists( "type" ) && typeMap.keyExists( arguments.connectionInfo.type )) {
            return typeMap[ arguments.connectionInfo.type ]
        }

        // 3. Parse a JDBC URL prefix from `connectionString`.
        if ( arguments.connectionInfo.keyExists( "connectionString" ) && len( arguments.connectionInfo.connectionString ) ) {
            var connectionString = trim( arguments.connectionInfo.connectionString )
            for ( var thisType in typeMap ) {
                if ( findNoCase( "jdbc:#thisType#", connectionString ) == 1 ) {
                    return typeMap[ thisType ]
                }
            }
        }

        return ""
    }

    /**
     * Ensures the given BoxLang JDBC driver module is present in `boxlang_modules/`
     * and registered with the active BoxLang runtime. Idempotent — safe to call
     * repeatedly. Failures are logged but never break the calling command.
     *
     * @slug The ForgeBox slug of the driver (e.g. `bx-mysql`).
     */
    void function ensureBoxLangDriver( required string slug ) {
        installBoxLangDriver( arguments.slug );
    }

    /**
     * Installs and loads a supported BoxLang JDBC driver module.
     *
     * @slug  The ForgeBox slug of the driver (e.g. `bx-mysql`).
     * @force If true, removes the existing module before installing it again.
     */
    void function installBoxLangDriver( required string slug, boolean force = false ) {
        var modulesDir = getBoxLangDriversDirectory();
        var targetModuleDir = modulesDir & "/" & arguments.slug;

        if ( !arrayFindNoCase( getSupportedBoxLangDriverSlugs(), arguments.slug ) ) {
            throw(
                type = "UnsupportedBoxLangDriver",
                message = "Unsupported BoxLang JDBC driver [#arguments.slug#]."
            );
        }

        if ( arguments.force && directoryExists( targetModuleDir ) ) {
            directoryDelete( targetModuleDir, true );
        }

        if ( !directoryExists( targetModuleDir ) ) {
            variables.print
                .yellowLine( "⬇️ Auto-installing BoxLang JDBC driver [#arguments.slug#]…" )
                .toConsole()
            var installed = variables.packageService.installPackage(
                ID                      = arguments.slug,
                directory               = modulesDir
            )
            if ( !installed ) {
                variables.print
                    .yellowLine( "⚠️ Driver [#arguments.slug#] could not be auto-installed. Continuing without it." )
                    .toConsole()
                return
            }
        }

        loadBoxLangDrivers( modulesDir );
    }

    /**
     * Returns the module-owned directory used for BoxLang JDBC drivers.
     */
    string function getBoxLangDriversDirectory() {
        return variables.moduleConfig.path & "/boxlang_modules";
    }

    /**
     * Returns the supported BoxLang JDBC driver ForgeBox slugs.
     */
    array function getSupportedBoxLangDriverSlugs() {
        var slugs = {};
        for ( var slug in getBoxLangDriverMap().valueArray() ) {
            slugs[ slug ] = true;
        }
        return slugs.keyArray().sort( "textnocase" );
    }

    /**
     * Returns the mapping between connection types and BoxLang JDBC modules.
     */
    private struct function getBoxLangDriverMap() {
        return {
            "mysql"      : "bx-mysql",
            "mariadb"    : "bx-mariadb",
            "postgresql" : "bx-postgresql",
            "pgsql"      : "bx-postgresql",
            "mssql"      : "bx-mssql",
            "sqlserver"  : "bx-mssql",
            "oracle"     : "bx-oracle",
            "oracledb"   : "bx-oracle",
            "sqlite"     : "bx-sqlite",
            "derby"      : "bx-derby",
            "h2"         : "bx-hypersql",
            "hypersql"   : "bx-hypersql",
            "hsqldb"     : "bx-hypersql"
        };
    }

    /**
     * Returns the installed BoxLang JDBC driver module slugs.
     */
    array function getInstalledBoxLangDriverSlugs() {
        var modulesDir = getBoxLangDriversDirectory();
        if ( !directoryExists( modulesDir ) ) {
            return [];
        }

        return directoryList( modulesDir, false, "array", "bx-*")
            .filter( ( path ) => directoryExists( path ) )
            .map( ( path ) => listLast( replace( path, "\\", "/", "all" ), "/" ) )
            .sort( "textnocase" );
    }

    /**
     * Removes all installed BoxLang JDBC driver modules owned by this module.
     */
    void function removeAllBoxLangDrivers() {
        var modulesDir = getBoxLangDriversDirectory();
        for ( var slug in getInstalledBoxLangDriverSlugs() ) {
            removeBoxLangDriver( slug );
        }
    }

    /**
     * Removes one installed BoxLang JDBC driver module.
     */
    void function removeBoxLangDriver( required string slug ) {
        var targetModuleDir = getBoxLangDriversDirectory() & "/" & arguments.slug;
        if ( directoryExists( targetModuleDir ) ) {
            directoryDelete( targetModuleDir, true );
        }
    }

    /**
     * Loads any modules found under `boxlang_modules/` into the active BoxLang
     * runtime. Calling `loadModules` on the parent directory is safe and
     * idempotent — already-registered modules are skipped.
     */
    void function loadBoxLangDrivers( required string modulesDir ) {
        if ( !directoryExists( modulesDir ) ) {
            return;
        }

        getBoxRuntime()
            .getModuleService()
            .loadModules(
                createObject( "java", "java.nio.file.Paths" ).get( modulesDir )
            )

        print.greenLine( "⚡ BoxLang driver module(s) loaded from [#modulesDir#]." )
    }

    /**
     * Returns the path to the first migrations config file found in the given directory,
     * checking `.cbmigrations.json` before `.cfmigrations.json`. If only
     * `.cfmigrations.json` exists, the user is prompted to rename it to the new
     * `.cbmigrations.json` name.
     */
    private string function findMigrationsConfigPath( required string directory ) {
        // Check for the modern config file first
        var cbmigrationsPath = "#arguments.directory#/.cbmigrations.json"
        if ( fileExists( cbmigrationsPath ) ) {
            return cbmigrationsPath
        }

        // Check for the legacy config file
        var cfmigrationsPath = "#arguments.directory#/.cfmigrations.json"
        if ( fileExists( cfmigrationsPath ) ) {
            return cfmigrationsPath
        }

        return ""
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
     * Loads the migrations config: from `.cbmigrations.json`/`.cfmigrations.json` if present,
     * otherwise falls back to the deprecated `cfmigrations` key in box.json (auto-converting
     * the legacy pre-v4 format if needed).
     */
    private struct function getMigrationsInfo() {
        var migrationsInfoType = "boxJSON"
        var directory = getCWD()

        // Check and see if a .cbmigrations.json or .cfmigrations.json file exists
        var configPath = findMigrationsConfigPath( directory )
        if ( len( configPath ) ) {
            var migrationsInfo = deserializeJSON( fileRead( configPath ) )
            variables.systemSettings.expandDeepSystemSettings( migrationsInfo )
            migrationsInfoType = "cfmigrations"
            return migrationsInfo
        }

        // Check and see if box.json exists
        if( !packageService.isPackage( directory ) ) {
            return error( "File [#packageService.getDescriptorPath( directory )#] does not exist." )
        }

        var boxJSON = packageService.readPackageDescriptor( directory );
        var boxJSONMigrationsInfo = JSONService.show( boxJSON, "cfmigrations", {} );

        if ( boxJSONMigrationsInfo.keyExists( "managers" ) ) {
        print.boldUnderscoredYellowLine( "📦 Storing cfmigrations information in box.json has been deprecated in v4 and will be removed in v5." );
            print.line( "Please refer to the migration guide at https://github.com/commandbox-modules/commandbox-migrations to upgrade." )
            print.line()

            var migrationsInfo = boxJSONMigrationsInfo
            variables.systemSettings.expandDeepSystemSettings( migrationsInfo )
            migrationsInfoType = "cfmigrations"
            return migrationsInfo
        }

        throw(
            type: "NoMigrationsConfigFound",
            message: "No migrations config found. Please create a .cbmigrations.json file found in the project root, or run migrate init to create one."
        )

    }

    /**
     * Returns "cbmigrations" if a dedicated config file or v4-style box.json config is found,
     * or "boxJSON" if only the legacy pre-v4 box.json format is present.
     */
    private string function getMigrationsConfigType() {
        var directory = getCWD();

        // Check and see if a .cbmigrations.json or .cbmigrations.json file exists
        if ( len( findMigrationsConfigPath( directory ) ) ) {
            return "cbmigrations";
        }

        // Check and see if box.json exists
        if( !packageService.isPackage( directory ) ) {
            return error( "File [#packageService.getDescriptorPath( directory )#] does not exist." );
        }

        var boxJSON = packageService.readPackageDescriptor( directory );
        var boxJSONMigrationsInfo = JSONService.show( boxJSON, "cfmigrations", {} );

        if ( boxJSONMigrationsInfo.keyExists( "managers" ) ) {
            return "cbmigrations";
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
    private boolean function startsWith( required string word, required string substring ) {
        if ( len( arguments.substring ) == 0 ) {
            return true;
        }

        return left( arguments.word, len( arguments.substring ) ) == arguments.substring;
    }

}
