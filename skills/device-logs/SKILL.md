---
name: device-logs
description: Use when the user wants to see app logs, asks "show me the logs", "what's the error", "device logs", "why is it crashing", "check the logs", or needs to diagnose errors from the running iOS Simulator or Android Emulator.
---

# device-logs

Pull recent app logs from the running iOS Simulator and/or Android Emulator.

## Parameters

- `platform`: `ios` | `android` | `both` (default: `both`)
- `level`: `error` | `debug` (default: `error`)
- `app_name` (iOS only): process name to filter by. For this project: `CarvatarApp` (confirmed)

## Steps

### iOS

Error/fault level (default):
```bash
xcrun simctl spawn booted log show --last 2m --predicate 'process == "CarvatarApp" AND (messageType == 16 OR messageType == 17)'
```

Debug level (all messages):
```bash
xcrun simctl spawn booted log show --last 2m --predicate 'process == "CarvatarApp"'
```

Non-streaming — returns immediately with logs from the last 2 minutes.

Note: `--level error` is not a valid flag on macOS. The process must be filtered inside the `--predicate` expression — combining `--process` with `--predicate` does not scope results to the named process. Use `messageType == 16` for errors and `messageType == 17` for faults.

**Error: no booted simulator** — surface: "No booted iOS Simulator found. Launch one first."

**No logs returned** — likely wrong `app_name`. Verify with:
```bash
xcrun simctl spawn booted log show --last 1m | grep -i carvatar
```

### Android

```bash
adb logcat -s ReactNativeJS:V -t 200
```

Last 200 lines filtered to React Native JS output.

**Error: adb not found or no device** — surface: "Android emulator not connected. Run `adb devices` to check."

### After retrieval

- Summarise errors found. Quote the most relevant lines verbatim.
- If no errors are found and `level=error`, suggest re-running with `level=debug` for broader output.
