---
external help file: GUIDEx-help.xml
Module Name: GUIDEx
online version:
schema: 2.0.0
---

# New-WindowsTerminalUUID

## SYNOPSIS
Creates a deterministic UUID for a Windows Terminal profile fragment.

## SYNTAX

### Official (Default)
```powershell
New-WindowsTerminalUUID [-ProfileName] <String> [<CommonParameters>]
```

### Fragment
```powershell
New-WindowsTerminalUUID [-ProfileName] <String> [-Application] <String> [<CommonParameters>]
```

## DESCRIPTION
This essentially calls `Get-UUIDFromNamespace` once or twice with the expected namespace and encoding, depending on the profile type.

## EXAMPLES

### EXAMPLE 1
```powershell
New-WindowsTerminalUUID -ProfileName "Ubuntu"
```

Output:
{2c4de342-38b7-51cf-b940-2309a097f518}

### EXAMPLE 2
```powershell
New-WindowsTerminalUUID -ProfileName "Git Bash" -Application "Git"
```

Output:
{f65ddb7e-706b-4499-8a50-40313caf510a}

## PARAMETERS

### -ProfileName
The name of the Windows Terminal profile.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Application
The name of the application for fragment profiles.
If not specified, an official profile UUID is generated.

```yaml
Type: String
Parameter Sets: Fragment
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Guid

## NOTES
{f65ddb7e-706b-4499-8a50-40313caf510a} is the namespace GUID for profiles created by plugins and fragments.
{2bde4a90-d05f-401c-9492-e40884ead1d8} is the namespace GUID for profiles created by the Windows Terminal Team.

## RELATED LINKS
[Windows Terminal Fragments](https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions#profile-guids)
