/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Display help and usage information for the migrate seed commands.
 */
component excludeFromHelp=true extends="commandbox-migrations.models.BaseMigrationCommand" {

    function run() {
        print
            .line()
            .boldCyan( "Database Seeders" )
            .line()
            .line()
            .whiteLine( "Seeders populate your database with initial or sample data." )
            .whiteLine( "Unlike migrations, seeders can be run multiple times — each run inserts data again." )
            .line()
            .boldWhiteLine( "Commands:" )
            .line()
            .greenLine( "  migrate seed run              Run all seeders or a specific named seeder" )
            .greenLine( "  migrate seed create <name>    Create a new seeder file" )
            .line()
            .yellowLine( "Examples:" )
            .line()
            .dim( "  ## Run all seeders" )
            .line( "  migrate seed run" )
            .line()
            .dim( "  ## Run a specific seeder by name" )
            .line( "  migrate seed run UserSeeder" )
            .line()
            .dim( "  ## Create a new seeder and open it immediately" )
            .line( "  migrate seed create UserSeeder --open" )
            .line()
            .dim( "  ## Create a BoxLang seeder" )
            .line( "  migrate seed create UserSeeder --boxlang" )
            .line()
            .dim( "  ## Run seeders on a named manager" )
            .line( "  migrate seed run --manager=secondary" )
            .line()
            .line()
            .yellowLine( "Tip: Type 'migrate seed <command> --help' for detailed options" )
            .line()
            .dim( "Documentation: https://forgebox.io/view/commandbox-migrations" )
            .line()
            .line()
    }

}
