#SingleInstance
#KeyHistory 200
#UseHook

;SendMode InputThenPlay

SetTitleMatchMode 2
CustomColor = EEAA99 ; Can be any RGB color (it will be made transparent below).
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, Color, %CustomColor%
Gui, Font, s10, Consolas ; Set a large font size (32-point).
Gui, Add, Text, vMyText cRed w210 h35


GetSelectedText()
{
  tmp = %ClipboardAll%    ; save clipboard
  Clipboard := ""         ; clear clipboard
  Send, ^c                ; simulate Ctrl+C (=selection in clipboard)
  ClipWait, 5             ; wait until clipboard contains data
  selection = %Clipboard% ; save the content of the clipboard
  Clipboard = %tmp%       ; restore old content of the clipboard
  return selection
}

PasteText(text)
{
  tmp = %ClipboardAll%    ; save clipboard
  Clipboard = %text%      ; set required text into clipboard
  ClipWait                ; wait untile clipboard contains data
  Send, ^v                ; simulate Ctrl+V
  sleep, 500
  Clipboard = %tmp%       ; restore old content of the clipboard
  ClipWait                ; wait until clipboard contains data
  return
}

GetFullText(test){
  Loop, read, map.txt
  {
    alias :=""
    fullText :=""

    Loop, parse, A_LoopReadLin, %A_Tab%
    {
      ;MsgBox, Field number %A_Index% is %A_LoopField%
      if(A_Index = 1){
        alias = %A_LoopField%
      }
      if(A_Index = 2){
        fullText = %A_LoopField%
      }

      ;MsgBox, [in]test is %test% and alias is %alias% and fulltext is %fullText%
    }

    test2_1 := RegExReplace(test, "(.[^\.]*)\.(.[^\.]*)$", "$1")
    test2_2 := RegExReplace(test, "(.[^\.]*)\.(.[^\.]*)$", "$2")

    if(test = alias){
      return fullText
    }
    else if (test2_2 = alias){
      return test2_1 . "." . fullText
    }
  }
  return
}

defaultText := ""

SetTimer, UpdateOSD, 500
;Gosub, UpdateOSD         ; Make the first update immediate rather than waiting for the timer.



#v::

send, %Clipboard%
return

^0::
InputBox, cnt, Enter Count
loop %cnt% {
  MouseClick, Left
}
return

#space::
keywait LWin
Send, +^{Left}
test := GetSelectedText()

result := GetFullText(test)

if(StrLen(result) > 0){
  StringReplace, result, result, \r, 'r, All
  ;SendInput, %result%
  PasteText(result)
}
else{
  SendInput, {right}
}

return


; Enclose each line in '$1',
; Used to format a list of strings for SQL
Alt & G::
  KeyWait Alt
  Send, +^{Left}
  selection := GetSelectedText()
  newStr := RegExReplace(selection, "m)^(.*)$", "'$1',")
  StringReplace, newStr, newStr, 'r'n, 'r, All    ; fix newline
  ; SendInput, %newStr%{Backspace}                ; paste everything and delete last comma
  PasteText(newStr)

return

Alt & F::
  KeyWait Alt
  Send, +^{Left}
  selection := GetSelectedText()
  newStr := RegExReplace(selection, "m)^(.*)$", "'$1'")
  StringReplace, newStr, newStr, 'r'n, 'r, All    ; fix newline
  ; SendInput, %newStr%{Backspace}                ; paste everything and delete last comma
  PasteText(newStr)

return

; Send today's date
Ctrl & G::
  KeyWait Ctrl
  FormatTime, datetime, , yyyyMMdd
  Send, %datetime%

return

