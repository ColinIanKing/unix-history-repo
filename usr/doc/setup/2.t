.ds lq ``
.ds rq ''
.ds LH "Installing/Operating 4.2BSD
.ds RH Bootstrapping
.ds CF \*(DY
.bp
.nr H1 2
.nr H2 0
.bp
.LG
.B
.ce
2. BOOTSTRAP PROCEDURE
.sp 2
.R
.NL
.PP
This section explains the bootstrap procedure that can be used
to get the kernel supplied with this tape running on your machine.
Even if you are currently running UNIX you will
have to do a full bootstrap.
.PP
If you are already running UNIX you should
first save your existing files on magnetic tape. 
4.2BSD uses a totally different file system organization than previous
versions of the system;
it is thus necessary to rebuild the file system format before
restoring the data.
The easiest way 
to save the current files on tape is by
doing a full dump and then restoring under
the new system.  Refer to chapter 3 in understanding
how to upgrade an existing 4BSD system.
.SH
Booting from tape
.PP
The tape bootstrap procedure used to create a
working system involves the following major
steps:
.IP 1)
Format a disk pack with the \fIformat\fP program.
.IP 2)
Copy a ``mini root'' file system from the
tape onto the swap area of the disk.
.IP 3)
Boot the UNIX system on the ``mini root''.
.IP 4)
Restore the full root file system using \fIrestore\fP\|(8).
.IP 5)
Build a console floppy or cassette for bootstrapping.
.IP 6)
Reboot the completed root file system.
.IP 7)
Build and restore the /usr file system from tape
with \fItar\fP\|(1).
.PP
Certain of these steps are dependent on your hardware
configuration.  Formatting the disk pack used for the
root file system may require using the DEC standard
formatting programs.  Also, if you are bootstrapping
the system on an 11/750, no console cassette is created.
.PP
The following sections describe the above steps in detail.
In these sections references to disk drives are of the
form \fIxx\fP\|(\fIn\fP,\fIm\fP)
and references to files on tape drives are of the form
\fIyy\fP\|(\fIn\fP,\fIm\fP) where \fIxx\fP and \fIyy\fP
are one of the names described in section 1.4 and \fIn\fP
and \fIm\fP are the unit and offset numbers described in
section 1.4.  Commands
you are expected to type are shown in roman, while that
information printed by the system is shown emboldened.
Throughout the installation steps the
reboot switch on an 11/780 or 11/730 should be set to
off; on an 11/750 set the power-on action to halt. (In
normal operation an 11/780 or 11/730 will have the reboot
switch on and an 11/750 will have the power-on action set
to reboot/restart.)
.PP
If you encounter problems in following the instructions in
this part of the document, refer to Appendix C for help in
troubleshooting.
.NH 2
Step 1: formatting the disk
.PP
All disks used with 4.2BSD should be formatted to insure
the proper handling of physically corrupted disk sectors.
If you have DEC disk drives, you should use the standard
DEC formatter to format your disks.  If not, the 
.I format
program included in the distribution, or a vendor supplied
formatting program, may be used to format disks.  The
.I format
program is capable of formatting
any of the following supported distribution devices:
.DS
.TS
lw(1.5i) l.
EMULEX MASSBUS:	AMPEX 300M, 330M, CDC 300M, FUJITSU 404M
EMULEX SC-21V UNIBUS:	AMPEX 300M, 330M, CDC 300M, FUJITSU 160M, 404M
.TE
.DE
.PP
If you have run a pre-4.1BSD version of UNIX on the packs you
are planning to use for bootstrapping it is likely that the
bad sector information on the packs has been destroyed, since
it was accessible as normal data in the last several tracks of
the disk.  You should therefore run the
formatter again to make sure the information is valid.
.PP
On an 11/750, to use a disk pack as a bootstrap device,
sectors 0 through 15, the disk sectors in the files
``/vmunix'' (the system image) and ``/boot'' (the program that
loads the system image),
and the file system indices that lead to these two files
must not have any errors.
On an 11/780 or 11/730, the ``boot'' program is loaded from
the console medium and includes device drivers for the
``hp'' and ``up'' disks which perform
ECC correction and bad sector forwarding; consequently, on
these machines the system may be bootstrapped on these disks
even if the disk is not error free in critical locations. 
In general, if the first 15884 sectors of your disk are
clean you are safe; if not you can take your chances.
.PP
To load the
.I format
program, insert the distribution TU58 cassette or RX01 floppy
disk in the appropriate console device (on the 11/730 use 
cassette 0) and perform the following steps.
.PP
If you have an 11/780 give the commands:
.RT
.DS
\fB>>>\|\fPHALT
\fB>>>\|\fPUNJAM
\fB>>>\|\fPLOAD FORMAT
\fB>>>\|\fPSTART 2
.DE
.PP
If you have an 11/750 give the commands:
.DS
\fB>>>\|\fPI
\fB>>>\|\fPB DDA0
\fB=\|\fPformat
.DE
.PP
If you have an 11/730 give the commands:
.DS
\fB>>>\|\fPH
\fB>>>\|\fPI
\fB>>>\|\fPL DD0:FORMAT
\fB>>>\|\fPS 2
.DE
.PP
The
.I format
program should now be running and awaiting your input:
.DS
\fBDisk format/check utility\fP

