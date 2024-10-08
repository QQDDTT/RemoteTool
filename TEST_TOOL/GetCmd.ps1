# 获取所有命令
$allCommands = Get-Command

# 遍历所有命令并存储到全局变量
foreach ($command in $allCommands) {
    # 创建全局变量名称，去掉命令名称中的破折号
    ("$" + "Global:original" + ($command.Name -replace '-', '') + " = Get-Command " + ($command.Name)) | Add-Content -Path "$PSScriptRoot\Source.txt"

    # $Global:originalTestPath = Get-Command Test-Path

}