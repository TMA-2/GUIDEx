# TODO

## General

### High Priority
- [x] Write/verify function help
- [ ] Fix *serious* issues with `Convert-UUIDFromNamespace` on Windows PowerShell
- [ ] Generate markdown and MAML help
- [ ] Compare `Convert-UUID` and `Convert-UUIDBytes`. Clean one or the other.
- [ ] Consolidate functions. There should be approximately three:
  - [x] `New-UUIDNamespace` to create UUID v3/v5 namespaces
  - [x] `Convert-UUIDSquished` for MSI GUIDs specifically
  - [ ] `Convert-UUID` to flip between LE/BE byte order
    - [ ] Decide on a damn method and STICK WITH IT
- [ ] Fix Pester tests once functions are sorted

### Medium Priority
- [x] Add Conversion as a required module for general binary functions
  - [ ] Move/combine `Format-Binary` to Conversion, or embed it in the function that uses it
  - [x] Move `Switch-ByteNibble` to Conversion
  - [x] Move any related tests to Conversion

### Low Priority
- [ ] Get `[GuidEx]` class working. Use instead of `[guid]`.
- [ ] Remove `Private\Test-GUID.ps1`

## Public Functions

### New-WindowsTerminalUUID
[New-WindowsTerminalUUID.ps1](Public/New-WindowsTerminalUUID.ps1)
- [x] Finish building out function (simple)
- [ ] Add Pester tests using [Windows Terminal examples](https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions#generating-a-new-profile-guid)

### Get-UUIDFromNamespace
[Get-UUIDFromNamespace.ps1](Public/Get-UUIDFromNamespace.ps1)
- [ ] Fix issues generating v3 UUIDs
  - `Get-UUIDFromNamespace '6ba7b810-9dad-11d1-80b4-00c04fd430c8' -Name 'example.com' -Version 3` should output "907e1018-10ac-35d1-b62e-561c32033af0"
- [ ] Fix issues running in Windows PowerShell
  - [ ] L128: Cannot convert argument "buffer", with value: "System.Object[]", for "ComputeHash" to type
"System.Byte[]"
  - [ ] L131-132: Cannot index into a null array.
  - [ ] L142: Exception calling ".ctor" with "1" argument(s): "Value cannot be null. Parameter name: b"
- [ ] Test performance of `Convert-UUIDOrder` vs. method used in [MSI "SquishedGuid" Conversion](https://github.com/heaths/psmsi/blob/develop/tools/ConvertFrom-SquishedGuid.ps1)

### Convert-UUIDSquished
[Convert-UUIDSquished.ps1](Public/Convert-UUIDSquished.ps1)
- [x] Add comment-based help
- [x] Rename `Convert-UUIDOrder` to `Convert-UUIDSquished`
- [ ] Add option to format the output normally ("B") or for use with the registry ("N") at `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products`

## Deprecated Functions

### Convert-UUID
- [ ] Consider just removing this albatross
- [ ] Test performance vs. `Convert-UUIDBytes` and keep one
- [ ] `-RespectBitOrder` alone returns the same GUID
- [ ] Fix `-Reverse` parameter which makes bytes 1-3, 7 blank
- [ ] Fix: Line 104 = "Value cannot be null. (Parameter 'd')" when using -Reverse -RespectBitOrder
- [ ] Implement Pester tests
- [ ] Creating a guid from `byte[]` with manually swapped order un-swaps it...
- [ ] Verify `[ref]` works as expected
- [ ] Verify pipeline support

#### Copilot Review
This one is... honestly a mess. It's trying to do multiple things:

- Handle both `[guid]` and `[byte[]]` input
- Do endianness conversion (overlaps with Convert-UUIDBytes)
- Do nibble swapping with the -Reverse flag (overlaps with Convert-UUIDSquished)
- Has incomplete/broken logic in several places

Recommendation: **Delete both functions**

### Convert-UUIDBytes
- [x] Fix input and output type inconsistency
- [ ] Test performance vs. `Convert-UUID`
- [ ] Combine with `Convert-UUID`, adding a `[bytes[]]` pipeline parameter (if `[guid]` doesn't automatically convert)

#### Copilot Review
This function appears to be your endianness conversion function - it takes a byte array and flips it between
little-endian and big-endian formats. The three methods are different approaches to the same goal:

- ShortOrder - Clean approach: reverse sections manually `$GUID[3..0] + $GUID[5..4] + $GUID[7..6] + $GUID[8..15]`
- LongOrder - Verbose approach: manual byte swapping with temp variables
- Class - PowerShell Core only: uses the `[guid]::new($bytes, $bigEndian)` constructor

**Problem:** It's trying to return both `[byte[]]` and `[guid]` types inconsistently.

Recommendation: **Delete both functions**
