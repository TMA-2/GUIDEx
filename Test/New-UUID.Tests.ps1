BeforeAll {
    . "$PSScriptRoot\..\Private\Convert-BinaryLSB.ps1"
    . "$PSScriptRoot\..\Public\Convert-UUIDBytes.ps1"
    . "$PSScriptRoot\..\Public\New-UUID.ps1"
}

Describe "New-UUID Function" {
    It "Should return the expected GUID" {
        # Arrange
        $expectedGUID = [Guid]::Parse('cfbff0d1-9375-5685-968c-48ce8b15ae17')

        # Act
        $result = New-UUID -Namespace "6ba7b810-9dad-11d1-80b4-00c04fd430c8" -Name 'example.com'

        # Assert
        $result | Should -Be $expectedGUID
    }
}

Describe "GUID Support Functions" {
    Context "Convert-UUIDBytes" {
        It "Should return a GUID" {
            $guid = Convert-UUIDBytes "{01020304-0506-0708-090a-0b0c0d0e0f10}"
            $guid | Should -BeOfType [guid]
        }
        It "Should swap each byte order" {
            $guid = Convert-UUIDBytes "{01020304-0506-0708-090a-0b0c0d0e0f10}"
            $guid.ToString() | Should -Be "04030201-0605-0807-090a-0b0c0d0e0f10"
        }
        It "Should swap the byte order as well as endianness" {
            $guid = Convert-UUIDBytes "{6D690465-8FAF-4B5F-8DA8-9177EED149CE}" -Reverse
            $guid.ToString() | Should -Be "564096D6-FAF8-F5B4-D88A-1977EE1D94EC"
        }
    }
    Context "Convert-BinaryLSB" {
        It "Should return a byte" {
            $byte = Convert-BinaryLSB 0xA1
            $byte | Should -BeOfType [byte]
        }
        It "Should swap the byte order" {
            $byte = Convert-BinaryLSB [byte[]]@(0x10, 0x20, 0x30, 0x40)
            $byte | Should -Be (0x01, 0x02, 0x03, 0x04)
        }
        It "Should take pipeline input" {
            [guid]"{906F89D8-00DA-3583-8057-A7425FB9FDD4}" | Convert-BinaryLSB | Should -Exist
        }
        It "Should reverse a GUID's byte order" {
            $GUIDA = [guid]"{906F89D8-00DA-3583-8057-A7425FB9FDD4}"
            $GUIDB = Convert-BinaryLSB $GUIDA
            $GUIDB | Should -BeOfType [guid]
            $GUIDB | Should -Be [guid]"D4FD9F25-7A04-5780-83DA-89F90600D8A1"
        }
    }
}