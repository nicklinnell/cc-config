---
name: simulator-snapshot
description: Use when the user wants to see the current app UI, asks "take a screenshot", "show me the simulator", "snapshot the app", "what does the screen look like", or needs a visual capture of the running iOS Simulator or Android Emulator.
allowedTools:
  - Bash(xcrun simctl io booted screenshot /tmp/snap_ios.png)
  - Bash(adb shell screencap -p /sdcard/snap.png && adb pull /sdcard/snap.png /tmp/snap_android.png)
---

# simulator-snapshot

Capture a screenshot from the running iOS Simulator and/or Android Emulator and read it into the conversation as an image.

## Parameters

- `platform`: `ios` | `android` | `both` (default: `both`)

## Steps

### iOS

```bash
xcrun simctl io booted screenshot /tmp/snap_ios.png
```

Then read `/tmp/snap_ios.png` using the Read tool — Claude sees it as an image.

**Error: no booted simulator** — `xcrun simctl io booted` exits non-zero. Surface: "No booted iOS Simulator found. Launch one from Xcode > Open Simulator first."

### Android

Two-step (reliable PNG output on macOS):
```bash
adb shell screencap -p /sdcard/snap.png && adb pull /sdcard/snap.png /tmp/snap_android.png
```

Then read `/tmp/snap_android.png`.

**Error: adb not found or no device** — surface: "Android emulator not connected. Run `adb devices` to check."

### After capture

- Check each file exists and is non-zero bytes. If zero bytes or missing: "Screenshot capture failed — check the simulator is showing the app."
- Read both files (or whichever platform was requested) into the conversation.
- Briefly describe what's visible on screen before any further analysis.
