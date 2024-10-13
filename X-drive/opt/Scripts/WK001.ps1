# $ScriptPath = $MyInvocation.MyCommand.Source
$ParentPath = $PSScriptRoot

Import-Module @(
    "${ParentPath}\Common\LogOutput.psm1",
    "${ParentPath}\Common\XmlRead.psm1"
)

$Xml_Path = "${ParentPath}\Xml\Config.xml"
$Log_Path = "${ParentPath}\Log\WK001.log"

try{
    Add_Log -Path $Log_Path -N -Message "WORK 001 START"
    [int]$result = 0
    if(Test-Path $Xml_Path) {
        [String]$WorkSpace = Read_Xml -Path $Xml_Path -Key "WORK_SPACE"
        [String]$Test1 = Read_Xml -Path $Xml_Path -Key "TEST_FILE_1" 
        [String]$Test2 = Read_Xml -Path $Xml_Path -Key "TEST_FILE_2"
        [String]$Test3 = Read_Xml -Path $Xml_Path -Key "TEST_FILE_3"
        [String[]]$List1 = Read_Xml -Path $Xml_Path -Key "LIST_1"
        [String[]]$List2 = Read_Xml -Path $Xml_Path -Key "LIST_2"
    } else {
        $result = 5
        return $result
    }

    $Path1 = Join-Path -Path $WorkSpace -ChildPath $Test1
    $Path2 = Join-Path -Path $WorkSpace -ChildPath $Test2
    $Path3 = Join-Path -Path $WorkSpace -ChildPath $Test3

    New-Item -Path $Path1
    New-Item -Path $Path2
    New-Item -Path $Path3

    if (Test-Path $Path1) {
        Add-Content -Path $Path1 -Value "*** LIST 1 ***"
        foreach ($l1 in $List1) {
            Add-Content -Path $Path1 -Value $l1
        }
    } else {
        $result = 1
        "$Path1 NOT FOUND" | Add_Log -W -Path $Log_Path
    }

    if (Test-Path $Path2) {
        Add-Content -Path $Path2 -Value "*** LIST 2 ***"
        foreach ($l2 in $List2) {
            Add-Content -Path $Path2 -Value $l2
        }
    } else {
        $result = 1
        "$Path2 NOT FOUND" | Add_Log -W -Path $Log_Path
    }

    if (Test-Path $Path3) {
        Add-Content -Path $Path3 -Value "*** LIST 1 & 2 ***"
        foreach ($l1 in $List1) {
            Add-Content -Path $Path3 -Value $l1
        }
        foreach ($l2 in $List2) {
            Add-Content -Path $Path3 -Value $l2
        }
    } else {
        $result = 1
        "$Path3 NOT FOUND" | Add_Log -W -Path $Log_Path
    }
    return $result
} catch {
    $result = 5
    "ERROR " + $_.Exception | Add_Log -E -Path $Log_Path
    return $result
} finally {
    switch ($result) {
        0 {
            "END" | Add_Log -N -Path $Log_Path
        }
        1 {
            "END with WRNNING" | Add_Log -W -Path $Log_Path
        }
        5 {
            "END with ERROR" | Add_Log -E -Path $Log_Path
        }
        Default {
            "END with ERROR" | Add_Log -E -Path $Log_Path
        }
    }
}
