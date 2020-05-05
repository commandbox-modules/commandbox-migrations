/**
* Rollback all committed migrations and then apply all migrations in order.
*/
component extends="commandbox-migrations.models.BaseMigrationCommand" {

    /**
    * @migrationsDirectory Override the default relative location of the migration files
    * @verbose             If true, errors output a full stack trace
    */
    function run(
        string migrationsDirectory = "",
        boolean verbose = false
    ) {
        setup();
        setupDatasource();

        pagePoolClear();
        if ( len(arguments.migrationsDirectory) )
            setMigrationPath( arguments.migrationsDirectory );

        command( "migrate down" )
            .params( argumentCollection = { verbose = arguments.verbose } )
            .run();

        command( "migrate up" )
            .params( argumentCollection = { verbose = arguments.verbose } )
            .run();
    }

}
