$ScriptPath = $MyInvocation.MyCommand.path
$ParentPath = Split-Path $ScriptPath -Parent
$BASE_PATH = Split-Path $ParentPath -Parent

Import-Module -Name @(
    "$BASE_PATH\X-drive\opt\Scripts\Common\LogOutput.psm1",
    "$BASE_PATH\X-drive\opt\Scripts\Common\XmlRead.psm1",
    "$BASE_PATH\TEST_TOOL\Functions.psm1"
)

function Global:SimulationSimpleTest {
    param(
        [Parameter(ValueFromPipeline = $true)][ScriptBlock]$SimulationBlock,
        [String[]]$T,
        [String[]]$V
    )
    process {
        try {
            Print -Status "PREPARE" -Message "start"
            if ($null -eq $T -or $null -eq $V) {
                Print -Status "VERIFICATION" -Errors "TruePaths or VirtualPaths is null"
                return
            }
            if ($T.Length -eq 0 -or $V.Length -eq 0) {
                Print -Status "VERIFICATION" -Errors "TruePaths or VirtualPaths length must be greater than 0"
                return
            }
            if ($T.Length -ne $V.Length) {
                Print -Status "VERIFICATION" -Errors "TruePaths and VirtualPaths must be of equal length"
                return
            }
        
            foreach ($path in $T) {
                if (-not (Test-Path -Path $path)) {
                    Print -Status "VERIFICATION" -Errors "[$path] is not a valid path."
                    return
                }
            }
            
            if (-not $SimulationBlock) {
                Print -Status "VERIFICATION" -Errors "SimulationBlock is empty"
                return
            }
            $Global:originalTestPath = Get-Command Test-Path
            $Global:originalJoinPath = Get-Command Join-Path
            $Global:originalSplitPath = Get-Command Split-Path
            $Global:originalGetContent = Get-Command Get-Content
            $Global:originalSetContent = Get-Command Set-Content
            $Global:originalAddContent = Get-Command Add-Content
            $Global:originalClearContent = Get-Command Clear-Content
            $Global:originalRemoveItem = Get-Command Remove-Item
            $Global:originalCopyItem = Get-Command Copy-Item
            $Global:originalMoveItem = Get-Command Move-Item
            $Global:originalNewItem = Get-Command New-Item
            $Global:originalGetItem = Get-Command Get-Item
            $Global:originalGetItemProperty = Get-Command Get-ItemProperty
            $Global:originalGetChildItem = Get-Command Get-ChildItem
            $Global:originalSetlocation = Get-Command Set-Location
            $Global:originalOutFile = Get-Command Out-File
            $Global:originalExportCsv = Get-Command Export-Csv
            $Global:originalImportCsv = Get-Command Import-Csv
            $Global:originalImportModule = Get-Command Import-Module

            $Global:originalAddLog = ${function:Add_Log}
            $Global:originalAddFile = ${function:Add_File}
            $Global:originalReadXml = ${function:Read_Xml}

            Print -Status "PREPARE" -Message "Command extraction is successful"

            # 替换原始命令
            Set-Item -Path Function:Test-Path -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path)
                Print -Status "RUNNING" -Cmd "Test-Path" -Keys @("Path") -Values @($Path)
                & $ProxyTestPath -Path $Path -OriginalCommand $Global:originalTestPath
            }
            Set-Item -Path Function:Join-Path -Value {
                param([String[]]$Path, [String]$ChildPath)
                Print -Status "RUNNING" -Cmd "Join-Path" -Keys @("Path", "ChildPath") -Values @($Path, $ChildPath)
                & $ProxyJoinPath -Path $Path -ChildPath $ChildPath -OriginalCommand $Global:originalJoinPath
            }
            Set-Item -Path Function:Split-Path -Value {
                param([String[]]$Path, [switch]$Parent)
                Print -Status "RUNNING" -Cmd "Split-Path" -Keys @("Path", {IIF($Parent, "Parent", "")}) -Values @($Path, "")
                & $ProxySplitPath -Path $Path -ChildPath $ChildPath -OriginalCommand $Global:originalSplitPath
            }
            Set-Item -Path Function:Get-Content -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path)
                Print -Status "RUNNING" -Cmd "Get-Content" -Keys @("Path") -Values @($Path)
                & $ProxyGetContent -Path $Path -OriginalCommand $Global:originalGetContent
            }
            Set-Item -Path Function:Set-Content -Value {
                param([String[]]$Path, [Parameter(ValueFromPipeline = $true)][Object[]]$Value)
                Print -Status "RUNNING" -Cmd "Set-Content" -Keys @("Path", "Value") -Values @($Path, $Value)
                & $ProxySetContent -Path $Path -Value $Value -OriginalCommand $Global:originalSetContent
            }
            Set-Item -Path Function:Add-Content -Value {
                param([String[]]$Path, [Parameter(ValueFromPipeline = $true)][Object[]]$Value)
                Print -Status "RUNNING" -Cmd "Add-Content" -Keys @("Path", "Value") -Values @($Path, $Value)
                & $ProxyAddContent -Path $Path -Value $Value -OriginalCommand $Global:originalAddContent
            }
            Set-Item -Path Function:Clear-Content -Value {
                param([String[]]$Path)
                Print -Status "RUNNING" -Cmd "Clear-Content" -Keys @("Path") -Values @($Path)
                & $ProxyClearContent -Path $Path -OriginalCommand $Global:originalClearContent
            }
            Set-Item -Path Function:Remove-Item -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path)
                Print -Status "RUNNING" -Cmd "Remove-Item" -Keys @("Path") -Values @($Path)
                & $ProxyRemoveItem -Path $Path -OriginalCommand $Global:originalRemoveItem
            }
            Set-Item -Path Function:Copy-Item -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path, [String]$Destination)
                Print -Status "RUNNING" -Cmd "Copy-Item" -Keys @("Path", "Destination") -Values @($Path, $Destination)
                & $ProxyCopyItem -Path $Path -Destination $Destination -OriginalCommand $Global:originalCopyItem
            }
            Set-Item -Path Function:Move-Item -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path, [String]$Destination)
                Print -Status "RUNNING" -Cmd "Move-Item" -Keys @("Path", "Destination") -Values @($Path, $Destination)
                & $ProxyMoveItem -Path $Path -Destination $Destination -OriginalCommand $Global:originalMoveItem
            }
            Set-Item -Path Function:New-Item -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path)
                Print -Status "RUNNING" -Cmd "New-Item" -Keys @("Path") -Values @($Path)
                & $ProxyNewItem -Path $Path -OriginalCommand $Global:originalNewItem
            }
            Set-Item -Path Function:Get-Item -Value {
                param([String[]]$Path)
                Print -Status "RUNNING" -Cmd "Get-Item" -Keys @("Path") -Values @($Path)
                & $ProxyGetItem -Path $Path -OriginalCommand $Global:originalGetItem
            }
            Set-Item -Path Function:Get-ItemProperty -Value {
                param([String[]]$Path)
                Print -Status "RUNNING" -Cmd "Get-ItemProperty" -Keys @("Path") -Values @($Path)
                & $ProxyGetItemProperty -LiteralPath $LiteralPath -OriginalCommand $Global:originalGetItemProperty
            }
            Set-Item -Path Function:Get-ChildItem -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path, [switch]$Recurse)
                Print -Status "RUNNING" -Cmd "Get-ChildItem" -Keys @("Path", {IIF ($Recurse, "Recurse", "")}) -Values @($Path, "")
                & $ProxyGetChildItem -Path $Path -Recurse $Recurse -OriginalCommand $Global:originalGetChildItem
            }
            Set-Item -Path Function:Set-Location -Value {
                param([String]$Path)
                Print -Status "RUNNING" -Cmd "Set-Location" -Keys @("Path") -Values @($Path)
                & $ProxySetLocation -Path $Path -OriginalCommand $Global:originalSetlocation
            }
            Set-Item -Path Function:Out-File -Value {
                param([String]$FilePath, [Parameter(ValueFromPipeline = $true)][psobject]$InputObject)
                Print -Status "RUNNING" -Cmd "Out-File" -Keys @("FilePath", "InputObject") -Values @($Path, $InputObject)
                & $ProxyOutFile -FilePath $FilePath -InputObject $InputObject -OriginalCommand $Global:originalOutFile
            }
            Set-Item -Path Function:Export-Csv -Value {
                param([psobject]$InputObject, [String]$Path)
                Print -Status "RUNNING" -Cmd "Export-Csv" -Keys @("FilePath", "InputObject") -Values @($Path, $InputObject)
                & $ProxyExportCsv -InputObject $InputObject -Path $Path -OriginalCommand $Global:originalExportCsv
            }
            Set-Item -Path Function:Import-Csv -Value {
                param([String[]]$Path)
                Print -Status "RUNNING" -Cmd "Import-Csv" -Keys @("Path") -Values @($Path)
                & $ProxyImportCsv -Path $Path -OriginalCommand $Global:originalImportCsv
            }
            Set-Item -Path Function:Import-Module -Value {
                param([String[]]$Name)
                Print -Status "RUNNING" -Cmd "Import-Module" -Keys @("Name") -Values @($Name)
                & $ProxyImportModule -Name $Name -OriginalCommand $Global:originalImportModule
            }

            Set-Item -Path Function:Add_Log -Value {
                param([String]$Path, [switch]$N, [switch]$W, [switch]$E, [Parameter(ValueFromPipeline = $true)][String[]]$Message)
                Print -Status "RUNNING" -Cmd "Add_Log" -Keys @("Path", "Message", {IIF ($N, "N", "")}, {IIF ($W, "W", "")}, {IIF ($W, "W", "")}) -Values @($Path, $Message, "", "", "")
                & $ProxyAddLog -Path $Path -N $N -W $W -E $E -Message $ Message -OriginalCommand $Global:originalAddLog
            }
            Set-Item -Path Function:Add_File -Value {
                param([String]$Path, [String]$Encoding, [Parameter(ValueFromPipeline = $true)][String[]]$Message)
                Print -Status "RUNNING" -Cmd "Add_File" -Keys @("Path", "Encoding", "Message") -Values @($Path, $Encoding, $Message)
                & $ProxyAddFile -Path $Path -Encoding $Encoding -Message $Message -OriginalCommand $Global:originalAddFile
            }
            Set-Item -Path Function:Read_Xml -Value {
                param([String]$Path, [Parameter(ValueFromPipeline = $true)][String]$Key)
                Print -Status "RUNNING" -Cmd "Read_Xml" -Keys @("Path", "Key") -Values @($Path, $Message)
                & $ProxyReadXml -Path $Path -Key $Key -OriginalCommand $Global:originalReadXml
            }

            Print -Status "PREPARE" -Message "Command substitution is successful"

            # 全局变量
            [String[]]$Global:TruePaths = $T
            [String[]]$Global:VirtualPaths = $V
            Print -Status "PREPARE" -Cmd "ENVERIMENT" -Keys $VirtualPaths -Values $TruePaths
            Print -Status "PREPARE" -Message "Block invoke start"

            $host.UI.RawUI.ForegroundColor = "Black"
            $host.UI.WriteLine("*****************************************************************************")

            try {
                $ReturnValue = & $SimulationBlock
            }
            catch {
                Print -Status "ERROR" -Errors "$_"
            }
            
            $host.UI.RawUI.ForegroundColor = "Black"
            $host.UI.WriteLine("-----------------------------------------------------------------------------")
            Print -Status "RUNNING" -Cmd "Return : [$ReturnValue]"
        }
        catch {
            Print -Status "DESTRUCTION" -Errors "$_.Exception"
        }
        finally {
            $host.UI.RawUI.ForegroundColor = "Black"
            $host.UI.WriteLine("*****************************************************************************")
            Print -Status "AFTER" -Message "Block invoke over"
            Read-Host "Please input any key to exit"
            Stop-Process -Id $PID
        }
    }
}

