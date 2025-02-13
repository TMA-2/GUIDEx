.\Get-UUIDv5.ps1

Describe "Get-UUID Function" {
    It "Should return the expected GUID" {
        # Arrange
        $expectedGUID = [Guid]::Parse('cfbff0d1-9375-5685-968c-48ce8b15ae17')

        # Act
        $result = Get-UUIDv5 -Namespace "6ba7b810-9dad-11d1-80b4-00c04fd430c8" -Name 'example.com'

        # Assert
        $result | Should -Be $expectedGUID
    }
}
