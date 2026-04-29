#Requires AutoHotkey v2.0
#SingleInstance Force

IME_CMODE_NATIVE := 0x1

CapsLock::
{
    ; Release within 250ms = tap. This mimics macOS CapsLock input switching.
    if KeyWait("CapsLock", "T0.25") {
        ToggleImeNativeMode()
        return
    }

    ; Hold CapsLock longer than 250ms, then toggle uppercase mode on release.
    KeyWait "CapsLock"
    isCapsOn := GetKeyState("CapsLock", "T")
    SetCapsLockState isCapsOn ? "Off" : "On"
}

ToggleImeNativeMode()
{
    global IME_CMODE_NATIVE

    hwnd := WinExist("A")

    ; Get the IME context for the active window.
    ; For Microsoft Pinyin, flipping IME_CMODE_NATIVE usually toggles Chinese/English
    ; without sending Ctrl+Space or Shift.
    hIMC := DllCall("Imm32\ImmGetContext", "Ptr", hwnd, "Ptr")
    if !hIMC
        return false

    convBuf := Buffer(4, 0)
    sentBuf := Buffer(4, 0)

    ok := DllCall(
        "Imm32\ImmGetConversionStatus",
        "Ptr", hIMC,
        "Ptr", convBuf,
        "Ptr", sentBuf
    )

    conv := NumGet(convBuf, 0, "UInt")
    sent := NumGet(sentBuf, 0, "UInt")

    if (conv & IME_CMODE_NATIVE)
        conv := conv & ~IME_CMODE_NATIVE
    else
        conv := conv | IME_CMODE_NATIVE

    mode := conv

    setOk := DllCall(
        "Imm32\ImmSetConversionStatus",
        "Ptr", hIMC,
        "UInt", conv,
        "UInt", sent
    )

    DllCall("Imm32\ImmReleaseContext", "Ptr", hwnd, "Ptr", hIMC)
    return mode
}
