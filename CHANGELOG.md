# # Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.7.2] - 2025-10-27

### Added
- `New-WindowsTerminalUUID` function to generate official and fragment profile GUIDs.
- Aliases `New-WindowsTerminalGUID` and `terminalguid`

### Changed
- `Convert-UUIDSquished` used on its own returns a GUID, while using `-Format` will output a string.

## [2.6.2] - 2025-09-15

### Changed
- Renamed `New-UUIDNamespace` to `Get-UUIDFromNamespace`
- Changed associated aliases: `Get-GUIDFromNamespace`, `gufn`

### Removed
- Moved `Switch-ByteNibble` to Conversion module

## [1.6.2] - 2025-09-12

### Removed

- Convert-UUID and Convert-UUIDBytes. They weren't really doing anything useful, especially now that
  v5 and Squished GUIDs can be created / converted.

## [0.6.2] - 2025-09-11

### Fixed

- I stupidly left out pipeline support from `convertUTF16Bytes` and yet was trying to pipe `$Name`
  into it, receiving nothing out. That's now fixed, and it's generating Windows Terminal GUIDs
  properly.

## [0.6.1] - 2025-09-05

### Added

- Added `-Encoding` option to `New-UUIDNamespace`
- Added UTF-16LE conversion to `New-UUIDNamespace` per the [Windows Terminal documentation][TerminalProfileGuids]
- Moved more comments to `TODO.md`

### Changed

- Renamed `Convert-UUIDOrder` to `Convert-UUIDSquished`, adding the old name as an alias
- Renamed `Convert-BinaryLSB` to `Switch-ByteNibble` as that's what it's doing
- Unified Pester test files

## [0.5.1] - 2025-02-14

### Added

- Added `Convert-UUID`, `New-UUID`, `New-UUIDNamespace`, as well as aliases.

### Changed

- Renamed functions to use UUID, but kept the old names as aliases.

## [0.4.1] - 2025-02-13

### Added

- Initial release.

<!-- Link references -->
[TerminalProfileGuids]: https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions#profile-guids
