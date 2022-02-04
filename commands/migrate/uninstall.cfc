/**
 * Uninstalls the cfmigrations table from your database.
 *
 * The cfmigrations table keeps track of the migrations ran against your database.
 * Uninstall it when you are removing cfmigrations from your application.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager.hint       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @verbose.hint       If true, errors output a full stack trace.
     * @force.hint         If true, will not wait for confirmation to uninstall cfmigrations.
     */
    function run( string manager = "default", boolean verbose = false, boolean force = false ) {
        setup( arguments.manager );

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cfmigrations info:" );
            print.line( variables.cfmigrationsInfo ).line();
        }

        pagePoolClear();

        try {
            if ( !variables.migrationService.isReady() ) {
                print.line( "No Migration table detected." );
                return;
            }

            if (
                arguments.force || confirm(
                    "Uninstalling cfmigrations will also run all your migrations down. Are you sure you want to continue? [y/n]"
                )
            ) {
                variables.migrationService.uninstall();
                print.line( "Migration table uninstalled!" ).line();
            } else {
                print.line( "Aborting uninstall process." );
            }
        } catch ( any e ) {
            if ( arguments.verbose ) {
                if ( structKeyExists( e, "Sql" ) ) {
                    print.whiteOnRedLine( "Error when trying to run #currentlyRunningMigration.componentName#:" );
                    print.line( variables.sqlHighlighter.highlight( variables.sqlFormatter.format( e.Sql ) ).toAnsi() );
                }
                rethrow;
            }

            return error( e.message, e.detail );
        }
    }

}
