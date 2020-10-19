;B.ack
;D.oor
;S.canner
;M.od

;B.D.S.M
;The Worlds First Automated Garrys Mod / Steam Workshop - Backdoor Scanner Modification: Made by Pandela
;Because the Steam Workshop is wildly insecure and nobody cares about it.

;Watch Folder Function Shamelessly Borrowed From:
;https://github.com/AHK-just-me/WatchFolder
;https://www.autohotkey.com/boards/viewtopic.php?t=8384
;https://www.autohotkey.com/boards/viewtopic.php?p=53750&sid=bb6d30c8187af2d0d8010aaf84fba09f#p53750

;https://cdn.discordapp.com/attachments/206605918501208065/726962004530561064/unknown.png
; #Warn  ; Enable warnings to assist with detecting common errors.
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_WorkingDir%  ; Ensures a consistent starting directory.
#ErrorStdOut
#Persistent
#SingleInstance,Force

ima := A_ScriptDir ;seriously
kum := 0 ;dont touch this
guzzler := 0 ;youll probably regret it
meme := 0 ;guess what, dont touch lol i swear if you do i will fucking find a way to make you reconsider your way of living so help me god who are you where are you parents why are you still reading this stay away from my goddamn code you creep
machine := "B.D.S.M"

Menu Tray, Tip, %machine%
Menu, Tray, NoStandard 
Menu, Tray, Add, Exit, RemoveKebab,
Menu, Tray, Add, Restart This Shit!, ReloadKebab,
Menu, Tray, Add, oWo Whats This?, info,
Menu, Tray, Default, Exit 

gmadPath := "C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmad.exe"
WatchFolder("C:\Program Files (x86)\Steam\steamapps\workshop\content\4000", "ReportFunction", True) ;The True at the end allows the script to also read subfolders.
;WatchFolder("C:\Users\kek\Downloads", "ReportFunction", True) ; Commented out for now, but you can monitor up to 64 folders at the same time this way.

; WatchFolder - Reportfunctions
ReportFunction(Directory, Changes) { 
	For Each, Change In Changes {
		Action := Change.Action
		Name := Change.Name
	     ; -------------------------------------------------------------------------------------------------------------------------
          ; Action 1 (added) = File gets added in the watched folder
		If (Action = 1) {
			
			
			;Prevent the output .gma from being read, again.
			if InStr(outputAddonName, Name) {
				;msgbox kms
				break
			}
			
			;Prevent the input .bin from being read, again?
			if InStr(inputAddonName, Name) {
				msgbox, kms
				break
			}
			
			if RegExMatch(Name,"(.part)") { ;Skip file if it is an unfinished download; i.e an ".part" file.
				break
			}
			
			
			if RegExMatch(Name,"(.bin)") { ;Legacy addons are in the .bin format and require LZMA decompression to access the data.
				global meme := 1
				global binPath := Name
				
				;Grab the addon URL so we can scrape the description as well!
				gosub, GetURL
				
				SetTimer, ChangeButtonNames, 8
				msgbox,,Older Addon Detected,Threat Level is Lower; However you Never Know.
				gosub, ExtractBIN
				;break
			}
			
			
			if RegExMatch(Name,"(.gma)") { ;Any addon uploaded after Feb 2020 will be in the .gma format automatically.
				global meme := 1
				global  gmaPath := Name
				
				;Grab the addon URL so we can scrape the description as well!
				gosub, GetURL
				
				SetTimer, ChangeButtonNames, 8
				msgbox,,Newer Addon Detected,Proceed with Caution; Anything is Possible.
				gosub, ExtractGMA
				;break
			}
			
			
			;Catch unwanted scans/files :3
			if !InStr(Name, ".gma") {
				;msgbox, nope %Name%
				break
			}
			
			if !InStr(Name, ".bin") {
				;msgbox, nope %Name%
				break
			}
			
			;Magic USED to Happen Here
			;msgbox % Name
		}
	}
}