\fBEnable debugging (1=bse, 2=ecc, 3=bse+ecc)?\fP
.DE
.PP
If you made a mistake loading the program off the TU58 cassette
the ``='' prompt should reappear and you can retype the program
name.  If something else happened, you may have a bad distribution
cassette or floppy, or your hardware may be broken; refer to
Appendix C for help in troubleshooting.  If you are unable to
load programs off the distributed medium,
consult Appendix B for an alternate (more painful) approach.
.PP
.I Format
will create sector headers and verify the integrity of each
sector formatted by using the disk controller's ``write check''
command.  Remember 
.I format
runs only on the 
.B up
and
.B hp
drives indicated above. 
.I Format
will prompt for the information required as shown below.
If you make a mistake in answering questions,
``#'' erases the last character typed, and ``@'' erases
the current input line.
.DS
\fBEnable debugging (0=none, 1=bse, 2=ecc, 3=bse+ecc)?\fP
\fBDevice to format?\fP \fIxx\|\fP(0,0)
 ...(the old bad sector table is read; ignore any errors that occur here)...
\fBFormatting drive \fIxx\fP0 on adaptor 0: verify (yes/no)?\fP yes
\fBDevice data: #cylinders=842, #tracks=20, #sectors=48\fP
\fBAvailable test patterns are:\fP
.in +1.0i
\fB1 - (f00f) RH750 worst case\fP
\fB2 - (ec6d) media worst case\fP
\fB3 - (a5a5) alternating 1's and 0's\fP
\fB4 - (ffff) Severe burnin (takes several hours)\fP
.in -1.0i
\fBPattern (one of the above, other to restart)?\fP 2
\fBStart formatting...make sure the drive is online\fP
 ...(soft ecc's and other errors are reported as they occur)...
 ...(if 4 write check errors were found, the program terminates like this)...
\fBErrors:\fP
\fBWrite check: 4\fP
\fBBad sector: 0\fP
\fBECC: 0\fP
\fBSkip sector: 0\fP
\fBTotal of 4 hard errors found.\fP
\fBWriting bad sector table at block 524256\fP
(\fI524256 is the block # of the first block in the bad sector table\fP)
\fBDone\fP
.DE
Once the root device has been formatted,
.I format
will prompt for another disk to format.  Halt the machine by
typing ``control-P'' and ``H'' (the ``H'' is necessary only on
an 11/780, but does not hurt on the other machines).
.DS
\fBEnable debugging (1=bse, 2=ecc, 3=bse+ecc)?\fP^P
\fB>>>\|\fPH
.DE
.PP
It may be necessary to format other drives before constructing
file systems on them; this can be done at a later time with the
steps just performed.
.I Format
can also be used in an extended test mode (pattern 4)
that uses numerous test patterns
in 46 passes to detect as many disk surface errors as possible;
this test runs for many hours, depending on the CPU and controller.
On an 11/780, this can be speeded up significantly by setting the
clock fast.
.NH 2
Step 2: copying the mini-root file system
.PP
The second step is to run a simple program,
\fIcopy\fP, which copies a very small root
file system into the second partition of the disk.
This file system will serve as the base for creating the actual root
file system to be restored.  The version of the operating
system maintained on the ``mini-root'' file system understands
not to swap on top of itself, thereby allowing double use
of the disk partition.  \fICopy\fP is loaded just as the
\fIformat\fP program was loaded; for example, on an 11/780:
.DS
.TS
lw(2i) l.
(copy mini root file system)
\fB>>>\|\fPLOAD COPY
\fB>>>\|\fPSTART 2
\fBFrom: \fIyy\fP(\fIy\fP,1)\fR	(unit \fIy\fP, second tape file)
\fBTo: \fIxx\fP(\fIx\fP,1)\fR	(mini root is on drive \fIx\fP; second partition)
\fBCopy completed: 205 records copied\fP
\fBFrom:\fP
.TE
.DE
while for an 11/750:
.DS
.TS
lw(2i) l.
(copy mini root file system)
\fB>>>\|\fPB DDA0
\fB=\|\fPcopy
\fBFrom: \fIyy\fP(\fIy\fP,1)\fR	(unit \fIy\fP, second tape file)
\fBTo: \fIxx\fP(\fIx\fP,1)\fR	(mini root is on drive \fIx\fP; second partition)
\fBCopy completed: 205 records copied\fP
\fBFrom:\fP
.TE
.DE
and for an 11/730:
.DS
.TS
lw(2i) l.
(copy mini root file system)
\fB>>>\|\fPL DD0:COPY
\fB>>>\|\fPS 2
\fBFrom: \fIyy\fP(\fIy\fP,1)\fR	(unit \fIy\fP, second tape file)
\fBTo: \fIxx\fP(\fIx\fP,1)\fR	(mini root is on drive \fIx\fP; second partition)
\fBCopy completed: 205 records copied\fP
\fBFrom:\fP
.TE
(As above, `#' erases characters and `@' erases lines.)
.DE
.NH 2
Step 3: booting from the mini-root file system
.PP
You now have the minimal set of tools necessary to create a
root file system and restore the file system contents from tape.
To access this file system load the bootstrap program
and boot the version of unix which has been placed in the
``mini-root'':
.DS
.TS
lw(2i) l.
(load bootstrap program)
\fB>>>\|\fPLOAD BOOT
\fB>>>\|\fPSTART 2
\fBBoot\fP
\fB: \fP\fIxx\fP(x,1)vmunix	(bring in \fIvmunix\fP off mini root)
.TE
.DE
or, on an 11/750:
.DS
.TS
lw(2i) l.
(load bootstrap program)
\fB>>>\|\fPB DDA0
\fB=\|\fPboot
\fBBoot\fP
\fB: \fP\fIxx\fP(x,1)vmunix	(bring in \fIvmunix\fP off mini root)
.TE
.DE
or, on an 11/730:
.DS
.TS
lw(2i) l.
(load bootstrap program)
\fB>>>\|\fPL DD0:BOOT
\fB>>>\|\fPS 2
\fBBoot\fP
\fB: \fP\fIxx\fP(x,1)vmunix	(bring in \fIvmunix\fP off mini root)
.TE
(As above, `#' erases characters and `@' erases lines.)
.DE
.LP
The standalone boot program should then read the system from
the mini root file system you just created, and the system should boot:
.DS
.B
215564+64088+69764 start 0xf98
4.2 BSD UNIX #1: Sun Feb 6 15:02:15 PST 1983
real mem  = \fIxxx\fP
avail mem = \fIyyy\fP
\fI\&... information about available devices ...\fP
root device? 
.R
.DE
.PP
The first three numbers are printed out by the bootstrap
programs and are the sizes of different
parts of the system (text, initialized and uninitialized data).  The
system also allocates several system data structures after it starts
running.  The sizes of these structures are based on the amount of available
memory and the maximum count of active users expected, as declared in a system
configuration description.  This will be discussed later.
.PP
UNIX itself then runs for the first time and begins by printing out a banner
identifying the release and
version of the system that is in use and the date it was compiled.  
.PP
Next the
.I mem
messages give the
amount of real (physical) memory and the
memory available to user programs
in bytes.
For example, if your machine has only 512K bytes of memory, then
xxx will be 523264, 1024 bytes less than 512K.
The system reserves the last 1024 bytes of memory for use in
error logging and doesn't count it as part of real memory.
.PP
The messages that came out next show what devices were found on
the current processor.  These messages are described in
\fIautoconf\fP\|(4).
The distributed system may not have
found all the communications devices you have (dh's and dz's),
or all the mass storage peripherals you have if you have more than
two of anything.  This will be corrected soon, when you create
a description of your machine to configure UNIX from.
The messages printed at boot here contain much of the information
that will be used in creating the configuration.
In a correctly configured system most of the information
present in the configuration description
is printed out at boot time as the system verifies that each device
is present.
.PP
The \*(lqroot device?\*(rq prompt was printed by the system 
and is now asking you for the name of the root file system to use.
This happens because the distribution system is a \fIgeneric\fP
system.  It can be bootstrapped on any VAX cpu and with its root device
and paging area on any available disk drive.  You should respond
to the root device question with \fIxx\fP0*.  This response
supplies two pieces of information:
first, \fIxx\fP0 indicates the disk it is running on is drive
0 of type \fIxx\fP, secondly the \*(lq*\*(rq indicates the system is
running \*(lqatop\*(rq the paging area.  The latter is most important,
otherwise the system will attempt to page on top of itself and
chaos will ensue.
You will later build a system tailored to your configuration that
will not ask this question when it is bootstrapped.
.DS
\fBroot device?\fP \fIxx\fP0*
WARNING: preposterous time in file system \-\- CHECK AND RESET THE DATE!
\fBerase ^?, kill ^U, intr ^C\fP
\fB#\fP
.DE
.PP
The \*(lqerase ...\*(rq message is part of /.profile
that was executed by the root shell when it started.  This message
is present to remind you that the line character erase,
line erase, and interrupt characters are set to be what
is standard on DEC systems; this insures things are
consistent with the DEC console interface characters.
.NH 2
Step 4: restoring the root file system
.PP
UNIX is now running,
and the `UNIX Programmer's manual' applies.
The `#' is the prompt from the shell,
and lets you know that you are the super-user,
whose login name is \*(lqroot\*(rq.  To complete installation
of the bootstrap system two steps remain.  First, the root
file system must be created, and second a boot floppy or
cassette must be constructed.
.PP
To create the root file system the shell script \*(lqxtr\*(rq
should be run as follows:
.DS
\fB#\|\fPdisk=\fIxx0\fP  type=\fItt\fP  tape=\fIyy\fP  xtr
.DE
where \fIxx0\fP is the name of the disk on which the root
file system is to be restored (unit 0), \fItt\fP is the type of
drive on which the root file system is to be restored
(see the table below),
and \fIyy\fP is the name
of the tape drive on which the distribution tape is mounted.
.PP
If the root file system is to reside on a disk other than
unit 0 (as shown in
the information printed out during autoconfiguration), you will
have to create the necessary special files in /dev and use
the appropriate value. For example, if the root should be
placed on hp1, you must create /dev/rhp1a and /dev/hp1a using 
\fImknod\fP(8).
.DS
.TS
l l | l l.
Drive	Type	Drive	Type
_
DEC RM03	type=rm03	DEC RM05	type=rm05
DEC RM80	type=rm80	DEC RP06	type=rp06
DEC RP07	type=rp07	DEC RK07	type=rk07
DEC RA80	type=ra80	DEC RA60	type=ra60
DEC RA81	type=ra81	DEC R80	type=rb80
CDC 9766	type=9766	CDC 9775	type=9775
AMPEX 300M	type=9300	AMPEX 330M	type=capricorn
FUJITSU 160M	type=fuji160	FUJITSU 404M	type=eagle
.TE
.DE
This will generate many messages regarding the construction
of the file system and the restoration of the tape contents,
but should eventually terminate with the messages:
.DS
 ...
\fBRoot filesystem extracted\fP

\fBIf this is a 780, update floppy\fP
\fBIf this is a 730, update the cassette\fP
\fB#\fP
.DE
.NH 2
Step 5: creating a boot floppy or cassette
.PP
If the machine is an 11/780 or 11/730, a boot floppy
or cassette should be constructed according to the instructions
in chapter 4.  For 11/750's, bootstrapping is performed by
using a boot prom and special code located in sectors 0-15 of the
root file system.  The 
.I newfs
program automatically installs the needed code, so you may continue
on to the next step.
On an 11/780 with interleaved memory, or other configurations that
require alteration of the standard boot files, this step may
be left for later.
.NH 2
Step 6: rebooting the completed root file system
.PP
With the above work completed, all that is left is to reboot:
.DS
.ta 3.5i
\fB#\|\fPsync	(synchronize file system state)
\fB#\|\fP^P	(halt machine)
\fB>>>\|\fPHALT	(for 11/780's only)
\fB>>>\|\fPUNJAM	(for 11/780's only)
\fB>>>\|\fPI	(initialize processor state)
\fB>>>\|\fPB \fIxx\fPS	(on an 11/750, use B/2)
\fI\&...(boot program is eventually loaded)...\fP
\fBBoot\fP
\fB: xx(x,0)vmunix\fP	(\fIvmunix\fP brought in off root)
\fB215564+64088+69764 start 0xf98\fP
\fB4.2 BSD UNIX #1: Sun Feb 6 15:02:15 PST 1983\fP
\fBreal mem  = \fIxxx\fR
\fBavail mem = \fIyyy\fR
\fI\&... information about available devices ...\fP
\fBroot on xx0\fP
WARNING: preposterous time in file system \-\- CHECK AND RESET THE DATE!
\fBerase ^?, kill ^U, intr ^C\fP
\fB#\fP

(see section 6.1 if the system does not reboot properly)
.DE
.PP
The system is now running single user on the installed
root file system.  The next section tells how to complete
the installation of distributed software on the /usr file system.
.NH 2
Step 7: setting up the /usr file system
.PP
First set a shell variable to the name of your disk, so
the commands we give will work regardless of the disk you
have; do one of
.DS
.TS
l l.
\fB#\fP disk=hp	(if you have an RP06, RM03, RM05, RM80, or other MASSBUS drive)
\fB#\fP disk=hk	(if you have RK07s)
\fB#\fP disk=ra	(if you have UDA50 storage module drives)
\fB#\fP disk=up	(if you have UNIBUS storage module drives)
\fB#\fP disk=rb	(if you have IDC storage module drives)
.TE
.DE
.PP
The next thing to do is to extract the rest of the data from
the tape.
You might wish to review the disk configuration information in section 4.4
before continuing; the partitions used below are those most appropriate
in size.
Find the disk you have in the following table and execute
the commands in the right hand portion of the table:
.DS
.TS
l l.
DEC RM03	\fB#\fP name=hp0g; type=rm03
DEC RM05	\fB#\fP name=hp0g; type=rm05
DEC RM80	\fB#\fP name=hp0g; type=rm80
DEC RP06	\fB#\fP name=hp0g; type=rp06
DEC RP07	\fB#\fP name=hp0h; type=rp07
DEC RK07	\fB#\fP name=hk0g; type=rk07
DEC RA80	\fB#\fP name=ra0h; type=ra80
DEC RA60	\fB#\fP name=ra0h; type=ra60
DEC RA81	\fB#\fP name=ra0h; type=ra81
DEC R80	\fB#\fP name=rb0h; type=rb80
UNIBUS CDC 9766	\fB#\fP name=up0g; type=9766
UNIBUS AMPEX 300M	\fB#\fP name=up0g; type=9300
UNIBUS AMPEX 330M	\fB#\fP name=up0g; type=capricorn
UNIBUS FUJITSU 160M	\fB#\fP name=up0g; type=fuji160
UNIBUS FUJITSU 404M	\fB#\fP name=up0h; type=eagle
MASSBUS CDC 9766	\fB#\fP name=hp0g; type=9766
MASSBUS AMPEX 300M	\fB#\fP name=hp0g; type=9300
MASSBUS AMPEX 330M	\fB#\fP name=hp0g; type=capricorn
MASSBUS FUJITSU 404M	\fB#\fP name=hp0h; type=eagle
.TE
.DE
Find the tape you have in the following table and execute the
commands in the right hand portion of the table:
.DS
.TS
l l.
DEC TE16/TU45/TU77	\fB#\fP cd /dev; MAKEDEV ht0; sync
DEC TU78	\fB#\fP cd /dev; MAKEDEV mt0; sync
DEC TS11	\fB#\fP cd /dev; MAKEDEV ts0; sync
EMULEX TC11	\fB#\fP cd /dev; MAKEDEV tm0; sync
SI 9700	\fB#\fP cd /dev; MAKEDEV ut0; sync
.TE
.DE
Then execute the following commands
.br
.ne 5
.sp
.DS
.TS
lw(2i) l.
\fB#\fP date \fIyymmddhhmm\fP	(set date, see \fIdate\fP\|(1))
\&....
\fB#\fP passwd root	(set password for super-user)
\fBNew password:\fP	(password will not echo)
\fBRetype new password:\fP
\fB#\fP newfs ${name} ${type}	(create empty user file system)
(this takes a few minutes)
\fB#\fP mount /dev/${name} /usr	(mount the usr file system)
\fB#\fP cd /usr	(make /usr the current directory)
\fB#\fP mkdir sys	(make directory for system source)
\fB#\fP cd sys	(make /usr/sys the current directory)
\fB#\fP mt fsf
\fB#\fP tar xpbf 20 /dev/rmt12 	(extract the system source)
(this takes about 5-10 minutes)
\fB#\fP cd ..	(back to /usr)
\fB#\fP mt fsf
\fB#\fP tar xpbf 20 /dev/rmt12 	(extract all of usr except usr/src)
(this takes about 15-20 minutes)
\fB#\fP cd /	(back to root)
\fB#\fP chmod 755  /  /usr  /usr/sys
\fB#\fP rm \-f sys
\fB#\fP ln \-s /usr/sys sys	(make a symbolic link to the system source)
\fB#\fP umount /dev/${name}	(unmount /usr)
.TE
.DE
The data on the fourth and fifth tape files has now been extracted
and the first reel of the distribution is no longer needed.
The remainder of the installation procedure uses the second
reel of tape which should be mounted in place of the first.
.PP
You can check the consistency of the /usr file system by doing
.DS
\fB#\fP fsck /dev/r${name}
.DE
The output from
.I fsck
should look something like:
.DS
.B
** /dev/r\fIxx\fP0h
** Last Mounted on /usr
** Phase 1 - Check Blocks and Sizes
** Phase 2 - Check Pathnames
** Phase 3 - Check Connectivity
** Phase 4 - Check Reference Counts
** Phase 5 - Check Cyl groups
671 files, 3497 used, 137067 free (75 frags, 34248 blocks)
.R
.DE
.PP
If there are inconsistencies in the file system, you may be prompted
to apply corrective action; see the document describing
.I fsck
for information.
.PP
To use the /usr file system, you should now remount it by
saying
.DS
\fB#\fP /etc/mount /dev/${name} /usr
.DE
You can now extract the first file on the
second tape (the source for the commands).
If you have RK07's you must first put a formatted pack in drive 1
and set up a UNIX file system on it by doing:
.DS
\fB#\fP newfs hk1g rk07
(this takes a few minutes)
\fB#\fP mount /dev/hk1g /usr/src
\fB#\fP cd /usr/src
.DE
In any case you can then extract the source code for the commands
(except on RK07's this will fit in the /usr file system):
.DS
\fB#\fP mkdir /usr/src
\fB#\fP chmod 755 /usr/src
\fB#\fP cd /usr/src
\fB#\fP tar xpb 20
.DE
If you get an error at this point, you can reposition the tape with the
following command and try the above commands again.
.DS
\fB#\fP mt rew
.DE
.NH 2
Additional software
.PP
There are three extra tape files on the distribution tapes
which have not been installed to this point.  They are
a font library for use with Varian and Versatec printers,
the Ingres database system, and user contributed software.
All three tapes files are in \fItar\fP\|(1) format and
can be installed by positioning the tape and reading
in the files as was done for /usr/src above.  As distributed,
the fonts should be placed in a directory /usr/lib/vfont, the
Ingres system should be placed in /usr/ingres, and the user
contributed software should be placed in /usr/src/new.  The
exact contents of the user contributed software is given in
a separate document.
