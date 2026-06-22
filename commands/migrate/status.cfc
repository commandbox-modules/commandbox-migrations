/**
 * Show the current status of migrations for a manager.
 *
 * Displays a summary of the migration configuration, tracking table state,
 * applied/pending counts, the current database revision, and a per-migration
 * table showing which files are applied or pending.
 *
 * When the database is unreachable, the command degrades gracefully and
 * shows the migration files present on disk with an unknown status.
 *
 * {code:bash}
 * ## Show migration status
 * migrate status
 *
 * ## Show status for a named manager
 * migrate status --manager=secondary
 *
 * ## Output status as JSON (useful for CI/CD scripting)
 * migrate status --json
 *
 * ## Show verbose config details
 * migrate status --verbose
 * {code}
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

	/**
	 * @manager          The Migration Manager to use.
	 * @manager.optionsUDF completeManagers
	 * @json             If true, outputs the status as a JSON object.
	 * @verbose          If true, errors output a full stack trace and config details are shown.
	 * @installDrivers   If true, auto-install the BoxLang JDBC driver module. Default: true.
	 */
	function run(
		string manager = "default",
		boolean json = false,
		boolean verbose = false,
		boolean installDrivers = true
	) {
		// ── Resolve config & migrations directory (always works, no DB needed) ──
		var config         = getMigrationsInfo();
		var migrationsDir  = "";

		if ( !config.keyExists( arguments.manager ) ) {
			return error(
				"No manager found named [#arguments.manager#].",
				"Available managers are: #config.keyList( ", " )#"
			);
		}

		var managerConfig  = config[ arguments.manager ];
		migrationsDir      = len( trim( managerConfig.migrationsDirectory ) )
			? managerConfig.migrationsDirectory
			: "resources/database/migrations/";

		if ( arguments.verbose ) {
			print.blackOnYellowLine( "cbmigrations info:" );
			print.line( config ).line();
		}

		// ── List migration files from disk ────────────────────────────────────
		var resolvedPath = getCWD() & "/" & migrationsDir;
		var diskFiles    = listMigrationFiles( resolvedPath );
		var totalCount   = diskFiles.len();

		// ── Try to connect to DB for applied/pending info ─────────────────────
		var dbAvailable     = false;
		var isTableInstalled = false;
		var appliedCount    = 0;
		var pendingCount    = totalCount;
		var currentRevision = "Unknown";
		var allMigrations   = [];

		try {
			setup( manager: arguments.manager, installDrivers = arguments.installDrivers );

			isTableInstalled = variables.migrationService.isReady();
			allMigrations    = variables.migrationService.findAll();
			dbAvailable      = true;

			var appliedMigrations = allMigrations.filter( ( m ) => m.migrated );
			appliedCount          = appliedMigrations.len();
			pendingCount          = allMigrations.len() - appliedCount;
			currentRevision       = appliedMigrations.len()
				? appliedMigrations[ appliedMigrations.len() ].componentName
				: "None";
		} catch ( any e ) {
			// DB unreachable — build a disk-only migration list for display
			dbAvailable = false;
			allMigrations = diskFiles.map( ( file ) => {
				return {
					componentName  : file.componentName,
					timestamp      : file.timestamp,
					migrated       : false,
					canMigrateUp   : false,
					canMigrateDown : false
				}
			} )
		}

		// ── JSON output ───────────────────────────────────────────────────────
		if ( arguments.json ) {
			print.line(
				serializeJSON( {
					"manager"        : arguments.manager,
					"directory"      : migrationsDir,
					"dbAvailable"    : dbAvailable,
					"tableInstalled" : isTableInstalled,
					"applied"        : appliedCount,
					"pending"        : pendingCount,
					"total"          : totalCount,
					"currentRevision": currentRevision,
					"migrations"     : allMigrations.map( ( m ) => {
						return {
							"componentName" : m.componentName,
							"timestamp"     : isDate( m.timestamp )
								? dateTimeFormat( m.timestamp, "yyyy-mm-dd HH:nn:ss" )
								: m.timestamp,
							"migrated"      : m.migrated ?: false,
							"canMigrateUp"  : m.canMigrateUp ?: false,
							"canMigrateDown": m.canMigrateDown ?: false
						};
					} )
				} )
			);
			return;
		}

		// ── Pretty output ─────────────────────────────────────────────────────
		print.boldLine( "Migration Status" ).line();

		print.bold( "Manager:    " ).line( arguments.manager );
		print.bold( "Directory:  " ).line( migrationsDir );

		if ( !dbAvailable ) {
			print.bold( "Database:   " ).yellowLine( "⚠ Unreachable" );
			print.yellowLine( "The database connection could not be established." );
			print.yellowLine( "Only filesystem information is shown below." );
		} else if ( isTableInstalled ) {
			print.bold( "Table:      " ).greenLine( "✓ Installed" );
		} else {
			print.bold( "Table:      " ).redLine( "✗ Not Installed" );
		}

		print.line();

		// ── Counts ────────────────────────────────────────────────────────────
		print.bold( "Applied:    " ).line( dbAvailable ? appliedCount : "?" );
		print.bold( "Pending:    " ).yellowLine( dbAvailable ? pendingCount : "?" );
		print.bold( "Total:      " ).line( totalCount );

		print.line();
		print.bold( "Current Revision: " );
		if ( dbAvailable ) {
			print.line( currentRevision );
		} else {
			print.yellowLine( currentRevision );
		}
		print.line();

		// ── Migration Table ───────────────────────────────────────────────────
		if ( !totalCount ) {
			print.yellowLine( "No migration files found." );
			return;
		}

		if ( dbAvailable && !isTableInstalled ) {
			print.yellowLine( "The migration tracking table has not been installed." );
			print.yellowLine( "Run 'migrate install' to create it, then re-run this command." );
			print.line();
		}

		// Column separators
		var sep = repeatString( "─", 80 );

		print.boldLine( sep );
		print.bold( "Status   " ).bold( "Timestamp              " ).boldLine( "Migration" );
		print.boldLine( sep );

		for ( var m in allMigrations ) {
			var tsFormatted = isDate( m.timestamp )
				? dateTimeFormat( m.timestamp, "yyyy-mm-dd HH:nn:ss" )
				: m.timestamp;

			if ( !dbAvailable ) {
				print.yellow( " ?       " );
			} else if ( m.migrated ) {
				print.green( " ✓       " );
			} else {
				print.yellow( " ⏳       " );
			}
			print.line( "#tsFormatted#  #m.componentName#" ).toConsole();
		}

		print.boldLine( sep );
		print.line();

		if ( !dbAvailable ) {
			print.yellowLine( "Tip: Ensure your database is running and environment variables are configured." );
		}
	}

	// ── Private Helpers ───────────────────────────────────────────────────────

	/**
	 * Lists migration files from the given directory on disk, extracting
	 * component names and timestamps from filenames. No database is needed.
	 *
	 * @directory Absolute path to the migrations directory.
	 *
	 * @return Array of structs with keys: fileName, componentName, timestamp.
	 */
	private array function listMigrationFiles( required string directory ) {
		if ( !directoryExists( arguments.directory ) ) {
			return [];
		}

		var files = directoryList(
			arguments.directory,
			true,
			"array",
			"*"
		);

		if ( !files.len() ) {
			return [];
		}

		return files
			.filter( ( file ) => {
				var ext = listLast( file, "." );
				return listFindNoCase( "cfc,bx", ext );
			} )
			.map( ( file ) => {
				var fileName     = getFileFromPath( file );
				var componentName = left( fileName, len( fileName ) - 4 );
				return {
					fileName      : fileName,
					componentName : componentName,
					timestamp     : extractTimestampFromFileName( fileName )
				};
			} )
			.filter( ( file ) => isDate( file.timestamp ) );
	}

	/**
	 * Extracts a datetime from a migration filename prefix (e.g.,
	 * "2022_11_01_192710_create_users_table.cfc" → {ts '2022-11-01 19:27:10'}).
	 *
	 * @fileName The migration file name (not full path).
	 *
	 * @return A date/time object, or an empty string if the prefix is invalid.
	 */
	private any function extractTimestampFromFileName( required string fileName ) {
		try {
			var timestampString = left( arguments.fileName, 17 );
			var timestampParts  = listToArray( timestampString, "_" );
			return createDateTime(
				timestampParts[ 1 ],
				timestampParts[ 2 ],
				timestampParts[ 3 ],
				mid( timestampParts[ 4 ], 1, 2 ),
				mid( timestampParts[ 4 ], 3, 2 ),
				mid( timestampParts[ 4 ], 5, 2 )
			);
		} catch ( any e ) {
			return "";
		}
	}

}
