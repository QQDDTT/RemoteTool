[String]$XmlEncoding = "UTF-8"
# 通过io.stream获取xml文件信息
function Global:Read_Xml {
    param(
        [String]$Path,
        [Parameter(ValueFromPipeline = $true)][String]$Key
    )
    process {
        try {
            $encoding = [System.Text.Encoding]::GetEncoding($XmlEncoding)
            # 使用 System.IO.StreamReader 读取文件
            $reader = [System.IO.StreamReader]::new($Path, $encoding)
            [xml]$xmlData = $reader.ReadToEnd()
            # 使用 SelectNodes 进行查询

            $nodes = $xmlData.SelectNodes("//*[@Key = '${Key}']")
            [String[]]$result = @()
            $nodes | Get-EndNode | ForEach-Object { $result += $_.InnerText }
            return $result
        } catch {
            Write-Error ${_.Exception.Message}
        } finally {
            $reader.Close()
        }
    }
}

# 将节点中的信息按末端节点拆分
function Get-EndNode {
    param(
        [Parameter(ValueFromPipeline = $true)][System.Xml.XmlNode]$Node
    )
    process {
        # 初始化一个数组以存储结果
        [System.Xml.XmlNode[]]$result = @()
        if ($Node.InnerText) {
            if ($Node.ChildNodes.Count -eq 0) {  # 检查节点是否没有子节点（即为结束节点）
                if ($Node.NodeType -ne "Comment" -and $Node.InnerText) {
                    $result += ${Node}
                }
            } else {
                $Node.ChildNodes | ForEach-Object {
                    Get-EndNode -Node $_ | ForEach-Object {
                        $result += ${_}
                    }
                } 
            }
        }
        return $result
    }
}

