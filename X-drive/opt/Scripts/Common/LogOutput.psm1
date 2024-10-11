# ログを追加する関数
function Global:Add_Log {
    param(
        [String]$Path,     # ログファイルのパス
        [switch]$N,        # INFO
        [switch]$W,        # WARNING
        [switch]$E,        # ERROR
        [Parameter(ValueFromPipeline = $true)][String[]]$Message # メッセージ
    )
    process {
        try {

            [String]$Date = [System.DateTime]::Now.ToString("yyyyMMdd")  # 現在の日付を取得
            $LogPath = $Path -replace "\.log$", "_${Date}.log"  # 日付を含むログファイル名を作成

            [String]$Time = [System.DateTime]::Now.ToString("yyyy/MM/dd HH:mm:ss.fff") # 現在の時間を取得
            [String]$Left = ""
            [String]$Spaces = ""
            if ($N) {
                [String]$Left = "${Time} [INFO] "
                [String]$Spaces = "                               "
            }
            if ($W) {
                [String]$Left = "${Time} [WARNING] "
                [String]$Spaces = "                                  "
            }
            if ($E) {
                [String]$Left = "${Time} [ERROR] "
                [String]$Spaces = "                                "
            }
            $Message[0] = $Left + $Message[0]
            for ([int]$i = 1; $i -lt $Message.Length; $i++) {
                $Message[$i] = $Spaces + $Message[$i]
            }
            $Message | Add_File -Path $LogPath -Append 
        } catch {
            Write-Error "[ERROR] Log File : $Path can not write."
        } finally {
        }
    }
}

function Global:Add_File {
    param (
        [String]$Path,
        [switch]$Append,
        [Parameter(ValueFromPipeline = $true)][String[]]$Content
    )
    process {
        try {
            # ファイル追加をスレッドセーフにするためのロックオブジェクト
            # $script:LogLock = New-Object System.Object

            # ロックを使用して、ファイルへの書き込みを同期化
            # [System.Threading.Monitor]::Enter($LogLock)

            if (-not [System.IO.File]::Exists($Path)) {
                Write-Warning "File : [$Path] is not exist. Creating..."
                $fileStream = [System.IO.File]::Create($Path)
                $fileStream.Close()
            }
    
            $encoding = [System.Text.Encoding]::GetEncoding($Encoding)  # エンコーディングを取得
            # StreamWriterを使用してファイルに書き込む
            if ($Append) {
                $streamWriter = [System.IO.StreamWriter]::new($Path, $true)
            } else {
                $streamWriter = [System.IO.StreamWriter]::new($Path, $false) 
            }
            $Content | ForEach-Object {
                $streamWriter.WriteLine($_)
            }
        } catch {
            Write-Error "[ERROR] File : $Path can not write."
            Write-Error $_.Exception
        } finally {
            if ($null -ne $streamWriter) {
                $streamWriter.Close()
            }
            # [System.Threading.Monitor]::Exit($LogLock)
        }
    }
}