*
* H8DIMGR4.ASM
* 2021-11-16 Les Bird
*
        XTEXT   HOSEQU
        XTEXT   MTR
        XTEXT   H17DEF
        XTEXT   HROM
        XTEXT   H17ROM
        XTEXT   HOSDEF
        XTEXT   DIRDEF
        XTEXT   ESINT
        XTEXT   EDRAM
        XTEXT   EDVEC
* BAUD RATE 38400
BAUDH   EQU     00H
BAUDL   EQU     03H
*
DAT4    EQU     340Q            DATA
IER4    EQU     341Q            IER
LCR4    EQU     343Q            CTRL
MCR4    EQU     344Q            MCTRL
LSR4    EQU     345Q            STATUS
*
DAT5    EQU     350Q
LSR5    EQU     355Q
*
TARTRK  EQU     4
BUFSIZ  EQU     0A00H           2560 BYTES
*
        ORG     USERFWA
*
START   EQU     *
        CALL    $TYPTX
        DB      0AH,'H8DIMGR4 2021 BY LES BIRD',0AH
        DB      'USE WITH H8DUTILITY V3 OR LATER',0AH,0AH
        DB      'CONNECT TO PORT 340Q AT 38,400 BAUD',0AH
        DB      'CONFIGURE SYSTEM AS FOLLOWS:',0AH
        DB      'SY0: 40 TRACK DOUBLE SIDED',0AH
        DB      'SY1: 80 TRACK DOUBLE SIDED',0AH
        DB      80H
        CALL    INIT34
        CALL    DMALL           DISMOUNT ALL DRIVES
        CALL    D.ABORT         SEEK TO TRACK 0
        CALL    INITV
        CALL    D.ABORT
        JMP     CMD
* HSY.DVD OVERWRITES THESE VECTORS SO RESTORE BACK TO ROM
INITV   EQU     *
        LXI     H,33316A
        SHLD    D.SYDD+1
        LXI     H,33345A
        SHLD    D.MOUNT+1
        LXI     H,33374A
        SHLD    D.XOK+1
        LXI     H,33366A
        SHLD    D.ABORT+1
        LXI     H,33375A
        SHLD    D.XIT+1
        LXI     H,34077A
        SHLD    D.READ+1
        LXI     H,34321A
        SHLD    D.READR+1
        LXI     H,34336A
        SHLD    D.WRITE+1
        LXI     H,35136A
        SHLD    D.CDE+1
        LXI     H,DDTS          CUSTOM VERSION
        SHLD    D.DTS+1
        LXI     H,DSDT          CUSTOM VERSION
        SHLD    D.SDT+1
        LXI     H,36062A
        SHLD    D.SDP+1
        LXI     H,36165A
        SHLD    D.STS+1
        LXI     H,36254A
        SHLD    D.STZ+1
        LXI     H,37150A
        SHLD    D.ERRT+1
        RET
*
INIT34  DI
        XRA     A
        OUT     LCR4
        OUT     IER4
        OUT     MCR4
        DCR     A
        OUT     LCR4
        MVI     A,BAUDL
        OUT     DAT4
        MVI     A,BAUDH
        OUT     IER4
        MVI     A,07H
        OUT     LCR4
        IN      LSR4
        IN      DAT4
        EI
        RET
*
IN340   IN      LSR4
        ANI     01H             NZ WHEN DATA READY
        JZ      IN340
        IN      DAT4
        RET
*
OUT340  PUSH    PSW
OUT34L  IN      LSR4
        ANI     20H             NZ WHEN READY TO SEND
        JZ      OUT34L
        POP     PSW
        OUT     DAT4
        RET
*
OUT350  PUSH    PSW
OUT35L  IN      LSR5
        ANI     20H
        JZ      OUT35L
        POP     PSW
        OUT     DAT5
        RET
*
DMALL   EQU     *
        LXI     H,SY0
        SCALL   .DMNMS
        LXI     H,SY1
        SCALL   .DMNMS
        LXI     H,SY2
        SCALL   .DMNMS
        RET
*
CMD     EQU     *
        CALL    $TYPTX
        DB      0AH,'CLIENT READY',8AH
