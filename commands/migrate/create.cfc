/**
 * Create a new migration CFC in an existing application.
 * Make sure you are running this command in the root of your app.
 *
 * It prepends the date at the beginning of the file name so
 * you can keep your migrations in the correct order.
 *
 * {code:bash}
 * ## Create a simple migration
 * migrate create CreateUsersTable
 *
 * ## Create and immediately open the migration for editing
 * migrate create AddEmailToUsers --open
 *
 * ## Create a BoxLang migration (.bx)
 * migrate create CreateProductsTable --boxlang
 *
 * ## Create a migration for a named manager
 * migrate create CreateOrdersTable --manager=secondary
 * {code}
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
     * @name          Name of the migration to create without the extension.
     * @manager       The Migration Manager to use.
     * @manager.optionsUDF completeManagers
     * @open          Open the file once generated.
     * @boxlang       Create a .bx file instead of a .cfc. Defaults to auto-detection based on your server/box.json.
     */
    function run(
        required string name,
        string manager = "default",
        boolean open = false,
        boolean boxlang = isBoxLangProject( getCWD() )
    ) {
        setup( manager = arguments.manager, setupDatasource = false )
        var migrationsDirectory = expandPath( variables.migrationService.getMigrationsDirectory() )

        // Validate migrationsDirectory
        if ( !directoryExists( migrationsDirectory ) ) {
            directoryCreate( migrationsDirectory )
        }

        var extension = arguments.boxlang ? "bx" : "cfc"
        var timestamp = dateTimeFormat( now(), "yyyy_MM_dd_HHnnss" )
        var migrationPath = "#migrationsDirectory##timestamp#_#arguments.name#.#extension#"
        var migrationContent = fileRead( "/commandbox-migrations/templates/Migration#arguments.boxlang ? "BX" : ""#.txt" )

        file action="write" file="#migrationPath#" mode="777" output="#trim( migrationContent )#";

        print.greenLine( "Created #migrationPath#" )

        // Open file?
        if ( arguments.open ) {
            openPath( migrationPath )
        }

        return
    }

}
