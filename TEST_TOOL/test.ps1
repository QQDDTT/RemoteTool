$ScriptPath = $MyInvocation.MyCommand.path
$ParentPath = Split-Path $ScriptPath -Parent
$BASE_PATH = Split-Path $ParentPath -Parent

Import-Module -Name @(
    "$BASE_PATH\X-drive\opt\Scripts\Common\LogOutput.psm1",
    "$BASE_PATH\X-drive\opt\Scripts\Common\XmlRead.psm1",
    "$BASE_PATH\TEST_TOOL\Functions.psm1"
)

$Global:originalReadXml = ${function:Read_Xml}

Set-Item -Path Function:Read_Xml -Value {
    param(
        [String]$Path,
        [Parameter(ValueFromPipeline = $true)][String]$Key
    )
    $host.UI.WriteLine("1")
    $result = & $ProxyReadXml -OriginalCommand $Global:originalReadXml -Path $Path -Key $Key 
    return $result
}

$Global:ProxyReadXml = {
    param (
        [string]$Path,
        [String]$Key,
        $OriginalCommand
    )
    process {
        try {
            $host.UI.WriteLine("1")
            $result = & $OriginalCommand -Path $Path -Key $Key
            return $result
        }
        catch {
            $host.UI.WriteDebugLine($_)
        }
    }
}

$Xml_Path = "${BASE_PATH}\X-drive\opt\Scripts\Xml\Config.xml"
[String]$WorkSpace = Read_Xml -Path $Xml_Path -Key "WORK_SPACE"
Write-Host $WorkSpace