# CFMigrations Commands

## Run your cfmigrations from CommandBox

You need to set up some information in your `box.json`:

```json
"cfmigrations": {
    "defaultGrammar": "BaseGrammar",
    "connectionInfo": {
        "class": "${DB_CLASS}",
        "connectionString": "${DB_CONNECTIONSTRING}",
        "username": "${DB_USER}",
        "password": "${DB_PASSWORD}"
    }
}
```

There are two main sections.  The `defaultGrammar` sets the correct Database Grammar for `qb` to use to build your schema.  Available grammar options can be found in the [qb documentation](https://elpete.gitbooks.io/qb/content/).

> You don't have to use qb's `SchemaBuilder` to use `cfmigrations`.  Just run your own migrations using `queryExecute` and you can have complete control over your sql.

The `connectionInfo` object is the information to create an on the fly connection in CommandBox to run your migrations. This is the same struct you would use to add an application datasource in Lucee. (Note: it must be Lucee compatible since that is what CommandBox runs on under-the-hood.)

You may notice that the values are surrounded in an escape sequence (`${}`).  This is how CommandBox injects environment variables into your `box.json` file.  Why environment variables?  Because you don't want to commit your database credentials in to source control.  Also, you want to be able to have different values in different environments.  Whether you have dedicated servers or are running your application in containers, you can find the supported way to add environment variables to your platform.

For local development using CommandBox, I recommend using the package [`commandbox-dotenv`](https://forgebox.io/view/commandbox-dotenv).  This package lets you define environment variables in a `.env` file in the root of your project.  CommandBox will add these to your server when starting it up and also to the CommandBox instance if you load or reload the shell in a directory with a `.env` file.  That is how we will get our environment variables available for `cfmigrations-commands`.

With `commandbox-dotenv` installed, create a `.env` file in the root of you project.  At the very least, it will look like this:

```
DB_CLASS=org.gjt.mm.mysql.Driver
DB_CONNECTIONSTRING=jdbc:mysql://localhost:3306/test_db?useUnicode=true&characterEncoding=UTF-8&useLegacyDatetimeCode=true
DB_USER=test
DB_PASSWORD=pass1234
```

I recommend adding this file to your `.gitignore`

```
.env
```

An added step to help new users get up to speed with the needed environment variables for your project is to add an `.env.example` file to the root of your project as well.  This file would have all the keys needed, but no values filled out.  Like so:

```
DB_CLASS=
DB_CONNECTIONSTRING=
DB_USER=
DB_PASSWORD=
```

You would update your `.gitignore` file to not ignore the `.env.example` file:

```
.env
!.env.example
```