CMDL    EQU     *
        CALL    IN340
        CPI     '0'
        JZ      SETSY0
        CPI     '1'
        JZ      SETSY1
        CPI     '4'
        JZ      SET1S4
        CPI     '5'
        JZ      SET2S4
        CPI     '6'
        JZ      SET1S8
        CPI     '7'
        JZ      SET2S8
        CPI     'A'
        JZ      CMDX2
        CPI     'B'
        JZ      CMDX2
        CPI     'V'
        JZ      SETVOL
        CPI     'C'
        JZ      CHKVOL
        CPI     'T'
        JZ      GETVOL
        CPI     'Q'
        JZ      QUERYD
        CPI     'R'
        JZ      RDIMG
        CPI     'W'
        JZ      WRIMG
* COMMAND NOT RECOGNIZED OR CLIENT ACKNOWLEDGE
        MVI     A,'?'
        CALL    OUT340
        JMP     CMDL
*
CMDA    EQU     *
        CALL    $TYPTX
        DB      0AH,'COMMAND ABORT',8AH
        JMP     CMD
*
CMDX    EQU     *
        POP     PSW
CMDX2   EQU     *
        CALL    OUT340
        JMP     CMDL
*
SETSY0  EQU     *
        PUSH    PSW
        CALL    $TYPTX
        DB      'SET DRIVE SY0:',8AH
        LDA     AIO.UNI
        ORA     A
        JZ      CMDX
        XRA     A
        STA     AIO.UNI
        CALL    D.SDP
        JMP     CMDX
*
SETSY1  EQU     *
        PUSH    PSW
        CALL    $TYPTX
        DB      'SET DRIVE SY1:',8AH
        LDA     AIO.UNI
        ORA     A
        JNZ     CMDX
        MVI     A,1
        STA     AIO.UNI
        CALL    D.SDP
        JMP     CMDX
*
SET1S4  EQU     *
        PUSH    PSW
        CALL    $TYPTX
        DB      'SET 1S40T',8AH
        MVI     A,0
        STA     DSKTYP
        JMP     CMDX
*
SET2S4  EQU     *
        PUSH    PSW
        CALL    $TYPTX
        DB      'SET 2S40T',8AH
        MVI     A,1
        STA     DSKTYP
        JMP     CMDX
*
SET1S8  EQU     *
        PUSH    PSW
        CALL    $TYPTX
        DB      'SET 1S80T',8AH
        MVI     A,2
        STA     DSKTYP
        JMP     CMDX
*
SET2S8  EQU     *
        PUSH    PSW
        CALL    $TYPTX
        DB      'SET 2S80T',8AH
        MVI     A,3
        STA     DSKTYP
        JMP     CMDX
*
SETVOL  EQU     *
        PUSH    PSW
        CALL    IN340
        LHLD    D.VOLPT
        MOV     M,A
        STA     HDRVOL
        CALL    $TYPTX
        DB      'SET DISK VOLUME',8AH
        JMP     CMDX
*
CHKVOL  EQU     *
        PUSH    PSW
        CALL    $TYPTX
        DB      'GET HDOS DISK VOLUME',8AH
        XRA     A
        STA     D.TT
        STA     D.TS
        LHLD    D.VOLPT
        MOV     M,A
        LXI     B,BUFSIZ
        LXI     D,TRKBUF
        LXI     H,0             SECTOR 0
        CALL    D.READ
        LDA     TRKBUF+0900H
        CALL    OUT340
        JMP     CMDX
*
GETVOL  EQU     *
        PUSH    PSW
        CALL    $TYPTX
        DB      'GET DISK HEADER VOLUME',8AH
        CALL    GETHDR
        CALL    OUT340
        CALL    D.ABORT
        JMP     CMDX
*
GETHDR  EQU     *
        CALL    D.SDP
        CALL    D.SDT
        CALL    D.STS
        CALL    D.WSC           WAIT FOR SYNC CHAR
        CALL    D.RDB           READ VOLUME NUM
        STA     HDRVOL
        CALL    D.RDB           READ TRACK
        STA     HDRTRK
        CALL    D.RDB           READ SECTOR
        STA     HDRSEC
        CALL    D.RDB           READ CHECKSUM
        STA     HDRCHK
        EI
        LDA     HDRVOL
        RET
*
SETSIDE EQU     *
        LDA     .CTL2FL
        ANI     CB2.SID
        JNZ     SETS2
SETS1   EQU     *
        LDA     .CTL2FL         SET SIDE 1
        ANI     -1-CB2.SID
        STA     .CTL2FL
        ORI     CB2.CLI
        OUT     OP2.CTL
        RET
