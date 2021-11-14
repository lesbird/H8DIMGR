
*
*
*
$TYPTX  EQU     31136A
AIO.UNI EQU     41061A          DEVICE UNIT NO.
ERPTCNT EQU     10              Soft Error Retry Count
**      H17 Control Information
DP.DC   EQU     07FH            Disk control port
DF.HD   EQU     00000001B       Hole Detect
DF.T0   EQU     00000010B       Track 0 detect
DF.WP   EQU     00000100B       Write protect
DF.SD   EQU     00001000B       Sync Detect

DF.WG   EQU     00000001B       Write gate enable
DF.DSO  EQU     00000010B       Drive select 0
DF.DS1  EQU     00000100B       Drive select 1
DF.DS2  EQU     00001000B       Drive select 2

DF.MO   EQU     00010000B       Motor On (both drives)
DF.DI   EQU     00100000B       Direction (0  out)
DF.ST   EQU     01000000B       Step command (active high)
DF.WR   EQU     10000000B       Write nable RAM

**      Disk UART portsand control flags
UP.DP   EQU     07CH            Data port
UP.FC   EQU     07DH            Fill Character
UP.ST   EQU     07DH            Status flags
UP.SC   EQU     07EH            Syn character (otput)
UP.SR   EQU     07EH            Sync reset (input)

UF.RDA  EQU     00000001B       Receive data available
UF.ROR  EQU     00000010B       Receiver overrun
UF.RPE  EQU     00000100B       Receiver parity error
UF.FCT  EQU     01000000B       Fill character transmitted
UF.TBM  EQU     10000000B       Transmitter buffer empty

**      IO PORTS
IP.PAD  EQU     360Q            PAD INPUT PORT
OP.CTL  EQU     360Q            CONTROL OUTPUT PORT
OP.DIG  EQU     360Q            DIGIT SELECT OUTPU PORT
OP.SEG  EQU     361Q            SEGMENT SELECT OUTPUT PORT
IP.CON  EQU     362Q            H-88/H-89/HA-8-8 Configuration  /80.07.gc/
OP2.CTL EQU     362Q            -88/H-89/HA-8-8 Control Port    /80.07.gc/

**      FRONT PANEL CONTROL BITS.                               /80.07.gc/
CB.SSI  EQU     00010000B       SINGLE STEP INTERRUPT
CB.MTL  EQU     00100000B       MONITOR LIGHT
CB.CLI  EQU     01000000B       CLOCK INTERRUPT ENABLE
CB.SPK  EQU     10000000B       SPEAKER ENABLE

CB2.SSI EQU     0000001B        Single Step Interrupt
CB2.CLI EQU     00000010B       Clock Interrupt Enable
CB2.ORG EQU     00100000B       ORG 0 Select
CB2.SID EQU     01000000B       Side 1 Select

**      Error Code Definitions
        ORG     0
        DS      1       No error #0
EC.EOF  DS      1       End of ile
EC.EOM  DS      1       End of media
EC.ILC  DS      1       Illegal SYSCALL code
EC.CNA  DS      1       Channel not available
EC.DNS  DS      1       Device not suitable
EC.IDN  DS      1       Illegal device name
EC.IFN  DS      1       Illegal file name
EC.NRD  DS      1       No room dor devic driver
EC.FNO  DS      1       channel not open
EC.ILR  DS      1       Illegal request
EC.FUC  DS      1       File name conflict
EC.FNF  DS      1       File name not found
EC.UND  DS      1       Unknown device
EC.ICN  DS      1       Illegal channel number
EC.DIF  DS      1       Directory full
EC.IFC  DS      1       Illegal file cotents
EC.NEM  DS      1       Not enough memory
EC.RF   DS      1       Read failure
EC.WF   DS      1       Write failure
EC.WPV  DS      1       Write protection violation
EC.WP   DS      1       disk write protected
EC.FAP  DS      1       file already present
EC.DDA  DS      1       device diver abort
EC.FL   DS      1       file locked
EC.FAO  DS      1       file already open
EC.IS   DS      1       illegal switch
EC.UUN  DS      1       unknown unit number
EC.FNR  DS      1       file name required
EC.DIW  DS      1       device is not readable
EC.UNA  DS      1       unit not available
EC.ILV  DS      1       llegal value
EC.ILO  DS      1       illegal option

*
        XTEXT   HOSDEF
*
CLOCK   EQU     34031A
WSP1    EQU     36355A          WRITE SYNC PATTERN C=NUM ZEROS,D=CHKSUM
MFLAG   EQU     40010A
UIVEC   EQU     40037A
DWRITA  EQU     40112A
DWRITB  EQU     40113A
DWRITC  EQU     40114A
DLPSA   EQU     40116A
DWHDA   EQU     40123A
DWNHA   EQU     40124A
DWSCA   EQU     40125A
DXOK    EQU     40136A
DABORT  EQU     40141A          DISK ABORT TO TRACK 0
DXIT    EQU     40144A
*DCDE   EQU     40160A
DMAI    EQU     40171A          MOVE ARM IN
DMAO    EQU     40174A          MOVE ARM OUT
*DLPS   EQU     40177A
DRDB    EQU     40202A          READ BYTE D=CHKSM,EXIT A=BYTE,D=CHKSUM
DSDP    EQU     40205A          SET DEVICE PARMS AIO.UNI,D.DVCTL=MOTORON+DEVSEL,
DSTS    EQU     40210A          SKIP THIS SECTOR
DSTZ    EQU     40213A          SEEK TRACK ZERO
DUDLY   EQU     40216A
DWSC    EQU     40221A          WAIT SYNC CHAR
DWSP    EQU     40224A
DWNB    EQU     40227A          WRITE NEXT BYTE A=CHAR,D=CHKSUM
DERRT   EQU     40232A
DTT     EQU     40240A          TARGET TRACK
DTS     EQU     40241A          TARGET SECTOR
DDVCTL  EQU     40242A
DDLYMO  EQU     40243A          DRIVE DELAYS
DDLYHS  EQU     40244A
DTRKPT  EQU     40245A
DVOLPT  EQU     40247A
DDRVTB  EQU     40251A
HECNT   EQU     40261A          HARD ERROR CONT
SECNT   EQU     40262A          SOFT ERROR CONT
OECNT   EQU     40264A          OPERATION ERROR COUNT
DEMDS   EQU     40265A          MISSING DATA SYNC ERROR
DECHK   EQU     40267A          DATA CHECKSUM ERROR
DOPR    EQU     40273A
DOPW    EQU     40275A
*
*       H17 DISK SYSTEM EQUATES
*
CTLPRT  EQU     0F2H            H88 CONTROL PORT
CTLBYTE EQU     40066A          2036H CURRENT CONTENTS OF CONTROL LATCH
*
* Ports for H8-4
*
LP4     EQU     0E0H
TX4     EQU     LP4
RX4     EQU     LP4
DVL4    EQU     LP4
DVH4    EQU     LP4+1
IER4    EQU     LP4+1
LCNTL4  EQU     LP4+3
MCNTL4  EQU     LP4+4
LSTAT4  EQU     LP4+5
*
ZBUF    EQU     0A00H
TBUF    EQU     1000H           TRACK BUFFER SIZE
ZSTK    EQU     100H
*
        ORG     42200A
