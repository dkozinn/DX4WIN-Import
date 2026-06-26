; Copyright (C) 2026  David Kozinn
;
;     This program is free software: you can redistribute it and/or modify
;     it under the terms of the GNU General Public License as published by
;     the Free Software Foundation, either version 3 of the License, or
;     (at your option) any later version.
;
;     This program is distributed in the hope that it will be useful,
;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;     GNU General Public License for more details.
;
;     You should have received a copy of the GNU General Public License
;     along with this program.  If not, see <https://www.gnu.org/licenses/>.

; ============================================================
; DX4WIN ADIF Import Automation
; ============================================================
; Hotkey: Ctrl+Alt+I
;
; Sequence:
;   1. DX4WIN main window (ahk_class TQSOForm) -> Alt+F -> "I" (Import/Export...)
;      This opens the "Import / Export Filters" dialog (ahk_class TPickIEFilter)
;   2. That dialog's own File menu -> Alt+F -> "I" (Import)
;      This opens the standard Windows file picker
;   3. Type the ADIF path, press Enter
;   4. "Options for duplicate QSOs" dialog (ahk_class TAskDupesImport) appears
;      -> set dropdown to "Imported QSO is ignored" -> click OK
;
; If the "Import / Export Filters" dialog is already open when the hotkey is
; pressed, the script skips step 1 and jumps straight to opening Import from
; that dialog's File menu, instead of reactivating the main window (which
; would disrupt the already-open dialog).
; ============================================================

; ============================================================
; ADIF Path resolution
; ============================================================
; If this script is running compiled (.exe), look for an .ini file with the
; same base name next to the executable (e.g. DX4WIN_Import.exe ->
; DX4WIN_Import.ini) and read the ADIF path from it. If that .ini doesn't
; exist yet, prompt the user with a file picker, then write their choice to
; the .ini for next time.
;
; If this script is running uncompiled (as a .ahk, whether standalone or
; #Include'd into another script), just use the hardcoded ADIFPath below.
; ============================================================

if (A_IsCompiled)
{
    ADIFPath := ""
    iniPath := A_ScriptDir . "\" . StrSplit(A_ScriptName, ".")[1] . ".ini"

    if FileExist(iniPath)
    {
        ADIFPath := IniRead(iniPath, "DX4WIN", "ADIFPath", "")
    }

    if (ADIFPath = "")
    {
        MsgBox("Please select your WSJT-X ADIF log file. This only needs to be done once.", "DX4WIN Import - Setup", "Iconi")
        selectedFile := FileSelect(1, , "Select ADIF log file", "ADIF Files (*.adi; *.adif)")
        if (selectedFile = "")
        {
            MsgBox("No file selected. The script cannot continue without an ADIF file path.", "DX4WIN Import", "Iconx")
            ExitApp()
        }
        ADIFPath := selectedFile
        IniWrite(ADIFPath, iniPath, "DX4WIN", "ADIFPath")
    }
}
else
{
    ADIFPath := "C:\ham program files\dx4w901\save\wsjtx_log.adi"  ; used when NOT compiled
}

^!i::DoDX4WinImport()

DoDX4WinImport()
{
    global ADIFPath

    ; --- Detect current state ---
    if WinExist("ahk_class TPickIEFilter")
    {
        WinActivate("ahk_class TPickIEFilter")
        if !WinWaitActive("ahk_class TPickIEFilter", , 3)
        {
            MsgBox("Could not activate existing Import / Export Filters dialog.", "DX4WIN Import", "Iconx")
            return
        }
    }
    else
    {
        ; --- 1. Activate DX4WIN main window ---
        if !WinExist("ahk_class TQSOForm")
        {
            MsgBox("DX4WIN main window not found. Make sure DX4WIN is running.", "DX4WIN Import", "Iconx")
            return
        }
        WinActivate("ahk_class TQSOForm")
        if !WinWaitActive("ahk_class TQSOForm", , 3)
        {
            MsgBox("Could not activate DX4WIN main window.", "DX4WIN Import", "Iconx")
            return
        }
        Sleep(300)  ; extra buffer: WinWaitActive confirms active state, but
                    ; keyboard input routing can lag slightly behind, especially
                    ; if another window from the same process previously had focus

        ; --- 2. Open File menu, then Import/Export... ---
        Send("!f")
        Sleep(300)
        Send("i")
        Sleep(300)

        ; --- 3. Wait for "Import / Export Filters" dialog ---
        if !WinWait("ahk_class TPickIEFilter", , 3)
        {
            MsgBox("Import / Export Filters dialog did not appear.", "DX4WIN Import", "Iconx")
            return
        }
        WinActivate("ahk_class TPickIEFilter")
        if !WinWaitActive("ahk_class TPickIEFilter", , 3)
        {
            MsgBox("Could not activate Import / Export Filters dialog.", "DX4WIN Import", "Iconx")
            return
        }
    }

    ; --- 4. Inside that dialog: Alt+F -> Import ---
    Send("!f")
    Sleep(300)
    Send("i")
    Sleep(500)

    ; --- 5. Standard Windows file picker should now be open ---
    if !WinWait("ahk_class #32770", , 3)
    {
        MsgBox("File selection dialog did not appear.", "DX4WIN Import", "Iconx")
        return
    }
    WinActivate("ahk_class #32770")
    Sleep(200)

    ; --- 6. Type the full path into the filename field and confirm ---
    Send("!n")          ; Alt+N focuses filename field in standard Open dialogs
    Sleep(200)
    Send("^a")
    Send(ADIFPath)
    Sleep(200)
    Send("{Enter}")

    ; --- 7. "Options for duplicate QSOs" dialog ---
    if !WinWait("ahk_class TAskDupesImport", , 3)
    {
        MsgBox("Options for duplicate QSOs dialog did not appear.", "DX4WIN Import", "Iconx")
        return
    }
    WinActivate("ahk_class TAskDupesImport")
    if !WinWaitActive("ahk_class TAskDupesImport", , 3)
    {
        MsgBox("Could not activate Options for duplicate QSOs dialog.", "DX4WIN Import", "Iconx")
        return
    }
    Sleep(200)

    ; Try to set the dropdown directly. TWheelx1 is a custom control (not a
    ; standard ComboBox), so ControlSetText may or may not work depending on
    ; how it's implemented. We verify afterward and fall back if needed.
    desiredText := "Imported QSO is ignored"
    try
        ControlSetText(desiredText, "TWheelx1", "ahk_class TAskDupesImport")
    catch {
    }
    Sleep(200)

    actualText := ""
    try
        actualText := ControlGetText("TWheelx1", "ahk_class TAskDupesImport")
    catch {
    }

    if (actualText != desiredText)
    {
        ; Fallback: click the control to give it focus, then try typing
        ; the first letter to jump to the matching entry.
        ControlClick("TWheelx1", "ahk_class TAskDupesImport")
        Sleep(200)
        Send("i")
        Sleep(200)

        try
            actualText := ControlGetText("TWheelx1", "ahk_class TAskDupesImport")
        catch {
        }

        if (actualText != desiredText)
        {
            MsgBox("Could not confirm dropdown is set to '" . desiredText . "'.`nCurrent value: '" . actualText . "'.`nPlease set it manually, then click OK.", "DX4WIN Import", "Icon!")
            return
        }
    }

    ; --- 8. Click OK ---
    ControlClick("TBitBtn2", "ahk_class TAskDupesImport")

    ; --- 9. Done ---
    Sleep(500)
    ToolTip("ADIF import sent to DX4WIN")
    SetTimer(() => ToolTip(), -2000)
}
