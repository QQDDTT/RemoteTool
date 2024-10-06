Import-Module "$PSScriptRoot\Common\LogOutput.psm1"
Import-Module "$PSScriptRoot\Common\XmlRead.psm1"

$Xml_Path = "$PSScriptRoot\Xml\Config.xml"

try{
    "WORK 1 START"
    [int]$result = 0
    if(Test-Item $Xml_Path) {
        [String]$LogPath = "LOG_PATH" | Read-Xml -Path $Xml_Path
        [String]$LogName = "LOG_NAME" | Read-Xml -Path $Xml_Path
        [String]$WorkSpace = "WORK_PACE" | Read-Xml -Path $Xml_Path
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
    $Path1 = Join-Path $WorkSpace $Test1
    $Path2 = Join-Path $WorkSpace $Test2
    $Path3 = Join-Path $WorkSpace $Test3
    if (Test-Path $Path1) {
        Add-Content -Path $Path1 -Value "*** LIST 1 ***"
        $List1 | ForEach-Object {
            Add-Content -Path $Path1 -Value $_
        }
    } else {
        $result = 1
        "$Path1 NOT FOUND" | Add-Log -W -Path $LogFullPathg
    }
    if (Test-Path $Path2) {
        Add-Content -Path $Path2 -Value "*** LIST 2 ***"
        $List2 | ForEach-Object {
            Add-Content -Path $Path2 -Value $_
        }
    } else {
        $result = 1
        "$Path2 NOT FOUND" | Add-Log -W -Path $LogFullPathg
    }
    if (Test-Path $Path3) {
        Add-Content -Path $Path3 -Value "*** LIST 1 & 2 ***"
        $List1 | ForEach-Object {
            Add-Content -Path $Path3 -Value $_
        }
        $List2 | ForEach-Object {
            Add-Content -Path $Path3 -Value $_
        }
    } else {
        $result = 1
        "$Path3 NOT FOUND" | Add-Log -W -Path $LogFullPathg
    }
} catch {
    $result = 5
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
return $result