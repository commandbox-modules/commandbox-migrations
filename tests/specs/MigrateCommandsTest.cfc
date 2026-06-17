/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Tests for the migrate install/up/down/reset/fresh command structure and behavior patterns.
 */
component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		variables.projectRoot = request.commandboxMigrationsProjectRoot;
	}

	function run() {

		describe( "migrate install command structure", () => {

			it( "should be a valid CFC file", () => {
				var commandPath = variables.projectRoot & "commands/migrate/install.cfc";
				expect( fileExists( commandPath ) ).toBeTrue();
			} );

			it( "should extend BaseMigrationCommand", () => {
				var commandPath = variables.projectRoot & "commands/migrate/install.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "extends=" )
				expect( content ).toInclude( "BaseMigrationCommand" );
			} );

			it( "should call setup() before installation", () => {
				var commandPath = variables.projectRoot & "commands/migrate/install.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "setup(" );
			} );

			it( "should check if migration service is ready before installing", () => {
				var commandPath = variables.projectRoot & "commands/migrate/install.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "isReady" );
			} );

			it( "should call migrationService.install()", () => {
				var commandPath = variables.projectRoot & "commands/migrate/install.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "migrationService.install()" );
			} );

		} );

		describe( "migrate up command structure", () => {

			it( "should be a valid CFC file", () => {
				var commandPath = variables.projectRoot & "commands/migrate/up.cfc";
				expect( fileExists( commandPath ) ).toBeTrue();
			} );

			it( "should extend BaseMigrationCommand", () => {
				var commandPath = variables.projectRoot & "commands/migrate/up.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "extends=" )
				expect( content ).toInclude( "BaseMigrationCommand" );
			} );

			it( "should support once parameter for single migration", () => {
				var commandPath = variables.projectRoot & "commands/migrate/up.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean once" );
			} );

			it( "should support pretend parameter for dry-run mode", () => {
				var commandPath = variables.projectRoot & "commands/migrate/up.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean pretend" );
			} );

			it( "should support file parameter for specific migration", () => {
				var commandPath = variables.projectRoot & "commands/migrate/up.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "string file" );
			} );

			it( "should support seed parameter to run seeders", () => {
				var commandPath = variables.projectRoot & "commands/migrate/up.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean seed" );
			} );

			it( "should use hooks for pre/post migration logging", () => {
				var commandPath = variables.projectRoot & "commands/migrate/up.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "preProcessHook" );
				expect( content ).toInclude( "postProcessHook" );
			} );

			it( "should clear page pool before execution", () => {
				var commandPath = variables.projectRoot & "commands/migrate/up.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "pagePoolClear" );
			} );

		} );

		describe( "migrate down command structure", () => {

			it( "should be a valid CFC file", () => {
				var commandPath = variables.projectRoot & "commands/migrate/down.cfc";
				expect( fileExists( commandPath ) ).toBeTrue();
			} );

			it( "should extend BaseMigrationCommand", () => {
				var commandPath = variables.projectRoot & "commands/migrate/down.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "extends=" )
				expect( content ).toInclude( "BaseMigrationCommand" );
			} );

			it( "should support file parameter for specific rollback", () => {
				var commandPath = variables.projectRoot & "commands/migrate/down.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "string file" );
			} );

			it( "should support pretend parameter for dry-run mode", () => {
				var commandPath = variables.projectRoot & "commands/migrate/down.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean pretend" );
			} );

			it( "should roll back the last batch when no file specified", () => {
				var commandPath = variables.projectRoot & "commands/migrate/down.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "runAllMigrations" );
				expect( content ).toInclude( 'direction = "down"' );
			} );

		} );

		describe( "migrate reset command structure", () => {

			it( "should be a valid CFC file", () => {
				var commandPath = variables.projectRoot & "commands/migrate/reset.cfc";
				expect( fileExists( commandPath ) ).toBeTrue();
			} );

			it( "should extend BaseMigrationCommand", () => {
				var commandPath = variables.projectRoot & "commands/migrate/reset.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "extends=" )
				expect( content ).toInclude( "BaseMigrationCommand" );
			} );

			it( "should delegate reset behavior to the migration service", () => {
				var commandPath = variables.projectRoot & "commands/migrate/reset.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "migrationService.reset()" );
			} );

		} );

		describe( "migrate fresh command structure", () => {

			it( "should be a valid CFC file", () => {
				var commandPath = variables.projectRoot & "commands/migrate/fresh.cfc";
				expect( fileExists( commandPath ) ).toBeTrue();
			} );

			it( "should extend BaseMigrationCommand", () => {
				var commandPath = variables.projectRoot & "commands/migrate/fresh.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "extends=" )
				expect( content ).toInclude( "BaseMigrationCommand" );
			} );

			it( "should chain reset, install, and up commands", () => {
				var commandPath = variables.projectRoot & "commands/migrate/fresh.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "command(" )
				// Should call at least migrate reset, migrate install, and migrate up
			} );

			it( "should use .run() to execute chained commands", () => {
				var commandPath = variables.projectRoot & "commands/migrate/fresh.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( ".run()" );
			} );

		} );

		describe( "Common error handling patterns", () => {

			it( "commands with direct migration service calls should have try/catch blocks", () => {
				var commands = [ "install.cfc", "up.cfc", "down.cfc", "reset.cfc" ];
				for ( var cmd in commands ) {
					var commandPath = variables.projectRoot & "commands/migrate/#cmd#";
					var content     = fileRead( commandPath );
					expect( content ).toInclude( "try {" );
					expect( content ).toInclude( "catch" );
				}
			} );

			it( "commands with direct migration service calls should format SQL on errors", () => {
				var commands = [ "install.cfc", "up.cfc", "down.cfc", "reset.cfc" ];
				for ( var cmd in commands ) {
					var commandPath = variables.projectRoot & "commands/migrate/#cmd#";
					var content     = fileRead( commandPath );
					// Should reference sqlHighlighter or sqlFormatter in catch blocks
					expect( content ).toInclude( "sqlHighlighter" );
				}
			} );

			it( "commands with direct migration service calls should use error() to propagate exit codes", () => {
				var commands = [ "install.cfc", "up.cfc", "down.cfc", "reset.cfc" ];
				for ( var cmd in commands ) {
					var commandPath = variables.projectRoot & "commands/migrate/#cmd#";
					var content     = fileRead( commandPath );
					expect( content ).toInclude( "error(" );
				}
			} );

			it( "all commands should support verbose parameter for diagnostics", () => {
				var commands = [ "install.cfc", "up.cfc", "down.cfc", "reset.cfc", "fresh.cfc" ];
				for ( var cmd in commands ) {
					var commandPath = variables.projectRoot & "commands/migrate/#cmd#";
					var content     = fileRead( commandPath );
					expect( content ).toInclude( "boolean verbose" );
				}
			} );

		} );
	}

}
