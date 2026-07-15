/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Tests for the migrate status command structure, including migration table
 * display, seeder listing, JSON output, and graceful degradation when the
 * database is unreachable.
 */
component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		variables.projectRoot = request.commandboxMigrationsProjectRoot;
	}

	function run() {

		describe( "migrate status command structure", () => {

			it( "should be a valid CFC file", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				expect( fileExists( commandPath ) ).toBeTrue();
			});

			it( "should extend BaseMigrationCommand", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "extends=" );
				expect( content ).toInclude( "BaseMigrationCommand" );
			});

			it( "should define a run() method", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "function run(" );
			});

			it( "should accept manager parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "string manager" );
			});

			it( "should accept json boolean parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean json" );
			});

			it( "should accept verbose boolean parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean verbose" );
			});

			it( "should accept installDrivers boolean parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean installDrivers" );
			});

		});

		describe( "migrate status lists both migrations and seeders", () => {

			it( "should call listMigrationFiles for .cfc and .bx files", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "listMigrationFiles" );
			});

			it( "should call listSeederFiles for .cfc and .bx files", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "listSeederFiles" );
			});

			it( "should resolve seedsDirectory from config", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "seedsDir" );
				expect( content ).toInclude( "seedsDirectory" );
			});

			it( "should render a Seeder table", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( '"Seeders"' );
			});

			it( "should include seeders in JSON output", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( '"seeders"' );
			});

			it( "should include seedsDirectory in JSON output", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( '"seedsDirectory"' );
			});

		});

		describe( "migrate status private helpers", () => {

			it( "should have listMigrationFiles helper", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "private array function listMigrationFiles" );
			});

			it( "should have listSeederFiles helper", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "private array function listSeederFiles" );
			});

			it( "should have extractTimestampFromFileName helper", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "private any function extractTimestampFromFileName" );
			});

			it( "should have buildMigrationList helper", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "private array function buildMigrationList" );
			});

			it( "listMigrationFiles should match *.cfc|*.bx pattern", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( '"*.cfc|*.bx"' );
			});

			it( "listSeederFiles should match *.cfc|*.bx pattern", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( '"*.cfc|*.bx"' );
			});

			it( "listSeederFiles should strip both .cfc and .bx extensions", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( '\.(cfc|bx)' );
			});

		});

		describe( "migrate status error handling and edge cases", () => {

			it( "should handle missing manager gracefully", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "No manager found named" );
			});

			it( "should degrade gracefully when database is unreachable", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "dbAvailable" );
				expect( content ).toInclude( "Unreachable" );
			});

			it( "should show helpful tip when no migration files exist", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "No migration files found" );
				expect( content ).toInclude( "migrate create" );
			});

			it( "should show helpful tip when no seeder files exist", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "No seeder files found" );
				expect( content ).toInclude( "migrate seed create" );
			});

			it( "should warn when tracking table is not installed", () => {
				var commandPath = variables.projectRoot & "commands/migrate/status.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "tracking table has not been installed" );
				expect( content ).toInclude( "migrate install" );
			});

		});

	}

}
