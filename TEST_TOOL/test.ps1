# 设置基本路径
$BASE_PATH = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition)
Import-Module "$PSSCriptRoot\PerformanceTest.psm1"
Import-Module "$BASE_PATH\X-drive\opt\Scripts\Common\LogOutput.psm1"
Import-Module "$BASE_PATH\X-drive\opt\Scripts\Common\XmlRead.psm1"
# $LogPath = "$BASE_PATH\X-drive\opt\Scripts\Log\Test.log"
# $XmlPath = "$BASE_PATH\X-drive\opt\Scripts\Xml\Config.xml"


. "$PSSCriptRoot\SimulationTest_Simple.ps1"


# 测试用的路径
$WorkPath = "$BASE_PATH\X-drive\opt\Scripts\WK001.ps1"
$LP = "X:\opt\Scripts\Log\Test.log"

# 调用 SimulationTest
# { . $WorkPath } | SimulationSimpleTest -T @("$BASE_PATH\X-drive\") -V @("X:\")

{ Add-Log -Path $LP -N "Testing..." } | SimulationSimpleTest -T @("$BASE_PATH\X-drive\") -V @("X:\")