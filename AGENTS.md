# Project Guidelines

## Code Style

This is a **CommandBox module** written in CFML (`.cfc`) with BoxLang (`.bx`) templates for scaffolding. Follow the **Ortus Coding Standards** skill (`ortus-coding-standards`) for all formatting — the key rules are:

- **Tabs** for indentation, never spaces.
- **K&R brace style** — opening brace on the same line as the statement.
- **Always use braces** — even for single-statement `if`/`for`/`while`.
- **Spaces inside parentheses** — `function process( name, count )` not `function process(name, count)`.
- **No space between function name and `(`** — `doThing( name )` not `doThing ( name )`.
- **One space around operators** — `var total = price * quantity`.
- **Align related assignments** in column groups.
- **Always use braces** — even for single-statement bodies, never inline bodies on the same line as the condition.

Semicolons are **optional** in CFML/BoxLang — match the surrounding file's convention (most files omit them).

Arrow functions use the fat-arrow syntax: `( migration ) => { ... }`

CFML code is formatted via **CFFormat** (`.cfformat.json`). After editing `.cfc` files, run:
```
box run-script format
```

BoxLang templates (`.bx`) are linted via `.bxlint.json`.

## Architecture

This is a **CommandBox CLI module** that wraps [cfmigrations](https://github.com/coldbox-modules/cfmigrations) to provide `migrate` commands. Key structure:

- `commands/migrate/` — CommandBox commands (each `.cfc` has a `run()` method). Nested folders are sub-commands (e.g., `seed/run.cfc` → `migrate seed run`).
- `models/BaseMigrationCommand.cfc` — Shared base class all commands extend. Contains `setup()`, `getMigrationsInfo()`, `isBoxLangProject()`, config resolution, and datasource registration.
- `ModuleConfig.cfc` — WireBox module lifecycle; registers `SqlHighlighter` singleton.
- `templates/` — Scaffolding templates for new migrations/seeds. `.txt` = CFML templates, `BX.txt` suffix = BoxLang templates.
- `lib/sql.nanorc` — jLine syntax highlighting rules for SQL output in CLI.

**Dependency Injection**: WireBox via `property name="x" inject="Y"` annotations. Key services: `FileSystem`, `PackageService`, `JSONService`, `SystemSettings`, `ServerService`, `Formatter@sqlFormatter`, `SqlHighlighter`.

**Config resolution order**: `.cbmigrations.json` → legacy `.cfmigrations.json` → legacy `box.json` `cfmigrations` key (deprecated, auto-converted). Environment variables are expanded via `systemSettings.expandDeepSystemSettings()`.

**Dual-language support**: Auto-detects BoxLang via running server engine or `box.json` `language` key. When generating scaffolding, select the correct template pair (`Migration.txt` vs `MigrationBX.txt`).

## Build and Test

```bash
# Format CFML files
box run-script format

# No test suite exists — this project relies on manual/CLI testing.
```

The only automated script is `format` (CFFormat). Release flow: format → publish to ForgeBox → git push with tags.

## Conventions

### Copyright Header
Every `.cfc` and `.bx` file starts with:
```
/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 */
```

### Command Structure
All commands follow this pattern:
1. `extends="commandbox-migrations.models.BaseMigrationCommand"`
2. JavaDoc-style `/** */` parameter annotations with `@paramName.optionsUDF completeXxx` for tab-completion wiring
3. `run()` method calls `setup( arguments.manager )` first
4. Optional verbose diagnostics block
5. `pagePoolClear()` before migration execution
6. `try`/`catch` with SQL formatting and highlighting in error output
7. Pre/post process hooks via lambdas for migration logging and SQL capture
8. `pretend` mode captures SQL without executing

### Error Handling Pattern
```js
catch ( any e ) {
    if ( arguments.verbose ) {
        if ( structKeyExists( e, "Sql" ) ) {
            print.whiteOnRedLine( "Error when trying to ..." );
            print.line( variables.sqlHighlighter.highlight( variables.sqlFormatter.format( e.Sql ) ).toAnsi() );
        }
        rethrow;
    }
    return error( e.message, e.detail );
}
```

### Naming

| Item | Convention | Example |
|------|-----------|---------|
| Command CFCs | Lowercase verb | `up.cfc`, `down.cfc`, `fresh.cfc` |
| Models | PascalCase | `BaseMigrationCommand.cfc` |
| Templates | PascalCase, `BX` suffix | `Migration.txt` / `MigrationBX.txt` |
| Config files | Dot-prefixed JSON | `.cbmigrations.json`, legacy `.cfmigrations.json` |