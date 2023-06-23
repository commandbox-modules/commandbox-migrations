# `commandbox-migrations`

## Run your [`cfmigrations`](https://github.com/elpete/cfmigrations) from CommandBox


## Upgrading to v4.0.0?

v4 brings a new configuration structure and file.
This pairs with new features in CFMigrations to allow for multiple named migration managers and new seeding capabilities.
Migrations will still run in v4 using the old configuration structure and location, but it is highly recommended you upgrade.

You can create the new `.cfmigrations.json` config file by running `migrate init`.

The new config file format mirrors `CFMigrations`:

```json
{
    "default": {
        "manager": "cfmigrations.models.QBMigrationManager",
        "migrationsDirectory": "resources/database/migrations/",
        "seedsDirectory": "resources/database/seeds/",
        "properties": {
            "defaultGrammar": "MySQLGrammar@qb",
            "schema": "${DB_SCHEMA}",
            "migrationsTable": "cfmigrations",
            "connectionInfo": {
                "host": "${DB_HOST}",
                "username": "${DB_USER}",
                "password": "${DB_PASSWORD}",
                "database": "${DB_DATABASE}",
                "type": "mysql"
            }
        }
    }
}
```

More managers can be added as new top-level keys:

```json
{
    "default": {
        "manager": "cfmigrations.models.QBMigrationManager",
        "migrationsDirectory": "resources/database/migrations/",
        "seedsDirectory": "resources/database/seeds/",
        "properties": {
            "defaultGrammar": "MySQLGrammar@qb",
            "schema": "${DB_SCHEMA}",
            "migrationsTable": "cfmigrations",
            "connectionInfo": {
                "host": "${DB_HOST}",
                "username": "${DB_USER}",
                "password": "${DB_PASSWORD}",
                "database": "${DB_DATABASE}",
                "type": "mysql"
            }
        }
    },
    "alternate": {
        "manager": "cfmigrations.models.QBMigrationManager",
        "migrationsDirectory": "resources/database/other-migrations/",
        "seedsDirectory": "resources/database/other-seeds/",
        "properties": {
            "defaultGrammar": "MySQLGrammar@qb",
            "schema": "${DB_SCHEMA}",
            "migrationsTable": "cfmigrations2",
            "connectionInfo": {
                "host": "${DB_HOST}",
                "username": "${DB_USER}",
                "password": "${DB_PASSWORD}",
                "database": "${DB_DATABASE}",
                "type": "mysql"
            }
        }
    }
}
```

Each `migrate` command takes an optional `manager` string to use the specified configuration.

## Upgrading to v3.0.0?

Make sure to append `@qb` to the end of any qb-supplied grammars, like `AutoDiscover`.

## Setup

You need to create a `.cfmigrations.json` config file in your application root folder. You can do this easily by running `migrate init`:

```json
{
    "default": {
        "manager": "cfmigrations.models.QBMigrationManager",
        "migrationsDirectory": "resources/database/migrations/",
        "seedsDirectory": "resources/database/seeds/",
        "properties": {
            "defaultGrammar": "MySQLGrammar@qb",
            "schema": "${DB_SCHEMA}",
            "migrationsTable": "cfmigrations",
            "connectionInfo": {
                "host": "${DB_HOST}",
                "username": "${DB_USER}",
                "password": "${DB_PASSWORD}",
                "database": "${DB_DATABASE}",
                "type": "mysql"
            }
        }
    }
}
```

Additional managers can be added as new top-level keys.

