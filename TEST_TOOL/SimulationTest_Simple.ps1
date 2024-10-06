function SimulationSimpleTest {
    param(
        [Parameter(ValueFromPipeline = $true)][ScriptBlock]$SimulationBlock,
        [String[]]$T,
        [String[]]$V
    )
    process {
        try {
            Write-Output "SimulationTest - Simple start."
            if ($null -eq $T -or $null -eq $V) {
                Write-Error "TruePaths or VirtualPaths cannot be null."
                return
            }
            if ($T.Length -eq 0 -or $V.Length -eq 0) {
                Write-Error "TruePaths or VirtualPaths length must be greater than 0."
                return
            }
            if ($T.Length -ne $V.Length) {
                Write-Error "TruePaths and VirtualPaths must be of equal length."
                return
            }
        
            foreach ($path in $T) {
                if (-not (Test-Path -Path $path)) {
                    Write-Error "$path is not a valid path."
                    return
                }
            }
            
            if (-not $SimulationBlock) {
                Write-Error "SimulationBlock cannot be null or empty."
                return
            }
            $originalTestPath = Get-Command Test-Path
            $originalGetContent = Get-Command Get-Content
            $originalSetContent = Get-Command Set-Content
            $originalAddContent = Get-Command Add-Content
            $originalClearContent = Get-Command Clear-Content
            $originalRemoveItem = Get-Command Remove-Item
            $originalCopyItem = Get-Command Copy-Item
            $originalMoveItem = Get-Command Move-Item
            $originalNewItem = Get-Command New-Item
            $originalGetChildItem = Get-Command Get-ChildItem
            $originalSetlocation = Get-Command Set-Location
            $originalGetItem = Get-Command Get-Item
            $originalGetItemProperty = Get-Command Get-ItemProperty
            $originalOutFile = Get-Command Out-File
            $originalExportCsv = Get-Command Export-Csv
            $originalImportCsv = Get-Command Import-Csv
            $originalImportModule = Get-Command Import-Module

            $originalAddLog = ${function:Add-Log}
            $originalReadXml = ${function:Read-Xml}

            Write-Output "SimulationTest command extraction is successful."

            # 替换原始命令
            Set-Item -Path Function:Test-Path -Value {
                param([String[]]$Path)
                & $ProxyTestPath -Path $Path -OriginalCommand $originalTestPath
            }
            Set-Item -Path Function:Get-Content -Value {
                param([String[]]$Path)
                & $ProxyGetContent -Path $Path -OriginalCommand $originalGetContent
            }
            Set-Item -Path Function:Set-Content -Value {
                param([String[]]$Path, [Object[]]$Value)
                & $ProxySetContent -Path $Path -Value $Value -OriginalCommand $originalSetContent
            }
            Set-Item -Path Function:Add-Content -Value {
                param([String[]]$Path, [Object[]]$Value)
                & $ProxyAddContent -Path $Path -Value $Value -OriginalCommand $originalAddContent
            }
            Set-Item -Path Function:Clear-Content -Value {
                param([String[]]$Path)
                & $ProxyClearContent -Path $Path -OriginalCommand $originalClearContent
            }
            Set-Item -Path Function:Remove-Item -Value {
                param([String[]]$Path)
                & $ProxyRemoveItem -Path $Path -OriginalCommand $originalRemoveItem
            }
            Set-Item -Path Function:Copy-Item -Value {
                param([String[]]$Path, [String]$Destination)
                & $ProxyCopyItem -Path $Path -Destination $Destination -OriginalCommand $originalCopyItem
            }
            Set-Item -Path Function:Move-Item -Value {
                param([String[]]$Path, [String]$Destination)
                & $ProxyMoveItem -Path $Path -Destination $Destination -OriginalCommand $originalMoveItem
            }
            Set-Item -Path Function:New-Item -Value {
                param([String[]]$Path)
                & $ProxyNewItem -Path $Path -OriginalCommand $originalNewItem
            }
            Set-Item -Path Function:Get-ChildItem -Value {
                param([String[]]$LiteralPath)
                & $ProxyGetChildItem -LiteralPath $LiteralPath -OriginalCommand $originalGetChildItem
            }
            Set-Item -Path Function:Set-Location -Value {
                param([String]$LiteralPath)
                & $ProxySetLocation -LiteralPath $LiteralPath -OriginalCommand $originalSetLocation
            }
            Set-Item -Path Function:Get-Item -Value {
                param([String[]]$Path)
                & $ProxyGetItem -Path $Path -OriginalCommand $originalGetItem
            }
            Set-Item -Path Function:Get-ItemProperty -Value {
                param([String[]]$LiteralPath)
                & $ProxyGetItemProperty -LiteralPath $LiteralPath -OriginalCommand $originalGetItemProperty
            }
            Set-Item -Path Function:Out-File -Value {
                param([String]$FilePath)
                & $ProxyOutFile -FilePath $FilePath -OriginalCommand $originalOutFile
            }
            Set-Item -Path Function:Export-Csv -Value {
                param([psobject]$InputObject, [String]$Path)
                & $ProxyExportCsv -InputObject $InputObject -Path $Path -OriginalCommand $originalExportCsv
            }
            Set-Item -Path Function:Import-Csv -Value {
                param([String[]]$Path)
                & $ProxyImportCsv -Path $Path -OriginalCommand $originalImportCsv
            }
            Set-Item -Path Function:Import-Module -Value {
                param([String[]]$Name)
                & $ProxyImportModule -Name $Name -OriginalCommand $originalImportModule
            }

            Set-Item -Path Function:Add-Log -Value {
                param([String]$Path, [String]$N, [String]$W, [String]$E)
                & $ProxyAddLog -Path $Path -N $N -W $W -E $E -OriginalCommand $originalAddLog
            }
            Set-Item -Path Function:Read-Xml -Value {
                param([String]$Path, [String]$id)
                & $ProxyReadXml -Path $Path -id $id -OriginalCommand $originalReadXml
            }

            Write-Output "SimulationTest command substitution is successful."

            # 全局变量
            [String[]]$Global:TruePaths = $T
            "TruePaths : $TruePaths" | Write-Output
            [String[]]$Global:VirtualPaths = $V
            "VirtualPaths : $VirtualPaths" | Write-Output

            Write-Output "SimulationTest block invoke start."
            & $SimulationBlock | Write-Output
            # Write-Output "SimulationBlock return : $result"
            Write-Output "SimulationTest block invoke over."
        }
        catch {
            Write-Output "SimulationTest - Simple error."
            Write-Output $_.Exception.Message
        }
        finally {
            Write-Output "SimulationTest - Simple end."
        }
    }
}

