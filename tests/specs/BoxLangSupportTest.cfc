/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Tests for BoxLang (.bx) migration and seeder file support in the cfmigrations
 * MigrationService. Validates that both .cfc and .bx files are discovered and
 * processed correctly.
 */
component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		variables.projectRoot = request.commandboxMigrationsProjectRoot;
	}

	function run() {

		describe( "MigrationService .bx file discovery", () => {

			it( "should use isMigrationFile filter to validate timestamp prefix", () => {
				var servicePath = variables.projectRoot & "modules/cfmigrations/models/MigrationService.cfc";
				var content     = fileRead( servicePath );
				expect( content ).toInclude( "isMigrationFile" );
			});

			it( "isMigrationFile should only check timestamp prefix, not extension", () => {
				var servicePath = variables.projectRoot & "modules/cfmigrations/models/MigrationService.cfc";
				var content     = fileRead( servicePath );
				// Should NOT hardcode ".cfc" in isMigrationFile
				expect( content ).notToInclude( 'filename contains ".cfc"' );
				expect( content ).notToInclude( "listLast( filename, '.' ) == 'cfc'" );
			});

		});

		describe( "Migration templates for both languages", () => {

			it( "should have CFML migration template (Migration.txt)", () => {
				expect( fileExists( variables.projectRoot & "templates/Migration.txt" ) ).toBeTrue();
			});

			it( "should have BoxLang migration template (MigrationBX.txt)", () => {
				expect( fileExists( variables.projectRoot & "templates/MigrationBX.txt" ) ).toBeTrue();
			});

			it( "CFML template should use 'component' keyword", () => {
				var content = fileRead( variables.projectRoot & "templates/Migration.txt" );
				expect( content ).toInclude( "component" );
			});

			it( "BoxLang template should use 'class' keyword", () => {
				var content = fileRead( variables.projectRoot & "templates/MigrationBX.txt" );
				expect( content ).toInclude( "class" );
			});

			it( "both templates should define up(schema, qb) and down(schema, qb)", () => {
				var cfmlContent = fileRead( variables.projectRoot & "templates/Migration.txt" );
				var bxContent   = fileRead( variables.projectRoot & "templates/MigrationBX.txt" );
				expect( cfmlContent ).toInclude( "function up(" );
				expect( cfmlContent ).toInclude( "function down(" );
				expect( bxContent ).toInclude( "function up(" );
				expect( bxContent ).toInclude( "function down(" );
			});

		});

		describe( "Seeder templates for both languages", () => {

			it( "should have CFML seeder template (seed.txt)", () => {
				expect( fileExists( variables.projectRoot & "templates/seed.txt" ) ).toBeTrue();
			});

			it( "should have BoxLang seeder template (seedBX.txt)", () => {
				expect( fileExists( variables.projectRoot & "templates/seedBX.txt" ) ).toBeTrue();
			});

			it( "CFML seeder template should use 'component' keyword", () => {
				var content = fileRead( variables.projectRoot & "templates/seed.txt" );
				expect( content ).toInclude( "component" );
			});

			it( "BoxLang seeder template should use 'class' keyword", () => {
				var content = fileRead( variables.projectRoot & "templates/seedBX.txt" );
				expect( content ).toInclude( "class" );
			});

			it( "both seeder templates should define run(qb, mockdata)", () => {
				var cfmlContent = fileRead( variables.projectRoot & "templates/seed.txt" );
				var bxContent   = fileRead( variables.projectRoot & "templates/seedBX.txt" );
				expect( cfmlContent ).toInclude( "function run(" );
				expect( bxContent ).toInclude( "function run(" );
			});

		});

		describe( "migrate create command supports --boxlang flag", () => {

			it( "should accept boxlang boolean parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean boxlang" );
			});

			it( "should select MigrationBX.txt when boxlang is true", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( '? "BX" : ""' );
			});

			it( "should default boxlang based on isBoxLangProject()", () => {
				var commandPath = variables.projectRoot & "commands/migrate/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "isBoxLangProject" );
			});

		});

		describe( "migrate seed create command supports --boxlang flag", () => {

			it( "should accept boxlang boolean parameter", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "boolean boxlang" );
			});

			it( "should select seedBX.txt when boxlang is true", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( '? "BX" : ""' );
			});

			it( "should default boxlang based on isBoxLangProject()", () => {
				var commandPath = variables.projectRoot & "commands/migrate/seed/create.cfc";
				var content     = fileRead( commandPath );
				expect( content ).toInclude( "isBoxLangProject" );
			});

		});

	}

}
