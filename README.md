# CapLockMod

macOS-style `CapsLock` behavior for Windows, built with **AutoHotkey v2**.

Tap `CapsLock` to switch IME state. Hold `CapsLock` to keep normal uppercase behavior.

## Highlights

- macOS-style tap/hold `CapsLock`
- Lightweight AutoHotkey v2 implementation
- Direct IME toggle through Windows IME APIs
- Long press preserves normal CapsLock behavior
- Built-in exclusion for remote desktop, VM, and streaming apps

## Demo Behavior

| Action | Result |
| --- | --- |
| Tap `CapsLock` | Toggle IME Chinese/English state |
| Hold `CapsLock` | Toggle CapsLock normally |
| Use inside excluded remote apps | Script stays out of the way |

## Compatibility

This project currently targets **Windows 11** and uses an **IMM32-based** IME control path.

| Environment / IME | Status | Notes |
| --- | --- | --- |
| Windows 11 + AutoHotkey v2 | Supported | Main target environment |
| Sogou Pinyin | Good | Chinese <-> English switching behaves as expected |
| Microsoft Pinyin on Windows 11 | Partial | Chinese -> English often works, English -> Chinese may fail |
| Remote desktop / VM apps in the exclusion list | Disabled by design | `CapsLock` is not intercepted there |

## Why This Exists

On macOS, `CapsLock` is commonly used as a fast language switch key.  
This project brings a similar feel to Windows:

- quick tap for input switching
- long press for uppercase mode
- minimal friction in daily typing

## How It Works

The script in `mac-capslock.ahk` uses:

- `KeyWait("CapsLock", "T0.25")` to distinguish tap vs hold
- `ImmGetDefaultIMEWnd`
- `WM_IME_CONTROL`
- `IMC_GETOPENSTATUS`
- `IMC_SETOPENSTATUS`

In short, it asks the active window's IME whether it is open, then flips that state.

## Included Remote-App Exclusions

The hotkey is disabled inside common remote desktop, VM, and game-streaming apps.

This helps avoid conflicts when `CapsLock` should pass through to a remote machine or VM.

## Known Limitations

- The current implementation is **not TSF-native**
- It does **not** provide a custom Text Service / TIP
- IME behavior depends on how well a target IME still supports legacy `IMM32` control
- Microsoft Pinyin on modern Windows 11 builds does not fully honor this control path in both directions
- Behavior can vary slightly across apps because the actual focused control may differ from the top-level window

## Microsoft Pinyin Caveat

The most important current limitation is the built-in Microsoft Chinese IME on Windows 11.

This project can often:

- switch from Chinese to English

But may fail to:

- switch from English back to Chinese

That is not just an AutoHotkey issue. It comes from the fact that modern Microsoft IMEs are centered around **TSF**, while this project currently talks to the older **IMM32 compatibility layer**.

## Installation

1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Run `mac-capslock.ahk`.

## Usage

1. Tap `CapsLock` for IME switching.
2. Hold `CapsLock` for normal CapsLock behavior.

## Auto Start

You can add the script to Windows Startup so it launches automatically on sign-in.

Current startup target:

- `mac-capslock.ahk`

## Roadmap

- Explore a real TSF-native implementation for better Microsoft Pinyin compatibility

## Status

CapLockMod is currently a practical **AutoHotkey + IMM32** solution for Windows users who want a macOS-style `CapsLock` workflow.

It already works well in some real-world setups, especially with third-party IMEs like Sogou.  
For full Windows 11 Microsoft Pinyin support, a future **TSF-native** implementation is likely needed.
