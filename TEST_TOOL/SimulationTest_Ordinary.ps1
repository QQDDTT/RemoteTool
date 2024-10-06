# 全局变量
$TruePaths
$VirtualPaths


function SimulationOrdinaryTest {
    param(
        [Parameter(ValueFromPipeline = $true)][ScriptBlock]$SimulationBlock,
        [String[]]$TruePaths,
        [String[]]$VirtualPaths
    )
    process {
        try {
            Write-Output "SimulationTest - Ordinary start."

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

            $originalAddLog = Get-Command Add-Log
            $originalReadXml = Get-Command Read-Xml

            Write-Output "SimulationTest command extraction is successful."

            # 替换原始命令
            Set-Item -Path Function:Test-Path -Value {
                param([String[]]$Path, [Parameter(Mandatory = $False)][String]$Filter, [Parameter(Mandatory = $False)][String[]]$Include, [Parameter(Mandatory = $False)][String[]]$Exclude)
                & $ProxyTestPath -Path $Path -OriginalCommand $originalTestPath
            }
            Set-Item -Path Function:Get-Content -Value {
                param([String[]]$Path)
                & $ProxyGetContent -Path $Path -OriginalCommand $originalGetContent
            }
            # Get-Content
            Set-Item -Path Function:Set-Content -Value {
                param([String[]]$Path, [Object[]]$Value)
                & $ProxySetContent -Path $Path -Value $Value -OriginalCommand $originalSetContent
            }
            # Set-Content
            Set-Item -Path Function:Add-Content -Value {
                param([String[]]$Path, [Object[]]$Value)
                & $ProxyAddContent -Path $Path -Value $Value -OriginalCommand $originalAddContent
            }
            # Add-Content
            Set-Item -Path Function:Clear-Content -Value {
                param([String[]]$Path, [Parameter(Mandatory = $False)][Strinrg]$Filter)
                & $ProxyClearContent -Path $Path -OriginalCommand $originalClearContent
            }
            # Clear-Content
            Set-Item -Path Function:Remove-Item -Value {
                param([String[]]$Path, [Parameter(Mandatory = $False)][Strinrg]$Filter)
                & $ProxyRemoveItem -Path $Path -OriginalCommand $originalRemoveItem
            }
            # Remove-Item
            Set-Item -Path Function:Copy-Item -Value {
                param([String[]]$Path, [Parameter(Mandatory = $False)][String[]]$Destination, [Parameter(Mandatory = $False)][Strinrg]$Filter)
                & $ProxyCopyItem -Path $Path -OriginalCommand $originalCopyItem
            }
            # Copy-Item
            Set-Item -Path Function:Move-Item -Value {
                param([String[]]$Path, [String[]]$Destination)
                & $ProxyMoveItem -Path $Path -OriginalCommand $originalMoveItem
            }
            # Move-Item
            Set-Item -Path Function:New-Item -Value {
                param([String[]]$Path, [String]$ItemType, [Object]$Value)
                & $ProxyNewItem -Path $Path -OriginalCommand $originalNewItem
            }
            # New-Item
            Set-Item -Path Function:Get-ChildItem -Value {
                param([String[]]$Path, [String]$Filter)
                & $ProxyGetChildItem -Path $Path -OriginalCommand $originalGetChildItem
            }
            # Get-ChildItem
            Set-Item -Path Function:Set-Location -Value {
                param([String]$LiteralPath)
                & $ProxySetLocation -Path $Path -OriginalCommand $originalSetLocation
            }
            # Set-Location
            Set-Item -Path Function:Get-Item -Value {
                param([String[]]$Path, [String]$Filter, [String[]]$Include)
                & $ProxyGetItem -Path $Path -OriginalCommand $originalGetItem
            }
            # Get-Item
            Set-Item -Path Function:Get-ItemProperty -Value {
                param([String[]]$Path, [String[]]$Name, [String]$Filter, [String[]]$Include)
                & $ProxyGetItemProperty -Path $Path -OriginalCommand $originalGetItemProperty
            }
            # Get-ItemProperty
            Set-Item -Path Function:Out-File -Value {
                param([String]$FilePath, [String]$Encoding)
                & $ProxyOutFile -Path $Path -OriginalCommand $originalOutFile
            }
            # Out-File
            Set-Item -Path Function:Export-Csv -Value {
                param([String]$Path, [String]$Delimiter)
                & $ProxyExportCsv -Path $Path -OriginalCommand $originalExportCsv
            }
            # Export-Csv
            Set-Item -Path Function:Import-Csv -Value {
                param([String]$Path, [String]$Delimiter)
                & $ProxyImportCsv -Path $Path -OriginalCommand $originalImportCsv
            }
            # Import-Csv
            Set-Item -Path Function:Import-Module -Value {
                param([String[]]$Name)
                & $ProxyImportModule -Path $Path -OriginalCommand $originalImportModule
            }
            # Import-Module

            Set-Item -Path Function:Add-Log -Value {
                param([String]$Path, [String]$N, [String]$W, [String]$E)
                & $ProxyAddLog -Path $Path -OriginalCommand $originalAddLog
            }
            # Add-Log
            Set-Item -Path Function:Read-Xml -Value {
                param([String]$Path, [String]$id)
                & $ProxyReadXml -Path $Path -OriginalCommand $originalReadXml
            }
            # Read-Xml

            Write-Output "SimulationTest command substitution is successful."

            Write-Output "SimulationTest block invoke start."
            & $SimulationBlock | Write-Output
            Write-Output "SimulationTest block invoke over."
        }
        catch {
            Write-Output "SimulationTest - Ordinary error."
            Write-Output $_.Exception.Message
        }
        finally {
            Write-Output "SimulationTest - Ordinary end."
        }
    }
}

