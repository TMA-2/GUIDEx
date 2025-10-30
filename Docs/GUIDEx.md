---
Module Name: GUIDEx
Module Guid: db6cf18e-9912-4a19-a508-371b5ac24600
Download Help Link: {{ Update Download Link }}
Help Version: 1.0.0.0
Locale: en-US
---

# GUIDEx Module
## Description
This module provides functionality for three primary applications:
- Windows Installer / Squished GUID conversion
  - See [Convert-UUIDSquished](#convert-uuidsquished).
- UUIDv5 and v3 generation
  - See [Get-UUIDFromNamespace](#get-uuidfromnamespace).
- Windows Terminal fragment and profile GUID generation
  - See [New-WindowsTerminalUUID](#new-windowsterminaluuid).

## GUIDEx Cmdlets
### [Convert-UUIDSquished](Convert-UUIDSquished.md)
Converts a GUID to the format stored by Windows Installer, e.g. in the Products registry key.

### [Get-UUIDFromNamespace](Get-UUIDFromNamespace.md)
Gets a UUID version 3 (UUIDv3) or version 5 (UUIDv5) derived from a namespace and a name.

### [New-WindowsTerminalUUID](New-WindowsTerminalUUID.md)
Creates a deterministic UUID for a Windows Terminal profile fragment.
