---
external help file: GUIDEx-help.xml
Module Name: GUIDEx
online version:
schema: 2.0.0
---

# Convert-UUIDSquished

## SYNOPSIS
Converts a GUID to the format stored by Windows Installer, e.g. in the Products registry key.

## SYNTAX

```powershell
Convert-UUIDSquished [-GUID] <Guid> [[-Format] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The cmdlet is idempotent -- this means you can give it a regular MSI GUID, or a GUID in the "Squished" format, and it will convert in either direction automatically.

## EXAMPLES

### EXAMPLE 1
```powershell
Convert-UUIDSquished "01020304-0506-0708-090a-0b0c0d0e0f10"
```

Output:
{04030201-0605-0807-090a-0b0c0d0e0f10}

### EXAMPLE 2
```powershell
Convert-UUIDSquished "01020304-0506-0708-090a-0b0c0d0e0f10" -Format n
```

Output:
0403020106050807090a0b0c0d0e0f10

## PARAMETERS

### -GUID
A GUID in a supported format.
Curly braces and hyphens optional.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Format
The GUID output format.
Default is "b".
Supported options are:
b - Default format with hyphens and curly braces (the typical format)
d - Default format with hyphens
n - Default format without hyphens (use this for Product registry keys)
p - Default format with parentheses and hyphens
x - Hexadecimal format

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [Guid] if Format is not specified.
### [String] if Format specified.

## NOTES
A "squished GUID" (SQUID) is a compressed format of a standard Windows Installer GUID, used to save space in the registry.
It removes hyphens and curly braces from the GUID and rearranges the hexadecimal digits, and is used internally by the installer to identify products and their updates.
You can find them used in: HKLM\Software\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products

## RELATED LINKS

[About SQUIDs](https://lordjeb.com/2013/10/01/windows-installer-squids/)

[Converting a Regular GUID to a Compressed GUID](https://community.revenera.com/s/article/converting-a-regular-guid-to-a-compressed-guid)