; ==================================================================================================================================
; Function:       Notifies about changes within folders.
;                 This is a rewrite of HotKeyIt's WatchDirectory() released at
;                    http://www.autohotkey.com/board/topic/60125-ahk-lv2-watchdirectory-report-directory-changes/
; Tested with:    AHK 1.1.23.01 (A32/U32/U64)
; Tested on:      Win 10 Pro x64
; Usage:          WatchFolder(Folder, UserFunc[, SubTree := False[, Watch := 3]])
; Parameters:
;     Folder      -  The full qualified path of the folder to be watched.
;                    Pass the string "**PAUSE" and set UserFunc to either True or False to pause respectively resume watching.
;                    Pass the string "**END" and an arbitrary value in UserFunc to completely stop watching anytime.
;                    If not, it will be done internally on exit.
;     UserFunc    -  The name of a user-defined function to call on changes. The function must accept at least two parameters:
;                    1: The path of the affected folder. The final backslash is not included even if it is a drive's root
;                       directory (e.g. C:).
;                    2: An array of change notifications containing the following keys:
;                       Action:  One of the integer values specified as FILE_ACTION_... (see below).
;                                In case of renaming Action is set to FILE_ACTION_RENAMED (4).
;                       Name:    The full path of the changed file or folder.
;                       OldName: The previous path in case of renaming, otherwise not used.
;                       IsDir:   True if Name is a directory; otherwise False. In case of Action 2 (removed) IsDir is always False.
;                    Pass the string "**DEL" to remove the directory from the list of watched folders.
;     SubTree     -  Set to true if you want the whole subtree to be watched (i.e. the contents of all sub-folders).
;                    Default: False - sub-folders aren't watched.
;     Watch       -  The kind of changes to watch for. This can be one or any combination of the FILE_NOTIFY_CHANGES_...
;                    values specified below.
;                    Default: 0x03 - FILE_NOTIFY_CHANGE_FILE_NAME + FILE_NOTIFY_CHANGE_DIR_NAME
; Return values:
;     Returns True on success; otherwise False.
; Change history:
;     1.0.02.00/2016-11-30/just me        -  bug-fix for closing handles with the '**END' option.
;     1.0.01.00/2016-03-14/just me        -  bug-fix for multiple folders
;     1.0.00.00/2015-06-21/just me        -  initial release
; License:
;     The Unlicense -> http://unlicense.org/
; Remarks:
;     Due to the limits of the API function WaitForMultipleObjects() you cannot watch more than MAXIMUM_WAIT_OBJECTS (64)
;     folders simultaneously. I am Pandela and I approve this Script. Do not steal B.D.S.M as your own pls, that is wrong and skiddy.
; MSDN:                                                                         Pandela 2020
;     ReadDirectoryChangesW          msdn.microsoft.com/en-us/library/aa365465(v=vs.85).aspx
;     FILE_NOTIFY_CHANGE_FILE_NAME   = 1   (0x00000001) : Notify about renaming, creating, or deleting a file.
;     FILE_NOTIFY_CHANGE_DIR_NAME    = 2   (0x00000002) : Notify about creating or deleting a directory.
;     FILE_NOTIFY_CHANGE_ATTRIBUTES  = 4   (0x00000004) : Notify about attribute changes.
;     FILE_NOTIFY_CHANGE_SIZE        = 8   (0x00000008) : Notify about any file-size change.
;     FILE_NOTIFY_CHANGE_LAST_WRITE  = 16  (0x00000010) : Notify about any change to the last write-time of files.
;     FILE_NOTIFY_CHANGE_LAST_ACCESS = 32  (0x00000020) : Notify about any change to the last access time of files.
;     FILE_NOTIFY_CHANGE_CREATION    = 64  (0x00000040) : Notify about any change to the creation time of files.
;     FILE_NOTIFY_CHANGE_SECURITY    = 256 (0x00000100) : Notify about any security-descriptor change.
;     FILE_NOTIFY_INFORMATION        msdn.microsoft.com/en-us/library/aa364391(v=vs.85).aspx
;     FILE_ACTION_ADDED              = 1   (0x00000001) : The file was added to the directory.
;     FILE_ACTION_REMOVED            = 2   (0x00000002) : The file was removed from the directory.
;     FILE_ACTION_MODIFIED           = 3   (0x00000003) : The file was modified.
;     FILE_ACTION_RENAMED            = 4   (0x00000004) : The file was renamed (not defined by Microsoft).
;     FILE_ACTION_RENAMED_OLD_NAME   = 4   (0x00000004) : The file was renamed and this is the old name.
;     FILE_ACTION_RENAMED_NEW_NAME   = 5   (0x00000005) : The file was renamed and this is the new name.
;     GetOverlappedResult            msdn.microsoft.com/en-us/library/ms683209(v=vs.85).aspx
;     CreateFile                     msdn.microsoft.com/en-us/library/aa363858(v=vs.85).aspx
;     FILE_FLAG_BACKUP_SEMANTICS     = 0x02000000
;     FILE_FLAG_OVERLAPPED           = 0x40000000
; ==================================================================================================================================
WatchFolder(Folder, UserFunc, SubTree := False, Watch := 0x03) {
	Static DummyObject := {Base: {__Delete: Func("WatchFolder").Bind("**END", "")}}
	Static TimerID := "**" . A_TickCount
	Static TimerFunc := Func("WatchFolder").Bind(TimerID, "")
	Static MAXIMUM_WAIT_OBJECTS := 64
	Static MAX_DIR_PATH := 260 - 12 + 1
	Static SizeOfLongPath := MAX_DIR_PATH << !!A_IsUnicode
	Static SizeOfFNI := 0xFFFF ; size of the FILE_NOTIFY_INFORMATION structure buffer (64 KB)
	Static SizeOfOVL := 32     ; size of the OVERLAPPED structure (64-bit)
	Static WatchedFolders := {}
	Static EventArray := []
	Static HandleArray := []
	Static WaitObjects := 0
	Static BytesRead := 0
	Static Paused := False
   ; ===============================================================================================================================
	If (Folder = "")
		Return False
	SetTimer, % TimerFunc, Off
	RebuildWaitObjects := False
   ; ===============================================================================================================================
	If (Folder = TimerID) { ; called by timer
		If (ObjCount := EventArray.Length()) && !Paused {
			ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", &WaitObjects, "Int", 0, "UInt", 0, "UInt")
			While (ObjIndex >= 0) && (ObjIndex < ObjCount) {
				FolderName := WatchedFolders[ObjIndex + 1]
				D := WatchedFolders[FolderName]
				If DllCall("GetOverlappedResult", "Ptr", D.Handle, "Ptr", D.OVLAddr, "UIntP", BytesRead, "Int", True) {
					Changes := []
					FNIAddr := D.FNIAddr
					FNIMax := FNIAddr + BytesRead
					OffSet := 0
					PrevIndex := 0
					PrevAction := 0
					PrevName := ""
					Loop {
						FNIAddr += Offset
						OffSet := NumGet(FNIAddr + 0, "UInt")
						Action := NumGet(FNIAddr + 4, "UInt")
						Length := NumGet(FNIAddr + 8, "UInt") // 2
						Name   := FolderName . "\" . StrGet(FNIAddr + 12, Length, "UTF-16")
						IsDir  := InStr(FileExist(Name), "D") ? 1 : 0
						If (Name = PrevName) {
							If (Action = PrevAction)
								Continue
							If (Action = 1) && (PrevAction = 2) {
								PrevAction := Action
								Changes.RemoveAt(PrevIndex--)
								Continue
							}
						}
						If (Action = 4)
							PrevIndex := Changes.Push({Action: Action, OldName: Name, IsDir: 0})
						Else If (Action = 5) && (PrevAction = 4) {
							Changes[PrevIndex, "Name"] := Name
							Changes[PrevIndex, "IsDir"] := IsDir
						}
						Else
							PrevIndex := Changes.Push({Action: Action, Name: Name, IsDir: IsDir})
						PrevAction := Action
						PrevName := Name
					} Until (Offset = 0) || ((FNIAddr + Offset) > FNIMax)
					If (Changes.Length() > 0)
						D.Func.Call(FolderName, Changes)
					DllCall("ResetEvent", "Ptr", EventArray[D.Index])
					DllCall("ReadDirectoryChangesW", "Ptr", D.Handle, "Ptr", D.FNIAddr, "UInt", SizeOfFNI, "Int", D.SubTree
                                              , "UInt", D.Watch, "UInt", 0, "Ptr", D.OVLAddr, "Ptr", 0)
				}
				ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", &WaitObjects, "Int", 0, "UInt", 0, "UInt")
				Sleep, 0
			}
		}
	}
   ; ===============================================================================================================================
	Else If (Folder = "**PAUSE") { ; called to pause/resume watching
		Paused := !!UserFunc
		RebuildObjects := Paused
	}
   ; ===============================================================================================================================
	Else If (Folder = "**END") { ; called to stop watching
		For K, D In WatchedFolders
			If K Is Not Integer
				DllCall("CloseHandle", "Ptr", D.Handle)
		For Each, Event In EventArray
			DllCall("CloseHandle", "Ptr", Event)
		WatchedFolders := {}
		EventArray := []
		Paused := False
		Return True
	}
   ; ===============================================================================================================================
	Else { ; called to add, update, or remove folders
		Folder := RTrim(Folder, "\")
		VarSetCapacity(LongPath, SizeOfLongPath, 0)
		If !DllCall("GetLongPathName", "Str", Folder, "Ptr", &LongPath, "UInt", SizeOfLongPath)
			Return False
		VarSetCapacity(LongPath, -1)
		Folder := LongPath
		If (WatchedFolders[Folder]) { ; update or remove
			Handle := WatchedFolders[Folder, "Handle"]
			Index  := WatchedFolders[Folder, "Index"]
			DllCall("CloseHandle", "Ptr", Handle)
			DllCall("CloseHandle", "Ptr", EventArray[Index])
			EventArray.RemoveAt(Index)
			WatchedFolders.RemoveAt(Index)
			WatchedFolders.Delete(Folder)
			RebuildWaitObjects := True
		}
		If InStr(FileExist(Folder), "D") && (UserFunc <> "**DEL") && (EventArray.Length() < MAXIMUM_WAIT_OBJECTS) {
			If (IsFunc(UserFunc) && (UserFunc := Func(UserFunc)) && (UserFunc.MinParams >= 2)) && (Watch &= 0x017F) {
				Handle := DllCall("CreateFile", "Str", Folder . "\", "UInt", 0x01, "UInt", 0x07, "Ptr",0, "UInt", 0x03
                                          , "UInt", 0x42000000, "Ptr", 0, "UPtr")
				If (Handle > 0) {
					Event := DllCall("CreateEvent", "Ptr", 0, "Int", 1, "Int", 0, "Ptr", 0)
					Index := EventArray.Push(Event)
					WatchedFolders[Index] := Folder
					WatchedFolders[Folder] := {Func: UserFunc, Handle: Handle, Index: Index, SubTree: !!SubTree, Watch: Watch}
					WatchedFolders[Folder].SetCapacity("FNIBuff", SizeOfFNI)
					FNIAddr := WatchedFolders[Folder].GetAddress("FNIBuff")
					DllCall("RtlZeroMemory", "Ptr", FNIAddr, "Ptr", SizeOfFNI)
					WatchedFolders[Folder, "FNIAddr"] := FNIAddr
					WatchedFolders[Folder].SetCapacity("OVLBuff", SizeOfOVL)
					OVLAddr := WatchedFolders[Folder].GetAddress("OVLBuff")
					DllCall("RtlZeroMemory", "Ptr", OVLAddr, "Ptr", SizeOfOVL)
					NumPut(Event, OVLAddr + 8, A_PtrSize * 2, "Ptr")
					WatchedFolders[Folder, "OVLAddr"] := OVLAddr
					DllCall("ReadDirectoryChangesW", "Ptr", Handle, "Ptr", FNIAddr, "UInt", SizeOfFNI, "Int", SubTree
                                              , "UInt", Watch, "UInt", 0, "Ptr", OVLAddr, "Ptr", 0)
					RebuildWaitObjects := True
				}
			}
		}
		If (RebuildWaitObjects) {
			VarSetCapacity(WaitObjects, MAXIMUM_WAIT_OBJECTS * A_PtrSize, 0)
			OffSet := &WaitObjects
			For Index, Event In EventArray
				Offset := NumPut(Event, Offset + 0, 0, "Ptr")
		}
	}
   ; ===============================================================================================================================
	If (EventArray.Length() > 0)
		SetTimer, % TimerFunc, -100
	Return (RebuildWaitObjects) ; returns True on success, otherwise False
}

;Flash Splash, but no fancy fade out yet Because bugs.
SplashImage := ima . "\ayylmao\KEK.png"
gui,add,picture,,%SplashImage%
Gui, Color, FFFFFF
Gui +LastFound
winset,transcolor,FFFFFF
gui,-caption +alwaysontop
gui,show
sleep,2000
gui,destroy

   ; ===============================================================================================================================
   ; Addon Extraction and Scanning Begins Below:
   ; ===============================================================================================================================
ExtractBIN:
if (meme = 1) {
	
	7z := ima . "\LZMA\lzma d "
	SelectAddon := chr(0x22) . binPath . chr(0x22)
	
	
	SplitPath, binPath, name1, dir1, ext1, name_no_ext1, drive1
	global outputAddon := " " chr(0x22) . dir1 . "\" . name_no_ext1 . ".gma" . chr(0x22)
	global outputAddonName := " " . dir1 . "\" . name_no_ext1 . ".gma"
	global inputAddonName := " " . dir1 . "\" . name_no_ext1 . ".bin"
	global outputPathName := dir1 . "\" . name_no_ext1
	global binDir := dir1 . "\*.gma"
	
	
	BatchCommand := ComSpec . " /c " . 7z . SelectAddon . outputAddon
	runwait, %BatchCommand%
	
	WinWaitClose, ahk_class ConsoleWindowClass 
	{
          ;msgbox, shiiiiiet!!!!
		gmad := chr(0x22) . "C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmad.exe" . chr(0x22) . outputAddon
		xtractAddon := " " . chr(0x22) . dir1 . "\" . name_no_ext1 . chr(0x22)
		scanpath := " " chr(0x22) . dir1 . "\" . name_no_ext1 . chr(0x22)
		;run, %gmad%
		
		
		fileList := ComObjCreate("WScript.Shell").Exec(gmad).StdOut.ReadAll()
		fileList.Visible := true
		fileList := StrReplace(fileList, "Done!", "Done! Screw Your LZMA LOL") ;Removes linebreak and shit.
		fileList := fileList . "`n" . "====================================================" . "`n"
		fileList := fileList . "~~~~~~~~~~~~~~~~~~~~~DESCRIPTION~~~~~~~~~~~~~~~~~~~~"
		fileList := fileList . "`n" . "====================================================" . "`n"
		
		
          ;Wait for extraction before writing file list.
		WinWaitClose, ahk_class ConsoleWindowClass 
		{
			
			fileList := fileList . "`n" . AddonDescription
			listfile := dir1 . "\" . name_no_ext1 . "\file_list ( ͡° ͜ʖ ͡°).txt"
			FileDelete, %listfile%
			sleep, 200
			FileAppend, %fileList%, %listfile%
			sleep, 500
			FileDelete, %binDir%
			
			kum := 1
			gosub, BackdoorScanner
		}
		
	}
	return
	
	
	meme := 0	
	Return
}
return

ExtractGMA:
if (meme = 1) {
	
	SplitPath, gmaPath, name2, dir2, ext2, name_no_ext2, drive2	
	;gmad := ComSpec . " /k " . chr(0x22) . gmadPath . chr(0x22) . " " . chr(0x22) . gmaPath . chr(0x22)
	gmad := chr(0x22) . gmadPath . chr(0x22) . " " . chr(0x22) . gmaPath . chr(0x22)	
	global outputPathName2 := dir2 . "\" . name_no_ext2
	
	fileList := ComObjCreate("WScript.Shell").Exec(gmad).StdOut.ReadAll()
	;fileList.Visible := true
	fileList := StrReplace(fileList, "Done!", "Done! All Your Addons Are Belong To Us!") ;Removes linebreak and shit.
	fileList := fileList . "`n" . "====================================================" . "`n"
	fileList := fileList . "~~~~~~~~~~~~~~~~~~~~~DESCRIPTION~~~~~~~~~~~~~~~~~~~~"	
	fileList := fileList . "`n" . "====================================================" . "`n"
	
	
	
	runwait, %gmad%
	msgbox, %fileList%
	
     ;Wait for extraction before writing file list.
	WinWaitClose, ahk_class ConsoleWindowClass 
	{
		listString := fileList . "`n" . AddonDescription
		FileName1 := outputPathName2 . "\file_list ( ͡° ͜ʖ ͡°).txt"
		file1 := FileOpen(FileName1, "w")
		file1.Write(listString)
		file1.Close()
	}
	
	kum := 1
	guzzler := 2
	gosub, BackdoorScanner
	;DO I NEED TO PLACE A RETURN HERE??? :thonk:
	
	
	;Reset Values.
	meme := 0
	guzzler := 0
	kum := 0
}
return


BackdoorScanner:
SetTitleMatchMode, 2
if (kum = 1) {
	;msgbox, wao
	BadDragonScammer := ima . "\ayylmao\BD-Scan.exe"
	;kmspls := "C:\Users\user\Documents\ahk_scripts\BDSM_Copy\ayylmao\BD-Scan.exe"
	sleep, 1000
	
	
	if (guzzler = 2) {
		outputPathName := outputPathName2
		name_no_ext1 := name_no_ext2
		StringLower, name_no_ext1, name_no_ext1
	}
	
	tit := "C:\WINDOWS"
	;msgbox, %BadDragonScammer%
	Run, %BadDragonScammer%,,, cmdPID
	;Run, %kmspls%
	Sleep, 200
	
	;WinWaitActive,%tit%
	WinWait, ahk_pid %cmdPID%
	{
		Sleep, 500
		WinActivate, ahk_pid %cmdPID%
		sleep, 100
		;WinWaitActive,%tit%
		;sleep, 10
		Send, %outputPathName%{Enter}
		;msgbox, kek
	}
	
	;Wait for Scan to finish.
	WinWaitClose, ahk_class ConsoleWindowClass 
	{
		;gosub, WriteFile
		explorerpath := "explorer /e," outputPathName
		Runwait, %explorerpath% ;open fresh extracted addon folder!
		
		;msgbox, title is %name_no_ext1%
		SetTitleMatchMode, 2
		sleep, 20
		WinWaitActive,, %name_no_ext1%
		
		SetTimer, ChangeButtonNames, 8
		msgbox,,All Done!!!,lookat all these files! o:
		gosub, MaliciousFileChecker
		gosub, FileCheck
		;ExitApp	
		
	}
	;return
	
}
Return



;Wait for ALL windows explorer processes to close.
FileCheck:
Loop {
	If !WinExist("ahk_class CabinetWClass") { ;Windows Explorer class.
		MsgBox, 4,lets make this easy!, Do YOU want to KEEP all these FILES? o:
		IfMsgBox, No 
		{   
			;Msgbox, nah
			gosub, RemoveAllFiles
			return
		}
		
		IfMsgBox, Yes 
		{
			;Msgbox, ye
			gosub, TransportAllFiles
			return	
		}
	}
	
}
Return


RemoveAllFiles:
SetTimer, ChangeButtonNames, 8
msgbox,,oh noes,Removing Files . . .
FileRemoveDir, %outputPathName%, 1 ;Remove that shit.
return


TransportAllFiles:
filePath := outputPathName
RegExMatch(filePath, "(.+\\\K|^)[^\\]+(?=\\)", m) ; Get Parent Folder Name <3 https://www.autohotkey.com/boards/viewtopic.php?p=324302#p324302
AddonBackupDir := ima . "\addon_backups\" . m

SetTimer, ChangeButtonNames, 8
msgbox,,Transporting Files. . ., . . . Now Located In %AddonBackupDir%
FileMoveDir, %outputPathName%, %AddonBackupDir%, 2  ; Move to a new Folder.

;No Longer Needed?
;if ErrorLevel { ;The only error likely to occur here is 
;	FileRemoveDir, %outputPathName%, 1 ;Remove that shit.
;}
return


info:
winTitle := "  =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~"
wtfisthis = 
(
The Worlds First Automated Garrys Mod / Steam Workshop AntiVirus
=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
>	B.ack         
>	D.oor
>	S.canner
>	M.od        
=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
Backdoor Scanner Modification: Made by Pandela.
Because the Steam Workshop is wildly insecure and nobody cares about it and probably never will (gaben pls respond).

This program is obfuscated to prevent you pesky peekers from poking around my code and sharing it to ungrateful skids. 
I can assure you my code is not malicious, the whole point of this is security after all :b If you disagree then make your own script.
`r
A donation would also help out a fuckload right now, 
I got kids to feed and servers to run <3
=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
)
SetTimer, ChangeButtonNames, 8
msgbox,,%winTitle%,%wtfisthis%
return



ChangeButtonNames: 
if !WinExist("Newer Addon Detected")
{
	if !WinExist("Older Addon Detected")
	{
		if !WinExist("All Done!!!")
		{
			If !WinExist("oh noes")
			{
				If !WinExist("Transporting Files. . .")
				{
					If !WinExist("ALERT!!!")
					{
						If !WinExist("  =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~")
						{
							return  ; Keep waiting, if windows don't exist.
							
						}		
					}
				}
			}
		}
	}
}
;Change the button names of specific msgboxs, if they exist.
if WinExist("Newer Addon Detected")
{
	buttonName := "&oh fuck lol"
}

if WinExist("Older Addon Detected")
{
	buttonName := "&ok thx"
}

if WinExist("All Done!!!")
{
	buttonName := "&ayy lmao"
}

if WinExist("oh noes")
{
	buttonName := "&bye bye"
}

if WinExist("Transporting Files. . .")
{
	buttonName := "&ah yes, data"
}

if WinExist("ALERT!!!")
{
	buttonName := "&kms"
}

if WinExist("  =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~")
{
	buttonName := "&idc lol"
}
SetTimer, ChangeButtonNames, Off 

WinActivate 
ControlSetText, Button1, %buttonName%
WinSet, AlwaysOnTop
return



;Grab the workshop URL so we can save the addons description!!
GetURL: ;Waits for the download to finish before proceeding <3
;clear clipboard.
sleep, 20
clipboard :=
url :=

if WinExist("Steam")
	WinActivate ; use the steam window found above
else
	WinActivate, Steam
sleep, 200

SetControlDelay -1
WinWaitActive, ahk_exe steam.exe
WinGetActiveStats, Title, Width, Height, X, Y

;Center Mouse In Steam Window.
MouseMove, Width / 2, Height / 2, 5
sleep,500
MouseClick, Right
sleep,200
Send, {Tab} ;Reset Tab Location
sleep,200
Send, {Down} ;Go down four times
sleep,200
Send, {Down}
sleep,200
Send, {Down}
sleep,200
Send, {Down}
sleep,200
Send, {Enter} ;copy url to clipboard
sleep,20
url := clipboard

 ;If URL wasnt captured, retry.
if !RegExMatch(url,"(https://steamcommunity.com/)") {
	gosub, GetURL
	;msgbox, trying again
}

; create handle to IE: ;Thank you NOU for the help <3
wb := ComObjCreate("InternetExplorer.Application")

; turn this to "false" when everything is working properly
; to not have the internet explorer open up 
wb.Visible := false
wb.Navigate(url)

; wait for page to load 
While (wb.busy || wb.ReadyState != 4)
	Sleep, 100

; while the data is still loading/blank, wait. 
While !(wb.document.getElementByID("highlightContent").innerText) {
	Sleep, 500 
	
	;Check if Description is empty.
	if InStr(wbText, "")
	{
		sleep, 200
		;msgbox rip
		;wb.quit
		break
	}
	
}

; store the data of the table into the text 
wbText := wb.document.getElementByID("highlightContent").innerText
wb.quit ;use Quit here only.

;Replace empty Description with something.
if (wbText= "") {
	;msgbox, shiet its empty
	wbText := "          Addon Contains No Description :("
}

global AddonDescription := wbText
return 



;Manual clipboard scan for the skids.
!s::
tit := "C:\WINDOWS"
probablyALeakedAddon := clipboard
SetTitleMatchMode, 2

manscan := ComSpec . " /k " . ima . "\ayylmao\BD-Scan.exe"
run, %manscan%,,,cumPID
sleep, 500

WinWait, ahk_pid %cumPID%
{
	Sleep, 500
	WinActivate, ahk_pid %cumPID%
	sleep, 100
	Send, %probablyALeakedAddon%{Enter}
	msgbox,,wao, I hope you payed for these, kek
}
return



;Scan for additional malicous files.
;For now its only checking for .dll files
MaliciousFileChecker:
sleep, 1000
Loop Files, %outputPathName%\*.*, R 
{
	owo := "oh SHIT, an .dll file was detected!!1!asdf#%$"
	DetectPls := A_LoopFileFullPath
	if RegExMatch(DetectPls,"(.dll)") { ;Looks for potentially backdoored dynamic link library (.dll) files.
		SetTimer, ChangeButtonNames, 8
		msgbox,,ALERT!!!,%owo%`n`n%DetectPls%
		Return
		
	}
}
Return




RemoveKebab: 
ExitApp 
Return

ReloadKebab:
Reload
Return
