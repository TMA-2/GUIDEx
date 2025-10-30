---
external help file: GUIDEx-help.xml
Module Name: GUIDEx
online version:
schema: 2.0.0
---

# Get-UUIDFromNamespace

## SYNOPSIS
Gets a UUID version 3 (UUIDv3) or version 5 (UUIDv5) derived from a namespace and a name.

## SYNTAX

```powershell
Get-UUIDFromNamespace [-Namespace] <Guid> [-Name] <String> [-Version <Int32>] [-Encoding <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-UUIDFromNamespace function gets a UUID version 3 or version 5, which are universally unique identifiers that are generated using a namespace identifier and a name.
UUIDv3 uses MD5 hashing, while UUIDv5 uses SHA-1 hashing to create the identifier.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-UUIDFromNamespace -Namespace "6ba7b810-9dad-11d1-80b4-00c04fd430c8" -Name "example" -Version 5
```

Gets a UUIDv5 based on the provided namespace and name.

### EXAMPLE 2
```powershell
Get-UUIDFromNamespace -Namespace "6ba7b810-9dad-11d1-80b4-00c04fd430c8" -Name "example" -Version 3
```

Gets a UUIDv3 based on the provided namespace and name.

### EXAMPLE 3
```powershell
Get-UUIDFromNamespace -Namespace "{2bde4a90-d05f-401c-9492-e40884ead1d8}" -Name "Ubuntu" -Encoding UTF16LE
```

Generates a UUID for a Windows Terminal profile using the profile namespace and UTF16LE encoding.
Output: 2c4de342-38b7-51cf-b940-2309a097f518

### EXAMPLE 4
```powershell
$AppNamespace = Get-UUIDFromNamespace -Namespace '{f65ddb7e-706b-4499-8a50-40313caf510a}' -Name "Git" -Encoding UTF16LE
Get-UUIDFromNamespace -Namespace $AppNamespace -Name "Git Bash" -Encoding UTF16LE
```

Generates a UUID for a Windows Terminal profile using the fragment namespace and UTF16LE encoding.
Output: 2ece5bfe-50ed-5f3a-ab87-5cd4baafed2b

## PARAMETERS

### -Namespace
The namespace identifier, which is a UUID that defines the scope of the name.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases: NS

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
The name from which the UUID will be generated.
This is typically a string.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Version
The version of the UUID to generate.
Accepts 3 or 5.
Default is 5.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 5
Accept pipeline input: False
Accept wildcard characters: False
```

### -Encoding
The encoding method to use for the name.
UTF8 for standard RFC compliance, UTF16LE for Windows Terminal compatibility.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: UTF8
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [Guid] The UUID version 3 or 5 derived from the namespace and name.

## NOTES
UUID version 3 is defined in RFC 4122.
UUID version 5 is defined in RFC 4122.

## RELATED LINKS
[Windows Terminal Fragment documentation](https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions#profile-guids)
