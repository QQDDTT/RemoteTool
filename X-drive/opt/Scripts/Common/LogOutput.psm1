# ログを追加する関数
function Add_Log {
    param(
        [String]$Path,     # ログファイルのパス
        [switch]$N,        # INFO
        [switch]$W,        # WARNING
        [switch]$E,        # ERROR
        [Parameter(ValueFromPipeline = $true)][String[]]$Message # メッセージ
    )
    process {
        try {

            [String]$Date = Get-Date -Format "yyyyMMdd"  # 現在の日付を取得
            $LogPath = $Path -replace "\.log$", "_$Date.log"  # 日付を含むログファイル名を作成

            [String]$Time = Get-Date -Format "yyyy/MM/dd HH:mm:ss.fff"  # 現在の時間を取得
            
            if ($N) {
                [String]$Left = "$Time [INFO] "
                [String]$Spaces = "                               "
            }
            if ($W) {
                [String]$Left = "$Time [WARNING] "
                [String]$Spaces = "                                  "
            }
            if ($E) {
                [String]$Left = "$Time [ERROR] "
                [String]$Spaces = "                                "
            }
            for ([int]$i = 0; $i -lt $Message.Length; $i++) {
                if ($i -eq 0) {
                    $Message[$i] = "$Left$Message[$i]"
                } else {
                    $Message[$i] = "$Spaces$Message[$i]"
                }
            }
            Add_File -Path $LogPath -Message $Message
        } catch {
            Write-Error "[ERROR] Log File : $Path can not write."
        } finally {
            $streamWriter.Close()  # StreamWriterを閉じる
        }
    }
}

function Add_File {
    param (
        [String]$Path,
        [String]$Encoding = "UTF-8",
        [Parameter(ValueFromPipeline = $true)][String[]]$Message
    )
    process {
        try {
            # ファイル追加をスレッドセーフにするためのロックオブジェクト
            $script:LogLock = New-Object System.Object

            # ロックを使用して、ファイルへの書き込みを同期化
            [System.Threading.Monitor]::Enter($LogLock)

            if (-not [System.IO.File]::Exists($LogPath)) {
                Write-Warning "File : [$Path] is not exist. Creating..."
                $fileStream = [System.IO.File]::Create($filePath)
                $fileStream.Close()
            }
    
            $encoding = [System.Text.Encoding]::GetEncoding($Encoding)  # エンコーディングを取得
            # StreamWriterを使用してファイルに書き込む
            $streamWriter = [System.IO.StreamWriter]::new($LogPath, $true, $encoding)  # trueは追加モードを示す
            
            $Message | ForEach-Object {
                $streamWriter.WriteLine($_)  # メッセージを書き込む
            }
        } catch {
            Write-Error "[ERROR] File : $Path can not write."
        } finally {
            $streamWriter.Close()  # StreamWriterを閉じる
            [System.Threading.Monitor]::Exit($LogLock)
        }
    }
}