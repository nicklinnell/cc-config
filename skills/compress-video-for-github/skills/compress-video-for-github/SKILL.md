---
name: compress-video-for-github
description: Compress any video file (.mov, .webm, .mkv, .avi, .mp4, .flv, .wmv, etc.) into an MP4 suitable for embedding in a GitHub PR description. Use this skill whenever the user wants to attach, embed, or share a screen recording or video in a GitHub PR, mentions any video file in the context of a pull request or code review, asks to "compress", "convert", or "resize" a video for GitHub, or says something like "make this video work for a PR". GitHub has a 10MB limit for PR description attachments.
---

# Compress Video for GitHub PR

GitHub PR descriptions accept video attachments up to 10MB. Screen recordings and other video files often exceed this limit due to high bitrates. This skill converts any video format to a compressed MP4 that stays well under the limit.

## Input

The skill accepts an optional file path argument:

- **File supplied** (e.g. `/compress-video-for-github path/to/video.webm`): compress that single file.
- **No file supplied**: scan the working directory (the directory Claude was started in) for all video files matching common extensions (.mov, .webm, .mkv, .avi, .mp4, .flv, .wmv, .m4v, .ts, .mts) and compress each one. Skip any files that are already under 10MB and already .mp4 format. List the files found and confirm with the user before proceeding.

To discover video files in the working directory:
```bash
find . -maxdepth 1 -type f \( -iname "*.mov" -o -iname "*.webm" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mp4" -o -iname "*.flv" -o -iname "*.wmv" -o -iname "*.m4v" -o -iname "*.ts" -o -iname "*.mts" \) | sort
```

## Steps

For each video file:

1. **Check the input file**
   Run `ffprobe` to get file size, duration, resolution, and bitrate:
   ```bash
   ls -lh "<file>"
   ffprobe "<file>" 2>&1 | grep -E "Duration|Stream|bitrate"
   ```

2. **Convert with ffmpeg**
   Use CRF 28 with libx264 — no scaling needed; CRF alone achieves dramatic compression on screen recordings:
   ```bash
   ffmpeg -y -i "<input-video>" \
     -c:v libx264 -crf 28 -preset slow \
     -movflags +faststart \
     "<output.mp4>"
   ```
   Output filename: same base name as input, with `.mp4` extension, in the same directory.

   **Do not use `-vf scale=...`** — scaling fails with high-framerate sources (e.g. 600fps screen recordings from macOS). CRF 28 alone reduces a typical 30MB screen recording to under 2MB.

3. **Check the output and report**
   ```bash
   ls -lh "<output.mp4>"
   ```
   Show the before/after file sizes. If the output is still over 10MB, suggest trimming: `ffmpeg -ss 0 -t 60 -i input ...` to keep the most relevant section, or using a higher CRF (e.g. `-crf 32`).

When processing multiple files, show a summary table at the end with all before/after sizes.

## Why this works

Screen recordings and casual video captures often use extremely high bitrates (10,000-20,000 kb/s) and sometimes very high frame rates. CRF 28 tells the encoder to target a fixed quality level rather than a fixed bitrate, and for video with large static areas it produces very small files at acceptable quality.

`-movflags +faststart` moves the MP4 metadata to the start of the file, which is correct practice for web-playable video.

ffmpeg handles input format detection automatically — no special flags are needed for .webm, .mkv, .avi, .mov, or any other container format.
