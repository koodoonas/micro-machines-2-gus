# Changelog

## 1.0

First final release, combining GF1 hardware mixing for music and effects, 4 KB DMA sample uploads, shared frame-timer scheduling, and the sound setup path correction in one DOS installer.

The patched game executable is identical to the successful shared-timer test v0.3. Real-hardware success was reported on 386/GUS MAX and, for the identical v0.3 executable, 486/GUS PnP.

## Development builds

- v0.3: shared frame timer resolved the severe slowdown in reported hardware testing.
- v0.2: DMA sample upload optimization; slowdown remained.
- v0.1: enabled the existing GF1 hardware-voice backend; severe slowdown was reported.
