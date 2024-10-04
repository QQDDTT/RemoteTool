[String]$LogEncoding = "UTF-8"
# 添加日志
function Add-Log {
    param(
        [String]$Path,
        [Parameter(ParameterSetName = "INFO")][String]$N,
        [Parameter(ParameterSetName = "WARNNING")][String]$W,
        [Parameter(ParameterSetName = "ERROR")][String]$E,
        [Parameter(ValueFromPipeline = $true)][String]$Message
    )
    process {
        [String]$Date = Get-Date -Format "yyyy/MM/dd"
        $LogPath = $Path -replace ".log", "_$Date.log"
        if (-not (Test-Path $LogPath)) {
            New-Item -Path $LogPath -ItemType File -Force
        }
        [String]$Time = Get-Date -Format "yyyy/MM/dd HH:mm:ss.fff"
        $maxRetries = 5
        $attempt = 0
        $success = $false
        while (-not $success -and $attempt -lt $maxRetries) {
            try {
                $encoding = [System.Text.Encoding]::GetEncoding($LogEncoding)
                # 使用 StreamWriter 来写入日志
                $streamWriter = [System.IO.StreamWriter]::new($LOG_PATH, $true, $encoding)  # true 为追加模式
                switch (ParameterSetName) {
                    "INFO" { 
                        $streamWriter.WriteLine("$Time [INFO] $Message")
                    }
                    "WARNNING" {
                        $streamWriter.WriteLine("$Time [WARNING] $Message")
                    }
                    "ERROR" {
                        $streamWriter.WriteLine("$Time [ERROR] $Message")
                    }
                    Default {
                        $streamWriter.WriteLine("$Time [INFO] $Message") # 默认 INFO 级别
                    }
                }
                $streamWriter.Close()
                $success = $true  # 写入成功
            } catch {
                $attempt++
                Start-Sleep -Milliseconds 500  # 等待 500 毫秒
                if ($attempt -eq $maxRetries) {
                    Write-Warning "Failed to write to log file after $maxRetries attempts."
                }
            }
        }
    }
}
