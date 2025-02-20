# Create UUID v3 or v5 from a namespace and string
# ref: https://github.com/icosa-foundation/open-brush/blob/78cc38cb172649340eb61eec3d3d38f7f289069c/Assets/Scripts/Util/GuidUtils.cs
# TODO: Test vs. New-UUID
# TODO: TEST w/ Pester using the Terminal documentation
# TODO: STANDARDIZE FUNC
#   [ ]: PIPELINE + PROCESS BLOCK
function New-UUIDNamespace {
    [Alias('New-GUIDNamespace','nudns')]
    [CmdletBinding()]
    [OutputType([System.Guid])]
    param (
        [Guid]
        $NS,
        [string]
        $Name,
        [ValidateSet(3, 5)]
        [int]
        $Version = 5
    )

    $Hasher = if ($Version -eq 5) {
        # alternately takes a string HashName
        [System.Security.Cryptography.SHA1]::Create()
    } elseif ($Version -eq 3) {
        # also takes a string AlgName
        [System.Security.Cryptography.MD5]::Create()
    } else {
        Throw [System.Exception]::new("Unrecognized UUID version $Version")
    }

    # get GUID as big endian byte[] (16ms)
    if ($IsCoreCLR) {
        $NSBytesBigEndian = $NS.ToByteArray($true)
    } else {
        $NSBytesBigEndian = $NS.ToByteArray()
        Convert-UUIDBytes ($NSBytesBigEndian)
    }
    # convert to big endian... uh... $NSBytesBigEndian.ToByteArray($true) ???
    # ByteswapGuid ([ref]$NSBytesBigEndian)

    # where does this go...?
    $Hasher.TransformBlock($NSBytesBigEndian, 0, $NSBytesBigEndian.Length, $null, 0)

    # get unicode bytes of string
    $UTF8Name = [System.Text.Encoding]::UTF8.GetBytes($Name)
    # transform... something
    $null = $Hasher.TransformFinalBlock($UTF8Name, 0, $UTF8Name.Length)

    # create 16-byte var to hold the crypt hash
    $Hash16 = [byte[]]::new(16)
    # Copy(arr Source, int SourceIndex, arr Dest, int DestIndex, int length)
    # TODO: Try Copy(arr Source, arr Dest, int length)
    [System.Array]::Copy($Hasher.Hash, 0, $Hash16, 0, $Hash16.Length)

    # see: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arithmetic_operators?view=powershell-7.4#bitwise-operators

    # RFC4122... Octet 8, clock_seq_hi_and_reserved, top 3 bits to 1 0 x
    # from (byte)((hash16[8] & ~0xc0) | 0x80)
    # ~0xC0 is the complement of 192, i.e. 63
    $Hash16[8] = [byte](($Hash16[8] -band (-bnot 0xC0)) -bor 0x80)
    # Version... most-significant 4 bits of time_hi_and_version (octets 6,7)
    # from (byte)((hash16[6] & ~0xf0) | (version << 4))
    # ~0xF0 is the complement of 0b11110000, i.e. 15, 0b1111
    # TODO: See how it's done in .NET Core [System.Numerics.BitOperations]::RotateLeft(), RotateRight()
    $Hash16[6] = [byte](($Hash16[6] -band (-bnot 0xF0)) -bor ($Version -shl 4))

    # convert back to little-endian
    Convert-UUIDBytes ($Hash16)
    # create final GUID
    $ReturnGUID = [System.Guid]::new($Hash16)

    Return $ReturnGUID
} # New-NamespaceGUID()
