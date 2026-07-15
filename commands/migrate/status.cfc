/**
 * Show the current status of migrations for a manager.
 *
 * Displays a summary of the migration configuration, tracking table state,
 * applied/pending counts, the current database revision, a per-migration
 * table showing which files are applied or pending, and a list of
 * available seeders.
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
		var config         = getMigrationsInfo()
		var migrationsDir  = ""
		var seedsDir       = ""

		if ( !config.keyExists( arguments.manager ) ) {
			return error(
				"No manager found named [#arguments.manager#].",
				"Available managers are: #config.keyList( ", " )#"
			)
		}

		var managerConfig  = config[ arguments.manager ]
		migrationsDir      = len( trim( managerConfig.migrationsDirectory ) )
			? managerConfig.migrationsDirectory
			: "resources/database/migrations/"
		seedsDir           = managerConfig.keyExists( "seedsDirectory" ) && len( trim( managerConfig.seedsDirectory ) )
			? managerConfig.seedsDirectory
			: "resources/database/seeds/"

		if ( arguments.verbose ) {
			print.blackOnYellowLine( "cbmigrations info:" )
			print.line( config ).line()
		}

		// ── List migration files from disk ────────────────────────────────────
		var resolvedPath = getCWD() & "/" & migrationsDir;
		var diskFiles    = listMigrationFiles( resolvedPath );

		// ── List seeder files from disk ───────────────────────────────────────
		var seedsResolvedPath = getCWD() & "/" & seedsDir;
		var seederFiles       = listSeederFiles( seedsResolvedPath );

		// ── Try to connect to DB for applied/pending info ─────────────────────
		var dbAvailable      = false;
		var isTableInstalled = false;
		var allMigrations    = [];

		try {
			setup( manager: arguments.manager, installDrivers = arguments.installDrivers );

			isTableInstalled = variables.migrationService.isReady();
			allMigrations    = variables.migrationService.findAll();
			dbAvailable      = true;
		} catch ( any e ) {
			// DB unreachable — we'll fall back to disk-only display below
			dbAvailable = false;
		}

		// ── Build a unified list: disk files + DB records ─────────────────────
		// Disk files are the source of truth for "what exists". DB records
		// provide the `migrated` state. The merge ensures pending migrations
		// (on disk but not yet applied) show up in the table and counts.
		allMigrations = buildMigrationList( diskFiles, dbAvailable ? allMigrations : [], dbAvailable );

		var appliedCount = dbAvailable ? allMigrations.filter( ( m ) => m.migrated ).len() : 0;
		var pendingCount = dbAvailable ? allMigrations.filter( ( m ) => !m.migrated ).len() : 0;
		var totalCount   = allMigrations.len();
		var lastApplied  = dbAvailable ? allMigrations.filter( ( m ) => m.migrated ) : [];
		var currentRevision = lastApplied.len() ? lastApplied[ lastApplied.len() ].componentName : "";
		var nextMigration   = dbAvailable ? ( allMigrations.find( ( m ) => !m.migrated ) ?: {} ) : {};

		// ── JSON output ───────────────────────────────────────────────────────
		if ( arguments.json ) {
			print.line(
				serializeJSON( {
					"manager"        : arguments.manager,
					"directory"      : migrationsDir,
					"seedsDirectory" : seedsDir,
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
					} ),
					"seeders"        : seederFiles.map( ( s ) => {
						return {
							"componentName" : s.componentName,
							"fileName"      : s.fileName
						};
					} )
				} )
			);
			return;
		}

		// ── Pretty output ─────────────────────────────────────────────────────
		print.boldLine( "Migration Status" ).line();

		print.bold( "Manager:    " ).line( arguments.manager );
		print.bold( "Migrations: " ).line( migrationsDir );
		print.bold( "Seeds:      " ).line( seedsDir );

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
		print.bold( "Seeders:    " ).line( seederFiles.len() );

		print.line();

		// ── Current Revision (only meaningful when DB is available) ──────────
		if ( dbAvailable ) {
			if ( currentRevision.len() ) {
				print.bold( "Current Revision: " ).line( currentRevision );
			} else if ( totalCount ) {
				print.bold( "Current Revision: " ).yellowLine( "— (no migrations applied yet)" );
			}
		} else {
			print.bold( "Current Revision: " ).yellowLine( "Unknown (database unreachable)" );
		}

		// ── Migration Table ───────────────────────────────────────────────────
		if ( !totalCount ) {
			print.line();
			print.yellowLine( "📭 No migration files found." );
			print.line( "💡 Run 'migrate create <name>' to create your first migration." );
		} else {
			if ( dbAvailable && !isTableInstalled ) {
				print.yellowLine( "The migration tracking table has not been installed." );
				print.yellowLine( "Run 'migrate install' to create it, then re-run this command." );
				print.line();
			}

			// Helpful next-step tips based on state
			if ( dbAvailable && isTableInstalled && pendingCount && !currentRevision.len() ) {
				print.line();
				print.yellowLine( "💡 No migrations have been applied yet. Run 'migrate up' to apply them." );
			} else if ( dbAvailable && isTableInstalled && pendingCount && currentRevision.len() ) {
				print.line();
				if ( nextMigration.keyExists( "componentName" ) ) {
					print.yellowLine( "💡 Next migration to run: #nextMigration.componentName#" );
				}
			} else if ( dbAvailable && isTableInstalled && !pendingCount && currentRevision.len() ) {
				print.line();
				print.greenLine( "✅ Database is up to date." );
			}

			print.line();

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
		}

		// ── Seeder Table ─────────────────────────────────────────────────────
		if ( seederFiles.len() ) {
			print.line();
			print.boldLine( "Seeders" );
			print.line();

			var seedSep = repeatString( "─", 80 );
			print.boldLine( seedSep );
			print.bold( "Status   " ).boldLine( "Seeder" );
			print.boldLine( seedSep );

			for ( var s in seederFiles ) {
				print.green( " 🌱       " ).line( s.componentName ).toConsole();
			}

			print.boldLine( seedSep );
			print.line();
			print.yellowLine( "💡 Run 'migrate seed run' to execute all seeders, or 'migrate seed run <Name>' for a specific one." );
			print.line();
		} else {
			print.line();
			print.yellowLine( "📭 No seeder files found." );
			print.line( "💡 Run 'migrate seed create <name>' to create your first seeder." );
			print.line();
		}

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
			"*.cfc|*.bx"
		);

		if ( !files.len() ) {
			return [];
		}

		return files
			.map( ( file ) => {
				var fileName      = getFileFromPath( file );
				var componentName = reReplaceNoCase( fileName, "\.(cfc|bx)$", "" );
				return {
					fileName      : fileName,
					componentName : componentName,
					timestamp     : extractTimestampFromFileName( fileName )
				};
			} )
			.filter( ( file ) => isDate( file.timestamp ) );
	}

	/**
	 * Lists seeder files from the given directory on disk. Seeders have no
	 * timestamp prefix and no tracking state — they can be run multiple times.
	 *
	 * @directory Absolute path to the seeds directory.
	 *
	 * @return Array of structs with keys: fileName, componentName.
	 */
	private array function listSeederFiles( required string directory ) {
		if ( !directoryExists( arguments.directory ) ) {
			return [];
		}

		var files = directoryList(
			arguments.directory,
			true,
			"array",
			"*.cfc|*.bx"
		);

		if ( !files.len() ) {
			return [];
		}

		return files.map( ( file ) => {
			var fileName      = getFileFromPath( file );
			var componentName = reReplaceNoCase( fileName, "\.(cfc|bx)$", "" );
			return {
				fileName      : fileName,
				componentName : componentName
			};
		} );
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

	/**
	 * Merges disk files with database migration records into a single,
	 * sorted list. Disk files are the source of truth for "what exists" —
	 * this ensures pending migrations (on disk but not yet applied) appear
	 * in the status output with their correct pending state.
	 *
	 * @diskFiles      Array of structs from listMigrationFiles() (fileName, componentName, timestamp).
	 * @dbMigrations   Array of migration records from migrationService.findAll().
	 * @dbAvailable    If false, DB records are ignored and the returned records are marked as unknown.
	 *
	 * @return Array of unified migration structs, sorted by timestamp (oldest first).
	 */
	private array function buildMigrationList(
		required array diskFiles,
		required array dbMigrations,
		required boolean dbAvailable
	) {
		// Build lookups keyed by component name for O(1) access
		var dbByName = {};
		for ( var m in arguments.dbMigrations ) {
			dbByName[ m.componentName ] = m;
		}

		var diskByName = {};
		for ( var f in arguments.diskFiles ) {
			diskByName[ f.componentName ] = f;
		}

		// Union of all component names (preserves insertion order)
		var allNames = {};
		for ( var name in dbByName ) {
			allNames[ name ] = true;
		}
		for ( var name in diskByName ) {
			allNames[ name ] = true;
		}

		// Build merged records
		var merged = [];
		for ( var name in allNames ) {
			var dbRec   = structKeyExists( dbByName, name ) ? dbByName[ name ] : {};
			var diskRec = structKeyExists( diskByName, name ) ? diskByName[ name ] : {};
			var onDisk  = structKeyExists( diskByName, name );

			// Prefer the DB timestamp (more precise), fall back to the filename
			var ts = "";
			if ( structKeyExists( dbRec, "timestamp" ) && isDate( dbRec.timestamp ) ) {
				ts = dbRec.timestamp;
			} else if ( structKeyExists( diskRec, "timestamp" ) ) {
				ts = diskRec.timestamp;
			}

			merged.append( {
				componentName  : name,
				timestamp      : ts,
				migrated       : arguments.dbAvailable && structKeyExists( dbRec, "migrated" ) ? ( dbRec.migrated ?: false ) : false,
				canMigrateUp   : arguments.dbAvailable ? ( dbRec.canMigrateUp ?: ( onDisk && !structKeyExists( dbByName, name ) ) ) : false,
				canMigrateDown : arguments.dbAvailable ? ( dbRec.canMigrateDown ?: false ) : false,
				onDisk         : onDisk
			} );
		}

		// Sort by timestamp, oldest first. Items without a parsable timestamp go last.
		merged.sort( ( a, b ) => {
			var aDate = isDate( a.timestamp ) ? a.timestamp : "";
			var bDate = isDate( b.timestamp ) ? b.timestamp : "";
			if ( !len( aDate ) && !len( bDate ) ) return 0;
			if ( !len( aDate ) ) return 1;
			if ( !len( bDate ) ) return -1;
			return dateCompare( aDate, bDate );
		} );

		return merged;
	}

}