$ChangeSpace = {
    param(
        [String[]]$OldPaths
    )
    process {
        return $OldPaths | ForEach-Object {
            for ($i = 0; $i -lt $TruePaths.Length; $i++) {
                if ($_.StartsWith($VirtualPaths[$i])) {
                    # 只在匹配时输出一次新路径
                    [String]$NewPath = $_ -replace "^$([regex]::Escape($VirtualPaths[$i]))", $TruePaths[$i]
                    return $NewPath
                }
            }
            # 如果没有匹配到，则返回原始路径
            return $_
        }
    }
}


$ProxyTestPath = {
    param (
        [String[]]$Path,
        [Parameter(Mandatory = $False)][String]$Filter,
        [Parameter(Mandatory = $False)][String[]]$Include,
        [Parameter(Mandatory = $False)][String[]]$Exclude,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = $ChangeSpace.Invoke($Path)
            $args = @("-Path", $N_Path)
    
            # if ($PSBoundParameters.ContainsKey("Filter")) {
            #     $args += @("-Filter", $Filter)
            # }
            # if ($PSBoundParameters.ContainsKey("Include")) {
            #     $args += @("-Include", $Include)
            # }
            # if ($PSBoundParameters.ContainsKey("Exclude")) {
            #     $args += @("-Exclude", $Exclude)
            # }
            $result = & $OriginalCommand @args
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
            $N_Path = $ChangeSpace.Invoke($Path)
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
            $N_Path = $ChangeSpace.Invoke($Path)
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
            $N_Path = $ChangeSpace.Invoke($Path)
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
            $N_Path = $ChangeSpace.Invoke($Path)
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
            $N_Path = $ChangeSpace.Invoke($Path)
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
            $N_Path = $ChangeSpace.Invoke($Path)
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
            $N_Path = $ChangeSpace.Invoke($Path)
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
        [String]$ItemType,
        [Object]$Value,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = $ChangeSpace.Invoke($Path)
            $result = & $OriginalCommand -Path $N_Path -ItemType $ItemType -Value $Value
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
        [String]$Filter,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = $ChangeSpace.Invoke($Path)
            $result = & $OriginalCommand -Path $N_Path -Filter $Filter
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
            $N_Path = $ChangeSpace.Invoke($Path)
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
        [String]$Filter,
        [String[]]$Include,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = $ChangeSpace.Invoke($Path)
            $result = & $OriginalCommand -Path $N_Path -Filter $Filter -Include $Include
            return $result
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}


$ProxyGetItemProperty = {
    param (
        [string[]]$Path,
        [Stirng[]]$Name,
        [String]$Filter,
        [String[]]$Include,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = $ChangeSpace.Invoke($Path)
            $result = & $OriginalCommand -Path $N_Path -Name $Name -Filter $Filter -Include $Include
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
        [Stirng[]]$Encoding,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = $ChangeSpace.Invoke($Path)
            $result = & $OriginalCommand -FilePath $N_Path -Encoding $Encoding
            return $result
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}

$ProxyExportCsv = {
    param (
        [string]$Path,
        [Stirng]$Delimiter,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = $ChangeSpace.Invoke($Path)
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
        [string]$Path,
        [Stirng]$Delimiter,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = $ChangeSpace.Invoke($Path)
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
        [string]$Name,
        $OriginalCommand
    )
    process {
        try {
            $N_Path = $ChangeSpace.Invoke($Path)
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
            $N_Path = $ChangeSpace.Invoke($Path)
            $result = & $OriginalCommand -Name $N_Path -N $N -W $W -E $E
            return $result
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
            $N_Path = $ChangeSpace.Invoke($Path)
            $result = & $OriginalCommand -Name $N_Path -id $id
            return $result
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}