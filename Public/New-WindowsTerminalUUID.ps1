function New-WindowsTerminalUUID {
    <#
        .SYNOPSIS
        Creates a deterministic UUID for a Windows Terminal profile fragment.
        .DESCRIPTION
        This essentially calls Get-UUIDFromNamespace once or twice, depending on the fragment type.
        .PARAMETER ProfileName
        The name of the Windows Terminal profile.
        .PARAMETER Application
        The name of the application for fragment profiles. If not specified, an official profile UUID is generated.
        .EXAMPLE
        PS C:\> New-WindowsTerminalUUID -ProfileName "Ubuntu"
        Output:
        {2c4de342-38b7-51cf-b940-2309a097f518}
        .EXAMPLE
        PS C:\> New-WindowsTerminalUUID -ProfileName "Git Bash" -Application "Git"
        Output:
        {f65ddb7e-706b-4499-8a50-40313caf510a}
        .NOTES
        {f65ddb7e-706b-4499-8a50-40313caf510a} is the namespace GUID for profiles created by plugins and fragments.
        {2bde4a90-d05f-401c-9492-e40884ead1d8} is the namespace GUID for profiles created by the Windows Terminal Team.
        .LINK
        Windows Terminal Fragments
        https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions#profile-guids
    #>
    [Alias('New-WindowsTerminalGUID','terminalguid')]
    [OutputType([guid])]
    [CmdletBinding(PositionalBinding,DefaultParameterSetName = 'Official')]
    Param(
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ParameterSetName = 'Official'
        )]
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ParameterSetName = 'Fragment'
        )]
        [string]$ProfileName,

        [Parameter(
            Mandatory,
            Position = 1,
            ParameterSetName = 'Fragment'
        )]
        [string]$Application
    )

    begin {
        $namespaceFragment = [guid]::Parse("{f65ddb7e-706b-4499-8a50-40313caf510a}")
        $namespaceOfficial = [guid]::Parse("{2bde4a90-d05f-401c-9492-e40884ead1d8}")
    }

    process {
        try {
            if ($Application) {
                # Fragment profile
                $appNamespaceGUID = Get-UUIDFromNamespace -Namespace $namespaceFragment -Name $Application -Encoding UTF16LE -Version 5
                $profileGUID = Get-UUIDFromNamespace -Namespace $appNamespaceGUID -Name $ProfileName -Encoding UTF16LE -Version 5
            }
            else {
                # Official profile
                $profileGUID = Get-UUIDFromNamespace -Namespace $namespaceOfficial -Name $ProfileName -Encoding UTF16LE -Version 5
            }
        }
        catch {
            $Err = $_
            throw "Exception $($Err.Exception.HResult) generating Windows Terminal profile GUID > $($Err.Exception.Message)"
        }

        $profileGUID
    }
}
