$ScriptPath = $MyInvocation.MyCommand.path
$ParentPath = Split-Path $ScriptPath -Parent
$Global:BASE_PATH = Split-Path $ParentPath -Parent

Import-Module -Name @(
    "$BASE_PATH\X-drive\opt\Scripts\Common\LogOutput.psm1",
    "$BASE_PATH\X-drive\opt\Scripts\Common\XmlRead.psm1",
    "$BASE_PATH\TEST_TOOL\Functions.psm1"
)

function Script:PrintConsole {
    param (
        [String]$Item = "Test",
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
        if ($Keys -and $Values) {
            for ([int]$i = 0; $i -lt $Keys.Length; $i++) {
                $host.UI.RawUI.ForegroundColor = "White"
                $Key = $Keys[$i]
                $host.UI.Write("$Key ")
                $host.UI.RawUI.ForegroundColor = "Black"

                $Values[$i] | ForEach-Object {
                    $Value = DivePath -TP $_
                    $host.UI.Write("$Value ")
                }
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

function Global:FloatingPaths {
    param(
        [String[]]$VP
    )
    process {
        for ([int]$i = 0; $i -lt $VirtualPaths.Length; $i++) {
            if ($VP.StartsWith($VirtualPaths[$i])) {
                return $VP -replace "^$([regex]::Escape($VirtualPaths[$i]))", $TruePaths[$i]
            }
        }
        return $VP
    }
}

function Global:DivePath {
    param(
        [String[]]$TP
    )
    process {
        for ($i = 0; $i -lt $TruePaths.Length; $i++) {
            if ($TP.StartsWith($TruePaths[$i])) {
                return $TP -replace "^$([regex]::Escape($TruePaths[$i]))", $VirtualPaths[$i]
            }
        }
        return $TP
    }
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
$Global:originallSelectString = Get-Command Select-String
$Global:originallSelectXml = Get-Command Select-Xml

$Global:originalAddLog = ${function:Add_Log}
$Global:originalAddFile = ${function:Add_File}
$Global:originalReadXml = ${function:Read_Xml}

PrintConsole -Status "PREPARE" -Message "Command extraction is successful"

# 替换原始命令
Set-Item -Path Function:Test-Path -Value {
    param(
        [Parameter(ValueFromPipeline = $true)][String[]]$Path
    )
    PrintConsole -Status "RUNNING" -Cmd "Test-Path" -Keys @("Path") -Values @($Path)
    $result = & $ProxyTestPath -OriginalCommand $Global:originalTestPath -Path $Path
    PrintConsole -Status "RUNNING" -Cmd "Test-Path" -Keys @("RESULT") -Values @($result)
    return $result
}
Set-Item -Path Function:Join-Path -Value {
    param(
        [String[]]$Path,
        [String]$ChildPath
    )
    PrintConsole -Status "RUNNING" -Cmd "Join-Path" -Keys @("Path", "ChildPath") -Values @($Path, $ChildPath)
    $result = & $ProxyJoinPath -OriginalCommand $Global:originalJoinPath -Path $Path -ChildPath $ChildPath
    PrintConsole -Status "RUNNING" -Cmd "Join-Path" -Keys @("RESULT") -Values @($result)
    return $result
}
Set-Item -Path Function:Split-Path -Value {
    param(
        [String[]]$Path,
        [switch]$Parent
    )
    if ($Parent) {
        $result = & $ProxySplitPath -OriginalCommand $Global:originalSplitPath -Path $Path -Parent
    } else {
        $result = & $ProxySplitPath -OriginalCommand $Global:originalSplitPath -Path $Path
    }
    PrintConsole -Status "RUNNING" -Cmd "Split-Path" -Keys @("Path", "Parent") -Values @($Path, $Parent)
    # PrintConsole -Status "RUNNING" -Cmd "Split-Path" -Keys @("RESULT") -Values @($result)
    return $result
}
Set-Item -Path Function:Get-Content -Value {
    param(
        [Parameter(ValueFromPipeline = $true)][String[]]$Path
    )
    $result = & $ProxyGetContent -OriginalCommand $Global:originalGetContent -Path $Path
    PrintConsole -Status "RUNNING" -Cmd "Get-Content" -Keys @("Path") -Values @($Path)
    return $result
}
Set-Item -Path Function:Set-Content -Value {
    param(
        [String[]]$Path,
        [Parameter(ValueFromPipeline = $true)][Object[]]$Value
    )
    $result = & $ProxySetContent -OriginalCommand $Global:originalSetContent -Path $Path -Value $Value
    PrintConsole -Status "RUNNING" -Cmd "Set-Content" -Keys @("Path", "Value") -Values @($Path, $Value)
    return $result
}
Set-Item -Path Function:Add-Content -Value {
    param(
        [String[]]$Path,
        [Parameter(ValueFromPipeline = $true)][Object[]]$Value
    )
    PrintConsole -Status "RUNNING" -Cmd "Add-Content" -Keys @("Path", "Value") -Values @($Path, $Value)
    $result = & $ProxyAddContent -OriginalCommand $Global:originalAddContent -Path $Path -Value $Value
    return $result
}
Set-Item -Path Function:Clear-Content -Value {
    param(
        [String[]]$Path
    )
    PrintConsole -Status "RUNNING" -Cmd "Clear-Content" -Keys @("Path") -Values @($Path)
    $result = & $ProxyClearContent -OriginalCommand $Global:originalClearContent -Path $Path
    return $result
}
Set-Item -Path Function:Remove-Item -Value {
    param(
        [Parameter(ValueFromPipeline = $true)][String[]]$Path
    )
    PrintConsole -Status "RUNNING" -Cmd "Remove-Item" -Keys @("Path") -Values @($Path)
    $result = & $ProxyRemoveItem -OriginalCommand $Global:originalRemoveItem -Path $Path
    return $result
}
Set-Item -Path Function:Copy-Item -Value {
    param(
        [Parameter(ValueFromPipeline = $true)][String[]]$Path,
        [String]$Destination
    )
    PrintConsole -Status "RUNNING" -Cmd "Copy-Item" -Keys @("N_Path", "Destination") -Values @($Path, $Destination)
    $result = & $ProxyCopyItem -OriginalCommand $Global:originalCopyItem -Path $Path -Destination $Destination
    return $result
}
Set-Item -Path Function:Move-Item -Value {
    param(
        [Parameter(ValueFromPipeline = $true)][String[]]$Path,
        [String]$Destination
    )
    PrintConsole -Status "RUNNING" -Cmd "Move-Item" -Keys @("Path", "Destination") -Values @($Path, $Destination)
    $result = & $ProxyMoveItem -OriginalCommand $Global:originalMoveItem -Path $Path -Destination $Destination
    return $result
}
Set-Item -Path Function:New-Item -Value {
    param(
        [Parameter(ValueFromPipeline = $true)][String[]]$Path
    )
    PrintConsole -Status "RUNNING" -Cmd "New-Item" -Keys @("Path") -Values @($Path)
    $result = & $ProxyNewItem -OriginalCommand $Global:originalNewItem -Path $Path 
    return $result
}
Set-Item -Path Function:Get-Item -Value {
    param(
        [String[]]$Path
    )
    PrintConsole -Status "RUNNING" -Cmd "Get-Item" -Keys @("Path") -Values @($Path)
    $result = & $ProxyGetItem -OriginalCommand $Global:originalGetItem -Path $Path
    return $result
}
Set-Item -Path Function:Get-ItemProperty -Value {
    param(
        [String[]]$Path
    )
    PrintConsole -Status "RUNNING" -Cmd "Get-ItemProperty" -Keys @("Path") -Values @($Path)
    $result = & $ProxyGetItemProperty -OriginalCommand $Global:originalGetItemProperty -Path $Path
    return $result
}
Set-Item -Path Function:Get-ChildItem -Value {
    param(
        [Parameter(ValueFromPipeline = $true)][String[]]$Path,
        [switch]$Recurse
    )
    if ($Recurse) {
        $result = & $ProxyGetChildItem -OriginalCommand $Global:originalGetChildItem -Path $Path -Recurse
    } else {
        $result = & $ProxyGetChildItem -OriginalCommand $Global:originalGetChildItem -Path $Path
    }
    PrintConsole -Status "RUNNING" -Cmd "Get-ChildItem" -Keys @("Path", "Recurse") -Values @($Path, $Recurse)
    return $result
}
Set-Item -Path Function:Set-Location -Value {
    param(
        [String]$Path
    )
    $result = & $ProxySetLocation -OriginalCommand $Global:originalSetlocation -Path $Path
    PrintConsole -Status "RUNNING" -Cmd "Set-Location" -Keys @("Path") -Values @($Path)
    return $result
}
Set-Item -Path Function:Out-File -Value {
    param(
        [String]$FilePath,
        [Parameter(ValueFromPipeline = $true)][psobject]$InputObject
    )
    $result = & $ProxyOutFile -OriginalCommand $Global:originalOutFile -FilePath $FilePath -InputObject $InputObject
    PrintConsole -Status "RUNNING" -Cmd "Out-File" -Keys @("FilePath", "InputObject") -Values @($Path, $InputObject)
    return $result
}
Set-Item -Path Function:Export-Csv -Value {
    param(
        [String]$Path,
        [psobject]$InputObject
    )
    $result = & $ProxyExportCsv -OriginalCommand $Global:originalExportCsv -InputObject $InputObject -Path $Path
    PrintConsole -Status "RUNNING" -Cmd "Export-Csv" -Keys @("Path", "InputObject") -Values @($Path, $InputObject)
    return $result
}
Set-Item -Path Function:Import-Csv -Value {
    param(
        [String[]]$Path
    )
    $result = & $ProxyImportCsv -OriginalCommand $Global:originalImportCsv -Path $Path 
    PrintConsole -Status "RUNNING" -Cmd "Import-Csv" -Keys @("Path") -Values @($Path)
    return $result
}
Set-Item -Path Function:Import-Module -Value {
    param(
        [String[]]$Name
    )
    PrintConsole -Status "RUNNING" -Cmd "Import-Module" -Keys @("Name") -Values @($Name)
    & $ProxyImportModule -OriginalCommand $Global:originalImportModule -Name $Name 
}

Set-Item -Path Function:Add_Log -Value {
    param(
        [String]$Path,
        [Parameter(ValueFromPipeline = $true)][String[]]$Message,
        [switch]$N,
        [switch]$W,
        [switch]$E
    )
    
    if ($N) {
        & $ProxyAddLog -OriginalCommand $Global:originalAddLog -Path $Path -Message $Message -N
    }
    if ($W) {
        & $ProxyAddLog -OriginalCommand $Global:originalAddLog -Path $Path -Message $Message -W
    }
    if ($E) {
        & $ProxyAddLog -OriginalCommand $Global:originalAddLog -Path $Path -Message $Message -E
    }
    PrintConsole -Status "RUNNING" -Cmd "Add_Log" -Keys @("Path", "Message", "N", "W", "W") -Values @($Path, $Message, $N, $W, $E)
}
Set-Item -Path Function:Add_File -Value {
    param(
        [String]$Path,
        [switch]$Append,
        [Parameter(ValueFromPipeline = $true)][String[]]$Content
    )
    PrintConsole -Status "RUNNING" -Cmd "Add_File" -Keys @("Path", "Append", "Content") -Values @($Path, $Append, $Content)
    if ($Append) {
        & $ProxyAddFile -OriginalCommand $Global:originalAddFile -Path $Path -Content $Content -Append
    } else {
        & $ProxyAddFile -OriginalCommand $Global:originalAddFile -Path $Path -Content $Content
    }
}
Set-Item -Path Function:Read_Xml -Value {
    param(
        [String]$Path,
        [Parameter(ValueFromPipeline = $true)][String]$Key
    )
    PrintConsole -Status "RUNNING" -Cmd "Read_Xml" -Keys @("Path", "Key") -Values @($Path, $Key)
    $result = & $ProxyReadXml -OriginalCommand $Global:originalReadXml -Path $Path -Key $Key 
    PrintConsole -Status "RUNNING" -Cmd "Read_Xml" -Keys @("RETURN") -Values @($result)
    return $result
}

PrintConsole -Status "PREPARE" -Message "Command substitution is successful"

$Global:ProxyTestPath = {
    param (
        [String[]]$Path,
        $OriginalCommand
    )
    process {
        try {
            $result = & $OriginalCommand -Path $Path
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            & $OriginalCommand -Path $Path -ChildPath $ChildPath
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            if ($Parent) {
                $result = & $OriginalCommand -Path $Path -Parent $Parent
            } else {
                $result = & $OriginalCommand -Path $Path
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path -Value $Value
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path -Value $Value
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path -Destination $Destination
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path -Destination $Destination
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            if ($Recurse) {
                $result = & $OriginalCommand -Path $Path -Recurse
            } else {
                $result = & $OriginalCommand -Path $Path
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -FilePath $FilePath -InputObject $InputObject
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path -InputObject $InputObject
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            $result = & $OriginalCommand -Path $Path
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            & $OriginalCommand -Name $Name
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
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
            if ($N) {
                & $OriginalCommand -Path $Path -N -Message $Message
            }
            if ($W) {
                & $OriginalCommand -Path $Path -W -Message $Message
            }
            if ($E) {
                & $OriginalCommand -Path $Path -E -Message $Message
            }
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyAddFile = {
    param (
        [string]$Path,
        [switch]$Append,
        [String[]]$Content,
        $OriginalCommand
    )
    process {
        try {
            if ($Append) {
                & $OriginalCommand -Path $Path -Append -Content $Content
            } else {
                & $OriginalCommand -Path $Path -Content $Content
            }
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
        }
    }
}

$Global:ProxyReadXml = {
    param (
        [string]$Path,
        [String]$Key,
        [function]$OriginalCommand
    )
    process {
        try {
            $results = & $OriginalCommand -Path $Path -Key $Key
            $newResults = @()
            foreach ($result in $results) {
                $newResults += FloatingPath -VP $result
                $host.UI.RawUI.ForegroundColor = "Red"
                $host.UI.WriteLine($result)
            }
            return $newResults
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_
        }
    }
}

function Global:SimulationSimpleTest {
    param(
        [Parameter(ValueFromPipeline = $true)][ScriptBlock]$SimulationBlock,
        [String[]]$T,
        [String[]]$V
    )
    process {
        try {
            PrintConsole -Status "PREPARE" -Message "Function start"
            if ($null -eq $T -or $null -eq $V) {
                PrintConsole -Status "VERIFICATION" -Errors "TruePaths or VirtualPaths is null"
                return
            }
            if ($T.Length -eq 0 -or $V.Length -eq 0) {
                PrintConsole -Status "VERIFICATION" -Errors "TruePaths or VirtualPaths length must be greater than 0"
                return
            }
            if ($T.Length -ne $V.Length) {
                PrintConsole -Status "VERIFICATION" -Errors "TruePaths and VirtualPaths must be of equal length"
                return
            }
        
            foreach ($path in $T) {
                if (-not [System.IO.Directory]::Exists($path)) {
                    PrintConsole -Status "VERIFICATION" -Errors "[$path] is not a valid path."
                    return
                }
            }
            
            if (-not $SimulationBlock) {
                PrintConsole -Status "VERIFICATION" -Errors "SimulationBlock is empty"
                return
            }
            

            # 全局变量
            [String[]]$Global:TruePaths = ${T}
            [String[]]$Global:VirtualPaths = ${V}
            for ([int]$i =0; $i -lt $VirtualPaths.Length; $i++) {
                $host.UI.RawUI.ForegroundColor = "White"
                $host.UI.Write("----------------------- Virtual[$i] ")
                $host.UI.RawUI.ForegroundColor = "Magenta"
                $host.UI.Write($VirtualPaths[$i])
                $host.UI.RawUI.ForegroundColor = "White"
                $host.UI.Write(" True[$i] ")
                $host.UI.RawUI.ForegroundColor = "Black"
                $host.UI.WriteLine($TruePaths[$i])

            }

            PrintConsole -Status "PREPARE" -Message "Block invoke start"

            $host.UI.RawUI.ForegroundColor = "Black"
            $host.UI.WriteLine("*****************************************************************************")

            try {
                $ReturnValue = & $SimulationBlock
            }
            catch {
                PrintConsole -Status "ERROR" -Errors "$_"
            }
            
            $host.UI.RawUI.ForegroundColor = "Black"
            $host.UI.WriteLine("-----------------------------------------------------------------------------")
            PrintConsole -Status "RUNNING" -Cmd "Return : [$ReturnValue]"
        }
        catch {
            PrintConsole -Status "DESTRUCTION" -Errors "$_.Exception"
        }
        finally {
            $host.UI.RawUI.ForegroundColor = "Black"
            $host.UI.WriteLine("*****************************************************************************")
            PrintConsole -Status "AFTER" -Message "Block invoke over"
            Read-Host "Please input any key to exit"
            Stop-Process -Id $PID
        }
    }
}

