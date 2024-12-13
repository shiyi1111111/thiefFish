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
;在读文本路径存储
Local $sFilePathPath = ".\txtPath" 
;文本路径存储
Local $sFilePathsPath = ".\txtPaths" 
;msg
Local $inputboxMsg = "请输入文本路径：" & @CRLF &"下一页：a;  上一页：d;  关闭：s; 隐藏：q;"& @CRLF &"更换文本：r" & @CRLF &"网络小说：cancel"

; 隐藏状态标志  
Global $bHidden = False  

Local $sFilePathContent = StringStripWS (FileRead($sFilePathPath) , 3 )
If @error Then  
	;画面上输入路径
	$sText = InputBox("thiefFish", $inputboxMsg)
	If @error = 1 Then
		$sTxtName = InputBox("thiefFish", "请输入完整小说名：")
		If @error = 1 Then
			Exit
		Else
			downloadTxt($sTxtName)
			$sFilePathContent = StringStripWS (FileRead($sFilePathsPath,1) , 3 )
			$sFilePath = $sFilePathContent
			$iCurrentLine = 1
		EndIf
	Else
		$sFilePath = $sText
		$iCurrentLine = 1
	EndIf
Else 
	;文件获取路径
	If $sFilePathContent = "" Then
		$sText = InputBox("thiefFish", $inputboxMsg)
		If @error = 1 Then
			$sTxtName = InputBox("thiefFish", "请输入完整小说名：")
			If @error = 1 Then
				Exit
			Else
				downloadTxt($sTxtName)
				$sFilePathContent = StringStripWS (FileRead($sFilePathsPath,1) , 3 )
				$sFilePath = $sFilePathContent
				$iCurrentLine = 1
			EndIf
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
Global $hGUI = GUICreate("透明窗口", @DesktopWidth*0.5, @DesktopHeight*0.03, 10, @DesktopHeight-80, BitOR($WS_POPUP, $WS_VISIBLE))  

; 设置窗口背景色  
;GUISetBkColor(0x00FF00) ; 设置背景为绿色  

; 显示窗口  
GUISetState(@SW_SHOW)  

; 设置窗口透明度  
WinSetTrans($hGUI, "", 150) ; 透明度范围 0 - 255（255 = 不透明，0 = 完全透明）  
WinSetOnTop($hGUI, "", $WINDOWS_ONTOP)

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
	; 检查键盘按下事件，"q" 键  
    If _IsPressed("51", $hDLL) Then ; "q 键对应的虚拟键码  
        ToggleWindow()  
		Sleep(400) ; 防止重复触发  
		ContinueLoop
    EndIf
    ; 检查键盘按下事件，"a" 键  
    If _IsPressed("41", $hDLL) Then ; "a" 键对应的虚拟键码  
        $iCurrentLine += 2 ; 行索引递增  
        If $iCurrentLine > $aLines[0] Then $iCurrentLine = $aLines[0] ; 不能超过总行数  
        GUICtrlSetData($hLabel, $aLines[$iCurrentLine]) ; 更新标签内容  
		GUICtrlSetColor(-1, $fontColor) ;字体颜色
		Sleep(400) ; 防止重复触发  
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
		Sleep(400) ; 防止重复触发  
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
		$sText = InputBox("thiefFish", $inputboxMsg)
		If @error = 1 Then
			$sTxtName = InputBox("thiefFish", "请输入完整小说名：")
			If @error = 1 Then
				Exit
			Else
				downloadTxt($sTxtName)
				$sFilePathContent = StringStripWS (FileReadLine($sFilePathsPath,1) , 3 )
				;MsgBox(0, "test",$sFilePathContent)  
				$sFilePath = $sFilePathContent
			EndIf
		Else
			$sFilePath = $sText
		EndIf
		
		; 读取文本文件  
		$sFileContent = FileRead($sFilePath)  
		If @error Then  
			MsgBox(0, "错误", "无法读取文件: " & $sFilePath)  
			Exit  
		EndIf  
		$iCurrentLine = 1
		; 将文件内容分割成行  
		$aLines = StringSplit($sFileContent, @CRLF)  
		GUICtrlSetData($hLabel, $aLines[$iCurrentLine]) ; 更新标签内容  
		GUICtrlSetColor(-1, $fontColor) ;字体颜色
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

 	FileWrite($fileHandle, $txt)  

	; 关闭文件  
	FileClose($fileHandle)
EndFunc

;输入小说名字，在网上下载下来
Func downloadTxt($bookName)
	;ShellExecuteWait()
	ShellExecute('GetBook1.exe',$bookName)
	If @error Then
		ShellExecute('GetBook.exe',$bookName)
	EndIf
	Sleep(8000)
EndFunc

Func ToggleWindow()  
    If Not $bHidden Then  
        ; 隐藏窗口  
        WinSetTrans($hGUI, "", 0)  
        $bHidden = True  
    Else  
        ; 显示窗口  
        WinSetTrans($hGUI, "", 150) 
        $bHidden = False  
    EndIf  
EndFunc 

