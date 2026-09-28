# Micro Machines 2 GUS hardware audio patch 1.0

Enables GF1 hardware mixing for both sound effects and tracked music, with DMA sample uploads and corrected audio scheduling to resolve the severe slowdown encountered with the initial hardware-mixing patches. Includes the sound setup path fix and uses the game's existing ULTRASND configuration.

Tested successfully on a 386 with GUS MAX. The identical patched executable also passed the earlier 486/GUS PnP test.

Download **MM2GUS-1.0-binary.zip**, extract MM2GUS.COM into the game directory and run `MM2GUS`. Restore originals with `MM2GUS /U`. Keep the generated MM2.OLD and SOUND.OLD backups.

Users of the working v0.3 shared-timer test already have the final game changes. Users with an active /M or /V diagnostic probe must first run `MM2PROBE /R`.

Audio scheduling follows the game's frame timer; long loading pauses may still delay music. Only the exact executable identified in the README is supported.

Assets:

- `MM2GUS-1.0-binary.zip`: DOS installer and README.
- `MM2GUS-1.0-source.zip`: source, build instructions and documentation.
- `MM2GUS-1.0-SHA256SUMS.txt`: release archive checksums.

No game executable or game assets are included.
