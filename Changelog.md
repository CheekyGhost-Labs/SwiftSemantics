# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.2] - 2023-04-10

### Changed

- Fixed bug where inout closure arguments were not being parsed
- Fixed bug where inout tuple arguments were not being parsed
- Fixed bug where inout tuple inputs were not being parsed
- Fixed type attributes stripping issue where all attributes were being stripped (een from closure type declaration)

## [3.0.1] - 2023-04-10

### Changed

- Fixed bug where closure and tuple function signature inputs were not being parsed correctly

## [3.0.0] - 2023-04-08

### Changed

- Adopting SwiftSyntax 5.8 (Xcode 14.3 + Swift 5.8 support) 
- Removed unsupported syntax visitor types
- Updated inits and references to use .fixedUp viewMode (as suggested for source code assessment tasks)
- Breaking change - this uses the new version of SwiftSyntax written in swift and no longer has dependencies on libraries in the Swift toolchain

## [2.2.0] - 2023-04-04

### Changed

- Added primary associated type support to Protocol declarations


## [2.1.1] - 2023-01-08

### Changed

- Ensured `Result<...>` types are parsed within closure types


## [2.1.0] - 2023-01-08

### Changed

- Added `startLocation` and `endLocation` support to `Declaration` types
- Added unit tests
- Added convenience methods for extracting source range and substrings

## [2.0.0] - 2022-12-14

### Changed

- Adds `ClosureDeclaration` and `ClosureParameter`
- Adds `TupleDeclaration` and `TupleParameter`
- Added optional `closureType` and `tupleType` to `Variable` and `Typealias` types
- Added `ParameterType` protocol which all parameters conform to
- Existing parameters now declared as `any ParameterType`
- Supported parameter types are `StandardParameter`, `ClosureParameter`, and `TupleParameter`
- Added full test coverage for changes
- Updated swift-syntax dependencies to `0.50700.1`

## [1.0.3] - 2022-10-19

### Changed

- Fixed bug where `Function.Paramater.typeWithAttributes` was not stripping `inout`

## [1.0.2] - 2022-08-21

### Changed

- Fixed bug where `Function.Paramater.typeWithAttributes` would only remove escaping attribute

## [1.0.1] - 2022-08-13

### Changed

- Fixed incorrect ordering of Subscript generic requirements in `description`

## [1.0.0] - 2022-08-13

### Changed

- Added dedicated `Parent` type to whole parent name, keyword, modifiers, and attributes

## [0.4.0] - 2022-07-26

### Changed

- Added closure utility getters to Variable, Function.Parameter, and TypeAlias.

## [0.3.2] - 2021-05-13

### Changed

- Changed swift-syntax dependency to target `release/5.5` branch
  to resolve an issue on Windows.
  #17 by @compnerd.

## [0.3.1] - 2021-05-04

### Changed

- Changed swift-syntax dependency to target `release/5.4` branch
  instead of `0.50400.0` tag to resolve an issue on Windows.
  #16 by @compnerd.

## [0.3.0] - 2021-04-23

### Added

- Added support for Swift 5.4 and 5.5.
  #12 by @compnerd and @mattt.

## [0.2.0] - 2020-11-11

### Added

- Added support for Swift 5.3.
  #10 by @mattt.

## [0.1.0] - 2020-03-28

### Changed

- Changed swift-syntax dependency to support Swift 5.2.
  4fdc48b by @mattt.

## [0.0.2] - 2020-02-14

### Added

- Added documentation for public APIs.
  1165c7a by @mattt.

### Changed

- Changed `ExpressibleBySyntax` requirement to be optional initializer.
  f0f84ab by @mattt.
- Changed `AssociatedType` to conform to `CustomStringConvertible`.
  0495879 by @mattt.
- Changed `Typealias` to conform to `CustomStringConvertible`.
  ba52df3 by @mattt.

## [0.0.1] - 2020-01-21

Initial release.

[unreleased]: https://github.com/SwiftDocOrg/SwiftSemantics/compare/0.3.2...main
[0.3.2]: https://github.com/SwiftDocOrg/SwiftSemantics/releases/tag/0.3.2
[0.3.1]: https://github.com/SwiftDocOrg/SwiftSemantics/releases/tag/0.3.1
[0.3.0]: https://github.com/SwiftDocOrg/SwiftSemantics/releases/tag/0.3.0
[0.2.0]: https://github.com/SwiftDocOrg/SwiftSemantics/releases/tag/0.2.0
[0.1.0]: https://github.com/SwiftDocOrg/SwiftSemantics/releases/tag/0.1.0
[0.0.2]: https://github.com/SwiftDocOrg/SwiftSemantics/releases/tag/0.0.2
[0.0.1]: https://github.com/SwiftDocOrg/SwiftSemantics/releases/tag/0.0.1