*
SETS2   EQU     *
        LDA     .CTL2FL         SET SIDE 2
        ORI     CB2.SID
        STA     .CTL2FL
        ORI     CB2.CLI
        OUT     OP2.CTL
        RET
* GET DISK HEADER TRACK
GETTRK  EQU     *
        MVI     A,TARTRK
        STA     D.TT
        CALL    GETHDR
*       LDA     HDRTRK
*       ADI     '0'
*       CALL    OUT350
*       LDA     HDRSEC
*       ADI     '0'
*       CALL    OUT350
*       MVI     A,20H
*       CALL    OUT350
        LDA     HDRTRK
        CPI     TARTRK
        JZ      SIDES1          SINGLE SIDED DISK
        RAR
        CPI     TARTRK
        JZ      SIDES2          DOUBLE SIDED DISK
        STC
        RET
SIDES1  EQU     *
        MVI     A,1
        RET
SIDES2  EQU     *
        MVI     A,2
        RET
*
QUERYD  EQU     *
        CALL    OUT340          ACK COMMAND
        CALL    $TYPTX
        DB      'QUERY FOR DISK TYPE:',80H
        XRA     A               1S40T
        STA     DSKTYP
        CALL    SETS1           SET SIDE 1
        CALL    GETTRK          RETURNS 1 OR 2 OR C
        JC      QUERYE
        CPI     1
        JZ      QUERY9          SINGLE SIDED DISK
        LDA     AIO.UNI
        ORA     A
        MVI     A,3             2S80T
        STA     DSKTYP
        JNZ     QUERYX
        MVI     A,1             2S40T
        STA     DSKTYP
        JMP     QUERYX
QUERY9  EQU     *
        LDA     AIO.UNI
        ORA     A
        JZ      QUERYX
        MVI     A,2             1S80T
        STA     DSKTYP
QUERYX  EQU     *
        LDA     DSKTYP
        CALL    OUT340
        ADI     '0'
        CALL    OUT350
        CALL    D.ABORT         SEEK TO TRACK 0
        CALL    $TYPTX
        DB      0AH,'QUERY SUCCESS',8AH
        JMP     CMDL
QUERYE  EQU     *
        MVI     A,0FFH
        STA     DSKTYP
        CALL    OUT340
        MVI     A,'X'
        CALL    OUT350
        CALL    D.ABORT         SEEK TO TRACK 0
        CALL    $TYPTX
        DB      0AH,'QUERY ERROR',8AH
        JMP     CMDL
*
RDIMG   EQU     *
        CALL    $TYPTX
        DB      'READ IMAGE',8AH
        LHLD    D.VOLPT
        XRA     A
        MOV     M,A             SET VOLUME 0
        LXI     H,0
        SHLD    BLKNUM
RDIMG1  EQU     *
        CALL    IN340           WAIT FOR 'R'
        CPI     'R'
        JNZ     RDIMGX          NOT 'R' SO ABORT
        MVI     A,'R'
        CALL    OUT350
        CALL    ZEROBUF
        LXI     B,BUFSIZ
        LXI     D,TRKBUF
        LHLD    BLKNUM
        CALL    D.READ
        EI
        MVI     A,08H
        CALL    OUT350
        MVI     A,'S'
        CALL    OUT350
        LXI     H,TRKBUF
        LXI     B,BUFSIZ
RDIMG2  EQU     *               SEND TO HOST
        MOV     A,M
        CALL    OUT340
        INX     H
        DCX     B
        MOV     A,C
        ORA     B
        JNZ     RDIMG2
        MVI     A,08H
        CALL    OUT350
        MVI     A,'.'
        CALL    OUT350
        LDA     D.TT
        CPI     79
        JNZ     RDIMG3
        MVI     A,'.'
        CALL    OUT350
        MVI     A,0DH
        CALL    OUT350
        MVI     A,0AH
        CALL    OUT350
* NEXT TRACK
RDIMG3  EQU     *
        LHLD    D.VOLPT
        LDA     HDRVOL          GET LOCAL VOL NUM
        MOV     M,A             SET VOL NUM
        LHLD    BLKNUM
        LXI     D,0AH           10 SECTORS
        DAD     D
        SHLD    BLKNUM
        LDA     DSKTYP
        LXI     D,-190H         1S40T
        ORA     A
        JZ      RDIMG4
        LXI     D,-320H         2S40T (-320H)
        DCR     A
        JZ      RDIMG4
        LXI     D,-320H         1S80T (-320H)
        DCR     A
        JZ      RDIMG4
        LXI     D,-640H         2S80T (-640H)
