# CommandBox Migrations

CommandBox Migrations is a [CommandBox](https://www.ortussolutions.com/products/commandbox) module that lets you manage and run database migrations directly from the CLI. It wraps the [ColdBox Migrations](https://github.com/coldbox-modules/cfmigrations) library, giving you a powerful, convention-driven way to evolve your database schema — without needing a running web server.

## Features

- **CLI-driven** — Run migrations from anywhere using `migrate up`, `migrate down`, `migrate status`, `migrate fresh`, and more.
- **Multi-manager support** — Manage multiple named migration configurations (e.g., `default`, `alternate`) from a single project.
- **Seeding** — Create and run database seeds with `migrate seed create` and `migrate seed run`.
- **Driver management** — Install, list, and remove BoxLang JDBC drivers with `migrate drivers install`, `migrate drivers list`, and `migrate drivers remove`.
- **BoxLang Prime** — Full support for BoxLang projects with automatic detection and `.cbmigrations.json` config.
- **Environment-aware** — Leverage `${ENV_VAR}` placeholders in your config for database credentials and settings.
- **Init scaffolding** — Get up and running fast with `migrate init` to generate your config and first migration.

Please note that the CFML version of CommandBox is reaching end of life soon, so we would encourage you to start using the BoxLang version base of CommandBox via the `bx-cli` module: https://forgebox.io/view/bx-cli with this module. You can install it via the following command:

```bash
# Install using the BoxLang installer scripts
install-bx-module bx-cli
```

## Upgrading to v6.0.0?

v6 makes `.cbmigrations.json` the **universal standard** config file for **all** projects — BoxLang and CFML alike. The legacy `.cfmigrations.json` is fully deprecated.

### What changed

- **Config file:** `.cbmigrations.json` is now the one and only config file name. If `migrate init` finds only `.cfmigrations.json`, it will prompt you to rename it automatically. If both files exist, `.cbmigrations.json` takes priority.
- **Migration table:** The default migration table name is now `cbmigrations` (was `cfmigrations` in v4/v5). New projects created with `migrate init` will use `cbmigrations` by default.
- **BoxLang support:** All the BoxLang support introduced in v5 is now fully mature. The `--boxlang` / `--no-boxlang` flags work identically, but `.cbmigrations.json` is used for both BoxLang and CFML projects alike.
- This module is now preferred to run on the BoxLang version of CommandBox as the CFML version will be end of life soon.

### How to upgrade

1. Rename your `.cfmigrations.json` to `.cbmigrations.json` (or let `migrate init` do it for you).
2. If you are starting fresh, your migration table will default to `cbmigrations`. If you have an existing `cfmigrations` table, keep the `"migrationsTable": "cfmigrations"` setting in your config.

## Upgrading to v5.0.0?

v5 introduced first-class [BoxLang](https://boxlang.io) support alongside the CFML experience.

### What changed

- **BoxLang detection:** The module now auto-detects BoxLang projects based on the running server engine or the `"language": "boxlang"` key in `box.json`.
- **Dual config support:** `.cbmigrations.json` was introduced as the BoxLang config file. If both `.cbmigrations.json` and `.cfmigrations.json` exist, the `.cbmigrations.json` file is read first.
- **Scaffolding:** `migrate create` and `migrate seed create` generate `.bx` files for BoxLang projects (auto-detected, or overridden with `--boxlang` / `--no-boxlang`).
- **`migrate init --boxlang`:** The init command gained `--boxlang` / `--no-boxlang` flags to override auto-detection.

### How to upgrade

Upgrading from v4 is straightforward — no breaking config changes. If you're a BoxLang user, your project will be auto-detected and you'll get `.bx` scaffolding automatically. If you're a CFML user, nothing changes.

## Upgrading to v4.0.0?

> ⚠️ **Legacy:** v4 introduced the `.cfmigrations.json` config file. As of v6, the standard config file is `.cbmigrations.json` for all projects. See [Upgrading to v6.0.0?](#upgrading-to-v600) for details.

v4 brings a new configuration structure and file.
This pairs with new features in CFMigrations to allow for multiple named migration managers and new seeding capabilities.
Migrations will still run in v4 using the old configuration structure and location, but it is highly recommended you upgrade.

You can create the new `.cfmigrations.json` config file by running `migrate init`.

> In v5, `.cbmigrations.json` was introduced for BoxLang projects alongside `.cfmigrations.json`.
> As of v6, `.cbmigrations.json` is the universal standard for all projects.

```json
{
    "default": {
        "manager": "cfmigrations.models.QBMigrationManager",
        "migrationsDirectory": "resources/database/migrations/",
        "seedsDirectory": "resources/database/seeds/",
        "properties": {
            "defaultGrammar": "MySQLGrammar@qb",
            "schema": "${DB_SCHEMA}",
            "migrationsTable": "cbmigrations",
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
            "migrationsTable": "cbmigrations",
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
            "migrationsTable": "cbmigrations_alternate",
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

You need to create a `.cbmigrations.json` config file in your application root folder or just run `migrate init`.

```json
{
    "default": {
        "manager": "cfmigrations.models.QBMigrationManager",
        "migrationsDirectory": "resources/database/migrations/",
        "seedsDirectory": "resources/database/seeds/",
        "properties": {
            "defaultGrammar": "MySQLGrammar@qb",
            "schema": "${DB_SCHEMA}",
            "migrationsTable": "cbmigrations",
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

> You don't have to use qb's `SchemaBuilder` to use `migrations`.
> Just run your own migrations using `queryExecute` and you can have complete control over your sql.

The `schema` represents the schema to install the migrations in.  This is a very important field,
especially for database setups hosting mutiple schemas. Without it, `commandbox-migrations` will
be unable to correct detect the migrations table.  It may tell you that the migration table is
already installed when it isn't because it detects it in a different schema.

The `connectionInfo` object is the information to create an on the fly datasource connection in CommandBox to run your migrations. This is the same struct you would use to add an application datasource in BoxLang.

The `migrationsDirectory` sets the default location for the migration scripts.  This setting is optional.

The `seedsDirectory` sets the default location for the seeder scripts.  This setting is optional.

> When using MySQL with the CFML version of CommandBox, two additional elements are required in the `connectionInfo` struct:
> `"bundleName":"com.mysql.cj"` and `"bundleVersion":"8.0.15"`.  These are not needed in BoxLang as the JDBC driver is managed by the module.

`commandbox-migrations` will create a datasource named `cbmigrations` from the information you specify.
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
    { datasource = "cbmigrations" }
)
```

`commandbox-migrations` will also set `cbmigrations` as the default datasource, so the following will work as well:

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

```bash
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

```bash
.env
!.env.example
```

## BoxLang Support

`commandbox-migrations` fully supports [BoxLang](https://boxlang.io) projects and can preferrably run on the BoxLang version of CommandBox. The module will auto-detect whether your project is BoxLang or CFML and adjust its behavior accordingly.

- Scaffolding: `migrate create` and `migrate seed create` generate `.bx` files
  instead of `.cfc` files when a BoxLang project is detected (or when `--boxlang` is passed).
- Config: `.cbmigrations.json` is used for all projects (BoxLang and CFML alike) as of v6.

Whether a project is treated as BoxLang is auto-detected by checking, in order:

1. Whether the running CommandBox server's engine is BoxLang.
2. Whether `box.json` has `"language": "boxlang"`.

You can skip auto-detection and force the behavior on any of `migrate init`,
`migrate create`, and `migrate seed create` with the `--boxlang` / `--no-boxlang` flags.

### BoxLang JDBC driver management (BoxLang Only)

BoxLang JDBC drivers are installed and loaded from the module-owned
`boxlang_modules/` directory. Database commands automatically install the driver
detected from the manager's `connectionInfo` when it is missing or you can force-install a specific driver with `migrate drivers install <driver>`. You can also remove drivers with `migrate drivers remove <driver>`.

Use the driver commands to inspect, repair, or remove the managed drivers:

```bash
# List installed BoxLang JDBC drivers
migrate drivers list

# List drivers as JSON
migrate drivers list --json

# Force-install the driver detected from the default manager
migrate drivers install

# Force-install a specific driver
migrate drivers install mysql
migrate drivers install bx-postgresql

# Force-install every supported driver
migrate drivers install --all

# Remove one driver, with confirmation
migrate drivers remove mysql

# Remove all managed drivers without confirmation
migrate drivers remove --force
```

When no driver name is supplied to `migrate drivers install`, the command uses
the selected manager's `connectionInfo`. Use `--manager=secondary` to select a
different manager. Supported driver names include MySQL, MariaDB, PostgreSQL,
Microsoft SQL Server, Oracle, SQLite, Derby, and HyperSQL.

## Usage

Every command below accepts an optional `manager` argument (defaulting to `default`)
to target a specific named manager from your config file. See the config examples
in the upgrade sections above for how to define multiple managers.

### `migrate init [--open] [--boxlang] [--no-boxlang]`

Creates the migration config file (`.cbmigrations.json`) if it doesn't already exist.
Pass `--boxlang`/`--no-boxlang` to control whether `.bx` or `.cfc` scaffolding is
generated by `migrate create` and `migrate seed create`.

Passing `--open` opens the config file once it's created.

### `migrate install [manager] [--verbose]`

Installs the migration table for the given manager in to your database.
This migration table keeps track of the ran migrations.

Passing the `--verbose` flag will show the resolved migrations config
as well as the full stack trace of any errors.

### `migrate status [manager] [--verbose] [--json]`

Displays the current migration status for the given manager — including
the configured directory, tracking table state, applied/pending counts,
the current database revision, and a table of all migration files with
their status.

When the database is unreachable, the command degrades gracefully and
shows the migration files present on disk with an unknown status.

Passing `--verbose` shows the resolved migrations configuration above the
status table.

Passing `--json` outputs the status as a JSON object for CI/CD scripting:

```json
{
  "manager": "default",
  "directory": "resources/database/migrations/",
  "dbAvailable": true,
  "tableInstalled": true,
  "applied": 1,
  "pending": 1,
  "total": 2,
  "currentRevision": "2022_11_01_192710_create_users_table",
  "migrations": [
    {
      "componentName": "2022_11_01_192710_create_users_table",
      "timestamp": "2022-11-01 19:27:10",
      "migrated": true,
      "canMigrateUp": false,
      "canMigrateDown": true
    }
  ]
}
```

### `migrate drivers list [--json]`

Lists the installed BoxLang JDBC drivers managed by `commandbox-migrations`.
Passing `--json` outputs the driver directory and driver slugs as JSON.

### `migrate drivers install [driver] [--all] [--manager=manager]`

Force-installs a BoxLang JDBC driver. Without a driver name, the driver is
detected from the selected migration manager's `connectionInfo`. Pass `--all`
to force-install every supported driver, or provide a driver name such as
`mysql` or `bx-postgresql`.

### `migrate drivers remove [driver] [--force]`

Removes one named BoxLang JDBC driver, or all managed drivers when no driver
name is provided. The command prompts for confirmation unless `--force` is
passed.

### `migrate create [name] [manager] [--open] [--boxlang] [--no-boxlang]`

Creates a migration file with an `up` and `down` method for the given manager.
The file name will be prepended with the current timestamp
in the format that `cfmigrations` expects. Creates a `.cfc` file by
default, or a `.bx` file for BoxLang projects (auto-detected, or
overridden with `--boxlang`/`--no-boxlang`).

Passing `--open` opens the migration file once it's created.

### `migrate up [manager] [--seed] [--once] [--verbose] [--pretend] [file]`

Runs all available migrations up for the given manager. Passing the `--once`
flag will only run a single migration up (if any are available).

Passing the `--seed` flag will run all seeders for the manager after the
migrations are applied (equivalent to running `migrate seed run` afterward).

Passing the `--verbose` flag with show the datasource information passed
as well as the full stack trace of any errors.

Passing the `--pretend` flag will not actually run the migrations but
instead print out the SQL that would have been run to the console.

Passing a `file` is used in conjunction with the `--pretend` flag.
If provided, the outputted sql will be saved to the file path provided.

> **WARNING: `--pretend` only captures SQL from `schema` (SchemaBuilder) and `qb` (QueryBuilder) calls.**
> Migrations that use `queryExecute()` directly are **not intercepted** — those queries **will execute against your database** even when `--pretend` is passed. If your migrations use raw `queryExecute()` calls, do not rely on `--pretend` to prevent changes.

### `migrate down [manager] [--once] [--verbose] [--pretend] [file]`

Runs all available migrations down for the given manager. Passing the
`--once` flag will only run a single migration down (if any are available).

Passing the `--verbose` flag with show the datasource information passed
as well as the full stack trace of any errors.

Passing the `--pretend` flag will not actually run the migrations but
instead print out the SQL that would have been run to the console.

Passing a `file` is used in conjunction with the `--pretend` flag.
If provided, the outputted sql will be saved to the file path provided.

> **WARNING: `--pretend` only captures SQL from `schema` (SchemaBuilder) and `qb` (QueryBuilder) calls.**
> Migrations that use `queryExecute()` directly are **not intercepted** — those queries **will execute against your database** even when `--pretend` is passed. If your migrations use raw `queryExecute()` calls, do not rely on `--pretend` to prevent changes.

### `migrate refresh [manager] [--seed] [--verbose]`

Runs all available migrations down and then runs all migrations up for the
given manager (delegates to `migrate down` and `migrate up`, forwarding
`manager`, `--seed`, and `--verbose`).

### `migrate reset [manager] [--verbose]`

Clears out all objects from the database, including the `cbmigrations` table,
for the given manager. Use this when your database is in an inconsistent
state in development.

Passing the `--verbose` flag will show the resolved migrations config
as well as the full stack trace of any errors.

### `migrate fresh [manager] [--seed] [--verbose]`

Runs `migrate reset`, `migrate install`, and `migrate up` (forwarding
`manager`, `--seed`, and `--verbose`) to give you a fresh copy of your
migrated database.

### `migrate uninstall [manager] [--verbose] [--force]`

Removes the `cbmigrations` table for the given manager after running down
any ran migrations. Prompts for confirmation before uninstalling unless
`--force` is passed.

Passing the `--verbose` flag will show the resolved migrations config
as well as the full stack trace of any errors.

### `migrate seed create [name] [manager] [--open] [--boxlang] [--no-boxlang]`

Creates a new Seeder file for the given manager. Creates a `.cfc` file by
default, or a `.bx` file for BoxLang projects (auto-detected, or
overridden with `--boxlang`/`--no-boxlang`).

Passing `--open` opens the seeder file once it's created.

### `migrate seed run [name] [manager] [--verbose]`

Runs one or all Seeders for the given manager. Pass `name` to only run a
single named seeder; omit it to run all seeders.

Passing the `--verbose` flag will show the resolved migrations config
as well as the full stack trace of any errors.
