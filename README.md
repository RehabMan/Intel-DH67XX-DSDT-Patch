## DSDT Patches for Intel DH67GD, DH67BL, DH67CF, DH67CL

These are the patches I am using for my hackintosh based on the Intel DH67GD board.

I started with the following file:
http://olarila.com/Packs/Intel/DH67GD.txt

… And then started fixing things … 

In particular:


### Added fixes for compilation errors that only result in current versions of the iasl compiler.

DWordMemory range incorrect.
Buffer being used for _PLD object instead of Package of Buffers
Package being used for _FDE object instead of Buffer


### Fixed Sleep

The DSDT code for the _PTS method ends up calling a method IOKS which appears to be trying to talk to the PS/2 port for mouse and keyboard.  I don't know about the DH67 board they have at Intel headquarters, but the one I have here doesn't have a PS/2 port (it is legacy free).

The PS/2 code, present in the IOKS method, causes a delay entering sleep mode.  I never timed it, but it must be something like 2 or more minutes.  Eventually, the computer would sleep and wake-up just fine, but during that 2 minutes the display is off and the computer is unresponsive.  The patch for the IOKS method just removes all code there to make it an empty method.

So far, I've not had any thing bad happen as a result of this patch.


### I used the Shutdown fix from "Shutdown Intel.txt" instead of the one originally in the file.  So far, shutdown works fine (except for the intermittent Mountain Lion delay that seems to be Apple's issue)


### Added Scope (_PR) with Processor definitions.  

I think this is required to use an SSDT as the SSDT I'm using refers to these objects as external.


### Added device ID injection for the integrated graphics.

Made it device ID 0x0116 (vendor 0x8086), so that it is possible to use vanilla AppleIntelSNBGraphicsFB.kext and AppleIntelHD3000Graphics.kext.  This patch is not strictly necessary, as you can always edit the Info.plist for those two kexts to allow the native ID to load the kexts (native ID for my i7-2600k is 0x0122).

But this way allows easier OS updates, since we are using less patched kexts (even though it is a relatively easy text-only patch).


### Misc. comments and formatting changes.

Made the patch file easier to read.


### How to use the patch.

You can use DSDT Editor from the following link:

http://www.insanelymac.com/forum/index.php?showtopic=223205

Download DSDT Editor, then use the patch text file contained here to patch your native DSDT.  You can extract your native DSDT using RW-Everything under Windows or using acpidump on Linux.  Also, if your computer boots with DSDT=No (or you are using the Windows version of DSDT Editor), you can extract your original DSDT with DSDT Editor itself.

The two files included are all the patches needed:

dh67gd.txt - Has all patches including HDEF patch for Mountain Lion.

dh67gd_lion_hdef.txt - Apply this patch *after* applying dh67gd.txt.  It re-writes the HDEF for Lion compatibility.