The `defaultGrammar` sets the correct Database Grammar for `qb` to use to build your schema.
Available grammar options can be found in the [qb documentation](https://qb.ortusbooks.com).

> You don't have to use qb's `SchemaBuilder` to use `cfmigrations`.
> Just run your own migrations using `queryExecute` and you can have complete control over your sql.

The `schema` represents the schema to install the migrations in.  This is a very important field,
especially for database setups hosting mutiple schemas. Without it, `commandbox-migrations` will
be unable to correct detect the migrations table.  It may tell you that the migration table is
already installed when it isn't because it detects it in a different schema.

The `connectionInfo` object is the information to create an on the fly connection in CommandBox to run your migrations. This is the same struct you would use to add an application datasource in Lucee. (Note: it must be Lucee compatible since that is what CommandBox runs on under-the-hood.)

The `migrationsDirectory` sets the default location for the migration scripts.  This setting is optional.

The `seedsDirectory` sets the default location for the seeder scripts.  This setting is optional.

> When using MySQL with CommandBox 5 or greater, two additional elements are required in the `connectionInfo` struct:
> `"bundleName":"com.mysql.cj"` and `"bundleVersion":"8.0.15"`

`commandbox-migrations` will create a datasource named `cfmigrations` from the information you specify.
You can use this in your queries:

```js
queryExecute(
    "
        CREATE TABLE `users` (
            `id` INT UNSIGNED AUTO_INCREMENT,
            `email` VARCHAR(255) NOT NULL,
            `password` VARCHAR(255) NOT NULL
        )
    ",
    [],
    { datasource = "cfmigrations" }
)
```

`commandbox-migrations` will also set `cfmigrations` as the default datasource, so the following will work as well:

```js
queryExecute( "
    CREATE TABLE `users` (
        `id` INT UNSIGNED AUTO_INCREMENT,
         `email` VARCHAR(255) NOT NULL,
         `password` VARCHAR(255) NOT NULL
    )
" );
```

You may notice that the values are surrounded in an escape sequence (`${}`). This is how CommandBox injects environment variables into your `box.json` file. Why environment variables? Because you don't want to commit your database credentials in to source control. Also, you want to be able to have different values in different environments. Whether you have dedicated servers or are running your application in containers, you can find the supported way to add environment variables to your platform.

For local development using CommandBox, I recommend using environment files. This lets you define environment variables in a `.env` file in the root of your project. CommandBox will add these to your server when starting it up and also to the CommandBox instance if you load or reload the shell in a directory with a `.env` file. That is how we will get our environment variables available for `commandbox-migrations`.

Create a `.env` file in the root of you project. At the very least, it will look like this:

```env
# MYSQL VERSION
DB_SCHEMA=test_db
DB_DATABASE=test_db
DB_HOST=localhost
DB_USER=test
DB_PASSWORD=pass1234
```

```env
# MSSQL VERSION
DB_SCHEMA=dbo
DB_DATABASE=test_db
DB_HOST=localhost
DB_USER=test
DB_PASSWORD=pass1234
```


I recommend adding this file to your `.gitignore`

```
.env
```

An added step to help new users get up to speed with the needed environment variables for your project is to add an `.env.example` file to the root of your project as well. This file would have all the keys needed, but no values filled out. Like so:

```env
DB_SCHEMA=test_db
DB_DATABASE=test_db
DB_HOST=localhost
DB_USER=test
DB_PASSWORD=
```

You would update your `.gitignore` file to not ignore the `.env.example` file:

```
.env
!.env.example
```

## Usage

### `migrate init`

Creates the migration config file as `.cfmigrations.json`, if it doesn't already exist.

### `migrate install`

Installs the migration table in to your database.
This migration table keeps track of the ran migrations.

### `migrate create [name]`

Creates a migration file with an `up` and `down` method.
The file name will be prepended with the current timestamp
in the format that `cfmigrations` expects.

### `migrate up [--once] [--verbose] [--pretend] [file]`

Runs all available migrations up. Passing the `--once` flag will only
run a single migration up (if any are available).

Passing the `--verbose` flag with show the datasource information passed
as well as the full stack trace of any errors.

Passing the `--pretend` flag will not actually run the migrations but
instead print out the SQL that would have been run to the console.

Passing a `file` is used in conjunction with the `--pretend` flag.
If provided, the outputted sql will be saved to the file path provided.

### `migrate down [--once] [--verbose] [--pretend] [file]`

Runs all available migrations down. Passing the `--once` flag will only
run a single migration down (if any are available).

Passing the `--verbose` flag with show the datasource information passed
as well as the full stack trace of any errors.

Passing the `--pretend` flag will not actually run the migrations but
instead print out the SQL that would have been run to the console.

Passing a `file` is used in conjunction with the `--pretend` flag.
If provided, the outputted sql will be saved to the file path provided.

### `migrate refresh`

Runs all available migrations down and then runs all migrations up.

### `migrate reset`

Clears out all objects from the database, including the `cfmigrations` table.
Use this when your database is in an inconsistent state in development.

### `migrate fresh`

Runs `migrate reset`, `migrate install`, and `migrate up` to give you
a fresh copy of your migrated database.

### `migrate uninstall`

Removes the `cfmigrations` table after running down any ran migrations.

### `migrate seed create [name]`

Creates a new Seeder file.

### `migrate seed run`

Runs one or all Seeders.
