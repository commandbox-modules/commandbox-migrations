/**
 * Resets the database and runs all migrations up.
 */
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
    * @migrationsDirectory Specify the relative location of the migration files
    * @verbose             If true, errors output a full stack trace
    */
    function run(
        string migrationsDirectory = "resources/database/migrations",
        boolean verbose = false
    ) {
        pagePoolClear();
        var relativePath = fileSystemUtil.makePathRelative(
            fileSystemUtil.resolvePath( migrationsDirectory )
        );
        migrationService.setMigrationsDirectory( relativePath );

        command( "migrate reset" )
            .params( argumentCollection = arguments )
            .run();
        command( "migrate install" )
            .params( argumentCollection = arguments )
            .run();
        command( "migrate up" )
            .params( argumentCollection = arguments )
            .run();
    }

}
