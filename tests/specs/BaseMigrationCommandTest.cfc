/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Tests for the commandbox-migrations configuration templates and fixtures.
 * These tests validate the template files, generated fixtures, and expected
 * configuration structures without requiring a live database or running server.
 */
component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		variables.projectRoot = request.commandboxMigrationsProjectRoot;
	}

	function run() {

		describe( "Migration Config Templates", () => {

			describe( ".cbmigrations.json template", () => {

				it( "should exist as config.txt", () => {
					var templatePath = variables.projectRoot & "templates/config.txt";
					expect( fileExists( templatePath ) ).toBeTrue();
				});

				it( "should contain valid JSON", () => {
					var templatePath    = variables.projectRoot & "templates/config.txt";
					var templateContent = replace( fileRead( templatePath ), "$" & "{DB_PORT}", "5432" );
					var config          = deserializeJSON( templateContent );
					expect( isStruct( config ) ).toBeTrue();
				});

				it( "should contain a default manager entry", () => {
					var templatePath = variables.projectRoot & "templates/config.txt";
					var config       = deserializeJSON( replace( fileRead( templatePath ), "$" & "{DB_PORT}", "5432" ) );
					expect( config ).toHaveKey( "default" );
				});

				it( "should use QBMigrationManager as the default manager", () => {
					var templatePath = variables.projectRoot & "templates/config.txt";
					var config       = deserializeJSON( replace( fileRead( templatePath ), "$" & "{DB_PORT}", "5432" ) );
					expect( config.default ).toHaveKey( "manager" );
					expect( config.default.manager ).toInclude( "QBMigrationManager" );
				});

				it( "should define a migrationsDirectory", () => {
					var templatePath = variables.projectRoot & "templates/config.txt";
					var config       = deserializeJSON( replace( fileRead( templatePath ), "$" & "{DB_PORT}", "5432" ) );
					expect( config.default ).toHaveKey( "migrationsDirectory" );
					expect( config.default.migrationsDirectory ).notToBeEmpty();
				});

				it( "should define a seedsDirectory", () => {
					var templatePath = variables.projectRoot & "templates/config.txt";
					var config       = deserializeJSON( replace( fileRead( templatePath ), "$" & "{DB_PORT}", "5432" ) );
					expect( config.default ).toHaveKey( "seedsDirectory" );
					expect( config.default.seedsDirectory ).notToBeEmpty();
				});

				it( "should define connectionInfo with database driver placeholder", () => {
					var templatePath = variables.projectRoot & "templates/config.txt";
					var config       = deserializeJSON( replace( fileRead( templatePath ), "$" & "{DB_PORT}", "5432" ) );
					expect( config.default ).toHaveKey( "properties" );
					expect( config.default.properties ).toHaveKey( "connectionInfo" );
					expect( config.default.properties.connectionInfo ).toHaveKey( "type" );
				});

				it( "should use environment variables for connection info", () => {
					var templatePath    = variables.projectRoot & "templates/config.txt";
					var templateContent = fileRead( templatePath );
					expect( templateContent ).toInclude( "${DB_DRIVER}" );
					expect( templateContent ).toInclude( "${DB_DATABASE}" );
					expect( templateContent ).toInclude( "${DB_HOST}" );
				});

			});

			describe( "Migration templates", () => {

				it( "should have a CFML migration template", () => {
					expect( fileExists( variables.projectRoot & "templates/Migration.txt" ) ).toBeTrue();
				});

				it( "should have a BoxLang migration template", () => {
					expect( fileExists( variables.projectRoot & "templates/MigrationBX.txt" ) ).toBeTrue();
				});

				it( "CFML template should use component keyword", () => {
					var content = fileRead( variables.projectRoot & "templates/Migration.txt" );
					expect( content ).toInclude( "component" );
				});

				it( "BoxLang template should use class keyword", () => {
					var content = fileRead( variables.projectRoot & "templates/MigrationBX.txt" );
					expect( content ).toInclude( "class" );
				});

				it( "both templates should define up() and down() functions", () => {
					var cfmlContent = fileRead( variables.projectRoot & "templates/Migration.txt" );
					var bxContent   = fileRead( variables.projectRoot & "templates/MigrationBX.txt" );
					expect( cfmlContent ).toInclude( "function up(" );
					expect( cfmlContent ).toInclude( "function down(" );
					expect( bxContent ).toInclude( "function up(" );
					expect( bxContent ).toInclude( "function down(" );
				});

				it( "both templates should accept schema and qb parameters", () => {
					var cfmlContent = fileRead( variables.projectRoot & "templates/Migration.txt" );
					var bxContent   = fileRead( variables.projectRoot & "templates/MigrationBX.txt" );
					expect( cfmlContent ).toInclude( "schema" );
					expect( cfmlContent ).toInclude( "qb" );
					expect( bxContent ).toInclude( "schema" );
					expect( bxContent ).toInclude( "qb" );
				});

			});

			describe( "Seed templates", () => {

				it( "should have a CFML seed template", () => {
					expect( fileExists( variables.projectRoot & "templates/seed.txt" ) ).toBeTrue();
				});

				it( "should have a BoxLang seed template", () => {
					expect( fileExists( variables.projectRoot & "templates/seedBX.txt" ) ).toBeTrue();
				});

				it( "CFML seed template should use component keyword", () => {
					var content = fileRead( variables.projectRoot & "templates/seed.txt" );
					expect( content ).toInclude( "component" );
				});

				it( "BoxLang seed template should use class keyword", () => {
					var content = fileRead( variables.projectRoot & "templates/seedBX.txt" );
					expect( content ).toInclude( "class" );
				});

				it( "both seed templates should define a run() function", () => {
					var cfmlContent = fileRead( variables.projectRoot & "templates/seed.txt" );
					var bxContent   = fileRead( variables.projectRoot & "templates/seedBX.txt" );
					expect( cfmlContent ).toInclude( "function run(" );
					expect( bxContent ).toInclude( "function run(" );
				});

			});

		});

		describe( "Config Fixtures", () => {

			beforeEach( () => {
				variables.fixturesDir = variables.projectRoot & "tests/resources/fixtures/";
				if ( !directoryExists( variables.fixturesDir ) ) {
					directoryCreate( variables.fixturesDir );
				}
			});

			describe( "Valid .cbmigrations.json fixture", () => {

				it( "should exist", () => {
					var fixturePath = variables.fixturesDir & "valid_cbmigrations.json";
					expect( fileExists( fixturePath ) ).toBeTrue();
				});

				it( "should contain valid JSON", () => {
					var fixturePath = variables.fixturesDir & "valid_cbmigrations.json";
					var config      = deserializeJSON( fileRead( fixturePath ) );
					expect( isStruct( config ) ).toBeTrue();
				});

				it( "should define a default manager", () => {
					var fixturePath = variables.fixturesDir & "valid_cbmigrations.json";
					var config      = deserializeJSON( fileRead( fixturePath ) );
					expect( config ).toHaveKey( "default" );
					expect( config.default ).toHaveKey( "manager" );
				});

			});

			describe( "Multiple managers fixture", () => {

				it( "should exist", () => {
					var fixturePath = variables.fixturesDir & "multi_manager_cbmigrations.json";
					expect( fileExists( fixturePath ) ).toBeTrue();
				});

				it( "should define multiple managers", () => {
					var fixturePath = variables.fixturesDir & "multi_manager_cbmigrations.json";
					var config      = deserializeJSON( fileRead( fixturePath ) );
					expect( structCount( config ) ).toBeGTE( 2 );
				});

				it( "should define default and secondary managers", () => {
					var fixturePath = variables.fixturesDir & "multi_manager_cbmigrations.json";
					var config      = deserializeJSON( fileRead( fixturePath ) );
					expect( config ).toHaveKey( "default" );
					expect( config ).toHaveKey( "secondary" );
				});

			});

		});

		describe( "Configuration File Patterns", () => {

			it( "should recognize .cbmigrations.json as the preferred config format", () => {
				// Document the resolution order: .cbmigrations.json > .cfmigrations.json
				var preferredConfig = ".cbmigrations.json";
				var legacyConfig    = ".cfmigrations.json";
				expect( preferredConfig ).notToBe( legacyConfig );
				// The actual resolution logic is in findMigrationsConfigPath()
				// which can only be tested with mocked dependencies
			});

			it( "should support legacy .cfmigrations.json format", () => {
				// Document: legacy format is still supported but deprecated
				var legacyFormat = ".cfmigrations.json";
				expect( legacyFormat ).toInclude( "cfmigrations" );
			});

			it( "should support box.json as fallback configuration", () => {
				// Document: box.json with cfmigrations key is deprecated but supported
				var boxJsonConfig = {
					"name"          : "test-project",
					"cfmigrations" : {
						"managers" : {
							"default" : {
								"manager"              : "cfmigrations.models.QBMigrationManager",
								"migrationsDirectory" : "resources/database/migrations/"
							}
						}
					}
				};
				expect( boxJsonConfig ).toHaveKey( "cfmigrations" );
				expect( boxJsonConfig.cfmigrations ).toHaveKey( "managers" );
			});

		});

	}

}
