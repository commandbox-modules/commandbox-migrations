# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [6.0.0] - 2026-07-22

### Added

- Added `migrate drivers list` to show installed BoxLang JDBC drivers.
- Added `migrate drivers install` to force-install the configured driver, with support for a named driver and `--all`.
- Added `migrate drivers remove` to remove all managed drivers or a single named driver.

### Fixed

- parser fix due to nested rethrow on BoxLang
- Fixed BoxLang JDBC drivers not being loaded after installation for commands such as `migrate refresh` and `migrate fresh` by loading them from the installation directory.

## [5.4.0] - 2026-07-15

### Added

- Added BoxLang support, including `.bx` migration and seeder scaffolding.
- Added the `migrate status` command with migration configuration, tracking-table, applied/pending migration, current revision, and seeder summaries.
- Added JSON output for `migrate status` for CI/CD and other automation workflows.
- Added graceful status reporting when the database is unavailable; filesystem migration and seeder information is still displayed.
- Added automatic discovery, installation, and loading of the matching `bx-*` JDBC driver module for BoxLang projects when driver installation is enabled.
- Added dedicated help commands and expanded command and argument documentation.

### Changed

- Preferred the `.cbmigrations.json` configuration filename and the `cbmigrations` datasource/migration-table naming for new projects.
- Added BoxLang-aware configuration and project detection while retaining support for legacy `.cfmigrations.json` and `box.json` configuration.
- Updated the generated configuration template to use explicit database driver, host, port, and database connection settings.
- Updated the cfmigrations and qb dependencies to current compatible versions.

### Fixed

- Corrected migration timestamp formatting to use the Java month pattern `MM`.
- Improved migration and seeder status handling for pending files, applied records, and seeders.
- Fixed BoxLang Prime compatibility issues in command execution and test coverage.
- Fixed generated configuration keys and connection metadata for current migration and BoxLang setups.

## [5.0.4] - 2026-07-15

### Changed

- This tag points to the same release commit as `5.4.0`; see the `5.4.0` notes above for the included changes.

## [5.2.2] - 2025-03-20

### Fixed

- Added the database value to the generated connection information in the `migrate init` configuration template.

## [5.2.1] - 2023-06-23

### Changed

- Updated the package version following the `5.2.0` release.

## [5.2.0] - 2023-06-23

### Added

- Documented the `pretend` and `file` options for generating migration SQL without applying it.

## [5.1.0] - 2023-06-20

### Added

- Added `--pretend` support to migration `up` and `down` commands to preview generated SQL.
- Added `--file` support to write generated migration SQL to a file.

### Changed

- Removed the requirement for bundle information from the migration configuration.

## [5.0.3] - 2023-05-19

### Fixed

- Simplified command configuration lookups by using migration metadata inline across migration and seeder commands.

## [5.0.2] - 2023-05-19

### Fixed

- Fixed seed execution when migration paths contain Windows-style path separators.

## [5.0.1] - 2023-05-19

### Fixed

- Fixed migration path resolution for projects using the shared migration command base class.
- Removed leftover path-resolution debugging output.

## [5.0.0] - 2023-05-12

### Changed

- Upgraded the cfmigrations and qb dependencies to their latest compatible versions.

[Unreleased]: https://github.com/commandbox-modules/commandbox-migrations/compare/v5.4.0...HEAD
[5.4.0]: https://github.com/commandbox-modules/commandbox-migrations/compare/v5.2.2...v5.4.0
[5.0.4]: https://github.com/commandbox-modules/commandbox-migrations/releases/tag/v5.0.4
[5.2.2]: https://github.com/commandbox-modules/commandbox-migrations/compare/v5.2.1...v5.2.2
[5.2.1]: https://github.com/commandbox-modules/commandbox-migrations/compare/v5.2.0...v5.2.1
[5.2.0]: https://github.com/commandbox-modules/commandbox-migrations/compare/v5.1.0...v5.2.0
[5.1.0]: https://github.com/commandbox-modules/commandbox-migrations/compare/v5.0.3...v5.1.0
[5.0.3]: https://github.com/commandbox-modules/commandbox-migrations/compare/v5.0.2...v5.0.3
[5.0.2]: https://github.com/commandbox-modules/commandbox-migrations/compare/v5.0.1...v5.0.2
[5.0.1]: https://github.com/commandbox-modules/commandbox-migrations/compare/v5.0.0...v5.0.1
[5.0.0]: https://github.com/commandbox-modules/commandbox-migrations/releases/tag/v5.0.0
