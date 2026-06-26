# DX4WIN ADIF Import — Quickstart

Automates importing your ADIF log into DX4WIN. Press **Ctrl+Alt+I** while DX4WIN is running.

> Built for **DX4WIN 9.0.9**. Not tested on other versions. Requires **Windows 10+**.

## Pick one

### No AutoHotkey installed → use the .exe

1. Copy `DX4WIN_Import.exe` somewhere permanent and run it.
2. First run: pick your ADIF file when prompted (saved to `DX4WIN_Import.ini` next to the .exe — won't ask again).
3. With DX4WIN open, press **Ctrl+Alt+I**.

### Have AutoHotkey v2 → run the script directly

1. Open `DX4WIN_Import.ahk` in a text editor, set the `ADIFPath :=` line near the top to your ADIF file's path.
2. Double-click to run.
3. With DX4WIN open, press **Ctrl+Alt+I**.

### Already run your own AHK script → include it

1. Set `ADIFPath :=` in `DX4WIN_Import.ahk` as above.
2. Remove any `#Requires` / `#SingleInstance` lines from `DX4WIN_Import.ahk`.
3. Add to your main script: `#Include C:\path\to\DX4WIN_Import.ahk`
4. Run your main script as usual.
5. With DX4WIN open, press **Ctrl+Alt+I**.

## If it doesn't work

- DX4WIN must already be running.
- If a dialog/menu step fails partway, see the Troubleshooting section in `README.md`.

Full details, requirements, and troubleshooting: see **README.md**.
