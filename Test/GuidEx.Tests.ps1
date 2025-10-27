BeforeAll {
    # Import the module, then use InModuleScope for private functions
    # see: https://pester.dev/docs/usage/modules#testing-private-functions
    Import-Module "$PSScriptRoot\..\GUIDEx.psd1" -Force
}

<# Describe "Deprecated Functions" {
    Context "Convert-UUID" {
        It "Should return a GUID" {
            $guid = Convert-UUID ([guid]'906F89D8-00DA-3583-8057-A7425FB9FDD4') -Reverse
            $guid | Should -BeOfType [guid]
        }
        It "Should reverse each byte" {
            $guid = Convert-UUID ([guid]'906F89D8-00DA-3583-8057-A7425FB9FDD4') -Reverse
            $guid | Should -Be ([guid]'8D98F609-AD00-3853-0875-7A24F59BDF4D')
        }
    }

    Context "Convert-UUIDBytes" {
        It "Should return byte[]" {
            $guid = [guid]"{01020304-0506-0708-090a-0b0c0d0e0f10}"
            $bytes = Convert-UUIDBytes $guid.ToByteArray()
            $bytes | Should -BeOfType [byte[]]
        }
        It "Should swap each byte order" {
            $bytes = [byte[]]@(0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10)
            $expectedBytes = [byte[]]@(0x04,0x03,0x02,0x01,0x06,0x05,0x08,0x07,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10)
            $flippedBytes = Convert-UUIDBytes $bytes
            $flippedBytes | Should -Be $expectedBytes
        }
        It "Should swap the byte order as well as endianness" {
            $bytes = [byte[]]@(0xD6,0x96,0x40,0x56,0xF8,0xFA,0xB4,0xF5,0xD8,0x8A,0x19,0x77,0xEE,0x1D,0x94,0xEC)
            $expectedBytes = [byte[]]@(0x56,0x40,0x96,0xD6,0xFA,0xF8,0xF5,0xB4,0xD8,0x8A,0x19,0x77,0xEE,0x1D,0x94,0xEC)
            $flippedBytes = Convert-UUIDBytes $bytes -Reverse
            $flippedBytes | Should -Be $expectedBytes
        }
    }
} #>

Describe "Public Support Functions" {
    Context "Convert-UUIDSquished" {
        It "Should return a GUID" {
            $guid = Convert-UUIDSquished "0102030405060708090a0b0c0d0e0f10"
            $guid | Should -BeOfType [guid]
        }

        It "Should return a string with -Format" {
            $guid = Convert-UUIDSquished "0102030405060708090a0b0c0d0e0f10" -Format n
            $guid | Should -BeOfType [string]
            $guid | Should -Be '403020106050807090a0b0c0d0e0f001'
        }

        It "Should convert squished UUID back to standard GUID format" {
            $squished = "403020106050807090a0b0c0d0e0f001"
            $expected = [guid]"{01020304-0506-0708-090a-0b0c0d0e0f10}"
            $guid = Convert-UUIDSquished $squished
            $guid | Should -Be $expected
        }

        It "Should be idempotent with pipeline support" {
            $inputGUID = [guid]"{01020304-0506-0708-090a-0b0c0d0e0f10}"
            $intermediate = [guid]"{40302010-6050-8070-90a0-b0c0d0e0f001}"
            $result1 = $inputGUID | Convert-UUIDSquished
            $result2 = $result1 | Convert-UUIDSquished
            $result1 | Should -Be $intermediate
            $result2 | Should -Be $inputGUID
        }

        It "Should be idempotent with string GUID input" {
            $inputString = "01020304-0506-0708-090a-0b0c0d0e0f10"
            $result1 = Convert-UUIDSquished $inputString
            $result2 = Convert-UUIDSquished $result1
            $result1 | Should -Be $result2
        }

        It "Should handle uppercase squished UUIDs" {
            $squished = "0102030405060708090A0B0C0D0E0F10"
            $guid = Convert-UUIDSquished $squished
            $guid.ToString() | Should -Be "01020304-0506-0708-090a-0b0c0d0e0f10"
        }

        It "Should handle braced GUID strings" {
            $bracedGUID = "{01020304-0506-0708-090a-0b0c0d0e0f10}"
            $guid = Convert-UUIDSquished $bracedGUID
            $guid.ToString() | Should -Be "01020304-0506-0708-090a-0b0c0d0e0f10"
        }
    }
    Context "Get-UUIDFromNamespace Function" {
        It "Should return the expected v3 UUID for a domain (UTF8)" {
            # ref: https://uuid.ca/uuid3/
            # Arrange
            $uriGUID = [guid]'6ba7b810-9dad-11d1-80b4-00c04fd430c8'
            $expectedGUID = [guid]'907e1018-10ac-35d1-b62e-561c32033af0'

            # Act
            $result = Get-UUIDFromNamespace -Namespace $uriGUID -Name 'example.com' -Version 3 -Encoding UTF8

            # Assert
            $result | Should -Be $expectedGUID
        }

        It "Should return the expected v5 UUID for a domain (UTF8)" {
            # Arrange
            $uriGUID = [guid]'6ba7b810-9dad-11d1-80b4-00c04fd430c8'
            $expectedGUID = [guid]'cfbff0d1-9375-5685-968c-48ce8b15ae17'

            # Act
            $result = Get-UUIDFromNamespace -Namespace $uriGUID -Name 'example.com' -Version 5 -Encoding UTF8

            # Assert
            $result | Should -Be $expectedGUID
        }

        It "Should return the expected v5 UUID for a Terminal profile" {
            # see: https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions#calculating-a-guid-for-a-built-in-profile
            # Arrange
            $internalNS = [guid]'{2bde4a90-d05f-401c-9492-e40884ead1d8}'
            $profileName = 'Ubuntu'
            $expectedGUID = [guid]'{2c4de342-38b7-51cf-b940-2309a097f518}'

            # Act
            $result = Get-UUIDFromNamespace -Namespace $internalNS -Name $profileName

            # Assert
            $result | Should -Be $expectedGUID
        }

        It "Should correctly convert v5 UUIDs for a Terminal fragment" {
            # see: https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions#generating-a-new-profile-guid
            # Arrange
            $terminalNS = [guid]'{f65ddb7e-706b-4499-8a50-40313caf510a}'
            $appName = 'Git'
            $profileName = 'Git Bash'
            $expectedGUID = [guid]'{2ece5bfe-50ed-5f3a-ab87-5cd4baafed2b}'

            # Act
            $appUUID = Get-UUIDFromNamespace -Namespace $terminalNS -Name $appName
            $profileUUID = Get-UUIDFromNamespace -Namespace $appUUID -Name $profileName

            # Assert
            $profileUUID | Should -Be $expectedGUID
        }
    }
}

