# 设置基本路径
$BASE_PATH = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition)
Import-Module (
    "$PSSCriptRoot\PerformanceTest.psm1",
    "$BASE_PATH\X-drive\opt\Scripts\Common\LogOutput.psm1",
    "$BASE_PATH\X-drive\opt\Scripts\Common\XmlRead.psm1",
    "$PSSCriptRoot\SimulationTest_Simple.ps1"
)

# 测试用的路径
$WorkPath = "$BASE_PATH\X-drive\opt\Scripts\WK001.ps1"
$T_Ps = @(
    "$BASE_PATH\X-drive\",
    "$BASE_PATH\Y-drive\"
)
$V_Ps = @(
    "X:\",
    "Y:\"
)

{
    & $WorkPath
} | SimulationSimpleTest -T $T_Ps -V $V_Ps