function Script:Print {
    param (
        [String]$Item = "SimulationSimpleTest",
        [String]$Status = "",
        [String]$Cmd = "",
        [String]$Message = "",
        [String[]]$Keys = @(),
        [psobject[]]$Values = @(),
        [String]$Errors = ""
    )
    process {
        $host.UI.RawUI.BackgroundColor = "Black"
        $DateTime = [DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss.fff")
        $host.UI.RawUI.ForegroundColor = "White"
        $host.UI.Write("$DateTime ")
        if ($Item) {
            $host.UI.RawUI.ForegroundColor = "Blue"
            $host.UI.Write("[$Item] ")
        }
        if ($Status) {
            $host.UI.RawUI.ForegroundColor = "Cyan"
            $host.UI.Write("[$Status] ")
        }
        if ($Cmd) {
            $host.UI.RawUI.ForegroundColor = "Yellow"
            $host.UI.Write("$Cmd ")
        }
        if ($Message) {
            $host.UI.RawUI.ForegroundColor = "White"
            $host.UI.Write("$Message ")
        }
        if ($Keys.Length -gt 0 -and $Values.Length -gt 0) {
            for ([int]$i = 0; $i -lt $Keys.Length; $i++) {
                $host.UI.RawUI.ForegroundColor = "White"
                $host.UI.Write("${Keys[$i]} ")
                $host.UI.RawUI.ForegroundColor = "Black"
                $host.UI.Write("${Values[$i]} ")
            }
        }
        if ($Errors) {
            $host.UI.RawUI.ForegroundColor = "Red"
            $host.UI.Write("$Errors ")
        }
        $host.UI.RawUI.ForegroundColor = "White"
        $host.UI.WriteLine()
    }
}

$Global:ChangePaths = {
    param(
        [String[]]$OldPaths
    )
    process {
        for ([int]$i = 0; $i -lt $OldPaths.Length; $i++) {
            $OldPaths[$i] = & $ChangePath -OldPath $OldPaths[$i]
        }
        return $OldPaths
    }
}

$Global:ChangePath = {
    param(
        [String]$OldPath
    )
    process {
        for ($i = 0; $i -lt $VirtualPaths.Length; $i++) {
            if ($OldPath.StartsWith($VirtualPaths[$i])) {
                # 只在匹配时输出一次新路径
                [String]$NewPath = $OldPath -replace "^$([regex]::Escape($VirtualPaths[$i]))", $TruePaths[$i]
                return $NewPath
            }
        }
        # 如果没有匹配到，则返回原始路径
        return $OldPath
    }
}

$Global:RecoveryPaths = {
    param(
        [String[]]$OldPaths
    )
    process {
        for ([int]$i = 0; $i -lt $OldPaths.Length; $i++) {
            $OldPaths[$i] = & $RecoveryPath -OldPath $OldPaths[$i]
        }
        return $OldPaths
    }
}

$Global:RecoveryPath = {
    param(
        [String]$OldPath
    )
    process {
        for ($i = 0; $i -lt $TruePaths.Length; $i++) {
            if ($OldPath.StartsWith($TruePaths[$i])) {
                # 只在匹配时输出一次新路径
                [String]$NewPath = $OldPath -replace "^$([regex]::Escape($TruePaths[$i]))", $VirtualPaths[$i]
                return $NewPath
            }
        }
        # 如果没有匹配到，则返回原始路径
        return $OldPath
    }
}

$Global:ProxyTestPath = {
    param (
        [String[]]$Path,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyJoinPath = {
    param (
        [String[]]$Path,
        [String]$ChildPath,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path -ChildPath $ChildPath
            $result = & $RecoveryPaths -OldPaths $result
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxySplitPath = {
    param (
        [String[]]$Path,
        [switch]$Parent,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            if ($Parent) {
                $result = & $OriginalCommand -Path $N_Path -Parent $Parent
            } else {
                $result = & $OriginalCommand -Path $N_Path
            }
            $result = & $RecoveryPaths -OldPaths $result
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyGetContent = {
    param (
        [string[]]$Path,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxySetContent = {
    param (
        [string[]]$Path,
        [Object[]]$Value,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path -Value $Value
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyAddContent = {
    param (
        [string[]]$Path,
        [Object[]]$Value,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path -Value $Value
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyClearContent = {
    param (
        [string[]]$Path,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyRemoveItem = {
    param (
        [string[]]$Path,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyCopyItem = {
    param (
        [string[]]$Path,
        [String[]]$Destination,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path -Destination $Destination
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyMoveItem = {
    param (
        [string[]]$Path,
        [String[]]$Destination,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path -Destination $Destination
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyNewItem = {
    param (
        [string[]]$Path,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyGetItem = {
    param (
        [string[]]$Path,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyGetItemProperty = {
    param (
        [string[]]$Path,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyGetChildItem = {
    param (
        [string[]]$Path,
        [switch]$Recurse,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            if ($Recurse) {
                $result = & $OriginalCommand -Path $N_Path -Recurse
            } else {
                $result = & $OriginalCommand -Path $N_Path
            }
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxySetLocation = {
    param (
        [string]$Path,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePath -OldPath $Path
            $result = & $OriginalCommand -Path $N_Path
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyOutFile = {
    param (
        [string]$FilePath,
        [psobject]$InputObject,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePath -OldPath $FilePath
            $result = & $OriginalCommand -FilePath $N_Path -InputObject $InputObject
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyExportCsv = {
    param (
        [psobject]$InputObject,
        [String]$Path,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePath -OldPath $Path
            $result = & $OriginalCommand -Path $N_Path -InputObject $InputObject
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyImportCsv = {
    param (
        [string[]]$Path,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Path
            $result = & $OriginalCommand -Path $N_Path
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyImportModule = {
    param (
        [string[]]$Name,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $Name
            $result = & $OriginalCommand -Name $N_Path
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyAddLog = {
    param (
        [string]$Path,
        [switch]$N,
        [switch]$W,
        [switch]$E,
        [String[]]$Message,
        $OriginalCommand
    )
    process {
        try {
            Write-Host "ProxyAddLog [Path] $Path"
            $N_Path = & $ChangePath -OldPath $Path
            if ($N) {
                $result = & $OriginalCommand -Path $N_Path -N -Message $Message
                return $result
            }
            if ($W) {
                $result = & $OriginalCommand -Path $N_Path -W -Message $Message
                return $result
            }
            if ($E) {
                $result = & $OriginalCommand -Path $N_Path -E -Message $Message
                return $result
            }
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyAddFile = {
    param (
        [string]$Path,
        [String]$Encoding,
        [String[]]$Message,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePath -OldPath $Path
            if ($Encoding) {
                $result = & $OriginalCommand -Path $N_Path -Encoding $Encoding -Message $Message
            } else {
                $result = & $OriginalCommand -Path $N_Path -Message $Message
            }
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyReadXml = {
    param (
        [string]$Path,
        [String]$Key,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePath -OldPath $Path
            $result = & $OriginalCommand -Path $N_Path -Key $Key
            return $result
        }
        catch {
            Print -Status "ERROR" -Errors $_
        }
    }
}