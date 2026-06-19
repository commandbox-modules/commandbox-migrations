/**
 * Uninstall the migrations tracking table from your database.
 *
 * WARNING: Uninstalling will also run all your migrations DOWN before removing
 * the tracking table. This means all applied migrations will be rolled back
 * and all data managed by those migrations will be lost.
 *
 * Use this command when you are fully removing migrations from your application
 * or want a completely clean slate. You will be asked to confirm before proceeding
 * unless the --force flag is provided.
 *
 * {code:bash}
 * ## Uninstall with confirmation prompt
 * migrate uninstall
 *
 * ## Uninstall without confirmation
 * migrate uninstall --force
 *
 * ## Uninstall a named manager
 * migrate uninstall --manager=secondary
 *
 * ## Uninstall with verbose error output
 * migrate uninstall --verbose
 * {code}
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @verbose       If true, errors output a full stack trace.
     * @force         If true, will not wait for confirmation to uninstall cbmigrations.
     */
    function run( string manager = "default", boolean verbose = false, boolean force = false ) {
        setup( arguments.manager );

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cbmigrations info:" );
            print.line( getMigrationsInfo() ).line();
        }

        pagePoolClear();

        try {
            if ( !variables.migrationService.isReady() ) {
                print.line( "No Migration table detected." );
                return;
            }

            if (
                arguments.force || confirm(
                    "Uninstalling cbmigrations will also run all your migrations down. Are you sure you want to continue? [y/n]"
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
