/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * TestBox Test Runner for commandbox-migrations
 *
 * Usage:
 *   box run-script test
 *   box task run taskFile=tests/Runner.cfc
 */
component {

	/**
	 * Main test runner
	 */
	function run() {
		var projectRoot = resolvePath( "../" )
		var testsDir    = projectRoot & "tests/"

        // Create filesystem mappings for the test specs to access the command and template files
		variables.fileSystemUtil.createMapping( "/testbox", projectRoot & "testbox" )
		variables.fileSystemUtil.createMapping( "/tests", testsDir )
        variables.fileSystemUtil.createMapping( "/commandbox-migrations", projectRoot )

        // Seed the test specs with the project root so they can locate the command files and templates
		request.commandboxMigrationsProjectRoot = projectRoot

		// Recurse = true so any nested spec directories are picked up automatically
		var tb = new testbox.system.TestBox(
			directory = { "mapping" : "tests.specs", "recurse" : true },
			reporter  = "text"
		)

		print.line( tb.run() ).toConsole()

		var testResult = tb.getResult()
		var totalFail  = testResult.getTotalFail()
		var totalError = testResult.getTotalError()

		if ( testResult.getTotalSpecs() == 0 ) {
			error( "No test specs were executed" )
		}

		if ( totalFail > 0 || totalError != 0 ) {
			error( "Test suite failed with #totalFail# failures and #totalError# errors" )
		}
	}

}
