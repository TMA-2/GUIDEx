function Convert-BinaryLSB {
    [OutputType(ParameterSetName='Byte', [byte[]])]
    [OutputType(ParameterSetName='Guid', [Guid])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            Position=0,
            ValueFromPipeline,
            ParameterSetName='Byte'
            )]
        [byte[]]$Bytes,
        [Parameter(
            Mandatory,
            Position=0,
            ValueFromPipeline,
            ParameterSetName='Guid'
            )]
        [Guid]$Guid
    )

    Begin {
        $ParamSet = $PSCmdlet.ParameterSetName
        $VERBOSE = $PSBoundParameters.ContainsKey('Verbose')
        function Show-Step {
            param (
                [string]$Step,
                [byte]$Byte1,
                [byte]$Byte2
            )

            $Byte1Fmt = [System.Convert]::ToString($Byte1, 2).PadLeft(8, '0')
            $Byte2Fmt = [System.Convert]::ToString($Byte2, 2).PadLeft(8, '0')

            "{0}: {1:X2} -> {2:X2}; 0b{3} -> 0b{4}" -f $Step, $Byte1, $Byte2, $Byte1Fmt, $Byte2Fmt
        }
    }

    process {
        if ($ParamSet -eq 'Guid') {
            $Bytes = $Guid.ToByteArray()
        }

        $reversedBytes = @()
        foreach ($byte in $bytes) {
            $reversedByte = [byte]0
            for ($i = 0; $i -lt 8; $i++) {
                # ex: 0xF8 -> 0x8F
                $reversedByte = $reversedByte -bor (($byte -shr $i -band 1) -shl (7 - $i))
                Show-Step -Step $i -Byte1 $byte -Byte2 $reversedByte | Write-Verbose
            }
            $reversedBytes += $reversedByte
        }

        if ($ParamSet -eq 'Guid') {
            return [Guid]::NewGuid($reversedBytes)
        } elseif($ParamSet -eq 'Byte') {
            return $reversedBytes
        }
    }
}

# Example usage:
# $namespace = [Guid]::Parse("6ba7b810-9dad-11d1-80b4-00c04fd430c8") # DNS namespace
# $name = "example.com"
# $uuidv5 = Get-UUIDv5 -Namespace $namespace -Name $name
# Write-Output $uuidv5
# # cfbff0d1-9375-5685-968c-48ce8b15ae17
function Get-UUIDv5 {
    param (
        [Parameter(Mandatory=$true)]
        [Guid]$Namespace,
        
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    Begin {
        $LITTLE_ENDIAN = [System.BitConverter]::IsLittleEndian
    }

    Process {
        # Convert the namespace GUID to a byte array, keeping the endianness from swapping
        $namespaceBytes = $Namespace.ToByteArray($LITTLE_ENDIAN)
    
        # Convert the name to a byte array
        $nameBytes = [System.Text.Encoding]::UTF8.GetBytes($Name)
    
        # Combine namespace and name
        $combinedBytes = $namespaceBytes + $nameBytes
    
        # Create a SHA1 hash
        $sha1 = [System.Security.Cryptography.SHA1]::Create()
        # toss the last 4 bytes
        $hashBytes = $sha1.ComputeHash($combinedBytes)[0..15]
    
        # Set the version (5) and variant bits
        $hashBytes[6] = ($hashBytes[6] -band 0x0F) -bor 0x50
        $hashBytes[8] = ($hashBytes[8] -band 0x3F) -bor 0x80

        # verify it's a byte array and not a generic object[]
        $hashBytes = $hashBytes -as [byte[]]
    
        # Create a new GUID from the hash
        $uuidv5 = [Guid]::New($hashBytes, $LITTLE_ENDIAN)
        return $uuidv5
    }

    End {
        $sha1.Dispose()
    }
}

