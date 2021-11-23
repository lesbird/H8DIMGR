# H8DIMGR
Heathkit client to work alongside [H8DUtility 3](https://github.com/lesbird/H8DUtility3)

A utility written in 8080 ASM to send and receive disk images from a PC/Mac running H8DUtility 3. Sends data at 38,400 baud. A full one sided 40 track disk image can be send to H8DUtility in less than 1 minute and received from H8DUtility in a little more than a minute.

H8DIMGR2.ASM - deprecated<br>
H8DIMGR3.ASM - deprecated<br>
H8DIMGR4.ASM - current WIP

On the Heathkit H8/H89 computer assemble the source file as follows<br>
Requires all supporting ACM files to be on the drive where H8DIMGR4.ASM resides<br>
In HDOS 2 if ASM.ABS is in SY0: and H8DIMGR4.ASM is in drive SY1:<br>

>ASM SY1:H8DIMGR4,=SY1:H8DIMGR4<br>

This will create H8DIMGR4.ABS on the SY1: drive

H8DIMGR4.ASM has been completely rewritten from the ground up. The code has been cleaned up and all jump vectors are restored from the ULTIMETH HSY driver routines to the original ROM routines. Only the necessary jump vectors (D.DTS and D.SDT) are intercepted and overridden to support multisided disks.
