# GUIDEx
This module provides functionality for three primary applications:
- Windows Installer / Squished GUID conversion
- UUIDv5 and v3 generation
- Windows Terminal fragment and profile GUID generation

[Module Help](Docs/GUIDEx.md)

## Functions

### Get-UUIDFromNamespace
> Generates UUIDv3 and v5 given a namespace and name.

[Function Help](Docs/Get-UUIDFromNamespace.md)

Refer to [Terminal GUID Examples](#standard-terminal-guid-example) for more information.

### Convert-UUIDSquished
> Converts between MSI GUIDs (ProductCode) and the "squished" format.

[Function Help](Docs/Convert-UUIDSquished.md)

The function is idempotent, so it can be used in either direction.
The original solution was to the problem of properly converting MSI ProductCodes for lookup in:
`HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products`

### New-WindowsTerminalUUID
> Generates Windows Terminal profile and fragment GUIDs given a profile name and optional parent namespace.

[Function Help](Docs/New-WindowsTerminalUUID.md)

This is a shorter way of using `Get-UUIDFromNamespace` for Windows Terminal as it provides the expected encoding and namespaces.

---

## Technical Notes

**NOTE**: `guid.ToString(format)` returns a string representation as defined in the [`Guid.ToString()` documentation][GuidToString]
**NOTE**: `guid.ParseExact(input, format)` returns a GUID, with `format` indicating what to expect from `input`. See [`Guid.ParseExact()` documentation][GuidParseExact]

### Example for Installer keys
1. `{906F89D8-00DA-3583-8057-A7425FB9FDD4}` becomes...
2. `8D98F609AD00385308757A24F59BDF4D` when used with the 'N' format specifier, which can be looked up as a subkey in...
3. `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products`

### Examples for GUID Swapping
> Swapped GUID order (little-endian) to full array order (big-endian)

| Type     | UUID                                                                                            |
| -------- | ----------------------------------------------------------------------------------------------- |
| Original | `0 1 2 3 4 5 6 7 - 8 9 10 11 - 12 13 14 15 - 16 17 18 19 - 20 21 22 23 24 25 26 27 28 29 30 31` |
| Swapped  | `7 6 5 4 3 2 1 0 - 11 10 9 8 - 15 14 13 12 - 17 16 19 18 - 21 20 23 22 25 24 27 26 29 28 31 30` |

#### Tables

##### Swapping
| Type     | GUID                                   |
| -------- | -------------------------------------- |
| Original | {D012DCD1-67EA-4627-938F-19FD677FC03A} |
| Swapped  | {1DCD210D-AE76-7264-39F8-91DF76F70CA3} |

##### Order
| Type          | Section 1 | Section 2 | Section 3 | Section 4 |    Section 5 |
|:--------------|----------:|----------:|----------:|----------:|-------------:|
| Original (LE) |  01234567 |      0123 |      0123 |      0123 | 0123456789AB |
| Swapped (BE)  |  67543210 |      3210 |      3210 |      1032 | 1032547698BA |

##### Sections
| Type      | Section 1    | Section 2 | Section 3 | Section 4                                 |
|-----------|--------------|-----------|-----------|-------------------------------------------|
| Original  | `0x906f89d8` | `0x00da`  | `0x3583`  | `0x80,0x57,0xa7,0x42,0x5f,0xb9,0xfd,0xd4` |
| Converted | `0x8d98f609` | `0xad00`  | `0x3853`  | `0x08,0x75,0x7a,0x24,0xf5,0x9b,0xdf,0x4d` |

### Examples for Namespace Creation

#### Terminal custom profile namespace GUID
> `[GUID]::new(<byte[]>, <bool>)` creation in PS Core, with the second param indicating Big Endianness

| Type                         | UUID                                                        |
|------------------------------|-------------------------------------------------------------|
| Terminal custom profile UUID | `{F6 5D DB 7E - 70 6B - 44 99 - 8A 50 - 40 31 3C AF 51 0A}` |
| Guid Big-endian UUID         | `{7E DB 5D F6 - 6B 70 - 99 44 - 8A 50 - 40 31 3C AF 51 0A}` |
| Order (LE)                   | `{01 23 45 67 - 89 AB - CD EF - A0 A1 - A2 A3 A4 A5 A6 A7}` |
| Order (BE)                   | `{67 45 23 01 - AB 89 - EF CD - A0 A1 - A2 A3 A4 A5 A6 A7}` |

#### Standard Terminal GUID Example
[JSON Fragment Extensions][WindowsTerminalFragments]
> Encoding should be BOM-less UTF-16LE

##### PowerShell version of the Python example to convert UTF16-LE strings
```powershell
$UTF16Encoding = [System.Text.UnicodeEncoding]::new($false, $false)
# alternately: $UTF16Encoding = [System.Text.Encoding]::GetEncoding('UTF-16')
$UTF16Bytes = $UTF16Encoding.GetBytes('Ubuntu')
$AsciiString = [System.Text.Encoding]::ASCII.GetString($UTF16Bytes)
# Should output 'Ubuntu' as bytes 85 00 98 00 117 00 110 00 116 00 117 00
```

##### Generated Profile Fragments
1. Fragment Namespace: `{f65ddb7e-706b-4499-8a50-40313caf510a}`
2. App Namespace: Fragment NS + 'Git'
3. Profile GUID: App NS + 'Git Bash' = `{2ece5bfe-50ed-5f3a-ab87-5cd4baafed2b}`

##### Generated for official Terminal profiles
1. Internal Namespace: `{2bde4a90-d05f-401c-9492-e40884ead1d8}`
2. Profile Namespace + "Ubuntu" = `{2c4de342-38b7-51cf-b940-2309a097f518}`

### .NET Guid Formats
> Format used in (e.g.) `[guid]::ParseExact(<string> input, <string> format)` and `$Guid.ToString(<string> format)`

**Format specifiers as defined in [.NET GUID Method Documentation](#net-guid-method-documentation)**
| Specifier | Example                                                                | Description                              |
|-----------|:-----------------------------------------------------------------------|------------------------------------------|
| **N**     | `012345670123012301230123456789AB`                                     | 32 hexadecimal digits                    |
| **D**     | `01234567-0123-0123-0123-0123456789AB`                                 | 32 hex digits w/ hyphens                 |
| **B**     | `{01234567-0123-0123-0123-0123456789AB}`                               | 32 hex digits w/ hyphens and braces      |
| **P**     | `(01234567-0123-0123-0123-0123456789AB)`                               | 32 hex digits w/ hyphens and parentheses |
| **X**     | `{0x01234567,0x0123,0x0123,{0x01,0x23,0x45,0x67,0x89,0xAB,0xCD,0xEF}}` | Four hex values w/ braces and subset     |

## .NET GUID Method Documentation
- [`Guid.ParseExact()`][GuidParseExact]
- [`Guid.ToString()`][GuidToString]

<!-- References -->

[GuidToString]: https://learn.microsoft.com/en-us/dotnet/api/system.guid.tostring?view=netframework-4.8.1#system-guid-tostring(system-string)
[GuidParseExact]: https://learn.microsoft.com/en-us/dotnet/api/system.guid.parseexact?view=netframework-4.8.1#system-guid-parseexact(system-string-system-string)
[WindowsTerminalFragments]: https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions#profile-guids
