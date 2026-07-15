/**
 * Install the migrations tracking table into your database.
 *
 * The migrations table records every migration that has been applied, allowing
 * cbmigrations to know which migrations are pending and which have been run.
 * This command must be run before executing `migrate up` for the first time.
 *
 * Running this command when the table already exists will display a message
 * and exit gracefully without making any changes.
 *
 * {code:bash}
 * ## Install the migrations table
 * migrate install
 *
 * ## Install for a named manager
 * migrate install --manager=secondary
 *
 * ## Install with verbose output
 * migrate install --verbose
 * {code}
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager          The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @verbose          If true, errors will output a full stack trace.
     * @installDrivers   If true, auto-install the BoxLang JDBC driver module. Default: true.
     */
    function run( string manager = "default", boolean verbose = false, boolean installDrivers = true ) {
        setup( manager: arguments.manager, installDrivers = arguments.installDrivers );

        if ( verbose ) {
            print.blackOnYellowLine( "cbmigrations info:" );
            print.line( getMigrationsInfo() ).line();
        }

        try {
            if ( variables.migrationService.isReady() ) {
                print.yellowLine( "ℹ️ Migration table already installed." );
                return;
            }

            variables.migrationService.install();
            print.greenLine( "✅ Migration table installed!" ).line();
        } catch ( any e ) {
            if ( verbose ) {
                if ( structKeyExists( e, "Sql" ) ) {
                    print.whiteOnRedLine( "❌ Error when trying to install the migration table:" );
                    print.line( variables.sqlHighlighter.highlight( variables.sqlFormatter.format( e.Sql ) ).toAnsi() );
                }
                rethrow;
            }

            return error( e.message, e.detail );
        }
    }

}
