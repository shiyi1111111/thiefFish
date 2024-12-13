; 定义源文件和目标文件  
Local $sSourceFile = "剑来(1001-1175章).txt"  
Local $sDestinationFile = "剑来(1001-1175章)1.txt"  

; 读取源文件内容  
Local $sFileContent = FileRead($sSourceFile)  

; 检查文件是否成功读取  
If @error Then  
    MsgBox(0, "错误", "无法读取源文件。")  
    Exit  
EndIf  

; 初始化一个字符串来存储处理后的内容  
Local $sProcessedContent = ""  

; 将内容每50个字符换行  
For $i = 1 To StringLen($sFileContent) Step 50  
    $sProcessedContent &= StringMid($sFileContent, $i, 50) & @CRLF  
Next  

; 写入处理后的内容到新的文件  
Local $iFile = FileOpen($sDestinationFile, 2) ; 以写入模式打开目标文件  

; 检查是否成功打开目标文件  
If $iFile = -1 Then  
    MsgBox(0, "错误", "无法创建目标文件。")  
    Exit  
EndIf  

; 写入内容  
FileWrite($iFile, $sProcessedContent)  

; 关闭文件  
FileClose($iFile)  

MsgBox(0, "完成", "文本已成功处理并写入到新的文件。")