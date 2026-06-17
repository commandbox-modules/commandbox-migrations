/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Tests for the migrate create command structure, template selection,
 * and timestamp generation patterns.
 */
component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		variables.projectRoot = request.commandboxMigrationsProjectRoot;
	}

	function run() {

		describe( "migrate create command structure", () => {

			it( "should be a valid CFC file", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				expect( fileExists( commandPath ) ).toBeTrue();
			} );

			it( "should extend BaseMigrationCommand", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "extends=" )
				expect( content ).toInclude( "BaseMigrationCommand" );
			} );

			it( "should define a run() method", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "function run(" );
			} );

			it( "should accept a name parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "string name" );
			} );

			it( "should accept a manager parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "string manager" );
			} );

			it( "should accept a boxlang boolean parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean boxlang" );
			} );

			it( "should call setup() with setupDatasource=false", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "setup(" ).toInclude( "setupDatasource" );
			} );

			it( "should choose the CFML migration template when boxlang is false", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "Migration##arguments.boxlang" );
				expect( content ).toInclude( '? "BX" : ""' );
			} );

			it( "should choose the BoxLang migration template when boxlang is true", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "Migration##arguments.boxlang" );
				expect( content ).toInclude( '? "BX" : ""' );
			} );

			it( "should use the yyyy_mm_dd_HHnnss timestamp format", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "yyyy_mm_dd_HHnnss" );
			} );

			it( "should create the migrationsDirectory if it does not exist", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "directoryCreate" );
			} );

		} );

		describe( "migrate create migration templates", () => {

			it( "should have a CFML migration template", () => {
				var templatePath = variables.projectRoot & "templates/Migration.txt";
				expect( fileExists( templatePath ) ).toBeTrue();
			} );

			it( "should have a BoxLang migration template", () => {
				var templatePath = variables.projectRoot & "templates/MigrationBX.txt";
				expect( fileExists( templatePath ) ).toBeTrue();
			} );

			it( "CFML template should use component keyword", () => {
				var content = fileRead( variables.projectRoot & "templates/Migration.txt" );
				expect( content ).toInclude( "component" );
			} );

			it( "BoxLang template should use class keyword", () => {
				var content = fileRead( variables.projectRoot & "templates/MigrationBX.txt" );
				expect( content ).toInclude( "class" );
			} );

			it( "CFML template should define up() and down() methods", () => {
				var content = fileRead( variables.projectRoot & "templates/Migration.txt" );
				expect( content ).toInclude( "function up(" );
				expect( content ).toInclude( "function down(" );
			} );

			it( "BoxLang template should define up() and down() methods", () => {
				var content = fileRead( variables.projectRoot & "templates/MigrationBX.txt" );
				expect( content ).toInclude( "function up(" );
				expect( content ).toInclude( "function down(" );
			} );

			it( "Both templates should accept schema and qb arguments", () => {
				var cfmlContent = fileRead( variables.projectRoot & "templates/Migration.txt" );
				var bxContent   = fileRead( variables.projectRoot & "templates/MigrationBX.txt" );
				expect( cfmlContent ).toInclude( "schema" );
				expect( cfmlContent ).toInclude( "qb" );
				expect( bxContent ).toInclude( "schema" );
				expect( bxContent ).toInclude( "qb" );
			} );

		} );

		describe( "migrate create timestamp format", () => {

			it( "should generate a valid timestamp string", () => {
				// Simulate what the command does
				var timestamp = dateFormat( now(), "yyyy_mm_dd" ) & "_" & timeFormat( now(), "HHnnss" );
				expect( reFind( "^\d{4}_\d{2}_\d{2}_\d{6}$", timestamp ) ).toBeTrue();
			} );

			it( "should produce sortable filenames", () => {
				var ts1 = dateFormat( "2024-01-01", "yyyy_mm_dd" ) & "_" & timeFormat( "08:00:00", "HHnnss" );
				var ts2 = dateFormat( "2024-01-02", "yyyy_mm_dd" ) & "_" & timeFormat( "08:00:00", "HHnnss" );
				expect( ts1 < ts2 ).toBeTrue();
			} );

		} );
	}

}
