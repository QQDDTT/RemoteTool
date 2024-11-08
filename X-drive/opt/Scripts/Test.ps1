Import-Module @(
    "${PSScriptRoot}\Common\LogOutput.psm1",
    "${PSScriptRoot}\Common\XmlRead.psm1"
)



$file_path = "${PSScriptRoot}\test\test\test.txt"

$text = "Hello, World!"


Remove-Item -Path "${PSScriptRoot}\test" -Recurse -Force
Add_File -Path $file_path -Content $text