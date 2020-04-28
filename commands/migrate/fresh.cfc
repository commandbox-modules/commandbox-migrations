/**
 * Resets the database and runs all migrations up.
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
        pagePoolClear();
        if ( len(arguments.migrationsDirectory) )
            setMigrationPath( arguments.migrationsDirectory );

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
