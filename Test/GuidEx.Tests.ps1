BeforeAll {
    # Import the module, then use InModuleScope for private functions
    # see: https://pester.dev/docs/usage/modules#testing-private-functions
    Import-Module "$PSScriptRoot\..\GUIDEx.psd1" -Force
}

Describe "Public Support Functions" {
    Context "Convert-UUIDSquished" {
        It "Should return a GUID by default" {
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
            $inputGuid = "01020304-0506-0708-090a-0b0c0d0e0f10"
            $result1 = Convert-UUIDSquished $inputGuid
            $result2 = Convert-UUIDSquished $result1
            $result2.ToString() | Should -Be $inputGuid
        }
    }
    Context "Get-UUIDFromNamespace Function" {
        It "Should return the expected v3 UUID for a domain (UTF8)" {
            # ref: https://uuid.ca/uuid3/
            # Arrange
            $uriGUID = [guid]'6ba7b810-9dad-11d1-80b4-00c04fd430c8'
            $expectedGUID = [guid]'9073926b-929f-31c2-abc9-fad77ae3e8eb'

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
    }
    Context "New-WindowsTerminalUUID Function" {
        It "Should generate a valid GUID" {
            $uuid = New-WindowsTerminalUUID -ProfileName "Test Profile"
            $uuid | Should -BeOfType [guid]
        }
        It "Should return the expected v5 UUID for a Terminal profile" {
            # see: https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions#calculating-a-guid-for-a-built-in-profile
            # Arrange
            $profileName = 'Ubuntu'
            $expectedGUID = [guid]'{2c4de342-38b7-51cf-b940-2309a097f518}'

            # Act
            $result = New-WindowsTerminalUUID -ProfileName $profileName

            # Assert
            $result | Should -Be $expectedGUID
        }

        It "Should correctly convert v5 UUIDs for a Terminal fragment" {
            # see: https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions#generating-a-new-profile-guid
            # Arrange
            $appName = 'Git'
            $profileName = 'Git Bash'
            $expectedGUID = [guid]'{2ece5bfe-50ed-5f3a-ab87-5cd4baafed2b}'

            # Act
            $profileUUID = New-WindowsTerminalUUID -ProfileName $profileName -Application $appName

            # Assert
            $profileUUID | Should -Be $expectedGUID
        }
    }
}

