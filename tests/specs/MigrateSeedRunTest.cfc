/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Tests for the migrate seed run command structure and execution patterns.
 */
component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		variables.projectRoot = request.commandboxMigrationsProjectRoot;
	}

	function run() {

		describe( "migrate seed run command structure", () => {

			it( "should be a valid CFC file", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				expect( fileExists( commandPath ) ).toBeTrue();
			} );

			it( "should extend BaseMigrationCommand", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "extends=" )
				expect( content ).toInclude( "BaseMigrationCommand" );
			} );

			it( "should define a run() method", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "function run(" );
			} );

			it( "should accept a manager parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "string manager" );
			} );

			it( "should accept a name parameter for a specific seeder", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "string name" );
			} );

			it( "should accept a verbose boolean parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean verbose" );
			} );

			it( "should call setup() before execution", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "setup(" );
			} );

			it( "should clear page pool before seed execution", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "pagePoolClear" );
			} );

			it( "should use preProcessHook for logging", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "preProcessHook" );
			} );

			it( "should use postProcessHook for logging", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "postProcessHook" );
			} );

		} );

		describe( "migrate seed run error handling", () => {

			it( "should have try/catch blocks", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "try {" );
				expect( content ).toInclude( "catch" );
			} );

			it( "should format SQL on errors", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "sqlHighlighter" );
			} );

			it( "should use error() to propagate exit codes", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "error(" );
			} );

			it( "should check SQL existence in error structure", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "structKeyExists" );
			} );

		} );

		describe( "migrate seed run seeder selection", () => {

			it( "should pass the selected seed name to the migration service", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "seedName" );
				expect( content ).toInclude( "arguments.name" );
			} );

			it( "should report when no seeders run", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/run.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "No seeders to run" );
			} );

		} );
	}

}
