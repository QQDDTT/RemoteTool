[String]$XmlEncoding = "UTF-8"
# 通过io.stream获取xml文件信息
function Read-Xml {
    param(
        [String]$Path,
        [Parameter(ValueFromPipeline = $true)][String]$id # 非必选参数
    )
    process {
        try {
            $encoding = [System.Text.Encoding]::GetEncoding($XmlEncoding)
            # 使用 System.IO.StreamReader 读取文件
            $reader = [System.IO.StreamReader]::new($Path, $encoding)
            [xml]$xmlData = $reader.ReadToEnd()
            # 使用 SelectNodes 进行查询
            $nodes = $xmlData.SelectNodes("//*[@id = '$id']")
            return $nodes | Get-EndNode | ForEach-Object { $_.InnerText } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        } catch {
            Add-Log "E" $_.Exception.Message
        } finally {
            $reader.Close()
        }
    }
}

# 将节点中的信息按末端节点拆分
function Get-EndNode {
    param(
        [Parameter(ValueFromPipeline = $true)][System.Xml.XmlNode[]]$Nodes
    )
    process {
        # 初始化一个数组以存储结果
        $result = @()
        $Node.ChildNodes | ForEach-Object {
            if ($Node.ChildNodes.Count -eq 0) {  # 检查节点是否没有子节点（即为结束节点）
                if ($Node.NodeType -ne "Comment") {
                    $result += $Node
                }
            } else {
                $result += Get-EndNode -Node $ChildNode
            }
        }
        return $result
    }
}