RDIMG4  EQU     *
        DAD     D
        MOV     A,L
        ORA     H
        JZ      RDIMGX
        MVI     A,'R'           ACKNOWLEDGE READ
        CALL    OUT340
        JMP     RDIMG1
RDIMGX  EQU     *
        MVI     A,'.'
        CALL    OUT350
        MVI     A,'R'
        CALL    OUT340
        CALL    D.ABORT
        JMP     CMD
RDIMGE  EQU     *
        MVI     A,'?'
        CALL    OUT340
        JMP     RDIMGX
*
WRIMG   EQU     *
        CALL    $TYPTX
        DB      'WRITE IMAGE',8AH
        LXI     H,0
        SHLD    BLKNUM
        XRA     A
        STA     D.TT
        CALL    D.SDP
        CALL    D.STZ
WRIMGL  EQU     *
        MVI     A,'R'
        CALL    OUT350
        CALL    IN340           WAIT FOR 'W' COMMAND
        CPI     'W'
        JNZ     WRIMGX
        LXI     B,BUFSIZ
        LXI     H,TRKBUF
        DI
WRIMG1  EQU     *
        CALL    IN340
        MOV     M,A
        INX     H
        DCX     B
        MOV     A,C
        ORA     B
        JNZ     WRIMG1
        EI
        MVI     A,08H
        CALL    OUT350
        LDA     D.TT
        MOV     C,A
        ORA     A
        JZ      WRIMG2
        LDA     HDRVOL
        MOV     B,A
WRIMG2  EQU     *
        LHLD    D.VOLPT
        MOV     M,B
        CALL    FTRK
        CALL    WRBUF
        JC      WRIMGE
        MVI     A,'.'
        CALL    OUT350
        LDA     D.TT
        INR     A
        STA     D.TT
        CPI     79
        JNZ     WRIMG3
        MVI     A,'.'
        CALL    OUT350
        MVI     A,0DH
        CALL    OUT350
        MVI     A,0AH
        CALL    OUT350
WRIMG3  EQU     *
        MVI     A,'W'
        CALL    OUT340
        LHLD    BLKNUM
        LXI     D,10
        DAD     D
        SHLD    BLKNUM
        LDA     DSKTYP
        LXI     D,-190H
        ORA     A
        JZ      WRIMG4
        LXI     D,-320H
        DCR     A
        JZ      WRIMG4
        LXI     D,-320H
        DCR     A
        JZ      WRIMG4
        LXI     D,-640H
WRIMG4  EQU     *
        DAD     D
        MOV     A,L
        ORA     H
        JZ      WRIMGX
        JMP     WRIMGL
WRIMGE  EQU     *
        MVI     A,'?'
        CALL    OUT340
        MVI     A,'E'
        CALL    OUT350
WRIMGX  EQU     *
        MVI     A,'.'
        CALL    OUT350
        CALL    D.ABORT
        JMP     CMD
*
WRBUF   EQU     *
        MVI     A,'W'
        CALL    OUT350
        LXI     B,BUFSIZ
        LXI     D,TRKBUF
        LHLD    BLKNUM
        MVI     A,2
        STA     D.DLYHS
        CALL    D.WRITE
        PUSH    PSW             SAVE (C) FLAG
        MVI     A,8
        CALL    OUT350
        POP     PSW
        RET
* FORMATS TRACK ON THE FLY (B=VOL, C=TRK)
FTRK    EQU     *
        DI
        MVI     A,'F'
        CALL    OUT350
        XRA     A
        STA     D.DVCTL
        STA     D.DLYMO
        EI
        PUSH    B               SAVE VOL,TRK
        CALL    D.SDP
        CALL    D.SDT           DI
        XRA     A
        OUT     UP.SC
        LDA     D.DVCTL
        INR     A
        OUT     DP.DC           TURN ON WRITE GATE
        MVI     A,2
        STA     D.DLYHS
FTRK1   EQU     *
        CALL    D.STS
        LDA     D.DLYHS
        ANA     A
        JNZ     FTRK1
        LHLD    SECSKEW
        POP     B               RESTORE VOL,TRK
