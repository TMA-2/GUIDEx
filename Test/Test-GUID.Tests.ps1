BeforeAll {
    ."$PSScriptRoot\..\Public\UUID.ps1"
}

Describe "Test-GUID" {
    Context "Convert-GUIDBytes" {
        BeforeAll {
            $guid = Convert-GUIDBytes "{01020304-0506-0708-090a-0b0c0d0e0f01}"
        }
        $guid = Convert-GUIDBytes "{01020304-0506-0708-090a-0b0c0d0e0f01}"
        It "Should return a GUID" {
            $guid | Should -BeOfType [guid]
        }
        It "Should swap each byte order" {
            $guid.ToString() | Should -Be "04030201-0605-0807-090a-0b0c0d0e0f01"
        }
        It "Should swap the byte order as well as endianness" {
            $guid = Convert-GUIDBytes "{01020304-0506-0708-090a-0b0c0d0e0f01}" -Reverse
            $guid.ToString() | Should -Be "40302010-6050-8070-90a0-b0c0d0e0f010"
        }
    }
    Context "Convert-Byte" {
        It "Should return a byte" {
            $byte = Convert-Byte 0xA1
            $byte | Should -BeOfType [byte]
        }
        It "Should swap the byte order" {
            $byte = Convert-Byte (0x10,0x20,0x30,0x40)
            $byte | Should -Be (0x01,0x02,0x03,0x04)
        }
        It "Should take pipeline input" {
            ([guid]"{906F89D8-00DA-3583-8057-A7425FB9FDD4}").ToByteArray() | Convert-Byte | Should -Exist
        }
    }
}
