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
        [Parameter(ValueFromPipeline = $true)][String[]]$Content,
        [String]$Encoding = "UTF-8"
    )
    process {
        try {
            $parent_path = [System.IO.Path]::GetDirectoryName($Path)
            if (-not [System.IO.Directory]::Exists($parent_path)) {
                [System.IO.Directory]::CreateDirectory($parent_path) | Out-Null
                $host.UI.WriteLine("Directory : [$parent_path] does not exist. Creating...")
            }

            if (-not [System.IO.File]::Exists($Path)) {
                [System.IO.File]::WriteAllText($Path, '', [System.Text.Encoding]::GetEncoding($Encoding))
                $host.UI.WriteLine("File : [$Path] does not exist. Creating...")
            }

            $streamWriter = [System.IO.StreamWriter]::new($Path, $true, [System.Text.Encoding]::GetEncoding($Encoding))
            $Content | ForEach-Object {
                $streamWriter.WriteLine($_)
            }
        } catch {
            $host.UI.RawUI.ForegroundColor = "Red"
            $host.UI.WriteLine("[ERROR] File : $Path cannot be written.")
            $host.UI.WriteLine($_)
            $host.UI.RawUI.ForegroundColor = "White"
        } finally {
            if ($null -ne $streamWriter) {
                $streamWriter.Close()
            }
        }
    }
}
