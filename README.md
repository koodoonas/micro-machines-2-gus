# Micro Machines 2 — GUS hardware audio patch

A DOS patch for **Micro Machines 2** that enables the game's existing Gravis Ultrasound GF1 hardware mixer for **both sound effects and tracked music**, with DMA sample uploads and a fix for the timer conflict that otherwise makes this audio path run painfully slowly.

**Version 1.0 has been tested successfully on a 386 with GUS MAX.** The same patched game executable also passed the earlier 486/GUS PnP hardware test.

## What this patch does

The supported game executable contains two GUS playback paths. Its normal GUS selection uses software mixing: the CPU combines audio into a PCM stream for playback through the card. This patch selects the existing GF1 voice-based path instead. The GUS then mixes the playing samples in its onboard RAM.

The CPU still reads tracker events and sends pitch, volume and voice commands. Hardware mixing does not mean the CPU does no audio work.

Version 1.0 combines four changes:

| Change | Result |
| --- | --- |
| Select the existing GF1 hardware-voice backend | Both tracked music and effects use the card's mixer. |
| Redirect sample uploads to the game's DMA helper; increase upload buffer size and alignment to 4 KB | Samples are transferred to card RAM in blocks rather than through the original per-byte upload loop. DMA here loads samples; it is not continuous streaming of a CPU-mixed soundtrack. |
| Run the audio scheduler from the game's existing frame timer | Avoids the separate audio timer competing with the game's video/joystick timer for the PC programmable interval timer (PIT). This fixes the severe slowdown seen with the initial hardware-mixing patches. |
| Replace SOUND.BAT with a corrected setup command | Runs `INSTALL CFG\E_SOUND.CFG` from the game directory, resolving the nested setup path associated with the `e_getset.cfg` error. |

This is a patch to the game's existing audio engine, not a replacement tracker player. It invokes routines already present in your executable. It does not preload all songs at startup, replace the soundtrack or add external sample files.

## Requirements

- A legally obtained copy with the exact supported `MM2.EXE` listed below.
- A working, initialized GF1-compatible GUS configuration.
- An appropriate `ULTRASND` environment variable for your own card.
- `MM2.EXE` and `SOUND.BAT` present in the game directory.

The game reads `ULTRASND` in its usual five-field format:

```
ULTRASND=base,playback_DMA,record_DMA,GUS_IRQ,MIDI_IRQ
```

The base address is hexadecimal; the remaining fields are decimal. Keep your working card settings. The installer does not hardcode a particular address, DMA or IRQ, and does not initialize a PnP card.

## Installation

Download the binary release ZIP and extract `MM2GUS.COM` into your game directory. Run it there:

```dos
MM2GUS
```

Then start the game normally. If necessary, run `SOUND` from that same directory and select the game's Gravis Ultrasound option.

The patch is installed into the executable once. There is no TSR or extra launcher, and Python is not required on the DOS machine.

On a fresh installation the patcher creates:

- `MM2.OLD` — original executable.
- `SOUND.OLD` — original sound setup batch file.

Keep these backups. The installer refuses to overwrite existing backup names on a fresh installation.

## Uninstall

From the game directory:

```dos
MM2GUS /U
```

This restores the original executable and setup batch file from the `.OLD` backups, leaving the backups in place. To reinstall after restoration, first move those retained backups somewhere safe so the installer can create fresh ones.

If a DOS write error interrupts installation, restore `MM2.EXE` from `MM2.OLD` and `SOUND.BAT` from `SOUND.OLD` manually. Keep an additional backup of your game directory before modifying it.

## Compatibility and testing

| System | Result |
| --- | --- |
| 386 / GUS MAX | Version 1.0 reported working well on real hardware. |
| 486 / GUS PnP | Shared-timer test reported working well on real hardware; final v1.0 produces the identical game executable. |
| DOSBox development environment | Fresh installation, v0.2 upgrade, v0.3 recognition and original restoration checked with SHA-256 comparisons. Playback reached the attract race with the tracker and GF1 voices active. |

Other executable revisions and hardware configurations have not been verified. File size and CRC-32 checks reject unsupported executables before patching; the installer also checks the resulting executable.

Supported original `MM2.EXE` SHA-256:

```
3a344aa1107476557db1aac66994c6872f37f3b8aabe4b566c56b1f1caed852c
```

Patched `MM2.EXE` SHA-256:

```
0882cf8b195f46ac092bacd37f506d3b50b145b55dda8d7e702177e8379f8237
```

## Timing and limitations

The audio scheduler receives 17,045 PIT clock ticks per video frame, based on a 70 Hz assumption. Existing tracker timing accumulates these intervals; music events are dispatched in frame-sized steps. Long loading operations or periods with interrupts disabled can still delay music. This is not sample-accurate event scheduling, and the patch does not claim to remove every possible click.

The patch targets the sampled/tracked audio path in the supported executable. It does not implement or modify Red Book CD playback. Behavior of other releases has not been established.

The timer conflict was found during investigation of this patch's slowdown. No verified evidence establishes why the original developers selected their software-mixing path; this project makes no claim about their reasons or a GF1 envelope-related ISA bus fault.

## Building

The repository includes the DOS binary and original NASM patcher source:

```
bin/MM2GUS.COM
src/MM2GUS.ASM
```

Build from the repository root with NASM:

```sh
nasm -f bin src/MM2GUS.ASM -o bin/MM2GUS.COM
```

Or run `make`. NASM is needed only to rebuild the installer.

## Distribution and AI disclosure

The repository and release packages contain the patcher, documentation and checksums. They do not contain a game executable, game source, music, samples or other game assets. The patcher writes small modifications into the user's compatible copy and calls its existing routines.

Development, reverse-engineering analysis and documentation were heavily assisted by AI. Testing and feedback on real GUS hardware were supplied by the project owner.