START   JMP     BOOT            Jump to Boot code

***     READ - read from disk
*
*       ENTRY   (BC) = count
*               (DE) = address
*               (HL) = block number
*               Interrupts enabled
*       EXIT    (DE) =next unused address
*               Interrupts disabled
*       USES    All

DREAD   PUSH    H               SAVE (HL)
        CALL    DSDP            SETUP DEVICE PARAMETERS
        LHLD    DOPR
        INX     H
        SHLD    DOPR            COUNT OPERATION

*       read to read sector
*       (BC) = amount
*       (DE) = address
*       ((SP)) = sector number

READ1   POP     H               (HL) = sector number
        PUSH    D               Save address
        MOV     A,C             Adjust (B) so that (B) = # of whole or partial
        ANA     A               sectors to read. (C) = bytes of last sector to
        JZ      READ1.5         read. (C) = 0 if to read entire last sector
        INR     B

**      **** NOTE ****
*       This code runs with interrrupts disabled from here on

READ1.5 PUSH    B               Save count
        CALL    DDTS            Decode track and sector
READ2   MVI     A,1             (A) = delay count for start
*       Look for right sector
*       (A) = delay count before search

READ2.4 CALL    DUDLY           Delay some uS
        CALL    DLPS            Locate proper sector
        JC      READ7           ERROR
        POP     B               (BC) = count
        POP     H               (HL) = address for data

*       check amount to read

READ3   MOV     A,B
        ORA     C
        JZ      READ8           No more to read
        PUSH    H
        PUSH    B               Save count and address in case of error
        DCR     B               See if on last (maybe partial) sector
        JZ      READ3.5         On last sector, read (C) count
***** Start of page 43
        MVI     C,0             will read all 256 bytes
READ3.5 MOV     B,C             (B) = # to read +1, (C) = # to skip
        CALL    DWSC            Wait for sync character
        JC      READ71          Didn't get one

*       READ DATA
READ4   CALL    DRDB            READ BYTE
        MOV     M,A             STORE
        INX     H
        DCR     B
        JNZ     READ4           MORE TO GO
        MOV     A,C
        ANA     A
        JZ      READ6           NONE O DISCARD

*       READ, CHECKSUM, AND DISCARD DATA
READ5   CALL    DRDB
        INR     C
        JNZ     READ5
READ6   MOV     B,D             (B) = CHECKSUM
        CALL    DRDB
        CMP     B
* H8DIMGR IGNORES DATA CHECKSUM
*       JNE     READ72          CHECKSUM ERROR

*       GOT GOO SECTOR
        POP     B               (BC) = OLD COUNT
        DCR     B               COUNT SECTOR READ
        JZ      READ8           JUST READ LAST ONE

*       HAVE MORE TO READ
        XTHL                    SAVE ADDRESS
        PUSH    B               SAVE COUNT
        LXI     H,DTS
        INR     M               COUNT SECTOR
        MVI     A,10
        SUB     M
        MVI     A,0
        JNE     READ2.4         Not at end of track
        MOV     M,A             Sector # = 0
        DCX     H
        INR     M
        EI                      Restore interrupts until *STS* called
        CALL    DSDT            Seek desired track
        JMP     READ2

*       Can't get data, header or checksum problem
READ71  LXI     H,DEMDS         Missing data sync error
        CALL    DERRT
        JMP     READ7
READ72  LXI     H,DECHK         Checksum error
        CALL    DERRT

READ7   CALL    DCDE            Count disk error
        JNC     READ2           Try again
        POP     B
        POP     D
        MVI     A,EC.RF         Read failure
        JMP     DXIT            Too many errors, too bad

*       Entire read was ok
READ8   POP     H               Clean stack
        JMP     DXOK            Exit ok

***     READR - read disk regardless of volume protection
*
*       ENTRY   (BC) = count
*               (DE) = address
*               (HL) = block #
*       EXIT    (DE) = next unused address
*       USES    All

READR   PUSH    H               Save (HL)
        CALL    DSDP            Setup device parameters
        LXI     H,ZEROS
        SHLD    DVOLPT
        JMP     READ1           Process as regular read

**      Constant zeros
ZEROS   DB      0,0,0,0,0,0,0,0

***     WRITE - process disk write
*
*       ENTRY   (BC) = count
*               (DE) = address
*               (HL) = block #
*       EXIT    (LINK) = last block #
*       USES    All

DWRITE  EQU     *
        PUSH    H               Save block #
        CALL    DSDP            Set device parameters
        LHLD    DOPW
        INX     H
        SHLD    DOPW            Count operation
        IN      DP.DC           See if disk write protected
        ANI     DF.WP
        STC
        MVI     A,EC.WP
        JNZ     WRITE8          Disk is write protected

*** Redy to write sector
*
*  (BC) = ount
*  (DE) = address
*   ((SP)) = sector number

        LXI     H,377Q
        DAD     B
        MOV     B,H             (B) = # sectors to write

WRITE1  POP     H               (HL) = sector number
        PUSH    D               Save addrss

*       ** NOTE **
* This code runs with interrupts disabled form this point on
        CALL    DDTS            Determine track and sector
