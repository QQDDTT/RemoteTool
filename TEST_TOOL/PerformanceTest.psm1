# 性能テストのメイン関数
# この関数は、渡されたスクリプトブロック（テストコード）をもとに性能テストを実行します。
# パラメーターを指定することで、異なるテストモード（ブルートフォーステストやセキュリティテスト）を選択可能です。
function PerformanceTest {
    param(
        [Parameter(ValueFromPipeline = $true)][ScriptBlock]$PerformanceBlock,             # テスト対象のコードブロック
        [Parameter(ParameterSetName = "Brute", Mandatory = $False)][switch]$B,            # ブルートフォーステストモードのフラグ
        [Parameter(ParameterSetName = "Security", Mandatory = $False)][switch]$S,         # セキュリティテストモードのフラグ
        [Parameter(ParameterSetName = "Security", Mandatory = $False)][int]$PoolSize,     # スレッドプールのサイズ
        [Parameter(ParameterSetName = "Security", Mandatory = $False)][int]$ThreadCount,  # 並列実行するスレッド数
        [Parameter(ParameterSetName = "Brute", Mandatory = $False)][int]$LoopTime,        # テストを実行する時間（秒）
        [Parameter(Mandatory = $False)][int]$SleepTime                                    # 各テスト間のスリープ時間（ミリ秒）
    )
    process {
        # ブルートフォーステストモードが選択された場合
        if ($B -or ($PSCmdlet.ParameterSetName -eq "Brute")) {
            # ループ時間が指定されていない場合、デフォルトで5秒に設定
            if ($null -eq $LoopTime -or $LoopTime -lt 1) {
                $LoopTime = 5
            }
            # スリープ時間が指定されていない場合、デフォルトで1ミリ秒に設定
            if ($null -eq $SleepTime -or $SleepTime -lt 1) {
                $SleepTime = 1
            }
            # ブルートフォーステストを実行
            $PerformanceBlock | BruteForceTest -LoopTime $LoopTime -SleepTime $SleepTime
            return
        }
        
        # セキュリティテストモードが選択された場合
        if ($S -or ($PSCmdlet.ParameterSetName -eq "Security")) {
            # プールサイズが指定されていない場合、デフォルトで5に設定
            if ($null -eq $PoolSize -or $PoolSize -lt 1) {
                $PoolSize = 5
            }
            # スレッド数が指定されていない場合、デフォルトで5に設定
            if ($null -eq $ThreadCount -or $ThreadCount -lt 1) {
                $ThreadCount = 5
            }
            # スリープ時間が指定されていない場合、デフォルトで1000ミリ秒に設定
            if ($null -eq $SleepTime -or $SleepTime -lt 1) {
                $SleepTime = 1000
            }
            # セキュリティテストを実行
            $PerformanceBlock | SecurityTest -PoolSize $PoolSize -ThreadCount $ThreadCount -SleepTime $SleepTime
            return
        }
    }
}

