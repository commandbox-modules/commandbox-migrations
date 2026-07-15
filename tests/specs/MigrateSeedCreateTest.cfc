/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Tests for the migrate seed create command structure and template selection.
 */
component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		variables.projectRoot = request.commandboxMigrationsProjectRoot;
	}

	function run() {

		describe( "migrate seed create command structure", () => {

			it( "should be a valid CFC file", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				expect( fileExists( commandPath ) ).toBeTrue();
			} );

			it( "should extend BaseMigrationCommand", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "extends=" )
				expect( content ).toInclude( "BaseMigrationCommand" );
			} );

			it( "should define a run() method", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "function run(" );
			} );

			it( "should accept a name parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "string name" );
			} );

			it( "should accept a manager parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "string manager" );
			} );

			it( "should accept a boxlang boolean parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean boxlang" );
			} );

			it( "should call setup() with setupDatasource=false", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "setup(" ).toInclude( "setupDatasource" );
			} );

			it( "should choose the CFML seed template when boxlang is false", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "seed##arguments.boxlang" );
				expect( content ).toInclude( '? "BX" : ""' );
			} );

			it( "should choose the BoxLang seed template when boxlang is true", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "seed##arguments.boxlang" );
				expect( content ).toInclude( '? "BX" : ""' );
			} );

			it( "should use the provided seed name without a timestamp", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "##arguments.name##.##extension##" );
			} );

			it( "should create the seedsDirectory if it does not exist", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "directoryCreate" );
			} );

		} );

		describe( "migrate seed create templates", () => {

			it( "should have a CFML seed template", () => {
				var templatePath = variables.projectRoot & "templates/seed.txt";
				expect( fileExists( templatePath ) ).toBeTrue();
			} );

			it( "should have a BoxLang seed template", () => {
				var templatePath = variables.projectRoot & "templates/seedBX.txt";
				expect( fileExists( templatePath ) ).toBeTrue();
			} );

			it( "CFML template should use component keyword", () => {
				var content = fileRead( variables.projectRoot & "templates/seed.txt" );
				expect( content ).toInclude( "component" );
			} );

			it( "BoxLang template should use class keyword", () => {
				var content = fileRead( variables.projectRoot & "templates/seedBX.txt" );
				expect( content ).toInclude( "class" );
			} );

			it( "CFML template should define a run() method", () => {
				var content = fileRead( variables.projectRoot & "templates/seed.txt" );
				expect( content ).toInclude( "function run(" );
			} );

			it( "BoxLang template should define a run() method", () => {
				var content = fileRead( variables.projectRoot & "templates/seedBX.txt" );
				expect( content ).toInclude( "function run(" );
			} );

			it( "Both templates should accept qb and mockdata arguments", () => {
				var cfmlContent = fileRead( variables.projectRoot & "templates/seed.txt" );
				var bxContent   = fileRead( variables.projectRoot & "templates/seedBX.txt" );
				expect( cfmlContent ).toInclude( "qb" );
				expect( cfmlContent ).toInclude( "mockdata" );
				expect( bxContent ).toInclude( "qb" );
				expect( bxContent ).toInclude( "mockdata" );
			} );

		} );
	}

}
