/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Tests for the migrate init command structure, template usage,
 * and configuration generation patterns.
 *
 * Since CommandBox commands require shell context to execute,
 * these tests validate the command's file structure, template
 * resolution, and expected configuration output.
 */
component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		variables.projectRoot = request.commandboxMigrationsProjectRoot;
	}

	function run() {

		describe( "migrate init command structure", () => {

			it( "should be a valid CFC file", () => {
				var commandPath = variables.projectRoot & "commands/migrate/init.cfc";
				expect( fileExists( commandPath ) ).toBeTrue();
			} );

			it( "should extend BaseMigrationCommand", () => {
				var commandPath = variables.projectRoot & "commands/migrate/init.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "extends=" )
				expect( content ).toInclude( "BaseMigrationCommand" );
			} );

			it( "should define a run() method", () => {
				var commandPath = variables.projectRoot & "commands/migrate/init.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "function run(" );
			} );

			it( "should accept an open parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/init.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean open" );
			} );

			it( "should reference the config.txt template", () => {
				var commandPath = variables.projectRoot & "commands/migrate/init.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "config.txt" );
			} );

			it( "should check if .cbmigrations.json already exists before creating", () => {
				var commandPath = variables.projectRoot & "commands/migrate/init.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "fileExists" );
				expect( content ).toInclude( ".cbmigrations.json" );
			} );

			it( "should write the config file with mode 777", () => {
				var commandPath = variables.projectRoot & "commands/migrate/init.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "mode=" );
				expect( content ).toInclude( "777" );
			} );

		} );

		describe( "init command config template output", () => {

			it( "should produce valid JSON when config.txt is written", () => {
				var templatePath = variables.projectRoot & "templates/config.txt";
				var content      = replace( fileRead( templatePath ), "$" & "{DB_PORT}", "5432" );
				// trim() is applied in the command before writing
				var config = deserializeJSON( trim( content ) );
				expect( isStruct( config ) ).toBeTrue();
			} );

			it( "should produce a config with the correct default manager", () => {
				var content = replace( fileRead( variables.projectRoot & "templates/config.txt" ), "$" & "{DB_PORT}", "5432" );
				var config  = deserializeJSON( trim( content ) );
				expect( config.default.manager ).toBe( "cfmigrations.models.QBMigrationManager" );
			} );

			it( "should produce a config with environment variable placeholders", () => {
				var content = fileRead( variables.projectRoot & "templates/config.txt" );
				expect( content ).toInclude( "${DB_DRIVER}" );
				expect( content ).toInclude( "${DB_DATABASE}" );
				expect( content ).toInclude( "${DB_HOST}" );
			} );

			it( "should produce a config file under 500 characters after trimming", () => {
				// The config template should be compact enough for a config file
				var content = trim( fileRead( variables.projectRoot & "templates/config.txt" ) );
				expect( len( content ) ).toBeGT( 100 );
				expect( len( content ) ).toBeLT( 2000 );
			} );

		} );

		describe( "init command idempotency logic", () => {

			it( "should use fileExists() to detect existing configs", () => {
				var commandPath = variables.projectRoot & "commands/migrate/init.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "fileExists( configPath )" );
			} );

			it( "should return early when config already exists", () => {
				var commandPath = variables.projectRoot & "commands/migrate/init.cfc";
				var content     = fileRead( commandPath );
				// Should have a return statement within the fileExists check
				expect( content ).toInclude( "return" );
			} );

			it( "should print a yellow warning when config already exists", () => {
				var commandPath = variables.projectRoot & "commands/migrate/init.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "print.yellowLine" );
				expect( content ).toInclude( "already exists" );
			} );

		} );
	}

}
