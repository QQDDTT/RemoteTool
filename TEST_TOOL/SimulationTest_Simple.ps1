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
        if ($Errors) {
            $host.UI.RawUI.ForegroundColor = "Red"
            $host.UI.Write("$Errors ")
        }

        if ($Keys -and $Values) {
            for ([int]$i = 0; $i -lt $Keys.Length; $i++) {
                $host.UI.RawUI.ForegroundColor = "White"
                $Key = $Keys[$i]
                $host.UI.Write("$Key ")
                $host.UI.RawUI.ForegroundColor = "Black"
                $Values[$i] | ForEach-Object {
                    try {
                        $Value = DivePath -TP $_
                        $host.UI.Write("$Value ")
                    } catch {
                        $host.UI.Write("null ")
                    }
                }
            }
        }
        $host.UI.RawUI.ForegroundColor = "White"
        $host.UI.WriteLine()
    }
}

function Global:FloatingPath {
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
$Global:originalClearContent = Get-Command Clear-Content # 清空文件内容，但不删除文件
$Global:originalRemoveItem = Get-Command Remove-Item
$Global:originalCopyItem = Get-Command Copy-Item
$Global:originalMoveItem = Get-Command Move-Item
$Global:originalNewItem = Get-Command New-Item
$Global:originalGetItem = Get-Command Get-Item
$Global:originalRenameItem = Get-Command Rename-Item
$Global:originalGetItemProperty = Get-Command Get-ItemProperty # 获取注册表项或文件属性
$Global:originalRemoveItemProperty = Get-Command Remove-ItemProperty # 删除注册表项属性
$Global:originalGetChildItem = Get-Command Get-ChildItem
$Global:originalSetlocation = Get-Command Set-Location # 更改当前工作目录
$Global:originalOutFile = Get-Command Out-File # 将输出写入文件
$Global:originalExportCsv = Get-Command Export-Csv # 将对象导出为 CSV 文件
$Global:originalImportCsv = Get-Command Import-Csv # 从 CSV 文件导入对象
$Global:originalImportModule = Get-Command Import-Module
$Global:originallSelectString = Get-Command Select-String
$Global:originallSelectXml = Get-Command Select-Xml

$Global:originalAddLog = ${function:Add_Log}
$Global:originalReadXml = ${function:Read_Xml}

$Global:originalGetProcess = Get-Command Get-Process # 查看当前正在运行的进程
$Global:originalStopProcess = Get-Command Stop-Process # 终止指定的进程
$Global:originalGetService = Get-Command Get-Service # 列出系统中的所有服务及其状态
$Global:originalStartService = Get-Command Start-Service # 启动指定的服务
$Global:originalStopService = Get-Command Stop-Service # 停止指定的服务
$Global:originalGetEventLog = Get-Command Get-EventLog # 查看系统事件日志
$Global:originalGetAlias = Get-Command Get-Alias # 获取命令的别名或查看所有可用别名
$Global:originalMeasureObject = Get-Command Measure-Object # 计算对象的数量、最小值、最大值、平均值等
$Global:originalSelectObject = Get-Command Select-Object # 选择对象的特定属性
$Global:originalWhereObject = Get-Command Where-Object # 根据条件过滤对象

# $Global:originalSortObject = Get-Command Sort-Object # 对对象进行排序
# $Global:originalForEachObject = Get-Command ForEach-Object
# $Global:originalStartJob = Get-Command Start-Job # 启动后台作业，异步执行任务
# $Global:originalReceiveJob = Get-Command Receive-Job # 获取后台作业的输出
# $Global:originalStopJob = Get-Command Stop-Job # 终止正在运行的后台作业
# $Global:originalGetJob = Get-Command Get-Job 
# $Global:originalGetDate = Get-Command Get-Date # 获取当前日期和时间
# $Global:originalSetDate = Get-Command Set-Date # 设置系统日期和时间
# $Global:originalCompressArchive = Get-Command Compress-Archive # 将文件或目录压缩为 ZIP 文件
# $Global:originalExpandArchive = Get-Command Expand-Archive # 解压 ZIP 文件
# $Global:originalStartProcess = Get-Command Start-Process # 启动指定的进程
# $Global:originalGetACL = Get-Command Get-ACL # 获取文件或目录的访问控制列表（ACL）
# $Global:originalSetACL = Get-Command Set-ACL # 设置文件或目录的访问控制列表（ACL）
# $Global:originalTestNetConnection = Get-Command Test-NetConnection # 测试网络连接，类似于 ping 或 tracert
# $Global:originalNewScheduledTask = Get-Command New-ScheduledTask # 创建计划任务
# $Global:originalGetScheduledTask = Get-Command Get-ScheduledTask # 列出所有计划任务

PrintConsole -Status "PREPARE" -Message "Command extraction is successful"

# 替换原始命令
Set-Item -Path Function:Test-Path -Value {
    param (
        [Parameter(ValueFromPipeline = $true)][String[]]$Path
    )
    PrintConsole -Status "RUNNING" -Cmd "Test-Path" -Keys @("Path") -Values @($Path)
    $result = & $ProxyTestPath -OriginalCommand $Global:originalTestPath -Path $Path
    PrintConsole -Status "RUNNING" -Cmd "Test-Path" -Keys @("RESULT") -Values @($result)
    return $result
}
Set-Item -Path Function:Join-Path -Value {
    param (
        [String[]]$Path,
        [String]$ChildPath
    )
    PrintConsole -Status "RUNNING" -Cmd "Join-Path" -Keys @("Path", "ChildPath") -Values @($Path, $ChildPath)
    $result = & $ProxyJoinPath -OriginalCommand $Global:originalJoinPath -Path $Path -ChildPath $ChildPath
    PrintConsole -Status "RUNNING" -Cmd "Join-Path" -Keys @("RESULT") -Values @($result)
    return $result
}
Set-Item -Path Function:Split-Path -Value {
    param (
        [String[]]$Path,
        [switch]$Parent
    )
    PrintConsole -Status "RUNNING" -Cmd "Split-Path" -Keys @("Path", "Parent") -Values @($Path, $Parent)
    if ($Parent) {
        $result = & $ProxySplitPath -OriginalCommand $Global:originalSplitPath -Path $Path -Parent
    } else {
        $result = & $ProxySplitPath -OriginalCommand $Global:originalSplitPath -Path $Path
    }
    PrintConsole -Status "RUNNING" -Cmd "Split-Path" -Keys @("RESULT") -Values @($result)
    return $result
}
Set-Item -Path Function:Get-Content -Value {
    param (
        [Parameter(ValueFromPipeline = $true)][String[]]$Path
    )
    PrintConsole -Status "RUNNING" -Cmd "Get-Content" -Keys @("Path") -Values @($Path)
    $result = & $ProxyGetContent -OriginalCommand $Global:originalGetContent -Path $Path
    PrintConsole -Status "RUNNING" -Cmd "Get-Content" -Keys @("RESULT") -Values @($result)
    return $result
}
Set-Item -Path Function:Set-Content -Value {
    param (
        [String[]]$Path,
        [Parameter(ValueFromPipeline = $true)][Object[]]$Value
    )
    PrintConsole -Status "RUNNING" -Cmd "Set-Content" -Keys @("Path", "Value") -Values @($Path, $Value)
    & $ProxySetContent -OriginalCommand $Global:originalSetContent -Path $Path -Value $Value
}
Set-Item -Path Function:Add-Content -Value {
    param (
        [String[]]$Path,
        [Parameter(ValueFromPipeline = $true)][Object[]]$Value
    )
    PrintConsole -Status "RUNNING" -Cmd "Add-Content" -Keys @("Path", "Value") -Values @($Path, $Value)
    & $ProxyAddContent -OriginalCommand $Global:originalAddContent -Path $Path -Value $Value
}
Set-Item -Path Function:Clear-Content -Value {
    param (
        [String[]]$Path
    )
    PrintConsole -Status "RUNNING" -Cmd "Clear-Content" -Keys @("Path") -Values @($Path)
    & $ProxyClearContent -OriginalCommand $Global:originalClearContent -Path $Path
}
Set-Item -Path Function:Remove-Item -Value {
    param (
        [Parameter(ValueFromPipeline = $true)][String[]]$Path,
        [switch]$Recurse,
        [switch]$Force
    )
    PrintConsole -Status "RUNNING" -Cmd "Remove-Item" -Keys @("Path", "Recurse", "Force") -Values @($Path, $Recurse, $Force)
    & $ProxyRemoveItem -OriginalCommand $Global:originalRemoveItem -Path $Path -Recurse $Recurse -Force Force
}
Set-Item -Path Function:Copy-Item -Value {
    param (
        [Parameter(ValueFromPipeline = $true)][String[]]$Path,
        [String]$Destination,
        [switch]$Recurse,
        [switch]$Force
    )
    PrintConsole -Status "RUNNING" -Cmd "Copy-Item" -Keys @("N_Path", "Destination", "Recurse", "Force") -Values @($Path, $Destination, $Recurse, $Force)
    & $ProxyCopyItem -OriginalCommand $Global:originalCopyItem -Path $Path -Destination $Destination -Recurse $Recurse -Force $Force
}
Set-Item -Path Function:Move-Item -Value {
    param (
        [Parameter(ValueFromPipeline = $true)][String[]]$Path,
        [String]$Destination,
        [switch]$Force
    )
    PrintConsole -Status "RUNNING" -Cmd "Move-Item" -Keys @("Path", "Destination", "Force") -Values @($Path, $Destination, $Force)
    & $ProxyMoveItem -OriginalCommand $Global:originalMoveItem -Path $Path -Destination $Destination -Force $Force
}
Set-Item -Path Function:New-Item -Value {
    param (
        [Parameter(ValueFromPipeline = $true)][String[]]$Path,
        [Patameter(Mandatory = $false)][String]$ItemType,
        [switch]$Force
    )
    PrintConsole -Status "RUNNING" -Cmd "New-Item" -Keys @("Path", "ItemType", "Force") -Values @($Path, $ItemType, $Force)
    & $ProxyNewItem -OriginalCommand $Global:originalNewItem -Path $Path -ItemType $ItemType -Force $Force
}
Set-Item -Path Function:Get-Item -Value {
    param (
        [String[]]$Path,
        [switch]$Force
    )
    PrintConsole -Status "RUNNING" -Cmd "Get-Item" -Keys @("Path", "Force") -Values @($Path ,$Force)
    $result = & $ProxyGetItem -OriginalCommand $Global:originalGetItem -Path $Path -Force $Force
    PrintConsole -Status "RUNNING" -Cmd "Get-Item" -Keys @("RESULt") -Values @($result)
    return $result
}
Set-Item -Path Function:Rename-Item -Value {
    param (
        [String]$Path,
        [String]$NewName,
        [switch]$Force,
        [switch]$PassThru
    )
    PrintConsole -Status "RUNNING" -Cmd "Rename-Item" -Keys @("Path", "NewName", "Force", "PassThru") -Values @($Path, $NewName ,$Force, $PassThru)
     & $ProxyRenameItem -OriginalCommand $Global:originalRenameItem -Path $Path -NewName $NewName -Force $Force -PassThru $PassThru
}
Set-Item -Path Function:Get-ItemProperty -Value {
    param (
        [String[]]$Path,
        [Patameter(Mandatory = $false)][String[]]$Name,
        [Patameter(Mandatory = $false)][String]$Filter
    )
    PrintConsole -Status "RUNNING" -Cmd "Get-ItemProperty" -Keys @("Path", "Name", "Filter") -Values @($Path, $Name, $Filter)
    $result = & $ProxyGetItemProperty -OriginalCommand $Global:originalGetItemProperty -Path $Path -Name $Name -Filter $Filter
    PrintConsole -Status "RUNNING" -Cmd "Get-ItemProperty" -Keys @("RESULT") -Values @($result)
    return $result
}
Set-Item -Path Function:Remove-ItemProperty -Value {
    param (
    [String[]]$Path,
    [String[]]$Name,
    [String[]]$Include,
    [switch]$Force
    )
    PrintConsole -Status "RUNNING" -Cmd "Remove-ItemProperty" -Keys @("Path", "Name", "Include", "Force") -Values @($Path, $Name, $Include, $Force)
    & $ProxyRemoveItemProperty -OriginalCommand $Global:originalRemoveItemProperty -Path $Path -Name $Name -Include $Include -Force $Force
}
Set-Item -Path Function:Get-ChildItem -Value {
    param (
        [Parameter(ValueFromPipeline = $true)][String[]]$Path,
        [Patameter(Mandatory = $false)][String]$Filter,
        [switch]$Recurse
    )
    PrintConsole -Status "RUNNING" -Cmd "Get-ChildItem" -Keys @("Path", "Filter", "Recurse") -Values @($Path, $Filter, $Recurse)
    $result = & $ProxyGetChildItem -OriginalCommand $Global:originalGetChildItem -Path $Path -Filter $Filter -Recurse $Recurse
    PrintConsole -Status "RUNNING" -Cmd "Get-ChildItem" -Keys @("RESULT") -Values @($result)
    return $result
}
Set-Item -Path Function:Set-Location -Value {
    param (
        [String]$Path,
        [switch]$PassThru,
        [switch]$UseTransaction
    )
    $result = & $ProxySetLocation -OriginalCommand $Global:originalSetlocation -Path $Path -PassThru $PassThru -UseTransaction $UseTransaction
    PrintConsole -Status "RUNNING" -Cmd "Set-Location" -Keys @("Path", "PassThru", "UseTransaction") -Values @($Path, $PassThru, $UseTransaction)
    return $result
}
Set-Item -Path Function:Out-File -Value {
    param (
        [String]$FilePath,
        [Parameter(ValueFromPipeline = $true, Mandatory = $false)][psobject]$InputObject,
        [switch]$Append
    )
    PrintConsole -Status "RUNNING" -Cmd "Out-File" -Keys @("FilePath", "InputObject", "Append") -Values @($Path, $InputObject, $Append)
    & $ProxyOutFile -OriginalCommand $Global:originalOutFile -FilePath $FilePath -InputObject $InputObject -Append $Append
}
Set-Item -Path Function:Export-Csv -Value {
    param (
        [String]$Path,
        [Parameter(ValueFromPipeline = $true)][psobject]$InputObject,
        [switch]$Append
    )
    PrintConsole -Status "RUNNING" -Cmd "Export-Csv" -Keys @("Path", "InputObject") -Values @($Path, $InputObject)
    & $ProxyExportCsv -OriginalCommand $Global:originalExportCsv -InputObject $InputObject -Path $Path -Append $Append
}
Set-Item -Path Function:Import-Csv -Value {
    param (
        [String[]]$Path,
        [Parameter(Mandatory = $false)][String[]]$Header
    )
    PrintConsole -Status "RUNNING" -Cmd "Import-Csv" -Keys @("Path", "Header") -Values @($Path, $Header)
    $result = & $ProxyImportCsv -OriginalCommand $Global:originalImportCsv -Path $Path -Header $Header
    PrintConsole -Status "RUNNING" -Cmd "Import-Csv" -Keys @("RESULT") -Values @($result)
    return $result
}
Set-Item -Path Function:Import-Module -Value {
    param (
        [String[]]$Name,
        [switch]$Global,
        [Parameter(Mandatory = $false)][String[]]$Function
    )
    PrintConsole -Status "RUNNING" -Cmd "Import-Module" -Keys @("Name", "Global", "Function") -Values @($Name, $Global, $Function)
    & $ProxyImportModule -OriginalCommand $Global:originalImportModule -Name $Name -Global $Global -Function $Function
}


Set-Item -Path Function:Add_Log -Value {
    param (
        [String]$Path,
        [Parameter(ValueFromPipeline = $true)][String[]]$Message,
        [switch]$N,
        [switch]$W,
        [switch]$E
    )
    PrintConsole -Status "RUNNING" -Cmd "Add_Log" -Keys @("Path", "Message", "N", "W", "E") -Values @($Path, $Message, $N, $W, $E)
    & $ProxyAddLog -OriginalCommand $Global:originalAddLog -Path $Path -Message $Message -N $N -W $W -E $E
}
Set-Item -Path Function:Read_Xml -Value {
    param (
        [String]$Path,
        [Parameter(ValueFromPipeline = $true)][String]$Key
    )
    PrintConsole -Status "RUNNING" -Cmd "Read_Xml" -Keys @("Path", "Key") -Values @($Path, $Key)
    $result = & $ProxyReadXml -OriginalCommand $Global:originalReadXml -Path $Path -Key $Key 
    PrintConsole -Status "RUNNING" -Cmd "Read_Xml" -Keys @("RETURN") -Values @($result)
    return $result
}


Set-Item -Path Function:Get-Process -Value {
    param (
        [Parameter(Mandatory = $false)][String[]]$Name,
        [Parameter(Mandatory = $false)][int[]]$Id,
        [Parameter(Mandatory = $false)][String[]]$ComputerName
    )
    PrintConsole -Status "RUNNING" -Cmd "Get-Process" -Keys @("Name", "Id", "ComputerName") -Values @($Name, $Id, $ComputerName)
    $result = & $ProxyGetProcess -OriginalCommand $Global:originalGetProcess -Name $Name -Id $Id -ComputerName $ComputerName
    PrintConsole -Status "RUNNING" -Cmd "Read_Xml" -Keys @("RETURN") -Values @($result)
    return $result
}
Set-Item -Path Function:Stop-Process -Value {
    param (
        [Parameter(Mandatory = $false)][int[]]$Id,
        [Parameter(Mandatory = $false)][String[]]$Name
    )
    PrintConsole -Status "RUNNING" -Cmd "Get-Process" -Keys @("Name", "Id") -Values @($Name, $Id)
    & $ProxyStopProcess -OriginalCommand $Global:originalStopProcess -Name $Name -Id $Id
}
Set-Item -Path Function:Get-Service -Value {
    param (
        [Parameter(Mandatory = $false)][String[]]$Name,
        [Parameter(Mandatory = $false)][String[]]$ComputerName
    )
    PrintConsole -Status "RUNNING" -Cmd "Get-Service" -Keys @("Name", "ComputerName") -Values @($Name, $ComputerName)
    $result = & $ProxyGetService -OriginalCommand $Global:originalGetService -Name $Name -ComputerName $ComputerName
    PrintConsole -Status "RUNNING" -Cmd "Get-Service" -Keys @("RETURN") -Values @($result)
    return $result
}
Set-Item -Path Function:Start-Service -Value {
    param (
        [Parameter(Mandatory = $false)][String[]]$Name,
        [Parameter(Mandatory = $false)][ServiceController[]]$InputObject
    )
    PrintConsole -Status "RUNNING" -Cmd "Start-Service" -Keys @("Name", "InputObject") -Values @($Name, $InputObject)
    & $ProxyStartService -OriginalCommand $Global:originalStartService -Name $Name -InputObject $InputObject
}
Set-Item -Path Function:Stop-Service -Value {
    param (
        [Parameter(Mandatory = $false)][String[]]$Name,
        [Parameter(Mandatory = $false)][ServiceController[]]$InputObject
    )
    PrintConsole -Status "RUNNING" -Cmd "Stop-Service" -Keys @("Name", "InputObject") -Values @($Name, $InputObject)
    & $ProxyStopService -OriginalCommand $Global:originalStopService -Name $Name -InputObject $InputObject
}
Set-Item -Path Function:Get-EventLog -Value {
    param (
        [String]$LogName,
        [Parameter(Mandatory = $false)][long[]]$InstanceId,
        [Parameter(Mandatory = $false)][String[]]$ComputerName
    )
    PrintConsole -Status "RUNNING" -Cmd "Get-EventLog" -Keys @("LogName", "InputObject", "ComputerName") -Values @($LogName, $InputObject, $ComputerName)
    $result = & $ProxyGetEventLog -OriginalCommand $Global:originalGetEventLog -LogName $LogName -InputObject $InputObject -ComputerName $ComputerName
    PrintConsole -Status "RUNNING" -Cmd "Get-Service" -Keys @("RETURN") -Values @($result)
    return $result
}
Set-Item -Path Function:Get-Alias -Value {
    param (
        [Parameter(Mandatory = $false)][String[]]$Name,
        [switch]$Force
    )
    PrintConsole -Status "RUNNING" -Cmd "Get-Alias" -Keys @("Name", "Force") -Values @($Name, $Force)
    $result = & $ProxyGetAlias -OriginalCommand $Global:originalGetAlias -Name $Name -Force $Force
    PrintConsole -Status "RUNNING" -Cmd "Get-Alias" -Keys @("RETURN") -Values @($result)
    return $result
}
Set-Item -Path Function:Measure-Object -Value {
    param (
        [Parameter(Mandatory = $false)][String[]]$Property,
        [Parameter(ValueFromPipeline = $true, Mandatory = $false)][psobject]$InputObject,
        [switch]$Sum,
        [switch]$Average,
        [switch]$Maximum,
        [switch]$Minimum
    )
    PrintConsole -Status "RUNNING" -Cmd "Measure-Object" -Keys @("Property", "InputObject", "Sum", "Average", "Maximum", "Minimum") -Values @($Property, $InputObject, $Sum, $Average, $Maximum, $Minimum)
    $result = & $ProxyMeasureObject -OriginalCommand $Global:originalMeasureObject -Property $Property -InputObject $InputObject -Sum $Sum -Average $Average -Maximum $Maximum -Minimum $Minimum
    PrintConsole -Status "RUNNING" -Cmd "Measure-Object" -Keys @("RETURN") -Values @($result)
    return $result
}
Set-Item -Path Function:Select-Object -Value {
    param (
        [Parameter(Mandatory = $false)][String[]]$Property,
        [Parameter(ValueFromPipeline = $true, Mandatory = $false)][psobject]$InputObject,
        [switch]$Unique
    )
    PrintConsole -Status "RUNNING" -Cmd "Select-Object" -Keys @("Property", "InputObject", "Unique") -Values @($Property, $InputObject, $Unique)
    $result = & $ProxySelectObject -OriginalCommand $Global:originalSelectObject -Property $Property -InputObject $InputObject -Unique $Unique
    PrintConsole -Status "RUNNING" -Cmd "Select-Object" -Keys @("RETURN") -Values @($result)
    return $result
}
Set-Item -Path Function:Where-Object -Value {
    param (
        [String]$Property,
        [Object]$Value,
        [psobject]$InputObject
    )
    Where-Object
    PrintConsole -Status "RUNNING" -Cmd "Where-Object" -Keys @("Property", "InputObject", "Unique") -Values @($Property, $InputObject, $Unique)
    $result = & $ProxySelectObject -OriginalCommand $Global:originalSelectObject -Property $Property -InputObject $InputObject -Unique $Unique
    PrintConsole -Status "RUNNING" -Cmd "Where-Object" -Keys @("RETURN") -Values @($result)
    return $result
}
# Set-Item -Path Function:Sort-Object -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:ForEach-Object -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Start-Job -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Receive-Job -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Stop-Job -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Get-Job -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Get-Date -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Set-Date -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Compress-Archive -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Expand-Archive -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Start-Process -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Get-ACL -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Set-ACL -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Test-NetConnection -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:New-ScheduledTask -Value {
#     param (
        
#     )
# }
# Set-Item -Path Function:Get-ScheduledTask -Value {
#     param (
        
#     )
# }

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
            PrintConsole -Status "ERROR" -Errors $_.Exception
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
            PrintConsole -Status "ERROR" -Errors $_.Exception
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
            PrintConsole -Status "ERROR" -Errors $_.Exception
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
            PrintConsole -Status "ERROR" -Errors $_.Exception
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
            PrintConsole -Status "ERROR" -Errors $_.Exception
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
            PrintConsole -Status "ERROR" -Errors $_.Exception
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
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyRemoveItem = {
    param (
        [string[]]$Path,
        $Recurse,
        $Force,
        $OriginalCommand
    )
    process {
        try {
            if ($Recurse -and $Force) {
                $result = & $OriginalCommand -Path $Path -Recurse -Force
            } elseif ($Recurse) {
                $result = & $OriginalCommand -Path $Path -Recurse
            } elseif ($Force) {
                $result = & $OriginalCommand -Path $Path -Force
            } else {
                $result = & $OriginalCommand -Path $Path
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyCopyItem = {
    param (
        [string[]]$Path,
        [String[]]$Destination,
        $Recurse,
        $Force,
        $OriginalCommand
    )
    process {
        try {
            if ($Recurse -and $Force) {
                $result = & $OriginalCommand -Path $Path -Destination $Destination -Recurse -Force
            } elseif ($Recurse) {
                $result = & $OriginalCommand -Path $Path -Destination $Destination -Recurse
            } elseif ($Force) {
                $result = & $OriginalCommand -Path $Path -Destination $Destination -Force
            } else {
                $result = & $OriginalCommand -Path $Path -Destination $Destination
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyMoveItem = {
    param (
        [string[]]$Path,
        $Destination,
        $Force,
        $OriginalCommand
    )
    process {
        try {
            if ($Force) {
                $result = & $OriginalCommand -Path $Path -Destination $Destination -Force
            } else {
                $result = & $OriginalCommand -Path $Path -Destination $Destination
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyNewItem = {
    param (
        [string[]]$Path,
        $ItemType,
        $Force,
        $OriginalCommand
    )
    process {
        try {
            if ($ItemType -and $Force) {
                $result = & $OriginalCommand -Path $Path -ItemType $ItemType -Force $Force
            } elseif ($ItemType) {
                $result = & $OriginalCommand -Path $Path -ItemType $ItemType
            } elseif ($Force) {
                $result = & $OriginalCommand -Path $Path -Force $Force
            } else {
                $result = & $OriginalCommand -Path $Path
            }

            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyGetItem = {
    param (
        [string[]]$Path,
        $Force,
        $OriginalCommand
    )
    process {
        try {
            if ($Force) {
                $result = & $OriginalCommand -Path $Path -Force
            } else {
                $result = & $OriginalCommand -Path $Path
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyRenameItem = {
    param (
        [String]$Path,
        [String]$NewName,
        $Force,
        $PassThru,
        $OriginalCommand
    )
    process {
        try {
            if ($Force -and $PassThru) {
                $result = & $OriginalCommand -Path $Path -NewName $NewName -Force -PassThru
            } elseif ($Force) {
                $result = & $OriginalCommand -Path $Path -NewName $NewName -Force
            } elseif ($PassThru) {
                $result = & $OriginalCommand -Path $Path -NewName $NewName -PassThru
            } else {
                $result = & $OriginalCommand -Path $Path -NewName $NewName
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyGetItemProperty = {
    param (
        [string[]]$Path,
        $Name,
        $Filter,
        $OriginalCommand
    )
    process {
        try {
            if ($Name -and $Filter) {
                $result = & $OriginalCommand -Path $Path -Name $Name -Filter $Filter
            } elseif ($Name) {
                $result = & $OriginalCommand -Path $Path -Name $Name
            } elseif ($Filter) {
                $result = & $OriginalCommand -Path $Path -Filter $Filter
            } else {
                $result = & $OriginalCommand -Path $Path
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyRemoveItemProperty = {
    param(
        [String[]]$Path,
        [String[]]$Name,
        [String[]]$Include,
        $Force,
        $OriginalCommand
        )
        process {
            try {
                if ($Include -and $Force) {
                    $result = & $OriginalCommand -Path $Path -Name $Name -Include $Include -Force
                } elseif ($Include) {
                    $result = & $OriginalCommand -Path $Path -Name $Name -Include $Include
                } elseif ($Force) {
                    $result = & $OriginalCommand -Path $Path -Name $Name -Force
                } else {
                    $result = & $OriginalCommand -Path $Path -Name $Name
                }
                return $result
            }
            catch {
                PrintConsole -Status "ERROR" -Errors $_.Exception
            }
        }
}

$Global:ProxyGetChildItem = {
    param (
        [string[]]$Path,
        $Filter,
        $Recurse,
        $OriginalCommand
    )
    process {
        try {
            if ($Filter -and $Recurse) {
                $result = & $OriginalCommand -Path $Path -Filter $Filter -Recurse
            } elseif ($Filter) {
                $result = & $OriginalCommand -Path $Path -Filter $Filter
            } elseif ($Recurse) {
                $result = & $OriginalCommand -Path $Path -Recurse
            } else {
                $result = & $OriginalCommand -Path $Path
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxySetLocation = {
    param (
        [string]$Path,
        $PassThru,
        $UseTransaction,
        $OriginalCommand
    )
    process {
        try {
            if ($PassThru -and $UseTransaction) {
                $result = & $OriginalCommand -Path $Path -PassThru -UseTransaction
            } elseif ($PassThru) {
                $result = & $OriginalCommand -Path $Path -PassThru
            } elseif ($UseTransaction) {
                $result = & $OriginalCommand -Path $Path -UseTransaction
            } else {
                $result = & $OriginalCommand -Path $Path
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyOutFile = {
    param (
        [string]$FilePath,
        [psobject]$InputObject,
        [switch]$Append,
        $OriginalCommand
    )
    process {
        try {
            if (&InputObject -and $Append) {
                $result = & $OriginalCommand -FilePath $FilePath -InputObject $InputObject -Append
            } elseif ($InputObject) {
                $result = & $OriginalCommand -FilePath $FilePath -InputObject $InputObject
            } elseif ($Append) {
                $result = & $OriginalCommand -FilePath $FilePath -Append
            } else {
                $result = & $OriginalCommand -FilePath $FilePath
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyExportCsv = {
    param (
        [psobject]$InputObject,
        [String]$Path,
        $Append,
        $OriginalCommand
    )
    process {
        try {
            if ($Append) {
                $result = & $OriginalCommand -Path $Path -InputObject $InputObject -Append
            } else {
                $result = & $OriginalCommand -Path $Path -InputObject $InputObject
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyImportCsv = {
    param (
        [string[]]$Path,
        $Header,
        $OriginalCommand
    )
    process {
        try {
            if ($Header) {
                $result = & $OriginalCommand -Path $Path -Header
            } else {
                $result = & $OriginalCommand -Path $Path
            }
            return $result
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyImportModule = {
    param (
        [string[]]$Name,
        $Global,
        $Function,
        $OriginalCommand
    )
    process {
        try {
            if ($Global -and $Function) {
                & $OriginalCommand -Name $Name -Global -Function $Function
            } elseif ($Global) {
                & $OriginalCommand -Name $Name -Global
            } elseif ($Function) {
                & $OriginalCommand -Name $Name -Function $Function
            } else {
                & $OriginalCommand -Name $Name
            }
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}





$Global:ProxyAddLog = {
    param (
        [string]$Path,
        [String[]]$Message,
        $N,
        $W,
        $E,
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

$Global:ProxyReadXml = {
    param (
        [string]$Path,
        [String]$Key,
        $OriginalCommand
    )
    process {
        try {
            $results = & $OriginalCommand -Path $Path -Key $Key
            $TPS = @()
            foreach ($result in $results) {
                $TPS += FloatingPath -VP $result
            }
            return $TPS
        }
        catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyGetProcess = {
    param (
        $Name,
        $Id,
        $ComputerName,
        $OriginalCommand
    )
    process {
        try {
            if ($Name) {
                $result = & $OriginalCommand -Name $Name
            } elseif ($Id) {
                $result = & $OriginalCommand -Id $Id
            } elseif ($ComputerName) {
                $result = & $OriginalCommand -ComputerName $ComputerName
            }
            retunr $result
        } catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyStopProcess = {
    param (
        $Id,
        $Name,
        $OriginalCommand
    )
    process {
        try {
            if ($Id) {
                $result = & $OriginalCommand -Id $Id
            } elseif ($Name) {
                $result = & $OriginalCommand -Name $Name
            }
            return $result
        } catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyGetService = {
    param (
        $Name,
        $ComputerName,
        $OriginalCommand
    )
    process {
        try {
            if ($Name) {
                $result = & $OriginalCommand -Name $Name
            } elseif ($ComputerName) {
                $result = & $OriginalCommand -ComputerName $ComputerName
            }
            return $result
        } catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyStartService = {
    param (
        $Name,
        $InputObject,
        $OriginalCommand
    )
    process {
        try {
            if ($Name) {
                $result = & $OriginalCommand -Name $Name
            } elseif ($InputObject) {
                $result = & $OriginalCommand -InputObject $InputObject
            }
            return $result
        } catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyStopService = {
    param (
        [String[]]$Name,
        [ServiceController[]]$InputObject,
        $OriginalCommand
    )
    process {
        try {
            if ($Name) {
                $result = & $OriginalCommand -Name $Name
            } elseif ($InputObject) {
                $result = & $OriginalCommand -InputObject $InputObject
            }
            return $result
        } catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyGetEventLog = {
    param (
        [String]$LogName,
        $InstanceId,
        $ComputerName,
        $OriginalCommand
    )
    process {
        try {
            if ($InstanceId -and $ComputerName) {
                $result = & $OriginalCommand -LogName $LogName -InstanceId $InstanceId -ComputerName $ComputerName
            } elseif ($InstanceId) {
                $result = & $OriginalCommand -LogName $LogName -InstanceId $InstanceId
            } elseif ($ComputerName) {
                $result = & $OriginalCommand -LogName $LogName -ComputerName $ComputerName
            } else {
                $result = & $OriginalCommand -LogName $LogName 
            }
            return $result
        } catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyGetAlias = {
    param (
        $Name,
        $Force,
        $OriginalCommand
    )
    process {
        try {
            if ($Name -and $Force) {
                $result = & $OriginalCommand -Name $Name -Force
            } elseif ($Name) {
                $result = & $OriginalCommand -Name $Name
            } elseif ($Force) {
                $result = & $OriginalCommand -Force
            } else {
                $result = & $OriginalCommand
            }
            return $result
        } catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxyMeasureObject = {
    param (
        $Property,
        $InputObject,
        $Sum,
        $Average,
        $Maximum,
        $Minimum,
        $OriginalCommand
    )
    process {
        try {
            if ($Sum) {
                if ($Property -and $InputObject) {
                    $result = & $OriginalCommand -Property $Property -InputObject $InputObject -Sum
                } elseif ($Property) {
                    $result = & $OriginalCommand -Property $Property -Sum
                } elseif ($InputObject) {
                    $result = & $OriginalCommand -InputObject $InputObject -Sum
                } else {
                    $result = & $OriginalCommand -Sum
                }
            } elseif ($Average) {
                if ($Property -and $InputObject) {
                    $result = & $OriginalCommand -Property $Property -InputObject $InputObject -Average
                } elseif ($Property) {
                    $result = & $OriginalCommand -Property $Property -Average
                } elseif ($InputObject) {
                    $result = & $OriginalCommand -InputObject $InputObject -Average
                } else {
                    $result = & $OriginalCommand -Average
                }
            } elseif ($Maximum) {
                if ($Property -and $InputObject) {
                    $result = & $OriginalCommand -Property $Property -InputObject $InputObject -Maximum
                } elseif ($Property) {
                    $result = & $OriginalCommand -Property $Property -Maximum
                } elseif ($InputObject) {
                    $result = & $OriginalCommand -InputObject $InputObject -Maximum
                } else {
                    $result = & $OriginalCommand -Maximum
                }
            } elseif ($Minimum) {
                if ($Property -and $InputObject) {
                    $result = & $OriginalCommand -Property $Property -InputObject $InputObject -Minimum
                } elseif ($Property) {
                    $result = & $OriginalCommand -Property $Property -Minimum
                } elseif ($InputObject) {
                    $result = & $OriginalCommand -InputObject $InputObject -Minimum
                } else {
                    $result = & $OriginalCommand -Minimum
                }
            } elser {
                if ($Property -and $InputObject) {
                    $result = & $OriginalCommand -Property $Property -InputObject $InputObject
                } elseif ($Property) {
                    $result = & $OriginalCommand -Property $Property
                } elseif ($InputObject) {
                    $result = & $OriginalCommand -InputObject $InputObject
                } else {
                    $result = & $OriginalCommand
                }
            }
            return $result
        } catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

$Global:ProxySelectObject = {
    param (
        $Property,
        $InputObject,
        $Unique,
        $OriginalCommand
    )
    process {
        try {
            if ($Unique) {
                if ($Property -and $InputObject) {
                    $result = & $OriginalCommand -Property $Property -InputObject $InputObject -Unique
                } elseif ($Property) {
                    $result = & $OriginalCommand -Property $Property -Unique
                } elseif ($InputObject) {
                    $result = & $OriginalCommand -InputObject $InputObject -Unique
                }
            } else {
                if ($Property -and $InputObject) {
                    $result = & $OriginalCommand -Property $Property -InputObject $InputObject
                } elseif ($Property) {
                    $result = & $OriginalCommand -Property $Property
                } elseif ($InputObject) {
                    $result = & $OriginalCommand -InputObject $InputObject
                }
            }
            return $result
        } catch {
            PrintConsole -Status "ERROR" -Errors $_.Exception
        }
    }
}

# $Global:ProxyWhereObject = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxySortObject = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyForEachObject = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyStartJob = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyReceiveJob = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyStopJob = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyGetJob = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyGetDate = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }    
# }

# $Global:ProxySetDate = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyCompressArchive = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyExpandArchive = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyStartProcess = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyGetACL = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxySetACL = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyTestNetConnection = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyNewScheduledTask = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

# $Global:ProxyGetScheduledTask = {
#     param (

#     )
#     process {
#         try {

#         } catch {
#             PrintConsole -Status "ERROR" -Errors $_.Exception
#         }
#     }
# }

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
                $host.UI.WriteLine()
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