$ChangePaths = {
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

$ChangePath = {
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

$ProxyTestPath = {
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

$ProxyGetContent = {
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

$ProxySetContent = {
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

$ProxyAddContent = {
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

$ProxyClearContent = {
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

$ProxyRemoveItem = {
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

$ProxyCopyItem = {
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

$ProxyMoveItem = {
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

$ProxyNewItem = {
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

$ProxyGetChildItem = {
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

$ProxySetLocation = {
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

$ProxyGetItem = {
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

$ProxyGetItemProperty = {
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

$ProxyOutFile = {
    param (
        [string]$FilePath,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePath -OldPath $FilePath
            $result = & $OriginalCommand -FilePath $N_Path
            return $result
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}

$ProxyExportCsv = {
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

$ProxyImportCsv = {
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

$ProxyImportModule = {
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

$ProxyAddLog = {
    param (
        [string]$Path,
        [String]$N,
        [String]$W,
        [String]$E,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePath -OldPath $Path
            if ($N) {
                $result = & $OriginalCommand -Path $N_Path -N $N
                return $result
            }
            if ($W) {
                $result = & $OriginalCommand -Path $N_Path -W $W
                return $result
            }
            if ($E) {
                $result = & $OriginalCommand -Path $N_Path -E $E
                return $result
            }
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}

$ProxyReadXml = {
    param (
        [string]$Path,
        [String]$id,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = & $ChangePath -OldPath $Path
            $result = & $OriginalCommand -Name $N_Path -id $id
            return $result
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}