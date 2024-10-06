[String]$LogEncoding = "UTF-8"

# ログを追加する関数
function Add-Log {
    param(
        [String]$Path,  # ログファイルのパス
        [Parameter(ParameterSetName = "INFO")][String]$N,  # INFOメッセージ
        [Parameter(ParameterSetName = "WARNING")][String]$W,  # WARNINGメッセージ
        [Parameter(ParameterSetName = "ERROR")][String]$E  # ERRORメッセージ
    )
    process {
        [String]$Date = Get-Date -Format "yyyyMMdd"  # 現在の日付を取得
        $LogPath = $Path -replace "\.log$", "_$Date.log"  # 日付を含むログファイル名を作成
        if (-not (Test-Path $LogPath)) {
            New-Item -Path $LogPath -ItemType File -Force  # ファイルが存在しない場合、新しいファイルを作成
        }
        [String]$Time = Get-Date -Format "yyyy/MM/dd HH:mm:ss.fff"  # 現在の時間を取得

        try {
            $encoding = [System.Text.Encoding]::GetEncoding($LogEncoding)  # エンコーディングを取得
            # StreamWriterを使用してログに書き込む
            $streamWriter = [System.IO.StreamWriter]::new($LogPath, $true, $encoding)  # trueは追加モードを示す
            
            switch ($PSCmdlet.ParameterSetName) {
                "INFO" { 
                    $streamWriter.WriteLine("$Time [INFO] $N")  # INFOメッセージを書き込む
                }
                "WARNING" {
                    $streamWriter.WriteLine("$Time [WARNING] $W")  # WARNINGメッセージを書き込む
                }
                "ERROR" {
                    $streamWriter.WriteLine("$Time [ERROR] $E")  # ERRORメッセージを書き込む
                }
                Default {
                    $streamWriter.WriteLine("$Time [INFO]")  # デフォルトはINFOレベル
                }
            }
            $streamWriter.Close()  # StreamWriterを閉じる
        } catch {
            Write-Warning "Failed to write to log file after $maxRetries attempts."  # 警告を表示
        }
    }
}

# スレッドセーフなログを追加する関数
function Add-SafeLog {
    param(
        [String]$Path,  # ログファイルのパス
        [Parameter(ParameterSetName = "INFO")][String]$N,  # INFOメッセージ
        [Parameter(ParameterSetName = "WARNING")][String]$W,  # WARNINGメッセージ
        [Parameter(ParameterSetName = "ERROR")][String]$E  # ERRORメッセージ
    )

    # ログ追加をスレッドセーフにするためのロックオブジェクト
    $script:LogLock = New-Object System.Object

    # ロックを使用して、ログへの書き込みを同期化
    [System.Threading.Monitor]::Enter($LogLock)
    try {
        switch ($PSCmdlet.ParameterSetName) {
            "INFO" { 
                Add-Log -Path $Path -N $N  # INFOメッセージを書き込む
            }
            "WARNING" {
                Add-Log -Path $Path -W $W # WARNINGメッセージを書き込む
            }
            "ERROR" {
                Add-Log -Path $Path -E $E  # ERRORメッセージを書き込む
            }
            Default {
                Add-Log -Path $Path -N $N  # デフォルトはINFOレベル
            }
        }
    } finally {
        [System.Threading.Monitor]::Exit($LogLock)
    }
}