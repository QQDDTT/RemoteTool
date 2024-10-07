Import-Module "X:\opt\Scripts\Common\LogOutput.psm1"
Import-Module "X:\opt\Scripts\Common\XmlRead.psm1"

$Xml_Path = "X:\opt\Scripts\Xml\Config.xml"
$Log_Path = "X:\opt\Scripts\Log\WK001.log"

try{
    Get-Content -Path $Xml_Path | Write-Host
    Add_Log -Path $Log_Path -N -Message "WORK 1 START"
    # [int]$result = 0
    # if(Test-Item $Xml_Path) {
    #     [String]$WorkSpace = "WORK_PACE" | Read-Xml -Path $Xml_Path
    #     [String]$Test1 = "TEST_FILE_1" | Read-Xml -Path $Xml_Path
    #     [String]$Test2 = "TEST_FILE_2" | Read-Xml -Path $Xml_Path
    #     [String]$Test3 = "TEST_FILE_3" | Read-Xml -Path $Xml_Path
    #     [String]$List1 = "LIST_1" | Read-Xml -Path $Xml_Path
    #     [String]$List2 = "LIST_2" | Read-Xml -Path $Xml_Path
    # } else {
    #     $result = 5
    #     return $result
    # }

    # $Path1 = Join-Path $WorkSpace $Test1
    # $Path2 = Join-Path $WorkSpace $Test2
    # $Path3 = Join-Path $WorkSpace $Test3

    # if (Test-Path $Path1) {
    #     Add-Content -Path $Path1 -Value "*** LIST 1 ***"
    #     $List1 | ForEach-Object {
    #         Add-Content -Path $Path1 -Value $_
    #     }
    # } else {
    #     $result = 1
    #     "$Path1 NOT FOUND" | Add-Log -W -Path $Log_Path
    # }

    # if (Test-Path $Path2) {
    #     Add-Content -Path $Path2 -Value "*** LIST 2 ***"
    #     $List2 | ForEach-Object {
    #         Add-Content -Path $Path2 -Value $_
    #     }
    # } else {
    #     $result = 1
    #     "$Path2 NOT FOUND" | Add-Log -W -Path $Log_Path
    # }

    # if (Test-Path $Path3) {
    #     Add-Content -Path $Path3 -Value "*** LIST 1 & 2 ***"
    #     $List1 | ForEach-Object {
    #         Add-Content -Path $Path3 -Value $_
    #     }
    #     $List2 | ForEach-Object {
    #         Add-Content -Path $Path3 -Value $_
    #     }
    # } else {
    #     $result = 1
    #     "$Path3 NOT FOUND" | Add-Log -W -Path $Log_Path
    # }
    return $result
} catch {
    $result = 5
    # "ERROR $_.Exception.Message" | Add-Log -E -Path $Log_Path
    return $result
} finally {
    # switch ($result) {
    #     0 {
    #         "END" | Add-Log -N -Path $Log_Path
    #     }
    #     1 {
    #         "END with WRNNING" | Add-Log -W -Path $Log_Path
    #     }
    #     5 {
    #         "END with ERROR" | Add-Log -E -Path $Log_Path
    #     }
    #     Default {
    #         "END with ERROR" | Add-Log -E -Path $Log_Path
    #     }
    # }
}
