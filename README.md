# Video transcoding and serving via Google Cloud

## MPEG-4 / H.264

```sh
ffmpeg -i input.mp4 -c:v libx264 -b:v 500k -maxrate 1M -bufsize 2M -preset veryfast -profile:v high -an -y -map_metadata -1 -movflags +faststart -loglevel warning output-h264.mp4
```

* **-i input.mp4**
  * Input file
* **-c:v libx264**
  * Video codec
* **-b:v 500k -maxrate 1M -bufsize 2M**
  * [Video quality](https://trac.ffmpeg.org/wiki/Limiting%20the%20output%20bitrate>)
* **-preset veryslow**
  * Slower = smaller file
  * _⚠ Seems not to make the file a lot smaller but the encoding a lot slower_
* **-provile:v high**
  * _Feature levels_ for the H.264 codec
* **-an**
  * Strip audio
* **-y**
  * Override output file
* **-map_metadata -1**
  * Removes metadata
* **-movflags +faststart**
  * Moves file information to the start of the file
* **-loglevel warning**
  * Log only limited to warnings
* **output-h264.mp4**
  * Output file

### ToDo

* **-pix_fmt yuv420p**
  * (pixel format) is a trick to reduce the size of a video. Basically, it uses full resolution for brightness and a smaller resolution for color. It is a way to fool a human eye, and you can safely remove this argument if it does not work in your case. [Source](https://evilmartians.com/chronicles/better-web-video-with-av1-codec)
* Max FPS
* Max memory usage (since Google Cloud Functions have a limit as well)

## AV1

_⚠ Too slow. Not worth it, yet. May try out SVT-AV1_

```sh
ffmpeg -i input.mp4 -c:v libaom-av1 -crf 55 -b:v 500k -an -y -strict experimental -map_metadata -1 -movflags +faststart output-av1.mp4
```

* **-i input.mp4**
  * Input file
* **-c:v libaom-av1**
  * Video codec
* **-crf 55**
  * Video quality (0 best quality, 61 worst quality)
* **-b:v 500k**
  * Max video bitrate
* **-an**
  * Strip audio
* **-y**
  * Override output file
* **-strict experimental**
  * Required for libaom-av1
* **-map_metadata -1**
  * Removes metadata
* **-movflags +faststart**
  * Moves file information to the start of the file
* **output-av1.mp4**
  * Output file
