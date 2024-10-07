function Global:SimulationSimpleTest {
    param(
        [Parameter(ValueFromPipeline = $true)][ScriptBlock]$SimulationBlock,
        [String[]]$T,
        [String[]]$V
    )
    process {
        try {
            Write-Output "---> SimulationTest - Simple start."
            if ($null -eq $T -or $null -eq $V) {
                Write-Error "---> TruePaths or VirtualPaths cannot be null."
                return
            }
            if ($T.Length -eq 0 -or $V.Length -eq 0) {
                Write-Error "---> TruePaths or VirtualPaths length must be greater than 0."
                return
            }
            if ($T.Length -ne $V.Length) {
                Write-Error "---> TruePaths and VirtualPaths must be of equal length."
                return
            }
        
            foreach ($path in $T) {
                if (-not (Test-Path -Path $path)) {
                    Write-Error "---> $path is not a valid path."
                    return
                }
            }
            
            if (-not $SimulationBlock) {
                Write-Error "---> SimulationBlock cannot be null or empty."
                return
            }
            $Global:originalTestPath = Get-Command Test-Path
            $Global:originalJoinPath = Get-Command Join-Path
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

            Write-Output "---> SimulationTest command extraction is successful."

            # 替换原始命令
            Set-Item -Path Function:Test-Path -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path)
                & $ProxyTestPath -Path $Path -OriginalCommand $Global:originalTestPath
            }
            Set-Item -Path Function:Join-Path -Value {
                param([String[]]$Path, [String]$ChildPath)
                & $ProxyJoinPath -Path $Path -ChildPath $ChildPath -OriginalCommand $Global:originalJoinPath
            }
            Set-Item -Path Function:Get-Content -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path)
                & $ProxyGetContent -Path $Path -OriginalCommand $Global:originalGetContent
            }
            Set-Item -Path Function:Set-Content -Value {
                param([String[]]$Path, [Parameter(ValueFromPipeline = $true)][Object[]]$Value)
                & $ProxySetContent -Path $Path -Value $Value -OriginalCommand $Global:originalSetContent
            }
            Set-Item -Path Function:Add-Content -Value {
                param([String[]]$Path, [Parameter(ValueFromPipeline = $true)][Object[]]$Value)
                & $ProxyAddContent -Path $Path -Value $Value -OriginalCommand $Global:originalAddContent
            }
            Set-Item -Path Function:Clear-Content -Value {
                param([String[]]$Path)
                & $ProxyClearContent -Path $Path -OriginalCommand $Global:originalClearContent
            }
            Set-Item -Path Function:Remove-Item -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path)
                & $ProxyRemoveItem -Path $Path -OriginalCommand $Global:originalRemoveItem
            }
            Set-Item -Path Function:Copy-Item -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path, [String]$Destination)
                & $ProxyCopyItem -Path $Path -Destination $Destination -OriginalCommand $Global:originalCopyItem
            }
            Set-Item -Path Function:Move-Item -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path, [String]$Destination)
                & $ProxyMoveItem -Path $Path -Destination $Destination -OriginalCommand $Global:originalMoveItem
            }
            Set-Item -Path Function:New-Item -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path)
                & $ProxyNewItem -Path $Path -OriginalCommand $Global:originalNewItem
            }
            Set-Item -Path Function:Get-Item -Value {
                param([String[]]$Path)
                & $ProxyGetItem -Path $Path -OriginalCommand $Global:originalGetItem
            }
            Set-Item -Path Function:Get-ItemProperty -Value {
                param([String[]]$LiteralPath)
                & $ProxyGetItemProperty -LiteralPath $LiteralPath -OriginalCommand $Global:originalGetItemProperty
            }
            Set-Item -Path Function:Get-ChildItem -Value {
                param([Parameter(ValueFromPipeline = $true)][String[]]$Path)
                & $ProxyGetChildItem -Path $Path -OriginalCommand $Global:originalGetChildItem
            }
            Set-Item -Path Function:Set-Location -Value {
                param([String]$LiteralPath)
                & $ProxySetLocation -LiteralPath $LiteralPath -OriginalCommand $Global:originalSetlocation
            }
            Set-Item -Path Function:Out-File -Value {
                param([String]$FilePath, [Parameter(ValueFromPipeline = $true)][psobject]$InputObject)
                & $ProxyOutFile -FilePath $FilePath -InputObject $InputObject -OriginalCommand $Global:originalOutFile
            }
            Set-Item -Path Function:Export-Csv -Value {
                param([psobject]$InputObject, [String]$Path)
                & $ProxyExportCsv -InputObject $InputObject -Path $Path -OriginalCommand $Global:originalExportCsv
            }
            Set-Item -Path Function:Import-Csv -Value {
                param([String[]]$Path)
                & $ProxyImportCsv -Path $Path -OriginalCommand $Global:originalImportCsv
            }
            Set-Item -Path Function:Import-Module -Value {
                param([String[]]$Name)
                & $ProxyImportModule -Name $Name -OriginalCommand $Global:originalImportModule
            }

            Set-Item -Path Function:Add_Log -Value {
                param([String]$Path, [switch]$N, [switch]$W, [switch]$E, [Parameter(ValueFromPipeline = $true)][String[]]$Message)
                & $ProxyAddLog -Path $Path -N $N -W $W -E $E -Message $ Message -OriginalCommand $Global:originalAddLog
            }
            Set-Item -Path Function:Add_File -Value {
                param([String]$Path, [String]$Encoding, [Parameter(ValueFromPipeline = $true)][String[]]$Message)
                & $ProxyAddFile -Path $Path -Encoding $Encoding -Message $Message -OriginalCommand $Global:originalAddFile
            }
            Set-Item -Path Function:Read_Xml -Value {
                param([String]$Path, [Parameter(ValueFromPipeline = $true)][String]$Key)
                & $ProxyReadXml -Path $Path -Key $Key -OriginalCommand $Global:originalReadXml
            }

            Write-Output "---> SimulationTest command substitution is successful."

            # 全局变量
            [String[]]$Global:TruePaths = $T
            "---> SimulationTest truePaths : $TruePaths" | Write-Output
            [String[]]$Global:VirtualPaths = $V
            "---> SimulationTest virtualPaths : $VirtualPaths" | Write-Output

            Write-Output "---> SimulationTest block invoke start."
            Write-Output "***************************************"
            $ReturnValue = & $SimulationBlock
            Write-Output "---------------------------------------"
            Write-Output "Return : [$ReturnValue]"
            Write-Output "***************************************"
            Write-Output "---> SimulationTest block invoke over."
        }
        catch {
            Write-Output "---> SimulationTest - Simple error."
            Write-Output $_.Exception.Message
        }
        finally {
            Write-Output "---> SimulationTest - Simple end."
        }
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
        }
    }
}

$Global:ProxyGetItemProperty = {
    param (
        [string[]]$LiteralPath,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePaths -OldPaths $LiteralPath
            $result = & $OriginalCommand -LiteralPath $N_Path
            return $result
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}

$Global:ProxyGetChildItem = {
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
            Write-Error $_.Exception.Message
        }
    }
}

$Global:ProxySetLocation = {
    param (
        [string]$LiteralPath,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePath -OldPath $LiteralPath
            $result = & $OriginalCommand -LiteralPath $N_Path
            return $result
        }
        catch {
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            $result = & $OriginalCommand -Path $N_Path -Delimiter $Delimiter
            return $result
        }
        catch {
            Write-Error $_.Exception.Message
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
            $result = & $OriginalCommand -Path $N_Path -Delimiter $Delimiter
            return $result
        }
        catch {
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
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
            Write-Error $_.Exception.Message
        }
    }
}