# 暴力テスト関数
# 指定されたループ時間に従ってテストコードを並列実行し、成功回数と失敗回数を記録します。
function BruteForceTest {
    param(
        [Parameter(ValueFromPipeline = $true)][ScriptBlock]$BruteForceBlock, # 実行するパフォーマンステストのコードブロック
        [int]$LoopTime,                                                      # ループ実行する時間（秒単位）
        [int]$SleepTime                                                      # 各テスト間のスリープ時間（ミリ秒単位）
    )
    process {
        try {
            # テストコードがnullまたは空の場合、エラーメッセージを出力し処理を中止
            if ($BruteForceBlock -eq $null -or -not $BruteForceBlock.ToString().Trim()) {
                Write-Error "BruteForceBlock is null or trim."
                return
            }
            # スレッドプールを作成し、開く
            $B_runspacePool = [runspacefactory]::CreateRunspacePool(1, 2)
            $B_runspacePool.Open()
            $jobs = @()  # 全てのスレッドのランスペースを格納するためのリスト
            [long]$GlobalSuccessCount = 0  # 全体の成功回数カウント
            [long]$GlobalFaildCount = 0     # 全体の失敗回数カウント
            Write-Output "Performance BruteForce Test ready...."  # テスト準備完了メッセージを出力

            # 内部スクリプトブロックを定義し、テスト実行のロジックを記述
            $bBlock = {
                param(
                    [ScriptBlock]$TestBlock,       # 実行するテストコードブロック
                    [int]$LoopTime,                # ループ時間
                    [int]$SleepTime,               # スリープ時間
                    [ref]$SuccessCount,            # 成功カウントへの参照
                    [ref]$FaildCount               # 失敗カウントへの参照
                )

                # 開始時刻を記録
                $startTime = [DateTime]::UtcNow
                $running = $true                # ループを継続するかを制御するフラグ
                $timeSpan = [TimeSpan]::FromSeconds($LoopTime)  # ループの実行時間

                while ($running) {
                    try {
                        # テストコードの実行
                        & $TestBlock | Out-Null
                        Start-Sleep -Milliseconds $SleepTime  # スリープ
                        # 成功した場合、成功カウントをインクリメント
                        [System.Threading.Interlocked]::Increment([ref]$SuccessCount.Value++) | Out-Null  # 参照でのインクリメント
                    }
                    catch {
                        # 失敗した場合、失敗カウントをインクリメント
                        [System.Threading.Interlocked]::Increment([ref]$FaildCount.Value++) | Out-Null
                    }

                    # 指定された時間が経過したら、ループを終了
                    if ([DateTime]::UtcNow - $startTime -ge $timeSpan) {
                        $running = $false
                    }
                }
            }

            # スレッドを作成して実行
            foreach ($i in 1..1) {
                $B_runspace = [powershell]::Create()  # 新しい PowerShell ランスペースを作成
                $B_runspace.AddScript($bBlock) | Out-Null  # スクリプトブロックを追加
                $B_runspace.AddArgument($BruteForceBlock) | Out-Null  # テストコードブロックを引数として追加
                $B_runspace.AddArgument($LoopTime) | Out-Null  # ループ時間を引数として追加
                $B_runspace.AddArgument($SleepTime) | Out-Null  # スリープ時間を引数として追加
                $B_runspace.AddArgument([ref]$GlobalSuccessCount) | Out-Null  # 成功カウントの参照を引数として追加
                $B_runspace.AddArgument([ref]$GlobalFaildCount) | Out-Null  # 失敗カウントの参照を引数として追加
                $B_runspace.RunspacePool = $B_runspacePool  # ランスペースプールを設定
                
                # ジョブを作成し、非同期実行開始
                $job = [pscustomobject]@{
                    Index  = $i
                    Pipe   = $B_runspace
                    Status = $B_runspace.BeginInvoke()  # 非同期実行開始
                }
                Write-Output "Performance BruteForce Test thread[$i] start"  # スレッド開始メッセージ
                $jobs += $job  # ジョブをリストに追加
            }

            Write-Output "Performance BruteForce Test wait $LoopTime seconds please..."  # 実行中メッセージ

            # 全てのスレッドの完了を待ち、結果を出力
            foreach ($job in $jobs) {
                $job.Pipe.EndInvoke($job.Status)  # スレッドの終了を待つ
                Write-Output "Performance BruteForce Test thread[$($job.Index)] over"  # スレッド終了メッセージ
                $job.Pipe.Dispose()  # リソースを解放
            }
        }
        finally {
            # 総合結果を計算し、出力
            $TotalCount = $GlobalSuccessCount + $GlobalFaildCount  # 全体の実行回数
            $SuccessRate = if ($TotalCount -gt 0) { 
                [math]::Round(($GlobalSuccessCount / $TotalCount) * 100, 2)  # 成功率を計算
            } else { 
                0 
            }
            # 統計情報を出力
            Write-Output "TOTAL: $TotalCount SUCCESS: $GlobalSuccessCount FAILD: $GlobalFaildCount"
            Write-Output "SUCCESS RATE: $SuccessRate%"

            # ランスペースプールを閉じ、リソースを解放
            $B_runspacePool.Close()
            $B_runspacePool.Dispose()
        }
    }
}