WRITE2  MVI     A,1             (A) = short delay count

* find right sector (A0 =delay count
WRIT2.5 CALL    DUDLY           Delay some microsecs
        PUSH    B               Save count
        CALL    DLPS            Locate proper sector (DI)
        POP     B               (BC) = count
        JC      WRITE7          Can't find it
        POP     H               (HL) = address
        LDA     DWRITA          (A) = guardband delay
WRITE4  DCR     A
        JNZ     WRITE4          Pause over guardband
        LDA     DWRITB
        MOV     C,A             (C) = # of 00 characters
        LDA     DWRITC          (A)= 128/2 = two character times before writing
        CALL    DWSP            Write sync pattern

WRITE5  MOV     A,M
        CALL    DWNB
        INX     H
        DCR     C
        JNZ     WRITE5          Not done yet so loop
        MOV     A,D             (A) = checksum
        CALL    DWNB            Write checksum

*       Have completed writing, leave write-gate open for 3 character times
*       to finish tunnel erasing

        CALL    DWNB
        CALL    DWNB
        CALL    DWNB
        LDA     DDVCTL
        OUT     DP.DC           Off disk control
        DCR     B
        JZ      DXOK            All done
        PUSH    H               SAVE ADDRSS
        LXI     H,DTS
        INR     M
        MVI     A,10
        SUB     M
        MVI     A,0
        JNZ     WRIT2.5         Not at end of track

*       move to next track
        MOV     M,A             clear current sector idex
        DCX     H
        INR     M
        EI                      Restore interrupts until *STS* call
        CALL    DSDT            Seek desired track
        JMP     WRITE2

*       ERROR
WRITE7  CALL    DCDE            Count disk error
        JNC     WRITE2          try again
        MVI     A,EC.WF         write failure
WRITE8  POP     H               restore stack
        JMP     DXIT            Too many .. try again

***     DS - decode track and sector
*       DTS decdes the track and sector number from
*       the supplied sector index
*
*       ENTRY   (HL) = sector index
*               Interrupts enabled
*       XIT     D.TS = sector number
*               D.TT = track number
*               Interrupts disabled
*       USES    A,F,H,L

DDTS    PUSH    B               Save (BC)
        LXI     B,-10
        MOV     A,B             (A) = 377Q
DTS1    INR     A
        DAD     B
        JC      DTS1
        STA     DTT             Set track number
        MOV     A,L
        ADI     10
        STA     DTS             Set sector
        POP     B               restore (BC)
* H8DIMGR CALLS ITS OWN VERSION OF DSDT
        JMP     DSDT            Seek desired track

***     SDT - set desired track
*       SDT moves the disk arm to the desired (D.TT) track
*       and sets the side bit i its a ss or ds disk
*
*       ENTRY   None
*       EXIT    None
*       USES    A,F,H,L
*       Move arm in
SDT3    INR     M
        CALL    DMAI

DSDT    LHLD    DTRKPT
        LDA     DTYPE
        ORA     A
        JZ      DSDT0           40 TRACK 1 SIDE
        CPI     1
        JZ      DSDT1           40 TRACK 2 SIDES
        CPI     2
        JZ      DSDT2           80 TRACK 1 SIDE
DSDT3   LDA     DTT             80 TRACK 2 SIDES
        RAR
        JMP     DSDTA
DSDT0   LDA     AIO.UNI         40 TRACK 1 SIDE
        ORA     A
        LDA     DTT
        JZ      DSDTA
        ADD     A               DOUBLE STEP
        JMP     DSDTA
DSDT1   LDA     AIO.UNI         40 TRACK 2 SIDES
        ORA     A
        LDA     DTT
        JZ      DSDT1A
        RAR
        ADD     A               DOUBLE STEP
        JMP     DSDTA
DSDT1A  RAR
        JMP     DSDTA
DSDT2   LDA     DTT             80 TRACK 1 SIDE
DSDTA   CMP     M
        JE      MSTS
        JP      SDT3

*       Move arm out
SDT1    DCR     M               update track number
        CALL    DMAO            move arm out
        JMP     DSDT            see if arm there yet
*
*       STS - skip this sector, set proper side based on DTT and DTYPE
*
MSTS    CALL    DSTS
        LDA     DTYPE
        ORA     A
        JZ      SETS0
        CPI     2
        JZ      SETS0
        LDA     DTT
        ANI     1
        JNZ     SETS1
        JMP     SETS0

***     CDE - count disk errors
*       CD is called when a disk soft error occurs.  If there have
*       been 10 soft errors for this operation then a hard error
*       is flagged.
*
*       ENTRY   None
*       EXIT    'C' set if hard rror
*               Interrupts disabled
*       USES    A,F,H,L

DCDE    EI
* H8DIMGR IGNORES TRACK RE-SEEKS
*       CALL    DSTZ            Seek track zero
        CALL    DSDT            seek desired track (DI)
        ANA     A               Clear carry
        LHLD    SECNT
        INX     H
        SHLD    SECNT           Increment count
        LXI     H,OECNT (HL) = # operation error count
        DCR     M
        RP                      Not too many
        DCX     H
        MVI     A,-ERPTCNT
        ADD     M               Remove soft count
        MOV     M,A
        INR     M               Count hard error
        STC
        RET                     Exit with 'C' set

BOOT    EQU     *
        CALL    $TYPTX
        DB      0AH,'H8DIMGR V1.0',0AH
        DB      'ALL PURPOSE HARD SECTOR DISK IMAGER (C) 2013 Les Bird',0AH
        DB      0AH
        DB      'Reads all Heatkit hard sector disk types and transmits',0AH
        DB      'the data via the serial LP port (340Q) to a PC running the',0AH
        DB      'H8DUtility V1.51 or later.',0AH,0AH
        DB      'Supported formats: CP/M + HDOS - 40/80 TRACK - SS/DS',0AH
        DB      'Disk type is automatically detected.',0AH
        DB      0AH
        DB      'Configure your Heathkit computer as follows:',0AH
        DB      'SY0 = 40 TRACK SINGLE SIDE',0AH
        DB      'SY1 = 80 TRACK DOUBLE SIDE',8AH
*
* DISMOUNT ALL DRIVES
*
        LXI     H,DEV1
        SCALL   .DMNMS
        LXI     H,DEV2
        SCALL   .DMNMS
        LXI     H,DEV3
        SCALL   .DMNMS
*
* SET DEFAULT DEVICE TO SY0
*
        DI
        LXI     SP,SPINT

        XRA     A
        STA     AIO.UNI         SET UNT 0 (SY0)
        OUT     DP.DC           Off disk

        LDA     DWSCA
        STA     DEFWSCA

        INR     A
        STA     MFLAG

*       LXI     H,UIVEC         (HL) = .UIVEC address, (A) = 1
*BOOT2  MVI     M,303Q
*       INX     H
*       MVI     M,#EIXIT
*       INX     H
*       MVI     M,EIXIT/256
*       INX     H
*       ADD     A               Shift '1' into (A) left 1
*       JP      BOOT2           More to go

*       Setup clock interrupts
        MVI     A,303Q
        STA     UIVEC
        LXI     H,CLOCK
        SHLD    UIVEC+1
        EI
        CALL    SINT
        JMP     LDRCM0

EIXIT   EI
        RET
*
* SETUP LPT PORT FOR 9600,8N2
*
SINT    DI
        XRA     A
        OUT     LCNTL4
        OUT     IER4
        OUT     MCNTL4
        DCR     A
        OUT     LCNTL4
        MVI     A,03H           38400 BAUD
*       MVI     A,0CH           9600 BAUD
        OUT     DVL4
        XRA     A
        OUT     DVH4
        MVI     A,07H
        OUT     LCNTL4
        IN      LSTAT4
        IN      RX4
        EI
        RET
*
SINT2   DI
        XRA     A
        OUT     LCNTL4
        OUT     IER4
        OUT     MCNTL4
        DCR     A
        OUT     LCNTL4
        MVI     A,06H           19200 baud
        OUT     DVL4
        XRA     A
        OUT     DVH4
        MVI     A,07H
        OUT     LCNTL4
        IN      LSTAT4
        IN      RX4
        EI
        RET
*
LDRCM0  CALL    $TYPTX
        DB      0AH,'CLIENT READY',8AH
LDRCM1  CALL    CHRIN
        CPI     0
        JZ      LDRCM1
*       SCALL   .SCOUT
        CPI     'R'
        JZ      RDIMG           Begin transfer using current source device
        CPI     'W'
        JZ      WRIMG
*       CPI     'S'
*       JZ      SVLDR
        CPI     'V'
        JZ      SETV
        CPI     'C'
        JZ      CHKV
*       CPI     'I'
*       JZ      INTRLV
        CPI     'T'
        JZ      RDDV
        CPI     '0'
        JZ      SETSY0          Set SY0 as working device
        CPI     '1'
        JZ      SETSY1          Set SY1 as working device
        CPI     '2'
        JZ      SETSY2          Set SY2 as working device
        CPI     '4'
        JZ      SETD0           Set disk type 0 - 1S40T
        CPI     '5'
        JZ      SETD1           Set disk type 1 - 2S40T
        CPI     '6'
        JZ      SETD2           Set disk type 2 - 1S80T
        CPI     '7'
        JZ      SETD3           Set disk type 3 - 2S80T
        CPI     '9'             9 = set 9600 baud
        JZ      SET9600
        CPI     '('             SHIFT-9 = set 19200 baud
        JZ      SET192K
        CPI     'A'
        JZ      SETSIDA         Set disk side 0
        CPI     'B'
        JZ      SETSIDB         Set disk side 1
        CPI     'Q'
        JZ      QDTYPE          Query for disk type
        CP      'Z'
        JZ      TREAD           Read entire track, return data buffer
        MVI     A,'?'
        CALL    CHROUT
        JMP     LDRCM1
LDRCM2  CALL    $TYPTX
        DB      0AH,'ABORT',8AH
        JMP     LDRCM0
*
* BAUD RATE TOGGLE
*
SET192K CALL    CHROUT
        MVI     A,1
        STA     BRATE
        CALL    SINT2
        CALL    $TYPTX
        DB      'SET AUDRATE TO 19200',8AH
        JMP     LDRCM0
SET9600 CALL    CHROUT
        XRA     A
        STA     BRATE
        CALL    SINT
        CALL    $TYPTX
        DB      'SET BAUDRATE TO 9600',8AH
        JMP     LDRCM0
*
*
*
SETSY0  CALL    $TYPTX
        DB      'USING DRIVE SY0',8AH
        MVI     A,'0'
        LXI     H,DEV1+2
        MOV     M,A
        LXI     H,DEV2+2
        MOV     M,A
        CALL    CHROUT
        LDA     AIO.UNI
        ORA     A
        JZ      LDRCM1
        XRA     A
        STA     AIO.UNI
        CALL    DABORT
*       CALL    DSDP
*       CALL    DSTZ
        JMP     LDRCM1
*
SETSY1  CALL    $TYPTX
        DB      'USING DRIVE SY1',8AH
        MVI     A,'1'
        LXI     H,DEV1+2
        MOV     M,A
        LXI     H,DEV2+2
        MOV     M,A
        CALL    CHROUT
        LDA     AIO.UNI
        CPI     1
        JZ      LDRCM1
        MVI     A,1
        STA     AIO.UNI
        CALL    DABORT
*       CALL    DSDP
*       CALL    DSTZ
        JMP     LDRCM1
*
SETSY2  CALL    $TYPTX
        DB      'USING DRIVE SY2',8AH
        MVI     A,'2'
        LXI     H,DEV1+2
        MOV     M,A
        LXI     H,DEV2+2
        MOV     M,A
        CALL    CHROUT
        LDA     AIO.UNI
        CPI     2
        JZ      LDRCM1
        MVI     A,2
        STA     AIO.UNI
        CALL    DABORT
*       CALL    DSDP
*       CALL    DSTZ
        JMP     LDRCM1
*
SETD0   CALL    $TYPTX
        DB      'SETTING DISK TYPE 0 - 1S40T',8AH
        MVI     A,0
        STA     DTYPE
        MVI     A,'4'
        CALL    CHROUT
*       MVI     A,0
*       STA     AIO.UNI
        JMP     LDRCM1
*
SETD1   CALL    $TYPTX
        DB      'SETTING DISK TYPE 1 - 2S40T',8AH
        MVI     A,1
        STA     DTYPE
        MVI     A,'5'
        CALL    CHROUT
        MVI     A,1
*       STA     AIO.UNI
        JMP     LDRCM1
*
SETD2   CALL    $TYPTX
        DB      'SETTING DISK TYPE 2 - 1S80T',8AH
        MVI     A,2
        STA     DTYPE
        MVI     A,'6'
        CALL    CHROUT
*       MVI     A,1
*       STA     AIO.UNI
        JMP     LDRCM1
*
SETD3   CALL    $TYPTX
        DB      'SETTING DISK TYPE 3 - 2S80T',8AH
        MVI     A,3
        STA     DTYPE
        MVI     A,'7'
        CALL    CHROUT
*       MVI     A,1
*STA    AIO.UNI
        JMP     LDRCM1
*
SETSIDA CALL    $TYPTX
        DB      'SETTING SIDE 1',8AH
        CALL    SETS0
        MVI     A,'A'
        CALL    CHROUT
        JMP     LDRCM1
*
SETSIDB CALL    $TYPTX
        DB      'SETTING SIDE 2',8AH
        CALL    SETS1
        MVI     A,'B'
        CALL    CHROUT
        JMP     LDRCM1
*
QDTYPE  CALL    $TYPTX
        DB      'QUERY FOR DISK TYPE - ',80H
        CALL    QDTYPE1
        MVI     A,'Q'
        CALL    CHROUT
        LDA     DTYPE
        CALL    CHROUT
        ADI     '0'
        SCALL   .SCOUT
        MVI     A,0AH
        SCALL   .SCOUT
        JMP     LDRCM1
*
TREAD   CALL    CHROUT          ECHO TE COMMAND
        CALL    CHRIN           GET TRACK NUMBER
        STA     DTT
        MVI     A,10            READ 10 SECTORS
        STA     NSECTRS
        CALL    TREADA
        MOV     A,C             SND LOW BYTE OF BYTE COUNT
        CALL    CHROUT
        MOV     A,B             SEND HIGH BYTE OF BYTE COUNT
        CALL    CHROUT
        ORA     C
        JZ      TREAD02         NOTHING TO SEND
        MVI     E,0
        LXI     H,TBUFFER
TREAD00 MOV     A,M             SEND TRACK BUFFER (BC) BYTES
        CALL    CHROUT
        DCR     E
        JNZ     TREAD01
        MVI     A,'.'
        SCALL   .SCOUT
TREAD01 INX     H
        DCX     B
        MOV     A,C
        ORA     B
        JNZ     TREAD00
TREAD02 EQU     *
        MVI     A,07H
        SCALL   .SCOUT
        JMP     LDRCM0
*
SETS0   LDA     CTLBYTE         SET SIDE 0
        ANI     -1-040H
        STA     CTLBYTE
        ORI     2
        OUT     CTLPRT
        RET
*
SETS1   LDA     CTLBYTE         SET SIDE 1
        ORI     040H
        STA     CTLBYTE
        ORI     2
        OUT     CTLPRT
        RET
*
* SEND A CHAR IN (A) TO THE LP PORT (340Q)
*
CHROUT  MOV     D,A
*
CHRO4   IN      LSTAT4
        ANI     60H
        CPI     60H
        JNZ     CHRO4
        MOV     A,D
        OUT     TX4
        RET
*
* READ A CHAR FROM THE LP PORT (340Q)
*
CHRIN   IN      LSTAT4
        RAR
        JNC     CHRIN
        IN      RX4
        RET
*
*
*
CHRRDY  IN      LSTAT4
        RAR
        RET                     Returns NC = no char, C = char ready

*
*       QUERY FOR DISK TYPE - MUST USE 80 TRACK DRIVE
*       DETERMINES DISK TYPE AS FOLLOWS:
*       1. SEEK TO TRACK 2
*       2. READ SECTOR 0 HEADER
*       3. IF TRACK NUMBER IN HEADER IS 1 THEN THIS IS A SS 40 TRACK DISK
*       4. IF TRACK NUMBER IN HEADER IS 4 THEN THIS IS A DS 80 TRACK DISK
*       5. SEEK TO TRACK 3 (ON A 80 TRACK DRIVE)
*       6. READ SECTOR 0 HEADER
*       7. IF TRACK NUMBER INHEADER IS 3 THEN ITS SS 80 TRACK
*       8. ELSE THIS IS A DS 40 TRACK DISK
*
QDTYPE1 XRA     A
        STA     DTYPE           SART WITH 40 TRACK 1 SIDE
        LDA     AIO.UNI
        ORA     A
        JZ      DXOK
        CALL    SETS0           SET SIDE 0
        MVI     A,1
        STA     NSECTRS         READ 1 SECTOR
        MVI     A,2
        STA     DTT             SET TRACK 2
        CALL    TREADA
*       MVI     A,0AH
*       SCALL   .SCOUT
        LDA     CURTRK
        CPI     1               IF 1 THEN 40 TRACK 1 SIDE
        JZ      DXOK
        CPI     4               IF 4 THEN 80 TRACK 2 SIDE
        JZ      QDTYPE4
        MVI     A,3
        STA     DTT             SET TRACK 3
        CALL    TREADA
        JC      QDTYPE2
        LDA     CURTRK
        CPI     3
        JZ      QDTYPE3
QDTYPE2 MVI     A,1             40 TRACK 2 SIDE
        STA     DTYPE
        CALL    DXOK
*       MVI     A,0AH
*       SCALL   .SCOUT
        RET
QDTYPE3 MVI     A,2             80 TRACK 1 SIDE
        STA     DTYPE
        CALL    DXOK
*       MVI     A,0AH
*       SCALL   .SCOUT
        RET
QDTYPE4 MVI     A,3             80 TRACK 2 SIDE
        STA     DTYPE
        CALL    DXOK
*       MVI     A,0AH
*       SCALL   .SCOUT
        RET

***     LPS - Locate proper sector
*       LPS reads over sector headers until the proper sector
*       is found.
*
*       Upon entry, the arm should be positioned over the sector.
*
*       D.TT = desired track
*       D.TS = desired sector
***     MAI - move disk arm in one track
*
*       ENTRY   None
*       EXIT    Interrrups disabled
*               'C' set if error
*       USES    All but C

LPS0    CALL    DSTS            Skip this sector (DI)
        EI

DLPS    LDA     DLPSA           (A) = #trys for this sector
        MOV     B,A
        LDA     DDLYHS
        ANA     A
        JNZ     LPS0

LPS1    DI
        CALL    DWSC            wait for sync character
        JC      LPS3            none
* H8DIMGR IGNORES VOLUME PROTECTION
*       LHLD    DVOLPT
        CALL    DRDB
*       CMP     M               see if proper volume
*       JNE     LPS4            wrong volume
        LXI     H,DTT
        CALL    DRDB
        CMP     M               see if proer track
        JNE     LPS5            wrong track
        INX     H
        CALL    DRDB
        CMP     M
        JNE     LPS2            wrong sector
*       got right sector, read checksum
        MOV     H,D
        CALL    DRDB
        CMP     H
        RE                      ALL OK
* H8DIMGR IGNORES ERROR REPORTING
*       MVI     L,#D.E.HCK      Header checksum error
*LPS1.5 MVI     H,D.ERR/256     (HL) = error byte address
*.      SET     D.ERR/256
*       ERRNZ   D.ERRL/256-.    Must in same bank
*       CALL    D.ERRT          Cunt error
*       Wrong sector or bad data. Try some more
LPS2    CALL    DSTS            Skip this sector (DI)
        DCR     B
        JNZ     LPS1            Try again
        STC                     Enough trys
        RET                     ERROR
LPS3    EQU     *
*       MVI     L,#D.E.HSY      Header sync error
*       JMP     LPS1.5
        JMP     LPS2
LPS4    EQU     *
*       MVI     L,#D.E.VOL      Bad volume number
*       JMP     LPS1.5          count error
        JMP     LPS2
LPS5    EQU     *
*       MVI     L,#D.E.TRK      Bad track number
*       JMP     LPS1.5
        JMP     LPS2

* TRACK READ (SYNC,VOL,TRK,SEC,CHK,SYNC,DATA,CHK)
* USED BY QUERY DISK TYPE (QDTYPE) AND FOR DUMPING TRACK DATA
TREADC  EQU     *
        XRA     A
        STA     DTS
        STA     GOODRD
        MVI     A,1
        STA     SKIPCHK
        LDA     DEFWSCA
        RAL
        STA     DWSCA
        CALL    DSDP
        CALL    DSDT            (DI)
        EI
        JMP     TREAD0
TREADA  EQU     *
*       CALL    $TYPTX
*       DB      'READ TRACK - ',80H
        XRA     A
        STA     DTS
        STA     GOODRD
        STA     SKIPCHK
        LDA     DEFWSCA
        RAL
        STA     DWSCA           WSC DELAY * 2
        MVI     A,20
        STA     SEC0CNT
*       MVI     A,'1'
*       SCALL   .SCOUT
        CALL    DSDP
*       MVI     A,'2'
*       SCALL   .SCOUT
        CALL    LTRK            MOVE TO TRACK DTT
*       MVI     A,'3'
*       SCALL   .SCOUT
TREAD0  CALL    DSTS            DI
        LDA     NSECTRS
        STA     SECCNT
        LXI     B,0             COUNT OF BYTES
        LXI     H,TBUFFER       DATA BUFFER
*FIND SECTOR 0
TREAD0A CALL    DWSC
        JC      TREAD0A
        MOV     M,A             SAVE SYNC CHAR
        INX     H
        INX     B
        CALL    DRDB            READ VOLUME
        MOV     M,A
        INX     H
        INX     B
        CALL    DRDB            READ TRCK
        STA     CURTRK          SAVE THE CURRENT TRACK
        MOV     M,A
        INX     H
        INX     B
        CALL    DRDB            READ SECTOR
        ORA     A
        JZ      TREAD1B
        LDA     SKIPCHK         IGNORING TIMEOUTS?
        ORA     A
        JNZ     TREAD0          YES THEN JUST KEEP LOOKING
        LDA     SEC0CNT
        DCR     A
        STA     SEC0CNT
        JNZ     TREAD0  IF NOT SECTOR 0 SKIP AND TRY AGAIN
        JMP     TREAD3          IF TOO MANY TRIES THEN BAIL
TREAD1A CALL    DWSC
        JC      TREAD1A
        MOV     M,A
        INX     H
        INX     B
        CALL    DRDB            READ VOLUME
        MOV     M,A
        INX     H
        INX     B
        CALL    DRDB            READ TRACK
        MOV     M,A
        INX     H
        INX     B
        CALL    DRDB            READ SECTOR
TREAD1B MOV     M,A
        INX     H
        INX     B
        PUSH    D               SAVE CHECKSUM (D)
        CALL    DRDB            READ CHECKSUM BYTE (A)
        POP     D               RESTORE RUNNING CHECKUM (D)
        MOV     M,A
        INX     H
        INX     B
        CMP     D
        JZ      TREAD1C
* BAD HEADER CHECKSUM
        LDA     SKIPCHK         DO WE WANT TO BAIL?
        ORA     A
        JZ      TREAD3          YES
TREAD1C CALL    DWSC            WAIT FOR DATA SYNC CHAR
        JC      TREAD1C
        MOV     M,A
        INX     H
        INX     B
        MVI     E,0             READ 256 BYTES
TREAD2  EQU     *
        CALL    TREADB
        MOV     M,A
        INX     H               NEXT BUFFER OSITION
        INX     B               ICREASE BYTE COUNT
        DCR     E
        JNZ     TREAD2
        CALL    TREADB          READ CHECKSUM
        MOV     M,A
        INX     H
        INX     B
        LDA     SECCNT
        DCR     A
        STA     SECCNT          MORE SECTORS TO READ?
        JNZ     TREAD1A         YES, KEEP GOING
        MVI     A,1
        STA     GOODRD
TREAD3  LDA     DEFWSCA
        STA     DWSCA
        EI
*       MVI     A,'4'
*       SCALL   .SCOUT
        CALL    DXOK
        LDA     GOODRD
        ORA     A
        RNZ
*MVI    A,'X'
*       SCALL   .SCOUT
        STC
        RET

* READ A BYTE FROM DISK
TREADB  EQU     *
        IN      UP.ST
        RAR
        JNC     TREADB
        IN      UP.DP
        RET

* LOCATE TRACK
LTRK3   INR     M
        CALL    DMAI
LTRK    EQU     *
        LHLD    DTRKPT
        LDA     DTT
        CMP     M
        RE
        JP      LTRK3
        DCR     M               update track number
        CALL    DMAO            move arm out
        JMP     LTRK            see if arm there yet

*
* FORMATS A TRACK ON THE FLY - CALLED BY WRIMG
*
FTRK    EQU     *
        MVI     A,'F'
        SCALL   .SCOUT
        DI
*       MVI     A,01
*       STA     MFLAG
        MOV     A,B
        STA     DTT
        MVI     A,02
        STA     DDLYHS          HEAD SETTLE DELAY
        XRA     A
        OUT     7FH
        STA     DDVCTL
        STA     DDLYMO
        LXI     H,DDRVTB+1
        SHLD    DVOLPT
        MOV     M,C             VOLUME NUMBER
        EI
        CALL    DSDP
        CALL    DSDT            SEEK TO TRACK DTT (DI)
        XRA     A
        OUT     7EH
        INR     A
        STA     DWHDA
        LDA     DDVCTL
        INR     A
        OUT     7FH
        EI
TRK1    CALL    DSTS            (DI)
*       LDA     DDLYHS
*       ANA     A
*       JNZ     TRK1
        LHLD    DVOLPT
        MOV     B,M
        LHLD    SECPNTR
TRK2    MVI     C,0AH
        CALL    WSP1            WRITE SYNC PATTER
        MOV     A,B
        CALL    DWNB            WRITE VOL NUMBER
        LDA     DTT
        CALL    DWNB            WRITE TRACK NUMBER
        MOV     A,M
        CALL    DWNB            WRITE SECTOR NUMBER
        INX     H
        MOV     A,D
        CALL    DWNB            WRITE CHKSUM
        MVI     C,10H
        CALL    WSP1            WRITE SYNC PATTERN
TRK3    CALL    DWNB            WRITE 256 ZEROS
        DCR     C
        JNZ     TRK3
TRK4    XRA     A               WRITE ZEROS UNTIL END OF SECTOR
        CALL    DWNB
        IN      7FH
        RAR
        JNC     TRK4
        MOV     A,M
        ORA     A               MORE SECTORS?
        JNZ     TRK2            YES, REPEAT PATTERN
        LDA     DDVCTL
        OUT     7FH
        MVI     A,14H
        STA     DWHDA
*       XRA     A
*       STA     MFLAG
        EI
        MVI     A,08H
        SCALL   .SCOUT
        RET
*
* WRITES A DISK IMAGE FROM DATA SENT FRO A PC VIA THE LP PORT (340Q)
*
WRIMG   EQU     *
        XRA     A
        STA     SECNUM
        STA     CURTRK
        STA     SECNUM+1
WRIMG1  LXI     H,DDRVTB+1
        MOV     M,A
        SHLD    DVOLPT
        CALL    CHRIN
        CPI     'W'
        JNZ     WRIMGX
        LXI     H,BUFFER
        LXI     B,ZBUF
        DI
WRIMG2  CALL    CHRIN
        MOV     M,A
        INX     H
        DCX     B
        MOV     A,B
        ORA     C
        JNZ     WRIMG2
        EI
        LDA     CURTRK
        MOV     B,A
        ORA     A
        JZ      WRIMG3
        LDA     VOLNUM
        MOV     C,A
WRIMG3  CALL    FTRK
        LDA     CURTRK
        INR     A
        STA     CURTRK
        LXI     B,ZBUF
        LXI     D,BUFFER
        LHLD    SECNUM
        CALL    WRBUF
        MVI     A,'.'
        SCALL   .SCOUT
        LHLD    SECNUM
        LXI     D,0AH
        DAD     D
        SHLD    SECNUM
        LDA     DTYPE
        LXI     D,-190H         SS 40 TRK
        ORA     A
        JZ      WRIMG4
        LXI     D,-320H         DS 40 TRK
        DCR     A
        JZ      WRIMG4
        LXI     D,-320H         SS 80 TRK
        DCR     A
        JZ      WRIMG4
        LXI     D,-640H         DS 80 TRK
WRIMG4  DAD     D
        MOV     A,H
        ORA     L
        JNZ     WRIMG5
WRIMGX  EQU     *
        EI
*       CALL    DXOK
        MVI     A,'W'
        CALL    CHROUT
        MVI     A,07H
        SCALL   .SCOUT
        JMP     LDRCM0
WRIMG5  MVI     A,'W'
        CALL    CHROUT
        LDA     VOLNUM
        JMP     WRIMG1
* BC = BUFFER SIZE
* DE = BUFFER ADDR
* HL = FIRST SEC#
WRBUF   MVI     A,'W'
        SCALL   .SCOUT
        MVI     A,02
        STA     DDLYHS
        CALL    DWRITE
        MVI     A,08H
        SCALL   .SCOUT
        RET
*
* READS A DISK AND TRANSMITS THE DATA SECTORS TO A PC VIA THELP PORT (340Q)
*
RDIMG   CALL    $TYPTX
        DB      'SEND DISK DATA TO H8DUTILITY',8AH
*
        XRA     A
        STA     SECNUM
        STA     SECNUM+1
RDIMG1  LXI     H,DDRVTB+1
        MOV     M,A
        SHLD    DVOLPT
        CALL    CHRIN
        CPI     'R'
        JNZ     RDIMGX
        LXI     B,ZBUF
        LXI     D,BUFFER
        LHLD    SECNUM
        CALL    RDBUF
        MVI     A,'S'
        SCALL   .SCOUT
        LXI     H,BUFFER
        LXI     B,ZBUF
RDIMG2  MOV     A,M
        CALL    CHROUT
        INX     H
        DCX     B
        MOV     A,B
        ORA     C
        JNZ     RDIMG2
        LDA     GOODRD
        ORA     A
        MVI     A,'R'
        JNZ     RDIMG3
        ORI     020H
RDIMG3  CALL    CHROUT
        MVI     A,08H
        SCALL   .SCOUT
        MVI     A,'.'
        SCALL   .SCOUT
        LHLD    SECNUM
        LXI     D,0AH
        DAD     D
        SHLD    SECNUM
        LDA     DTYPE
        LXI     D,-190H         SS 40 TRK
        ORA     A
        JZ      RDIMG4
        LXI     D,-320H         DS 40 TRK
        DCR     A
        JZ      RDIMG4
        LXI     D,-320H         SS 80 TRK
        DCR     A
        JZ      RDIMG4
        LXI     D,-640H         DS 80 TRK
RDIMG4  DAD     D
        MOV     A,H
        ORA     L
        LDA     VOLNUM
        JNZ     RDIMG1
RDIMGX  CALL    DXOK
        MVI     A,07H
        SCALL   .SCOUT
        JMP     LDRCM0
* BC = BUFFER SIZE
* DE = BUFFER ADDR
* HL = FIRST SEC#
RDBUF   MVI     A,'R'
        SCALL   .SCOUT
*       MVI     A,02
*       STA     DDLYHS
        CALL    DREAD
        MVI     A,0
        JC      RDBF1
        DCR     A
RDBF1   STA     GOODRD          NON-ZERO IS GOOD READ, ZERO IS BAD READ
        MVI     A,08H
        SCALL   .SCOUT
        RET
*
* EXPERIMENTAL RDIMG REPLACEMENT (NOT USED)
*
RDIMGA  XRA     A
        STA     CURTRK
        STA     DTT
        MVI     A,10
        STA     NSECTRS
RDIMGA1 CALL    CHRIN
        CPI     'R'
        JNZ     LDRCM2
        MVI     A,'R'
        SCALL   .SCOUT
        CALL    TREADC
        JC      RDIMGAX
        MVI     A,08H
        SCALL   .SCOUT
        MVI     A,'S'
        SCALL   .SCOUT
        MVI     B,10            10 SECTORS
        LXI     H,TBUFFER       SYNC
RDIMGA3 INX     H               VOL
        INX     H               TRK
        INX     H               SEC
        INX     H               CHK
        INX     H               SYNC
        INX     H               DATA
        MVI     C,0             256 BYTES EACH
RDIMGA2 MOV     A,M
        CALL    CHROUT
        INX     H
        DCR     C
        JNZ     RDIMGA2
        INX     H               SYNC
        DCR     B
        JNZ     RDIMGA3
        MVI     A,'R'
        CALL    CHROUT
        MVI     A,08H
        SCALL   .SCOUT
        MVI     A,'.'
        SCALL   .SCOUT
        LDA     DTYPE
        CPI     1
        JZ      RDIMGA4
        CPI     2
        JZ      RDIMGA4
        CPI     3
        JZ      RDIMGA5
        LDA     DTT
        CPI     39
        JZ      RDIMGAX
        INR     A
        STA     DTT
        JMP     RDIMGA1
RDIMGA4 LDA     DTT
        CPI     79
        JZ      RDIMGAX
        INR     A
        STA     DTT
        JMP     RDIMGA1
RDIMGA5 LDA     DTT
        CPI     159
        JZ      RDIMGAX
        INR     A
        STA     DTT
        JMP     RDIMGA1
RDIMGAX EQU     *
        CALL    DXOK
        MVI     A,07H
        SCALL   .SCOUT
        JMP     LDRCM0
*
* CHECK THE HDOS DISK LABEL FOR VOLUME NUMBER
*
CHKV    CALL    $TYPTX
        DB      'CHECK HDOS DISK VOLUME',8AH
        CALL    SETS0
        XRA     A
        STA     SECNUM
        STA     SECNUM+1
CHKV1   LXI     H,DDRVTB+1
        MOV     M,A
        SHLD    DVOLPT
        LXI     B,ZBUF
        LXI     D,BUFFER
        LHLD    SECNUM
        CALL    RDBUF
        LDA     BUFFER+900H
        CALL    CHROUT
        MVI     A,'C'
        CALL    CHROUT
        JMP     LDRCM1
*
* SET VOLUME OVERRIDE VALUE
*
SETV    CALL    CHRIN
        STA     VOLNUM
        MVI     A,'V'
        CALL    CHROUT
        JMP     LDRCM1
*
* CHECK DISK HEADER FOR VOLUME NUMBER
*
RDDV    CALL    $TYPTX
        DB      'CHECK DISK HEADER VOLUME',8AH
        CALL    SETS0
        LXI     H,20H
        PUSH    H
        CALL    DSDP
        POP     H
        CALL    DDTS
        MVI     A,1
        CALL    DUDLY
RDDV1   CALL    DSTS
        EI
        LDA     DDLYHS
        ANA     A
        JNZ     RDDV1
        DI
        CALL    DWSC
        CALL    DRDB
        EI
        PUSH    PSW
        CALL    DABORT
        POP     PSW
        CALL    CHROUT
        MVI     A,'T'
        CALL    CHROUT
        JMP     LDRCM1
*
* DATA AREA
*
DATAS   EQU     *
DTYPE   DB      0
BRATE   DB      0
DEV1    DB      'SY0:',0
DEV2    DB      'SY1:',0
DEV3    DB      'SY2:',0
SECCNT  DB      0
SEC0CNT DB      0
SKIPCHK DB      0
GOODRD  DB      0
VOLNUM  DB      0
CURTRK  DB      0
NTRACKS DB      0
NSECTRS DB      10
DEFWSCA DB      0
SECNUM  DW      0
SECPNTR DW      SEC1
SEC1    DB      0,1,2,3,4,5,6,7,8,9
SEC2    DB      0,2,4,6,8,1,3,5,7,9
SEC3    DB      0,3,6,9,2,5,8,1,4,7
TBUFFER EQU     *
BUFFER  DS      TBUF
        DS      ZSTK
SPINT   EQU     *
*
        END     START
*****************************************************
* END OF FILE PADDING - NEEDED FOR HEATHKIT ASSEMBLER
*****************************************************
>