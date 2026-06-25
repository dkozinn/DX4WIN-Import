# DX4WIN ADIF Import Automation

An AutoHotkey script that automates importing an ADIF log file into DX4WIN, so you don't have to manually click through File → Import/Export → File → Import → browse → confirm duplicate-handling → OK every time.

Press **Ctrl+Alt+I** while DX4WIN is running, and the script does the rest.

> **Compatibility note:** This script was built and tested specifically against **DX4WIN version 9.0.9**. It relies on DX4WIN's internal window class names and control names, which may differ in other versions. It has **not been tested on any other version of DX4WIN** and may not work correctly if your version's dialogs are structured differently.

---

## What it does

1. Activates DX4WIN's main window
2. Opens **File → Import/Export...**
3. In the Import/Export Filters dialog, opens **File → Import**
4. Types your ADIF file path into the Windows file picker and confirms
5. In the "Options for duplicate QSOs" dialog, sets the dropdown to **"Imported QSO is ignored"** and clicks **OK**
6. When finished, it leaves the import summary dialog box open for review

If the Import/Export Filters dialog is already open when you press the hotkey, the script detects that and skips ahead instead of disrupting it.

---

## Minimum requirements

- **Windows 10 or later** (64-bit recommended). The script uses standard Win32 dialog classes and should work on any modern Windows version, but it has only been tested on Windows 10/11.
- **DX4WIN version 9.0.9** (see compatibility note above)
- If running the **.ahk script** (not the compiled .exe): [AutoHotkey v2.0](https://www.autohotkey.com/) or later must be installed
- If running the **DX4WIN_Import.exe**: no separate AutoHotkey installation is required — it's self-contained

---

## Choosing how to run it

There are three ways to use this. Pick whichever fits your setup:

| Method | Best for |
| --- | --- |
| **DX4WIN_Import.exe** | Users who don't have AutoHotkey installed and just want it to work |
| **Standalone .ahk script** | Users who have AutoHotkey installed and want to see/edit the code |
| **Included into your own main AHK script** | Users who already run a personal AHK script at startup and want this folded into it |

---

## Option A: Running the executable (DX4WIN_Import.exe)

1. Copy `DX4WIN_Import.exe` to a permanent folder (e.g. `C:\Scripts\` or wherever you keep ham radio utilities) — avoid leaving it in your Downloads folder long-term.
2. Double-click `DX4WIN_Import.exe` to run it. A tray icon will appear, indicating it's running in the background.
3. **First run only:** since no configuration file exists yet, you'll be prompted to select your ADIF log file (e.g. the file WSJT-X writes to). Choose it in the file dialog that appears.
   - This creates a file named `DX4WIN_Import.ini` in the same folder as the .exe, storing your chosen path.
   - On every run after this, it reads silently from that .ini — you won't be asked again unless the .ini is deleted or moved.
4. With DX4WIN running, press **Ctrl+Alt+I** to trigger the import.

**To change the ADIF file path later:** close the program (right-click the tray icon → Exit), delete `DX4WIN_Import.ini`, and run the .exe again to be re-prompted. Alternatively, open `DX4WIN_Import.ini` in a text editor and edit the path directly.

**To run it automatically at Windows startup:** place a shortcut to `DX4WIN_Import.exe` in your Windows Startup folder (`Win+R`, type `shell:startup`, press Enter, then copy a shortcut to the .exe into that folder).

---

## Option B: Running as a standalone .ahk script

1. Make sure [AutoHotkey v2.0](https://www.autohotkey.com/) (or later) is installed.
2. Copy `DX4WIN_Import.ahk` to a permanent folder.
3. Open the script in a text editor and set your ADIF file path on this line near the top:

   ```autohotkey
   ADIFPath := "C:\ham program files\dx4w901\save\wsjtx_log.adi"  ; used when NOT compiled
   ```

   Replace the path with the actual location of your ADIF file.
4. Double-click `DX4WIN_Import.ahk` to run it (or right-click → Run Script).
5. With DX4WIN running, press **Ctrl+Alt+I** to trigger the import.

> Note: the `.ini`-based configuration described in Option A only applies when this script is **compiled into an .exe**. When run directly as a `.ahk` file, it always uses the hardcoded `ADIFPath` value above — edit the script directly to change it.

**To run it automatically at Windows startup:** place a shortcut to `DX4WIN_Import.ahk` in your Windows Startup folder (`Win+R`, type `shell:startup`, press Enter, then copy a shortcut into that folder).

---

## Option C: Including it in your own main AHK script

If you already run a personal AutoHotkey script at startup and want this folded in rather than run as a separate process:

1. Copy `DX4WIN_Import.ahk` to a folder alongside (or referenced by) your main script.
2. Open `DX4WIN_Import.ahk` and set your ADIF path as in Option B, step 3.
3. In your **main** script, add an include line near the top:

   ```autohotkey
   #Include C:\Scripts\DX4WIN_Import.ahk
   ```

   (adjust the path to wherever you saved it)
4. If `DX4WIN_Import.ahk` contains a `#Requires` or `#SingleInstance` directive, remove those from the included file — these belong only in your main script, not in a file that's being pulled into it. (If you started from a version of this script that already had them removed, no action needed.)
5. Run your main script as you normally do. The `Ctrl+Alt+I` hotkey and DX4WIN import logic are now part of it.

> As with Option B, the included script will always use its hardcoded `ADIFPath` — the `.ini` prompt logic only activates when the file is compiled into a standalone `.exe`.

---

## Troubleshooting

- **"DX4WIN main window not found"** — Make sure DX4WIN is running before pressing the hotkey.
- **"Import / Export Filters dialog did not appear"** — This can happen if DX4WIN hasn't fully processed the previous keystrokes yet. Try again; if it persists, DX4WIN's menu structure in your version may differ from 9.0.9.
- **"Could not confirm dropdown is set to 'Imported QSO is ignored'"** — The script will stop and let you set this manually rather than risk importing duplicate QSOs incorrectly. Set the dropdown yourself and click OK.
- **Hotkey doesn't do anything at all** — Check that the script (or compiled .exe) is actually running — look for its icon in the Windows system tray.

---

## Customizing the hotkey

By default the hotkey is **Ctrl+Alt+I**, set by this line in the script:

```autohotkey
^!i::DoDX4WinImport()
```

`^` = Ctrl, `!` = Alt, `i` = the I key. See the [AutoHotkey hotkey symbol reference](https://www.autohotkey.com/docs/v2/Hotkeys.htm#Symbols) if you'd like to change it to something else.
