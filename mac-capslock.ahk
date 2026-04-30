#Requires AutoHotkey v2.0
#SingleInstance Force

; 远程控制 / 远程桌面 / 虚拟机 / 串流软件
GroupAdd "RemoteApps", "ahk_exe mstsc.exe"          ; Windows 远程桌面
GroupAdd "RemoteApps", "ahk_exe AnyDesk.exe"        ; AnyDesk
GroupAdd "RemoteApps", "ahk_exe TeamViewer.exe"     ; TeamViewer
GroupAdd "RemoteApps", "ahk_exe RustDesk.exe"       ; RustDesk
GroupAdd "RemoteApps", "ahk_exe parsecd.exe"        ; Parsec
GroupAdd "RemoteApps", "ahk_exe vmware.exe"         ; VMware
GroupAdd "RemoteApps", "ahk_exe VirtualBoxVM.exe"   ; VirtualBox
GroupAdd "RemoteApps", "ahk_exe moonlight.exe"      ; Moonlight
GroupAdd "RemoteApps", "ahk_exe PcAccess.exe"       ; PcAccess

; 只要当前窗口不是这些远程软件，下面的热键才启用
#HotIf !WinActive("ahk_group RemoteApps")

CapsLock::
{
    ; Release within 250ms = tap. This mimics macOS CapsLock input switching.
    if KeyWait("CapsLock", "T0.25") {
        IME_Toggle()
        return
    }

    ; Hold CapsLock longer than 250ms, then toggle uppercase mode on release.
    KeyWait "CapsLock"
    isCapsOn := GetKeyState("CapsLock", "T")
    SetCapsLockState isCapsOn ? "Off" : "On"
}

; 结束条件区，后面的热键恢复全局
#HotIf

; 0 = 英文/关闭 IME
; 1 = 中文/打开 IME
IME_Set(open, winTitle := "A") {
    hwnd := WinExist(winTitle)

    ; 对当前活动窗口，尽量取真正获得焦点的子控件
    if WinActive(winTitle) {
        hwnd := GetFocusedHwnd(hwnd)
    }

    imeWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")

    ; WM_IME_CONTROL = 0x0283
    ; IMC_SETOPENSTATUS = 0x006
    return DllCall(
        "SendMessage",
        "Ptr", imeWnd,
        "UInt", 0x0283,
        "Ptr", 0x006,
        "Ptr", open ? 1 : 0,
        "Ptr"
    )
}

IME_Get(winTitle := "A") {
    hwnd := WinExist(winTitle)

    if WinActive(winTitle) {
        hwnd := GetFocusedHwnd(hwnd)
    }

    imeWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")

    ; IMC_GETOPENSTATUS = 0x005
    return DllCall(
        "SendMessage",
        "Ptr", imeWnd,
        "UInt", 0x0283,
        "Ptr", 0x005,
        "Ptr", 0,
        "Ptr"
    )
}

IME_Toggle() {
    IME_Set(!IME_Get())
}

GetFocusedHwnd(fallback := 0) {
    ptrSize := A_PtrSize
    cbSize := 8 + ptrSize * 6 + 16
    gti := Buffer(cbSize, 0)

    NumPut("UInt", cbSize, gti, 0)

    if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", gti.Ptr) {
        hwndFocus := NumGet(gti, 8 + ptrSize, "Ptr")
        return hwndFocus ? hwndFocus : fallback
    }

    return fallback
}