# セキュリティテスト
function SecurityTest {
    param(
        [Parameter(ValueFromPipeline = $true)][ScriptBlock]$SecurityBlock,  # 実行するパフォーマンステストコードブロック
        [int]$PoolSize,                                                     # 実行スペースプールのサイズ
        [int]$ThreadCount,                                                  # 並行スレッドの数
        [int]$SleepTime                                                     # 実行間のスリープ時間（ミリ秒）
    )
    process {
        try {
            # コードブロックが空でないか確認
            if ($SecurityBlock -eq $null -or -not $SecurityBlock.ToString().Trim()) {
                Write-Error "SecurityBlock is null or trim."  # エラーメッセージを出力
                return
            }
            # 実行スペースプールを作成し、オープン
            $S_runspacePool = [runspacefactory]::CreateRunspacePool(1, $PoolSize)
            $S_runspacePool.Open()
            $jobs = @()  # すべての実行スペースオブジェクトを保存するための変数
            [long]$GlobalSuccessCount = 0  # グローバル成功カウント
            [long]$GlobalFaildCount = 0     # グローバル失敗カウント
            Write-Output "Performance Security Test ready...."  # 準備完了メッセージを出力

            # パフォーマンステストを実行するための内部スクリプトブロックを定義
            $sBlock = {
                param(
                    [ScriptBlock]$TestBlock,       # テストコードブロック
                    [ref]$SuccessCount,            # 参照型の成功カウント
                    [ref]$FaildCount               # 参照型の失敗カウント
                )
                try {
                    & $TestBlock | Out-Null  # テストコードブロックを実行
                    [System.Threading.Interlocked]::Increment([ref]$SuccessCount.Value++) | Out-Null  # 成功カウントを増加
                }
                catch {
                    [System.Threading.Interlocked]::Increment([ref]$FaildCount.Value++) | Out-Null  # 失敗カウントを増加
                }
                
            }

            # 各スレッドを作成して起動
            foreach ($i in 1..$ThreadCount) {
                $S_runspace = [powershell]::Create()  # 新しいPowerShell実行スペースを作成
                $S_runspace.AddScript($sBlock) | Out-Null  # スクリプトブロックを追加し、出力を抑制
                $S_runspace.AddArgument($SecurityBlock) | Out-Null  # テストコードブロック引数を追加し、出力を抑制
                $S_runspace.AddArgument([ref]$GlobalSuccessCount) | Out-Null  # グローバル成功カウント引数を追加し、出力を抑制
                $S_runspace.AddArgument([ref]$GlobalFaildCount) | Out-Null  # グローバル失敗カウント引数を追加し、出力を抑制
                $S_runspace.RunspacePool = $S_runspacePool  # 実行スペースプールを設定
                
                # タスクオブジェクトを作成し、非同期実行を開始
                $job = [pscustomobject]@{
                    Index  = $i
                    Pipe   = $S_runspace
                    Status = $S_runspace.BeginInvoke()  # 非同期実行を開始
                }
                Write-Output "Performance Security Test thread[$i] start"  # スレッド開始情報を出力
                $jobs += $job  # タスクリストに追加
                Start-Sleep -Milliseconds $SleepTime  # スリープ
                Write-Output "Performance Security Test wait $SleepTime Milliseconds please..."  # 待機メッセージを出力
            }

            # すべてのスレッドが完了するのを待ち、結果を出力
            foreach ($job in $jobs) {
                $job.Pipe.EndInvoke($job.Status)  # スレッドの終了を待つ
                Write-Output "Performance Security Test thread[$($job.Index)] over"  # スレッド終了情報を出力
                $job.Pipe.Dispose()  # リソースをクリーンアップ
            }
        }
        finally {
            # 最終結果を計算し出力
            $TotalCount = $GlobalSuccessCount + $GlobalFaildCount  # 総実行回数を計算
            $SuccessRate = if ($TotalCount -gt 0) { 
                [math]::Round(($GlobalSuccessCount / $TotalCount) * 100, 2)  # 成功率を計算
            } else { 
                0 
            }
            # 統計情報を出力
            Write-Output "TOTAL: $TotalCount SUCCESS: $GlobalSuccessCount FAILD: $GlobalFaildCount"
            Write-Output "SUCCESS RATE: $SuccessRate%"

            # 実行スペースプールを閉じ、リリース
            $S_runspacePool.Close()
            $S_runspacePool.Dispose()
        }
    }
}


# サンプル：PerformanceTest関数を使用してテストを実行
# モジュールをインポート
# Import-Module "$PSSCriptRoot\PerformanceTest.psm1"

# ブルートフォーステスト
# { *** スクリプト *** } | PerformanceTest -B [-LoopTime $LoopTime] [-SleepTime $SleepTime]
# { *** スクリプト *** } | BruteForceTest -LoopTime $LoopTime -SleepTime $SleepTime

# セキュリティテスト
# { *** スクリプト *** } | PerformanceTest -S [-PoolSize $PoolSize] [-ThreadCount $ThreadCount] [-SleepTime $SleepTime]
# { *** スクリプト *** } | SecurityTest -PoolSize $PoolSize -ThreadCount $ThreadCount -SleepTime $SleepTime
