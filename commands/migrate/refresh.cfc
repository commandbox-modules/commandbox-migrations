/**
* Rollback all committed migrations and then apply all migrations in order.
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

        command( "migrate down" )
            .params( argumentCollection = { verbose = arguments.verbose } )
            .run();

        command( "migrate up" )
            .params( argumentCollection = { verbose = arguments.verbose } )
            .run();
    }

}
