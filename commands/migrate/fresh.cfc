/**
 * Drop all database objects and re-run every migration from scratch.
 *
 * WARNING: This is a destructive operation! It calls `migrate reset` to wipe
 * the entire database schema, then re-installs the migrations table and applies
 * all migrations in order. All data will be lost.
 *
 * Use this command to get a clean-slate database during development.
 *
 * {code:bash}
 * ## Drop everything and re-run all migrations
 * migrate fresh
 *
 * ## Drop everything, re-run migrations, then seed the database
 * migrate fresh --seed
 *
 * ## Run a fresh migration for a named manager
 * migrate fresh --manager=secondary
 *
 * ## Run with verbose error output
 * migrate fresh --verbose
 * {code}
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @manager          The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @seed             If true, runs all seeders for the manager after creating a fresh database.
     * @verbose          If true, errors output a full stack trace.
     * @installDrivers   If true, auto-install the BoxLang JDBC driver module. Default: true.
     */
    function run(
        string manager = "default",
        boolean seed = false,
        boolean verbose = false,
        boolean installDrivers = true
    ) {
        setup( manager: arguments.manager, installDrivers = arguments.installDrivers );

        if ( arguments.verbose ) {
            print.blackOnYellowLine( "cbmigrations info:" );
            print.line( getMigrationsInfo() ).line();
        }

        pagePoolClear();

        command( "migrate reset" ).params( argumentCollection = arguments ).run();
        command( "migrate install" ).params( argumentCollection = arguments ).run();
        command( "migrate up" ).params( argumentCollection = arguments ).run();
    }

}
