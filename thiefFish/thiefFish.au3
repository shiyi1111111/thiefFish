#include <GUIConstantsEx.au3>  
#include <WindowsConstants.au3>  
#include <File.au3>  
#include <Misc.au3>

;文本行数
Local $iCurrentLine = 1
; 文本page页  
Local $pagePath = ".\page"  
; 文本路径
Local $sFilePath = ""
;文本路径存储
Local $sFilePathPath = ".\txtPath" 

Local $sFilePathContent = StringStripWS (FileRead($sFilePathPath) , 3 )
If @error Then  
	;画面上输入路径
	$sText = InputBox("thiefFish", "请输入文本路径  下一页：a 上一页：d 关闭：s 更换文本：r")
	If @error = 1 Then
		Exit  
	Else
		$sFilePath = $sText
		$iCurrentLine = 1
	EndIf
Else 
	;文件获取路径
	If $sFilePathContent = "" Then
		;画面上输入路径
		$sText = InputBox("thiefFish", "请输入文本路径  下一页：a 上一页：d 关闭：s 更换文本：r")
		If @error = 1 Then
			Exit  
		Else
			$sFilePath = $sText
			$iCurrentLine = 1
		EndIf
	Else
		$sFilePath = $sFilePathContent
	EndIf
EndIf 

; 读取文件内容 page
Local $pageContent = FileRead($pagePath)  

; 字体颜色  
Local $fontColor ="0x000000" 

; 检查文件是否成功读取  
If @error Then  
	$iCurrentLine = 1
Else  
    ; 显示文件内容  
	$iCurrentLine = $pageContent
EndIf 

Local $hDLL = DllOpen("user32.dll")

; 创建一个全屏透明窗口  
$hGUI = GUICreate("透明窗口", @DesktopWidth*0.5, @DesktopHeight*0.06, 10, @DesktopHeight-90, BitOR($WS_POPUP, $WS_VISIBLE))  

; 设置窗口背景色  
;GUISetBkColor(0x00FF00) ; 设置背景为绿色  

; 显示窗口  
GUISetState(@SW_SHOW)  

; 设置窗口透明度  
WinSetTrans($hGUI, "", 150) ; 透明度范围 0 - 255（255 = 不透明，0 = 完全透明）  

; 读取文本文件  
Local $sFileContent = FileRead($sFilePath)  

; 检查文件是否读取成功  
If @error Then  
    MsgBox(0, "错误", "无法读取文件: " & $sFilePath)  
    Exit  
EndIf  

; 将文件内容分割成行  
Local $aLines = StringSplit($sFileContent, @CRLF)  

; 如果文件不为空，显示第一行  
If $aLines[0] > 0 Then  
    ; 创建标签并显示第一行  
    $hLabel = GUICtrlCreateLabel($aLines[$iCurrentLine], 10, 10, @DesktopWidth*0.5-10, 30) ; 显示第一行内容  
	;GUICtrlSetFont(-1, 24, 700, '', 'heiti') ;字体大小
	GUICtrlSetColor(-1, $fontColor) ;字体颜色
EndIf  

; 开始事件循环  
While 1  
    $msg = GUIGetMsg()  
    
    ; 检查是否关闭窗口  
    If $msg = $GUI_EVENT_CLOSE Then ExitLoop  

    ; 检查键盘按下事件，"a" 键  
    If _IsPressed("41", $hDLL) Then ; "a" 键对应的虚拟键码  
        $iCurrentLine += 2 ; 行索引递增  
        If $iCurrentLine > $aLines[0] Then $iCurrentLine = $aLines[0] ; 不能超过总行数  
        GUICtrlSetData($hLabel, $aLines[$iCurrentLine]) ; 更新标签内容  
		GUICtrlSetColor(-1, $fontColor) ;字体颜色
		Sleep(100) ; 防止重复触发  
		ContinueLoop
    EndIf  
	; 检查键盘按下事件，"d" 键
    If _IsPressed("44", $hDLL) Then ; "d" 键对应的虚拟键码  
        $iCurrentLine -= 2 ; 行索引递减
		If $iCurrentLine < 0 Then
			$iCurrentLine = 1
		EndIf
        If $iCurrentLine > $aLines[0] Then $iCurrentLine = $aLines[0] ; 不能超过总行数  
        GUICtrlSetData($hLabel, $aLines[$iCurrentLine]) ; 更新标签内容  
		GUICtrlSetColor(-1, $fontColor) ;字体颜色
		Sleep(100) ; 防止重复触发  
		ContinueLoop
    EndIf  
	; 检查键盘按下事件， "s" 键 
    If _IsPressed("53", $hDLL) Then
		remainPage($pagePath,$iCurrentLine)
		remainPage($sFilePathPath,$sFilePath)
		Exit
    EndIf  
	; 检查键盘按下事件， "r" 键  
    If _IsPressed("52", $hDLL) Then
		;画面上输入路径
		$sText = InputBox("thiefFish", "请输入文本路径  下一页：a 上一页：d 关闭：s 更换文本：r")
		If @error = 1 Then
			Exit  
		Else
			$sFilePath = $sText
			$iCurrentLine = 1
			GUICtrlSetData($hLabel, $aLines[$iCurrentLine]) ; 更新标签内容  
			GUICtrlSetColor(-1, $fontColor) ;字体颜色
		EndIf
    EndIf 
WEnd

remainPage($pagePath,$iCurrentLine)
remainPage($sFilePathPath,$sFilePath)
; 关闭窗口  
GUIDelete($hGUI)  

Func remainPage($path,$txt)
	; 打开文件，使用 2 作为模式参数表示写入模式（如果文件已存在，会覆盖）  
	Local $fileHandle = FileOpen($path, 2)  

	; 检查文件是否成功打开  
	If $fileHandle = -1 Then  
		ConsoleWrite("无法打开文件: " & $path & @CRLF)  
		Exit  
	EndIf  

	; 写入新内容到文件  
	FileWrite($fileHandle, $txt)  

	; 关闭文件  
	FileClose($fileHandle)
EndFunc

