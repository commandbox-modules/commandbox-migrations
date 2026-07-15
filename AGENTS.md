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

## Skills

Project-specific agent skills are located in `.agents/skills/`. Each skill has a `SKILL.md` file with detailed instructions. When working on a task that matches a skill's domain, read the skill file first.

### BoxLang Language

| Skill | Description |
|-------|-------------|
| `boxlang-application-descriptor` | Application.bx behavior: app discovery, lifecycle events, sessions, mappings, schedulers/watchers |
| `boxlang-async-programming` | BoxFuture, asyncRun, asyncAll, executors, schedulers, thread components, parallel pipelines |
| `boxlang-best-practices` | Community best practices for naming, structure, scoping, error handling, performance |
| `boxlang-cfml-migration` | Migrating from CFML (Adobe/Lucee) to BoxLang: syntax differences, bx-compat-cfml, common issues |
| `boxlang-classes-and-oop` | Classes, components, interfaces, inheritance, annotations, properties, constructors, OOP patterns |
| `boxlang-code-documenter` | Javadoc-style comments, argument/return documentation, DocBox-compatible API reference generation |
| `boxlang-code-reviewer` | Code review for quality, correctness, security, performance, and style |
| `boxlang-configuration` | boxlang.json settings, env var overrides, datasources, caches, executors, modules, logging |
| `boxlang-database-access` | queryExecute, bx:query, datasource config, parameterized queries, transactions, SQL injection prevention |
| `boxlang-docbox` | DocBox API documentation generation: install, CLI, config, output strategies, themes |
| `boxlang-file-handling` | fileRead, fileWrite, fileCopy, fileMove, directoryList, fileUpload, streaming, CSV/JSON processing |
| `boxlang-file-watchers` | Filesystem watchers: watcherNew/Start/Stop, event payloads, debounce/throttle, error thresholds |
| `boxlang-functional-programming` | Lambdas, closures, arrow functions, array/struct pipelines (map, filter, reduce), destructuring, spread |
| `boxlang-interceptors` | Interceptor/event system: registration, announcement points, pre/post hooks, BoxRegisterInterceptor |
| `boxlang-java-integration` | createObject, static methods, type conversion, importing classes, closures as functional interfaces, JARs |
| `boxlang-language-fundamentals` | Syntax, file types, variables, scopes, operators, control flow, exception handling, type system |
| `boxlang-modules-and-packages` | box install, module settings, BoxLang+ premium modules (bx-pdf, bx-redis, bx-csv), ORM, mail |
| `boxlang-runtime-cli-scripting` | CLI scripts, command-line arguments, REPL, action commands (compile, cftranspile), CLI-specific BIFs |
| `boxlang-runtime-commandbox` | Deploying via CommandBox: server.json, modules, SSL, rewrites, BoxLang+/++ subscriptions |
| `boxlang-scheduled-tasks` | Scheduler DSL, BaseScheduler/ScheduledTask APIs, cron expressions, lifecycle callbacks, bx:schedule |
| `boxlang-security` | Security review, OWASP Top 10, injection prevention, file upload safety, secrets management |
| `boxlang-templating` | .bxm templates, bx:output, bx:loop, bx:if, bx:include, bx:script, building views |
| `boxlang-testing` | TestBox: BDD specs, xUnit classes, expectations, MockBox, mockData, async testing, CLI runner |
| `boxlang-web-development` | Web apps: request/response, sessions, forms, REST APIs, HTTP clients, routing, CSRF, SSE |
| `boxlang-zip` | bx:zip component: compress, extract, filter entries, read archives, download as ZIP |

### CommandBox CLI

| Skill | Description |
|-------|-------------|
| `commandbox-config-settings` | Global config: set/show/clear, server defaults, ForgeBox tokens, endpoints, proxy, env overrides |
| `commandbox-deploying` | Production deployment: Docker, GitHub Actions, Heroku, Lightsail, OS service, server.json, CFConfig |
| `commandbox-developing` | Custom commands, modules, namespaces, tab completion, WireBox DI, interceptors, lifecycle events |
| `commandbox-embedded-server` | Server management: start/stop, server.json, JVM args, SSL/TLS, rewrites, rules, profiles, auth, gzip |
| `commandbox-package-management` | box.json, installing from ForgeBox/Git/HTTP, semver, dependencies, lock files, publishing |
| `commandbox-setup` | Installing/upgrading CommandBox: Homebrew, apt-get, Windows, Java requirements, first-run config |
| `commandbox-task-runners` | Task CFCs, targets, lifecycle events, interactive jobs, progress bars, async, file watching |
| `commandbox-testing` | testbox run command, runner URL, output formats, test watcher, CI integration, code coverage |
| `commandbox-usage` | CLI usage: commands, namespaces, tab completion, system settings, env vars, piping, recipes, REPL |

### TestBox Testing

| Skill | Description |
|-------|-------------|
| `testbox-assertions` | $assert object: isTrue, isEqual, includes, throws, between, closeTo, typeOf, custom assertions |
| `testbox-bdd` | BDD describe/it blocks, Gherkin-style suites, lifecycle hooks, focused/skipped specs, asyncAll |
| `testbox-cbmockdata` | Fake data generation: age, email, name, uuid, autoincrement, nested objects, custom suppliers |
| `testbox-expectations` | Fluent expect() matchers: toBe, toBeTrue, toHaveKey, toThrow, notToBe, chaining, custom matchers |
| `testbox-listeners` | Run listeners: onBundleStart/End, onSuiteStart/End, onSpecStart/End, progress, dashboards |
| `testbox-mockbox` | Mocks/stubs/spies: createMock, prepareMock, $args/$results/$throws, $callLog, $property, querySim |
| `testbox-reporters` | Reporters: ANTJunit, Console, Doc, JSON, JUnit, Min, Simple, XML, Streaming, custom IReporter |
| `testbox-runners` | Running tests: CLI, BoxLang CLI runner, HTML web runner, programmatic, streaming, watcher mode |
| `testbox-unit-xunit` | xUnit-style: testXxx() functions, setup/teardown lifecycle, $assert, Arrange-Act-Assert pattern |
| `testing-coverage` | Code coverage: setup, reporting, CI integration, TestBox options, interpreting metrics |
| `testing-fixtures` | Test fixtures, factory patterns, test data builders, cbMockData, fixture management |

### Other

| Skill | Description |
|-------|-------------|
| `ortus-coding-standards` | Official Ortus coding standards: indentation, spacing, braces, naming, alignment, comments |
| `github-action-authoring` | Composite GitHub Actions: multi-platform, PATH issues, inputs/outputs, PowerShell, CI testing |
| `java-expert` | Java services/libraries: API design, concurrency, performance, dependency management, production |
| `junit-expert` | JUnit 5 tests: lifecycle, parameterized tests, extensions, assertions, parallel execution, suites |