FTRKL   EQU     *
        PUSH    B               SAVE VOL,TRK
        MVI     C,0AH           WRITE SECTOR HEADER
        CALL    D.WSP1
        POP     B               RESTORE VOL.TRK
        MOV     A,B             WRITE VOLUME NUM
        CALL    D.WNB
        MOV     A,C             WRITE TRACK NUM
        CALL    D.WNB
        MOV     A,M             WRITE SECTOR NUM
        CALL    D.WNB
        MOV     A,D             WRITE CHECKSUM
        CALL    D.WNB
        PUSH    B               SAVE VOL,TRK
        MVI     C,10H
        CALL    D.WSP1
        XRA     A
        MOV     C,A
FTRK2   EQU     *               WRITE SECTOR DATA
        MOV     A,M
        CALL    D.WNB
        DCR     C
        JNZ     FTRK2
        MOV     A,D
        CALL    D.WNB           WRITE CHECKSUM 3 TIMES
        CALL    D.WNB
        CALL    D.WNB
FTRK3   EQU     *               WRITE ZEROS UNTIL END
        XRA     A
        CALL    D.WNB
        IN      DP.DC
        RAR
        JNC     FTRK3
        POP     B               RESTORE TRK,VOL
        INX     H               POINT TO NEXT SECTOR NUM
        MOV     A,M
        ORA     A               MORE SECTORS?
        JNZ     FTRKL           YES, REPEAT PATTERN
        LDA     D.DVCTL
        OUT     DP.DC           WRITE GATE OFF
        CALL    D.XOK           EI
        MVI     A,8
        CALL    OUT350
        RET
*
D.WSP1  EQU     *
        XRA     A
        CALL    D.WNB
        DCR     C
        JNZ     D.WSP1
        MVI     A,C.DSYN
        MOV     D,A
        JMP     D.WNB
* DECODE TRACK SECTOR MODIFIED FOR DOUBLE SIDE DISKS
DDTS    EQU     *
        PUSH    B
        LXI     B,-10
        MOV     A,B
DDTS1   EQU     *
        INR     A
        DAD     B
        JC      DDTS1
        STA     D.TT
        MOV     A,L
        ADI     10
        STA     D.TS
        POP     B
* SEEK DESIRED TRACK MODIFIED FOR DOUBLE SIDE DISKS
DSDT    EQU     *
        LDA     D.TT
        MOV     C,A
        LDA     DSKTYP
        ANI     01H
        JZ      DSDTL
        MOV     A,C
        RAR
        MOV     C,A
DSDTL   EQU     *
        LHLD    D.TRKPT
        MOV     A,C
        CMP     M
        JE      DSDT2
        JP      DSDT1
        DCR     M
        CALL    D.MAO
        JMP     DSDTL
DSDT1   EQU     *
        INR     M
        CALL    D.MAI
        JMP     DSDTL
* DETERMINE SIDE SELECT
DSDT2   EQU     *
        LDA     DSKTYP
        ANI     01H
        JNZ     DSDT3
        CALL    SETS1
        JMP     D.STS
DSDT3   EQU     *               DOUBLE SIDED DISK
        LDA     D.TT
        ANI     01H             ODD TRACK?
        JNZ     DSDT4
        CALL    SETS1
        JMP     D.STS
DSDT4   EQU     *
        CALL    SETS2
        JMP     D.STS
*
ZEROBUF EQU     *
        LXI     H,TRKBUF
        LXI     B,BUFSIZ
ZEROBUL EQU     *
        XRA     A
        MOV     M,A
        INX     H
        DCX     B
        MOV     A,C
        ORA     B
        JNZ     ZEROBUL
        RET
*
DSKTYP  DB      0
DSKTRK  DB      0
* DISK HEADER
HDRVOL  DB      0
HDRTRK  DB      0
HDRSEC  DB      0
HDRCHK  DB      0
*
SECSKEW DW      SEC1
SEC1    DB      0,1,2,3,4,5,6,7,8,9,0
SEC2    DB      0,2,4,6,8,1,3,5,7,9,0
SEC3    DB      0,3,6,9,2,5,8,1,4,7,0
*
SY0     DB      'SY0:',0
SY1     DB      'SY1:',0
SY2     DB      'SY2:',0
*
BLKNUM  DW      0
TRKBUF  DS      BUFSIZ          TRACK BUFFER
*
        END     START
