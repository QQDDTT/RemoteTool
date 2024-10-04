$script_path = $MyInvocation.MyCommand.Definition
$parent_path = Split-Path -Path $script_path

Import-Module "$PSScriptRoot\Common\LogOutput.psm1"
Import-Module "$PSScriptRoot\Common\XmlRead.psm1"

$Xml_Path = "$PSScriptRoot\Xml\Config.xml"

try{
    "WORK 1 START"
    [int]$result = 0
    if(Test-Item $Xml_Path) {
        [String]$LogPath = "LOG_PATH" | Read-Xml -Path $Xml_Path
        [String]$LogName = "LOG_NAME" | Read-Xml -Path $Xml_Path
        [String]$Test1 = "TEST_FILE_1" | Read-Xml -Path $Xml_Path
        [String]$Test2 = "TEST_FILE_2" | Read-Xml -Path $Xml_Path
        [String]$Test3 = "TEST_FILE_3" | Read-Xml -Path $Xml_Path
        [String]$List1 = "LIST_1" | Read-Xml -Path $Xml_Path
        [String]$List2 = "LIST_2" | Read-Xml -Path $Xml_Path
    } else {
        $result = 5
        return $result
    }

    $LogFullPath = Join-Path $LogPath $LogName
} catch {
    "ERROR $_.Exception.Message" | Add-Log -E -Path $LogFullPath
} finally {
    switch ($result) {
        0 {
            "END" | Add-Log -N -Path $LogFullPath
        }
        1 {
            "END with WRNNING" | Add-Log -W -Path $LogFullPath
        }
        5 {
            "END with ERROR" | Add-Log -E -Path $LogFullPath
        }
        Default {
            "END with ERROR" | Add-Log -E -Path $LogFullPath
        }
    }
}