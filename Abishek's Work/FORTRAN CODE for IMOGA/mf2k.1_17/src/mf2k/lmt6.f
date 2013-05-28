C  I edited all occurrences of common block HUFCOM (in sen1huf2.f, 
C  lmt6.f, gwfhuf2.f, and obs1bas6.f) to put all REAL arrays before all 
C  INTEGER arrays.  The original order is OK when both REALs and 
C  INTEGERs are KIND=4.  But when REALs are promoted to DOUBLE 
C  PRECISION, KIND goes from 4 to 8, and this generates alignment 
C  problems.  The alignment problems are avoided when all variables of 
C  larger KIND precede all variables of smaller KIND. -- ERB 6/29/2006
C
C ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C LINK-MT3DMS (LMT) PACKAGE FOR MODFLOW-2000
C Documented in:
C     Zheng, C., M.C. Hill, and P.A. Hsieh, 2001,
C         MODFLOW-2000, the U.S. Geological Survey modular ground-water
C         model--User guide to the LMT6 Package, the linkage with
C         MT3DMS for multispecies mass transport modeling:
C         U.S. Geological Survey Open-File Report 01-82
C
C Revision History
C     Version 6.0: 05-25-2001 cz
C             6.1: 05-01-2002 cz
C             6.2: 07-15-2003 cz
C             6.3: 05-10-2005 cz
C ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
C
      SUBROUTINE LMT6BAS6(INUNIT,IOUT,NCOL,NROW,NLAY,NPER,ISS,NODES,
     & IUNIT,CUNIT,NIUNIT,IBOUND,IMT3D,ILMTHEAD)
C *********************************************************************
C OPEN AND READ THE INPUT FILE FOR THE LINK-MT3DMS PACKAGE VERSION 6.
C CHECK KEY FLOW MODEL INFORMATION AND SAVE IT IN THE HEADER OF
C THE MODFLOW-MT3DMS LINK FILE FOR USE IN MT3DMS TRANSPORT SIMULATION.
C NOTE THAT IF THE 'STANDARD' HEADER OPTION IS SPECIFIED, THE LINK
C FILE IS COMPATIBLE WITH ALL VERSIONS OF MT3D/MT3DMS UP TO [3.50].
C IF THE 'EXTENDED' HEADER OPTION IS SPECIFIED, THE LINK FILE IS
C COMPATIBLE ONLY WITH MT3DMS VERSION [4.00] OR LATER.
C *********************************************************************
C last modified: 07-15-2003
C
      INTEGER     NCOL,NROW,NLAY,IUNIT,NIUNIT,NPER,ISS,NODES,IBOUND,
     &            IU,N,MTISS,MTNPER,MTCHD,IMT3D,MTBCF,MTLPF,MTHUF,
     &            MTWEL,MTDRN,MTRCH,MTEVT,MTRIV,MTSTR,MTGHB,MTRES,
     &            MTFHB,MTTLK,MTIBS,MTLAK,MTMNW,INUNIT,IOUT,ITYP1,
     &            ITYP2,ISTART,ISTOP,INAM1,INAM2,IFLEN,LLOC,INLMT,
     &            ILMTFMT,ILMTHEAD,IERR,MTUSR1,MTUSR2,MTUSR3,
     &            MTDRT,MTETS
      REAL        R
      LOGICAL     LOP
      CHARACTER   CUNIT*4,LINE*200,FNAME*200,NME*200,
     &            OUTPUT_FILE_HEADER*8,OUTPUT_FILE_FORMAT*11
      DIMENSION   IUNIT(NIUNIT),CUNIT(NIUNIT),IBOUND(NODES)
      COMMON     /LINKMT3D/ILMTFMT
      DATA        INLMT,MTBCF,MTLPF,MTHUF,MTWEL,MTDRN,MTRCH,MTEVT,
     &            MTRIV,MTSTR,MTGHB,MTRES,MTFHB,MTDRT,MTETS,MTTLK,
     &            MTIBS,MTLAK,MTMNW,MTUSR1,MTUSR2,MTUSR3
     &           /22*0/
C
C--USE FILE SPECIFICATION of MODFLOW-2000
      INCLUDE 'openspec.inc'
C
C--CHECK for OPTIONS/PACKAGES USED IN MODFLOW-2000
      IMT3D=0
      DO IU=1,NIUNIT
        IF(CUNIT(IU).EQ.'LMT6') THEN
          INLMT=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'BCF6') THEN
          MTBCF=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'LPF ') THEN
          MTLPF=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'HUF2') THEN
          MTHUF=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'WEL ') THEN
          MTWEL=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'DRN ') THEN
          MTDRN=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'RCH ') THEN
          MTRCH=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'EVT ') THEN
          MTEVT=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'RIV ') THEN
          MTRIV=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'STR ') THEN
          MTSTR=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'GHB ') THEN
          MTGHB=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'RES ') THEN
          MTRES=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'FHB ') THEN
          MTFHB=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'DRT ') THEN
          MTDRT=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'ETS ') THEN
          MTETS=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'TLK ') THEN
          MTTLK=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'IBS ') THEN
          MTIBS=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'LAK ') THEN
          MTLAK=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'MNW1') THEN
          MTMNW=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'USR1') THEN
          MTUSR1=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'USR2') THEN
          MTUSR2=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'USR3') THEN
          MTUSR3=IUNIT(IU)
        ENDIF
      ENDDO
C
C--IF LMT6 PACKAGE IS NOT ACTIVATED, SKIP TO END AND RETURN
      IF(INLMT.EQ.0) GOTO 9999
C
C--ASSIGN DEFAULTS TO LMT INPUT VARIABLES AND OUTPUT FILE NAME
      OUTPUT_FILE_HEADER='STANDARD'
      ILMTHEAD=0
      OUTPUT_FILE_FORMAT='UNFORMATTED'
      ILMTFMT=0
      INQUIRE(UNIT=INLMT,NAME=NME,OPENED=LOP)
      IFLEN=INDEX(NME,'.')-1
      IF(IFLEN.LE.0) IFLEN=INDEX(NME,' ')-1
      FNAME=NME(1:IFLEN)//'.FTL'
      IMT3D=333
C
C--READ ONE LINE OF LMT PACKAGE INPUT FILE
   10 READ(INLMT,'(A)',END=1000) LINE
      IF(LINE.EQ.' ') GOTO 10
      IF(LINE(1:1).EQ.'#') GOTO 10
C
C--DECODE THE INPUT RECORD
      LLOC=1
      CALL URWORD(LINE,LLOC,ITYP1,ITYP2,1,N,R,IOUT,INUNIT)
C
C--CHECK FOR "OUTPUT_FILE_NAME" KEYWORD AND GET FILE NAME
      IF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_NAME') THEN
        CALL URWORD(LINE,LLOC,INAM1,INAM2,0,N,R,IOUT,INUNIT)
        IFLEN=INAM2-INAM1+1
        IF(LINE(INAM1:INAM2).EQ.' ') THEN
        ELSE
          FNAME=LINE(INAM1:INAM2)
        ENDIF
C
C--CHECK FOR "OUTPUT_FILE_UNIT" KEYWORD AND GET UNIT NUMBER
      ELSEIF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_UNIT') THEN
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IU,R,IOUT,INUNIT)
        IF(IU.GT.0) THEN
          IMT3D=IU
        ELSEIF(IU.LT.0) THEN
          WRITE(IOUT,11) IU
          WRITE(*,11) IU
          CALL USTOP(' ')
        ENDIF
C
C--CHECK FOR "OUTPUT_FILE_HEADER" KEYWORD AND GET INPUT VALUE
      ELSEIF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_HEADER') Then
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INUNIT)
        IF(LINE(ISTART:ISTOP).EQ.' '.OR.
     &     LINE(ISTART:ISTOP).EQ.'STANDARD') THEN
          OUTPUT_FILE_HEADER='STANDARD'
          ILMTHEAD=0
        ELSEIF(LINE(ISTART:ISTOP).EQ.'EXTENDED') THEN
          OUTPUT_FILE_HEADER='EXTENDED'
          ILMTHEAD=1
        ELSE
          WRITE(IOUT,12) LINE(ISTART:ISTOP)
          WRITE(*,12) LINE(ISTART:ISTOP)
          CALL USTOP(' ')
        ENDIF
C
C--CHECK FOR "OUTPUT_FILE_FORMAT" KEYWORD AND GET INPUT VALUE
      ELSEIF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_FORMAT') Then
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INUNIT)
        IF(LINE(ISTART:ISTOP).EQ.' '.OR.
     &     LINE(ISTART:ISTOP).EQ.'UNFORMATTED') THEN
          OUTPUT_FILE_FORMAT='UNFORMATTED'
          ILMTFMT=0
        ELSEIF(LINE(ISTART:ISTOP).EQ.'FORMATTED') THEN
          OUTPUT_FILE_FORMAT='FORMATTED'
          ILMTFMT=1
        ELSE
          WRITE(IOUT,14) LINE(ISTART:ISTOP)
          WRITE(*,14) LINE(ISTART:ISTOP)
          CALL USTOP(' ')
        ENDIF
C
C--ERROR DECODING LMT INPUT KEYWORDS
      ELSE
        WRITE(IOUT,28) LINE
        WRITE(*,28) LINE
        CALL USTOP(' ')
      ENDIF
C
C--CONTINUE TO THE NEXT INPUT RECORD IN LMT FILE
      GOTO 10
C
   11 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'INVALID OUTPUT FILE UNIT: ',I5)
   12 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'INVALID OUTPUT_FILE_HEADER CODE: ',A)
   14 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'INVALID OUTPUT_FILE_FORMAT SPECIFIER: ',A)
   28 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'UNRECOGNIZED KEYWORD: ',A)
C
C--OPEN THE LINK-MT3DMS OUTPUT FILE NEEDED BY MT3DMS
C--AND PRINT AN IDENTIFYING MESSAGE IN MODFLOW-2000 OUTPUT FILE
 1000 INQUIRE(UNIT=IMT3D,OPENED=LOP)
      IF(LOP) THEN
        REWIND (IMT3D)
      ELSE
        IF(ILMTFMT.EQ.0) THEN
          OPEN(IMT3D,FILE=FNAME,FORM=FORM,ACCESS=ACCESS,
     &      ACTION=ACTION(2),STATUS='REPLACE')
        ELSEIF(ILMTFMT.EQ.1) THEN
          OPEN(IMT3D,FILE=FNAME,FORM='FORMATTED',ACTION=ACTION(2),
     &      STATUS='REPLACE',DELIM='APOSTROPHE')
        ENDIF
      ENDIF
C
      WRITE(IOUT,30) FNAME,IMT3D,
     &               OUTPUT_FILE_FORMAT,OUTPUT_FILE_HEADER
   30 FORMAT(//1X,'***Link-MT3DMS Package***',
     &        /1x,'OPENING LINK-MT3DMS OUTPUT FILE: ',A,
     &        /1X,'ON UNIT NUMBER: ',I5,
     &        /1X,'FILE TYPE: ',A,
     &        /1X,'HEADER OPTION: ',A,
     &        /1X,'***Link-MT3DMS Package***',/1X)
C
C--GATHER AND CHECK KEY FLOW MODEL INFORMATION
      MTISS=ISS
      MTNPER=NPER
      MTCHD=0
      DO N=1,NODES
        IF(IBOUND(N).LT.0) MTCHD=MTCHD+1
      ENDDO
C
C--ERROR CHECKING
      IF(OUTPUT_FILE_HEADER.EQ.'STANDARD') THEN
        IF(MTRIV.GT.0.AND.MTSTR.GT.0) THEN
          WRITE(*,1200)
          CALL USTOP(' ')
        ELSEIF(MTFHB.GT.0) THEN
          WRITE(*,1202)
          CALL USTOP(' ')
        ELSEIF(MTRES.GT.0) THEN
          WRITE(*,1204)
          CALL USTOP(' ')
        ELSEIF(MTTLK.GT.0) THEN
          WRITE(*,1206)
          CALL USTOP(' ')
        ELSEIF(MTIBS.GT.0) THEN
          WRITE(*,1208)
          CALL USTOP(' ')
        ELSEIF(MTLAK.GT.0) THEN
          WRITE(*,1210)
          CALL USTOP(' ')
        ELSEIF(MTMNW.GT.0) THEN
          WRITE(*,1212)
          CALL USTOP(' ')
        ELSEIF(MTDRT.GT.0) THEN
          WRITE(*,1214)
          CALL USTOP(' ')
        ELSEIF(MTETS.GT.0) THEN
          WRITE(*,1216)
          CALL USTOP(' ')
        ELSEIF(MTUSR1.GT.0.OR.MTUSR2.GT.0.OR.MTUSR3.GT.0) THEN
          WRITE(*,1224)
          CALL USTOP(' ')
        ENDIF
      ENDIF
      IF(MTEVT.GT.0.AND.MTETS.GT.0) THEN
        WRITE(*,1300)
        CALL USTOP(' ')
      ENDIF
 1200 FORMAT(/1X,'Both RIV and STR packages are used in flow model;',
     &  /1X,'The Link-MT3DMS file must be saved with EXTENDED header.')
 1202 FORMAT(/1X,'The FHB Pacakge is used in flow simulation;',
     &  /1X,'The Link-MT3DMS file must be saved with EXTENDED header.')
 1204 FORMAT(/1X,'The RES Pacakge is used in flow simulation;',
     &  /1X,'The Link-MT3DMS file must be saved with EXTENDED header.')
 1206 FORMAT(/1X,'The TLK Pacakge is used in flow simulation;',
     &  /1X,'The Link-MT3DMS file must be saved with EXTENDED header.')
 1208 FORMAT(/1X,'The IBS Pacakge is used in flow simulation;',
     &  /1X,'The Link-MT3DMS file must be saved with EXTENDED header.')
 1210 FORMAT(/1X,'The LAK Pacakge is used in flow simulation;',
     &  /1X,'The Link-MT3DMS file must be saved with EXTENDED header.')
 1212 FORMAT(/1X,'The MNW Pacakge is used in flow simulation;',
     &  /1X,'The Link-MT3DMS file must be saved with EXTENDED header.')
 1214 FORMAT(/1X,'The DRT Pacakge is used in flow simulation;',
     &  /1X,'The Link-MT3DMS file must be saved with EXTENDED header.')
 1216 FORMAT(/1X,'The ETS Pacakge is used in flow simulation;',
     &  /1X,'The Link-MT3DMS file must be saved with EXTENDED header.')
 1224 FORMAT(/1X,'A USER-DEFINED Pacakge is used in flow simulation;',
     &  /1X,'The Link-MT3DMS file must be saved with EXTENDED header.')
 1300 FORMAT(/1X,'Both EVT and ETS Packages are used in flow ',
     &  'simulation;'
     &  /1X,'Only one is allowed in the same transport simulation.')
C
C--WRITE A HEADER TO MODFLOW-MT3DMS LINK FILE
      IF(OUTPUT_FILE_HEADER.EQ.'STANDARD') THEN
        MTRIV=MAX(MTRIV,MTSTR)
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IMT3D) 'MT3D3.00.99',
     &     MTWEL,MTDRN,MTRCH,MTEVT,MTRIV,MTGHB,MTCHD,MTISS,MTNPER
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IMT3D,*) 'MT3D3.00.99',
     &     MTWEL,MTDRN,MTRCH,MTEVT,MTRIV,MTGHB,MTCHD,MTISS,MTNPER
        ENDIF
      ELSEIF(OUTPUT_FILE_HEADER.EQ.'EXTENDED') THEN
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IMT3D) 'MT3D4.00.00',
     &     MTWEL,MTDRN,MTRCH,MTEVT,MTRIV,MTGHB,MTCHD,MTISS,MTNPER,
     &     MTSTR,MTRES,MTFHB,MTDRT,MTETS,MTTLK,MTIBS,MTLAK,MTMNW,
     &     MTUSR1,MTUSR2,MTUSR3
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IMT3D,*) 'MT3D4.00.00',
     &     MTWEL,MTDRN,MTRCH,MTEVT,MTRIV,MTGHB,MTCHD,MTISS,MTNPER,
     &     MTSTR,MTRES,MTFHB,MTDRT,MTETS,MTTLK,MTIBS,MTLAK,MTMNW,
     &     MTUSR1,MTUSR2,MTUSR3
        ENDIF
      ENDIF
C
C--NORMAL RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT6BCF6(HNEW,IBOUND,CR,CC,CV,ISS,ISSCURRENT,DELT,
     & SC1,SC2,HOLD,BOTM,NBOTM,NCOL,NROW,NLAY,KSTP,KPER,BUFF,IOUT)
C *********************************************************************
C SAVE SATURATED CELL THICKNESS; FLOW ACROSS THREE CELL INTERFACES;
C TRANSIENT FLUID-STORAGE; AND LOCATIONS AND FLOW RATES OF
C CONSTANT-HEAD CELLS FOR USE BY MT3D.  THIS SUBROUTINE IS CALLED
C ONLY IF THE 'BCF6' PACKAGE IS USED IN MODFLOW.
C *********************************************************************
C Modified from Harbaugh et al. (2000)
C last modified: 05-01-2002
C
      CHARACTER*16 TEXT
      DOUBLE PRECISION HNEW,HD
      DIMENSION HNEW(NCOL,NROW,NLAY), IBOUND(NCOL,NROW,NLAY),
     & CR(NCOL,NROW,NLAY), CC(NCOL,NROW,NLAY),
     & CV(NCOL,NROW,NLAY), SC1(NCOL,NROW,NLAY), SC2(NCOL,NROW,NLAY),
     & BOTM(NCOL,NROW,0:NBOTM),BUFF(NCOL,NROW,NLAY),HOLD(NCOL,NROW,NLAY)
      COMMON /BCFCOM/LAYCON(999)
      COMMON /DISCOM/LBOTM(999),LAYCBD(999)
      COMMON /LINKMT3D/ILMTFMT
C
C--CALCULATE AND SAVE SATURATED THICKNESS
      TEXT='THKSAT'
C
C--INITIALIZE BUFF ARRAY WITH 1.E30 FOR INACTIVE CELLS
C--OR FLAG -111 FOR ACTIVE CELLS
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).EQ.0) THEN
              BUFF(J,I,K)=1.E30
            ELSE
              BUFF(J,I,K)=-111.
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE SATURATED THICKNESS FOR UNCONFINED/CONVERTIBLE
C--LAYERS AND STORE IN ARRAY BUFF
      DO K=1,NLAY
        IF(LAYCON(K).EQ.0 .OR. LAYCON(K).EQ.2) CYCLE
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0) THEN
              TMP=HNEW(J,I,K)
              BUFF(J,I,K)=TMP-BOTM(J,I,LBOTM(K))
              IF(LAYCON(K).EQ.3) THEN
                THKLAY=BOTM(J,I,LBOTM(K)-1)-BOTM(J,I,LBOTM(K))
                IF(BUFF(J,I,K).GT.THKLAY) BUFF(J,I,K)=THKLAY
              ENDIF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--SAVE THE CONTENTS OF THE BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
C--CALCULATE AND SAVE FLOW ACROSS RIGHT FACE
      NCM1=NCOL-1
      IF(NCM1.LT.1) GO TO 405
      TEXT='QXX'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCM1
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J+1,I,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
              BUFF(J,I,K)=HDIFF*CR(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  405 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NRM1=NROW-1
      IF(NRM1.LT.1) GO TO 505
      TEXT='QYY'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NRM1
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I+1,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
              BUFF(J,I,K)=HDIFF*CC(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  505 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NLM1=NLAY-1
      IF(NLM1.LT.1) GO TO 700
      TEXT='QZZ'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL CALCULATE FLOW THRU LOWER FACE & STORE IN BUFFER
      DO K=1,NLM1
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I,K+1).NE.0) THEN
              HD=HNEW(J,I,K+1)
              IF(LAYCON(K+1).EQ.3 .OR. LAYCON(K+1).EQ.2) THEN
                TMP=HD
                IF(TMP.LT.BOTM(J,I,LBOTM(K+1)-1))
     &           HD=BOTM(J,I,LBOTM(K+1)-1)
              ENDIF
              HDIFF=HNEW(J,I,K)-HD
              BUFF(J,I,K)=HDIFF*CV(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  700 CONTINUE
C
C--CALCULATE AND SAVE GROUNDWATER STORAGE IF TRANSIENT
      IF(ISS.NE.0) GO TO 705
      TEXT='STO'
C
C--INITIALIZE AND CLEAR BUFFER
      ZERO=0.
      ONE=1.
      TLED=ONE/DELT
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
      IF(ISSCURRENT.NE.0) GOTO 704
C
C--RUN THROUGH EVERY CELL IN THE GRID
      KT=0
      DO K=1,NLAY
        LC=LAYCON(K)
        IF(LC.EQ.3 .OR. LC.EQ.2) KT=KT+1
        DO I=1,NROW
          DO J=1,NCOL
C
C--CALCULATE FLOW FROM STORAGE (VARIABLE HEAD CELLS ONLY)
            IF(IBOUND(J,I,K).GT.0) THEN
              HSING=HNEW(J,I,K)
              IF(LC.NE.3 .AND. LC.NE.2) THEN
                RHO=SC1(J,I,K)*TLED
                STRG=RHO*HOLD(J,I,K) - RHO*HSING
              ELSE
                TP=BOTM(J,I,LBOTM(K)-1)
                RHO2=SC2(J,I,KT)*TLED
                RHO1=SC1(J,I,K)*TLED
                SOLD=RHO2
                IF(HOLD(J,I,K).GT.TP) SOLD=RHO1
                SNEW=RHO2
                IF(HSING.GT.TP) SNEW=RHO1
                STRG=SOLD*(HOLD(J,I,K)-TP) + SNEW*TP - SNEW*HSING
              ENDIF
              BUFF(J,I,K)=STRG
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
  704 IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  705 CONTINUE
C
C--CALCULATE FLOW INTO OR OUT OF CONSTANT-HEAD CELLS
      TEXT='CNH'
      NCNH=0
C
C--CLEAR BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL IF IT IS CONSTANT HEAD COMPUTE FLOW ACROSS 6
C--FACES.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--IF CELL IS NOT CONSTANT HEAD SKIP IT & GO ON TO NEXT CELL.
            IF(IBOUND(J,I,K).GE.0) CYCLE
            NCNH=NCNH+1
C
C--CLEAR FIELDS FOR SIX FLOW RATES.
            X1=0.
            X2=0.
            X3=0.
            X4=0.
            X5=0.
            X6=0.
C
C--CALCULATE FLOW THROUGH THE LEFT FACE
C
C--IF THERE IS AN INACTIVE CELL ON THE OTHER SIDE OF THIS
C--FACE THEN GO ON TO THE NEXT FACE.
            IF(J.EQ.1) GO TO 30
            IF(IBOUND(J-1,I,K).EQ.0) GO TO 30
            HDIFF=HNEW(J,I,K)-HNEW(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THIS FACE INTO THE ADJACENT CELL.
            X1=HDIFF*CR(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THE RIGHT FACE
   30       IF(J.EQ.NCOL) GO TO 60
            IF(IBOUND(J+1,I,K).EQ.0) GO TO 60
            HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
            X2=HDIFF*CR(J,I,K)
C
C--CALCULATE FLOW THROUGH THE BACK FACE.
   60       IF(I.EQ.1) GO TO 90
            IF (IBOUND(J,I-1,K).EQ.0) GO TO 90
            HDIFF=HNEW(J,I,K)-HNEW(J,I-1,K)
            X3=HDIFF*CC(J,I-1,K)
C
C--CALCULATE FLOW THROUGH THE FRONT FACE.
   90       IF(I.EQ.NROW) GO TO 120
            IF(IBOUND(J,I+1,K).EQ.0) GO TO 120
            HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
            X4=HDIFF*CC(J,I,K)
C
C--CALCULATE FLOW THROUGH THE UPPER FACE
  120       IF(K.EQ.1) GO TO 150
            IF (IBOUND(J,I,K-1).EQ.0) GO TO 150
            HD=HNEW(J,I,K)
            IF(LAYCON(K).NE.3 .AND. LAYCON(K).NE.2) GO TO 122
            TMP=HD
            IF(TMP.LT.BOTM(J,I,LBOTM(K)-1))
     &       HD=BOTM(J,I,LBOTM(K)-1)
  122       HDIFF=HD-HNEW(J,I,K-1)
            X5=HDIFF*CV(J,I,K-1)
C
C--CALCULATE FLOW THROUGH THE LOWER FACE.
  150       IF(K.EQ.NLAY) GO TO 180
            IF(IBOUND(J,I,K+1).EQ.0) GO TO 180
            HD=HNEW(J,I,K+1)
            IF(LAYCON(K+1).NE.3 .AND. LAYCON(K+1).NE.2) GO TO 152
            TMP=HD
            IF(TMP.LT.BOTM(J,I,LBOTM(K+1)-1))
     &       HD=BOTM(J,I,LBOTM(K+1)-1)
  152       HDIFF=HNEW(J,I,K)-HD
            X6=HDIFF*CV(J,I,K)
C
C--SUM UP FLOWS THROUGH SIX SIDES OF CONSTANT HEAD CELL.
  180       BUFF(J,I,K)=X1+X2+X3+X4+X5+X6
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCNH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NCNH
      ENDIF
C
C--IF THERE ARE NO CONSTANT-HEAD CELLS THEN SKIP
      IF(NCNH.LE.0) GOTO 1000
C
C--WRITE CONSTANT-HEAD CELL LOCATIONS AND RATES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).LT.0) THEN
              IF(ILMTFMT.EQ.0) WRITE(IOUT)   K,I,J,BUFF(J,I,K)
              IF(ILMTFMT.EQ.1) WRITE(IOUT,*) K,I,J,BUFF(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
 1000 CONTINUE
      RETURN
      END
C
C
      SUBROUTINE LMT6LPF1(HNEW,IBOUND,CR,CC,CV,ISS,ISSCURRENT,DELT,
     & SC1,SC2,HOLD,BOTM,NBOTM,NCOL,NROW,NLAY,KSTP,KPER,BUFF,IOUT)
C *********************************************************************
C SAVE FLOW ACROSS THREE CELL INTERFACES (QXX, QYY, QZZ), FLOW RATE TO
C OR FROM TRANSIENT FLUID-STORAGE (QSTO), AND LOCATIONS AND FLOW RATES
C OF CONSTANT-HEAD CELLS FOR USE BY MT3D.  THIS SUBROUTINE IS CALLED
C ONLY IF THE 'LPF1' PACKAGE IS USED IN MODFLOW.
C *********************************************************************
C Modified from Harbaugh et al. (2000)
C last modified: 05-01-2002
C
      CHARACTER*16 TEXT
      DOUBLE PRECISION HNEW,HD
      DIMENSION HNEW(NCOL,NROW,NLAY), IBOUND(NCOL,NROW,NLAY),
     & CR(NCOL,NROW,NLAY), CC(NCOL,NROW,NLAY),
     & CV(NCOL,NROW,NLAY), SC1(NCOL,NROW,NLAY), SC2(NCOL,NROW,NLAY),
     & BOTM(NCOL,NROW,0:NBOTM),BUFF(NCOL,NROW,NLAY),HOLD(NCOL,NROW,NLAY)
      COMMON /DISCOM/LBOTM(999),LAYCBD(999)
      COMMON /LPFCOM/LAYTYP(999),LAYAVG(999),CHANI(999),LAYVKA(999),
     &        LAYWET(999)
      COMMON /LINKMT3D/ILMTFMT
C
C--CALCULATE AND SAVE SATURATED THICKNESS
      TEXT='THKSAT'
C
C--INITIALIZE BUFF ARRAY WITH 1.E30 FOR INACTIVE CELLS
C--OR FLAG -111 FOR ACTIVE CELLS
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).EQ.0) THEN
              BUFF(J,I,K)=1.E30
            ELSE
              BUFF(J,I,K)=-111.
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE SATURATED THICKNESS FOR UNCONFINED/CONVERTIBLE
C--LAYERS AND STORE IN ARRAY BUFF
      DO K=1,NLAY
        IF(LAYTYP(K).EQ.0) CYCLE
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0) THEN
              TMP=HNEW(J,I,K)
              BUFF(J,I,K)=TMP-BOTM(J,I,LBOTM(K))
              THKLAY=BOTM(J,I,LBOTM(K)-1)-BOTM(J,I,LBOTM(K))
              IF(BUFF(J,I,K).GT.THKLAY) BUFF(J,I,K)=THKLAY
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--SAVE THE CONTENTS OF THE BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
C--CALCULATE AND SAVE FLOW ACROSS RIGHT FACE
      NCM1=NCOL-1
      IF(NCM1.LT.1) GO TO 405
      TEXT='QXX'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCM1
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J+1,I,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
              BUFF(J,I,K)=HDIFF*CR(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  405 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NRM1=NROW-1
      IF(NRM1.LT.1) GO TO 505
      TEXT='QYY'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NRM1
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I+1,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
              BUFF(J,I,K)=HDIFF*CC(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  505 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NLM1=NLAY-1
      IF(NLM1.LT.1) GO TO 700
      TEXT='QZZ'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL CALCULATE FLOW THRU LOWER FACE & STORE IN BUFFER
      DO K=1,NLM1
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I,K+1).NE.0) THEN
              HD=HNEW(J,I,K+1)
              IF(LAYTYP(K+1).NE.0) THEN
                TMP=HD
                TOP=BOTM(J,I,LBOTM(K+1)-1)
                IF(TMP.LT.TOP) HD=TOP
              ENDIF
              HDIFF=HNEW(J,I,K)-HD
              BUFF(J,I,K)=HDIFF*CV(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  700 CONTINUE
C
C--CALCULATE AND SAVE GROUNDWATER STORAGE IF TRANSIENT
      IF(ISS.NE.0) GO TO 705
      TEXT='STO'
C
C--INITIALIZE AND CLEAR BUFFER
      ZERO=0.
      ONE=1.
      TLED=ONE/DELT
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
      IF(ISSCURRENT.NE.0) GOTO 704
C
C--RUN THROUGH EVERY CELL IN THE GRID
      KT=0
      DO K=1,NLAY
        LC=LAYTYP(K)
        IF(LC.NE.0) KT=KT+1
        DO I=1,NROW
          DO J=1,NCOL
C
C--CALCULATE FLOW FROM STORAGE (VARIABLE HEAD CELLS ONLY)
            IF(IBOUND(J,I,K).GT.0) THEN
              HSING=HNEW(J,I,K)
              IF(LC.EQ.0) THEN
                RHO=SC1(J,I,K)*TLED
                STRG=RHO*HOLD(J,I,K) - RHO*HSING
              ELSE
                TP=BOTM(J,I,LBOTM(K)-1)
                RHO2=SC2(J,I,KT)*TLED
                RHO1=SC1(J,I,K)*TLED
                SOLD=RHO2
                IF(HOLD(J,I,K).GT.TP) SOLD=RHO1
                SNEW=RHO2
                IF(HSING.GT.TP) SNEW=RHO1
                STRG=SOLD*(HOLD(J,I,K)-TP) + SNEW*TP - SNEW*HSING
              ENDIF
              BUFF(J,I,K)=STRG
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
  704 IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  705 CONTINUE
C
C--CALCULATE FLOW INTO OR OUT OF CONSTANT-HEAD CELLS
      TEXT='CNH'
      NCNH=0
C
C--CLEAR BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL IF IT IS CONSTANT HEAD COMPUTE FLOW ACROSS 6
C--FACES.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--IF CELL IS NOT CONSTANT HEAD SKIP IT & GO ON TO NEXT CELL.
            IF(IBOUND(J,I,K).GE.0) CYCLE
            NCNH=NCNH+1
C
C--CLEAR FIELDS FOR SIX FLOW RATES.
            X1=0.
            X2=0.
            X3=0.
            X4=0.
            X5=0.
            X6=0.
C
C--CALCULATE FLOW THROUGH THE LEFT FACE
C
C--IF THERE IS AN INACTIVE CELL ON THE OTHER SIDE OF THIS
C--FACE THEN GO ON TO THE NEXT FACE.
            IF(J.EQ.1) GO TO 30
            IF(IBOUND(J-1,I,K).EQ.0) GO TO 30
            HDIFF=HNEW(J,I,K)-HNEW(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THIS FACE INTO THE ADJACENT CELL.
            X1=HDIFF*CR(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THE RIGHT FACE
   30       IF(J.EQ.NCOL) GO TO 60
            IF(IBOUND(J+1,I,K).EQ.0) GO TO 60
            HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
            X2=HDIFF*CR(J,I,K)
C
C--CALCULATE FLOW THROUGH THE BACK FACE.
   60       IF(I.EQ.1) GO TO 90
            IF (IBOUND(J,I-1,K).EQ.0) GO TO 90
            HDIFF=HNEW(J,I,K)-HNEW(J,I-1,K)
            X3=HDIFF*CC(J,I-1,K)
C
C--CALCULATE FLOW THROUGH THE FRONT FACE.
   90       IF(I.EQ.NROW) GO TO 120
            IF(IBOUND(J,I+1,K).EQ.0) GO TO 120
            HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
            X4=HDIFF*CC(J,I,K)
C
C--CALCULATE FLOW THROUGH THE UPPER FACE
  120       IF(K.EQ.1) GO TO 150
            IF (IBOUND(J,I,K-1).EQ.0) GO TO 150
            HD=HNEW(J,I,K)
            IF(LAYTYP(K).EQ.0) GO TO 122
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K)-1)
            IF(TMP.LT.TOP) HD=TOP
  122       HDIFF=HD-HNEW(J,I,K-1)
            X5=HDIFF*CV(J,I,K-1)
C
C--CALCULATE FLOW THROUGH THE LOWER FACE.
  150       IF(K.EQ.NLAY) GO TO 180
            IF(IBOUND(J,I,K+1).EQ.0) GO TO 180
            HD=HNEW(J,I,K+1)
            IF(LAYTYP(K+1).EQ.0) GO TO 152
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K+1)-1)
            IF(TMP.LT.TOP) HD=TOP
  152       HDIFF=HNEW(J,I,K)-HD
            X6=HDIFF*CV(J,I,K)
C
C--SUM UP FLOWS THROUGH SIX SIDES OF CONSTANT HEAD CELL.
  180       BUFF(J,I,K)=X1+X2+X3+X4+X5+X6
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCNH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NCNH
      ENDIF
C
C--IF THERE ARE NO CONSTANT-HEAD CELLS THEN SKIP
      IF(NCNH.LE.0) GOTO 1000
C
C--WRITE CONSTANT-HEAD CELL LOCATIONS AND RATES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).LT.0) THEN
              IF(ILMTFMT.EQ.0) WRITE(IOUT)   K,I,J,BUFF(J,I,K)
              IF(ILMTFMT.EQ.1) WRITE(IOUT,*) K,I,J,BUFF(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
 1000 CONTINUE
      RETURN
      END
C
C
      SUBROUTINE LMT6HUF2(HNEW,IBOUND,CR,CC,CV,ISS,ISSCURRENT,DELT,
     & HOLD,SC1,BOTM,NBOTM,NCOL,NROW,NLAY,KSTP,KPER,HUFTHK,NHUF,IZON,
     & NZONAR,RMLT,NMLTAR,DELR,DELC,BUFF,IOUT,ILVDA,VDHT)
C *********************************************************************
C SAVE FLOW ACROSS THREE CELL INTERFACES (QXX, QYY, QZZ), FLOW RATE TO
C OR FROM TRANSIENT FLUID-STORAGE (QSTO), AND LOCATIONS AND FLOW RATES
C OF CONSTANT-HEAD CELLS FOR USE BY MT3D.  THIS SUBROUTINE IS CALLED
C ONLY IF THE 'HUF' PACKAGE IS USED IN MODFLOW.
C *********************************************************************
C Modified from Anderman and Hill (2000) & Anderman et al. (2002)
C last modified: 05-10-2005
C
      CHARACTER*16 TEXT
      DOUBLE PRECISION HNEW,HN,HD,DFL,DFR,DFT,DFB
      DIMENSION HNEW(NCOL,NROW,NLAY),IBOUND(NCOL,NROW,NLAY),
     & CR(NCOL,NROW,NLAY),CC(NCOL,NROW,NLAY),CV(NCOL,NROW,NLAY),
     & SC1(NCOL,NROW,NLAY),HUFTHK(NCOL,NROW,NLAY,NHUF,2),
     & IZON(NCOL,NROW,NZONAR),RMLT(NCOL,NROW,NMLTAR),
     & DELR(NCOL),DELC(NROW),BOTM(NCOL,NROW,0:NBOTM),
     & BUFF(NCOL,NROW,NLAY),HOLD(NCOL,NROW,NLAY),
     & VDHT(NCOL,NROW,NLAY,3)
      COMMON /DISCOM/LBOTM(999),LAYCBD(999)
      COMMON /HUFCOM/HGUHANI(999),HGUVANI(999),LTHUF(999),LAYWT(999)
      COMMON /LINKMT3D/ILMTFMT
C
C--CALCULATE AND SAVE SATURATED THICKNESS
      TEXT='THKSAT'
C
C--INITIALIZE BUFF ARRAY WITH 1.E30 FOR INACTIVE CELLS
C--OR FLAG -111 FOR ACTIVE CELLS
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).EQ.0) THEN
              BUFF(J,I,K)=1.E30
            ELSE
              BUFF(J,I,K)=-111.
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE SATURATED THICKNESS FOR UNCONFINED/CONVERTIBLE
C--LAYERS AND STORE IN ARRAY BUFF
      DO K=1,NLAY
        IF(LTHUF(K).EQ.0) CYCLE
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0) THEN
              TMP=HNEW(J,I,K)
              BUFF(J,I,K)=TMP-BOTM(J,I,LBOTM(K))
              THKLAY=BOTM(J,I,LBOTM(K)-1)-BOTM(J,I,LBOTM(K))
              IF(BUFF(J,I,K).GT.THKLAY) BUFF(J,I,K)=THKLAY
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--SAVE THE CONTENTS OF THE BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
C--CALCULATE AND SAVE FLOW ACROSS RIGHT FACE
      NCM1=NCOL-1
      IF(NCM1.LT.1) GO TO 405
      TEXT='QXX'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCM1
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J+1,I,K).NE.0) THEN            
              if(ILVDA.gt.0) then
                CALL SGWF1HUF2VDF9(I,J,K,VDHT,HNEW,IBOUND,
     &           NLAY,NROW,NCOL,DFL,DFR,DFT,DFB)
                BUFF(J,I,K) = DFR
              else                       
                HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
                BUFF(J,I,K)=HDIFF*CR(J,I,K)
              endif  
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  405 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NRM1=NROW-1
      IF(NRM1.LT.1) GO TO 505
      TEXT='QYY'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NRM1
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I+1,K).NE.0) THEN
              if(ILVDA.gt.0) then
                CALL SGWF1HUF2VDF9(I,J,K,VDHT,HNEW,IBOUND,
     &           NLAY,NROW,NCOL,DFL,DFR,DFT,DFB)
                BUFF(J,I,K) = DFT
              else                        
                HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
                BUFF(J,I,K)=HDIFF*CC(J,I,K)
              endif  
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  505 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS LOWER FACE
      NLM1=NLAY-1
      IF(NLM1.LT.1) GO TO 700
      TEXT='QZZ'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL 
      DO K=1,NLM1
        DO I=1,NROW
          DO J=1,NCOL
C
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I,K+1).NE.0) THEN
              HD=HNEW(J,I,K+1)
              IF(LTHUF(K+1).NE.0) THEN
                TMP=HD
                TOP=BOTM(J,I,LBOTM(K+1)-1)
                IF(TMP.LT.TOP) HD=TOP
              ENDIF
              HDIFF=HNEW(J,I,K)-HD
              BUFF(J,I,K)=HDIFF*CV(J,I,K)
            ENDIF
C
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  700 CONTINUE
C
C--CALCULATE AND SAVE GROUNDWATER STORAGE IF TRANSIENT
      IF(ISS.NE.0) GO TO 705
      TEXT='STO'
C
C--INITIALIZE and CLEAR BUFFER
      ZERO=0.
      ONE=1.
      TLED=ONE/DELT
      DO K=1,NLAY 
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
      IF(ISSCURRENT.NE.0) GOTO 704
C
C5------LOOP THROUGH EVERY CELL IN THE GRID.
      KT=0
      DO K=1,NLAY
        LC=LTHUF(K)
        IF(LC.NE.0) KT=KT+1
        DO I=1,NROW
          DO J=1,NCOL
C
C6------SKIP NO-FLOW AND CONSTANT-HEAD CELLS.
            IF(IBOUND(J,I,K).LE.0) CYCLE
            HN=HNEW(J,I,K)
            HO=HOLD(J,I,K)
            STRG=0.
C
C7-----CHECK LAYER TYPE TO SEE IF ONE STORAGE CAPACITY OR TWO.
            IF(LC.EQ.0) GO TO 285
            TOP=BOTM(J,I,LBOTM(K)-1)
            BOT=BOTM(J,I,LBOTM(K))
            IF(HO.GT.TOP.AND.HN.GT.TOP) GOTO 285
C
C7A----TWO STORAGE CAPACITIES.
C---------------Compute SC1 Component
            IF(HO.GT.TOP) THEN
              STRG=SC1(J,I,K)*(HO-TOP)*TLED
            ELSEIF(HN.GT.TOP) THEN
              STRG=SC1(J,I,K)*TLED*(TOP-HN)
            ENDIF
C---------------Compute SC2 Component
            CALL SGWF1HUF2SC2(1,J,I,K,TOP,BOT,HN,HO,TLED,CHCOF,STRG,
     &       HUFTHK,NCOL,NROW,NHUF,IZON,NZONAR,RMLT,NMLTAR,
     &       DELR(J)*DELC(I),IOUT)          
C------STRG=SOLD*(HOLD(J,I,K)-TP) + SNEW*TP - SNEW*HSING
            GOTO 288
C
C7B----ONE STORAGE CAPACITY.
  285       RHO=SC1(J,I,K)*TLED
            STRG=RHO*(HO-HN)
C
C8-----STORE CELL-BY-CELL FLOW IN BUFFER
  288       BUFF(J,I,K)=STRG
C
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
  704 IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IOUT) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
        WRITE(IOUT,*) BUFF
      ENDIF
C
  705 CONTINUE
C
C--CALCULATE FLOW INTO OR OUT OF CONSTANT-HEAD CELLS
      TEXT='CNH'
      NCNH=0
C
C--CLEAR BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL IF IT IS CONSTANT HEAD COMPUTE FLOW ACROSS 6
C--FACES.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--IF CELL IS NOT CONSTANT HEAD SKIP IT & GO ON TO NEXT CELL.
            IF (IBOUND(J,I,K).GE.0) CYCLE
            NCNH=NCNH+1
C
C--CLEAR FIELDS FOR SIX FLOW RATES.
            X1=0.
            X2=0.
            X3=0.
            X4=0.
            X5=0.
            X6=0.
C            
C--COMPUTE HORIZONTAL FLUXES IF THE LVDA CAPABILITY IS USED            
            if(ILVDA.gt.0)
     &       CALL SGWF1HUF2VDF9(I,J,K,VDHT,HNEW,IBOUND,
     &       NLAY,NROW,NCOL,DFL,DFR,DFT,DFB)                        
C
C--CALCULATE FLOW THROUGH THE LEFT FACE
C
C--IF THERE IS AN INACTIVE CELL ON THE OTHER SIDE OF THIS
C--FACE THEN GO ON TO THE NEXT FACE.
            IF(J.EQ.1) GO TO 30
            IF(IBOUND(J-1,I,K).EQ.0) GO TO 30
C
C--CALCULATE FLOW THROUGH THIS FACE INTO THE ADJACENT CELL.
            if(ILVDA.gt.0) then
              X1 = -DFL
            else
              HDIFF=HNEW(J,I,K)-HNEW(J-1,I,K)            
              X1=HDIFF*CR(J-1,I,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE RIGHT FACE
   30       IF(J.EQ.NCOL) GO TO 60
            IF(IBOUND(J+1,I,K).EQ.0) GO TO 60
            if(ILVDA.gt.0) then
              X2 = DFR
            else                       
              HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
              X2=HDIFF*CR(J,I,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE BACK FACE.
   60       IF(I.EQ.1) GO TO 90
            IF (IBOUND(J,I-1,K).EQ.0) GO TO 90
            if(ILVDA.gt.0) then
              X3 = -DFT
            else                       
              HDIFF=HNEW(J,I,K)-HNEW(J,I-1,K)
              X3=HDIFF*CC(J,I-1,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE FRONT FACE.
   90       IF(I.EQ.NROW) GO TO 120
            IF(IBOUND(J,I+1,K).EQ.0) GO TO 120
            if(ILVDA.gt.0) then
              X4 = DFB
            else             
              HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
              X4=HDIFF*CC(J,I,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE UPPER FACE
  120       IF(K.EQ.1) GO TO 150
            IF (IBOUND(J,I,K-1).EQ.0) GO TO 150
            HD=HNEW(J,I,K)
            IF(LTHUF(K).EQ.0) GO TO 122
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K)-1)
            IF(TMP.LT.TOP) HD=TOP
  122       HDIFF=HD-HNEW(J,I,K-1)
            X5=HDIFF*CV(J,I,K-1)
C
C--CALCULATE FLOW THROUGH THE LOWER FACE.
  150       IF(K.EQ.NLAY) GO TO 180
            IF(IBOUND(J,I,K+1).EQ.0) GO TO 180
            HD=HNEW(J,I,K+1)
            IF(LTHUF(K+1).EQ.0) GO TO 152
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K+1)-1)
            IF(TMP.LT.TOP) HD=TOP
  152       HDIFF=HNEW(J,I,K)-HD
            X6=HDIFF*CV(J,I,K)
C
C--SUM UP FLOWS THROUGH SIX SIDES OF CONSTANT HEAD CELL.
  180       BUFF(J,I,K)=X1+X2+X3+X4+X5+X6
C
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCNH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NCNH
      ENDIF
C
C--IF THERE ARE NO CONSTANT-HEAD CELLS THEN SKIP
      IF(NCNH.LE.0) GOTO 1000
C
C--WRITE CONSTANT-HEAD CELL LOCATIONS AND RATES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).LT.0) THEN
              IF(ILMTFMT.EQ.0) WRITE(IOUT)   K,I,J,BUFF(J,I,K)
              IF(ILMTFMT.EQ.1) WRITE(IOUT,*) K,I,J,BUFF(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
 1000 CONTINUE
      RETURN
      END
C
C
      SUBROUTINE LMT6WEL6(NWELLS,MXWELL,NWELVL,WELL,IBOUND,
     &  NCOL,NROW,NLAY,KSTP,KPER,IOUT)
C *********************************************************************
C SAVE WELL CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C *********************************************************************
C Modified from  Harbaugh et al. (2000)
C last modified: 05-01-2002
C
      CHARACTER*16 TEXT
      DIMENSION WELL(NWELVL,MXWELL),IBOUND(NCOL,NROW,NLAY)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='WEL'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NWELLS
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NWELLS
      ENDIF
C
C--IF THERE ARE NO WELLS RETURN
      IF(NWELLS.LE.0) RETURN
C
C--WRITE WELL LOCATION AND RATE ONE AT A TIME
      DO L=1,NWELLS
        IL=WELL(1,L)
        IR=WELL(2,L)
        IC=WELL(3,L)
C
C--IF CELL IS EXTERNAL Q=0
        Q=0.
        IF(IBOUND(IC,IR,IL).GT.0) Q=WELL(4,L)
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IOUT) IL,IR,IC,Q
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IOUT,*) IL,IR,IC,Q
        ENDIF
      ENDDO
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT6DRN6(NDRAIN,MXDRN,NDRNVL,DRAI,HNEW,
     &  NCOL,NROW,NLAY,IBOUND,KSTP,KPER,IOUT)
C ********************************************************************
C SAVE DRAIN CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C ********************************************************************
C Modified from Harbaugh et al. (2000)
C last modified: 05-01-2002
C
      CHARACTER*16 TEXT
      DOUBLE PRECISION HNEW,CEL,CC,HHNEW
      DIMENSION DRAI(NDRNVL,MXDRN),
     &           HNEW(NCOL,NROW,NLAY),IBOUND(NCOL,NROW,NLAY)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='DRN'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NDRAIN
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NDRAIN
      ENDIF
C
C--IF THERE ARE NO DRAINS THEN SKIP
      IF(NDRAIN.LE.0) RETURN
C
C--FOR EACH DRAIN ACCUMULATE DRAIN FLOW
      DO L=1,NDRAIN
C
C--GET LAYER, ROW & COLUMN OF CELL CONTAINING REACH.
        IL=DRAI(1,L)
        IR=DRAI(2,L)
        IC=DRAI(3,L)
        Q=0.
C
C--CALCULATE Q FOR ACTIVE CELLS
        IF(IBOUND(IC,IR,IL).GT.0) THEN
C
C--GET DRAIN PARAMETERS FROM DRAIN LIST.
          EL=DRAI(4,L)
          C=DRAI(5,L)
          HHNEW=HNEW(IC,IR,IL)
          CEL=C*EL
          CC=C
C
C--IF HEAD LOWER THAN DRAIN THEN FORGET THIS CELL.
C--OTHERWISE, CALCULATE Q=C*(EL-HHNEW).
          IF(HHNEW.GT.EL) Q=CEL-CC*HHNEW
        ENDIF
C
C--WRITE DRAIN LOCATION AND RATE
        IF(ILMTFMT.EQ.0) WRITE(IOUT)   IL,IR,IC,Q
        IF(ILMTFMT.EQ.1) WRITE(IOUT,*) IL,IR,IC,Q
      ENDDO
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT6RIV6(NRIVER,MXRIVR,NRIVVL,RIVR,IBOUND,HNEW,
     &  NCOL,NROW,NLAY,KSTP,KPER,IOUT)
C *********************************************************************
C SAVE RIVER CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C *********************************************************************
C Modified from Harbaugh et al. (2000)
C last modified: 05-01-2002
C
      CHARACTER*16 TEXT
      DOUBLE PRECISION HNEW,CHRIV,CCRIV,RRBOT,HHNEW
      DIMENSION RIVR(NRIVVL,MXRIVR),IBOUND(NCOL,NROW,NLAY),
     &          HNEW(NCOL,NROW,NLAY)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='RIV'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NRIVER
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NRIVER
      ENDIF
C
C--IF NO REACHES SKIP
      IF(NRIVER.LE.0) RETURN
C
C--FOR EACH RIVER REACH ACCUMULATE RIVER FLOW
      DO L=1,NRIVER
C
C--GET LAYER, ROW & COLUMN OF CELL CONTAINING REACH.
        IL=RIVR(1,L)
        IR=RIVR(2,L)
        IC=RIVR(3,L)
C
C--IF CELL IS EXTERNAL RATE=0
        IF(IBOUND(IC,IR,IL).LE.0) THEN
          RATE=0.
C
C--GET RIVER PARAMETERS FROM RIVER LIST.
        ELSE
          HRIV=RIVR(4,L)
          CRIV=RIVR(5,L)
          RBOT=RIVR(6,L)
          HHNEW=HNEW(IC,IR,IL)
          CHRIV=CRIV*HRIV
          CCRIV=CRIV
          RRBOT=RBOT
C
C--COMPARE HEAD IN AQUIFER TO BOTTOM OF RIVERBED.
C
C--AQUIFER HEAD > BOTTOM THEN RATE=CRIV*(HRIV-HNEW).
          IF(HHNEW.GT.RRBOT) RATE=CHRIV-CCRIV*HHNEW
C
C--AQUIFER HEAD < BOTTOM THEN RATE=CRIV*(HRIV-RBOT)
          IF(HHNEW.LE.RRBOT) RATE=CRIV*(HRIV-RBOT)
        ENDIF
C
C--WRITE RIVER REACH LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IOUT) IL,IR,IC,RATE
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IOUT,*) IL,IR,IC,RATE
        ENDIF
      ENDDO
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT6RCH6(NRCHOP,IRCH,RECH,IBOUND,NROW,NCOL,NLAY,
     &  KSTP,KPER,BUFF,IOUT)
C *******************************************************************
C SAVE REACHARGE LAYER INDICES (IF NLAY>1) AND VOLUMETRIC FLOW RATES
C FOR USE BY MT3D.
C *******************************************************************
C Modified from Harbaugh et al. (2000)
C last modified: 05-01-2002
C
      CHARACTER*16 TEXT
      DIMENSION IRCH(NCOL,NROW),RECH(NCOL,NROW),
     &  IBOUND(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='RCH'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
      ENDIF
C
C--CLEAR THE BUFFER.
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--IF NRCHOP=1 RECH GOES INTO LAYER 1.
      IF(NRCHOP.EQ.1) THEN
        IL=1
        IF(ILMTFMT.EQ.0) WRITE(IOUT)   ((IL,J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IOUT,*) ((IL,J=1,NCOL),I=1,NROW)
C
C--STORE RECH RATE IN BUFF FOR ACTIVE CELLS
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,1).GT.0) BUFF(J,I,1)=RECH(J,I)
          ENDDO
        ENDDO
        IF(ILMTFMT.EQ.0) WRITE(IOUT)   ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IOUT,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
C
C--IF NRCHOP=2 OR 3 RECH IS IN LAYER SHOWN IN INDICATOR ARRAY(IRCH).
      ELSEIF(NRCHOP.NE.1) THEN
        IF(ILMTFMT.EQ.0) WRITE(IOUT)   ((IRCH(J,I),J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IOUT,*) ((IRCH(J,I),J=1,NCOL),I=1,NROW)
C
C--STORE RECH RATE IN BUFF FOR ACTIVE CELLS
        DO I=1,NROW
          DO J=1,NCOL
            IL=IRCH(J,I)
            IF(IBOUND(J,I,IL).GT.0) BUFF(J,I,1)=RECH(J,I)
          ENDDO
        ENDDO
        IF(ILMTFMT.EQ.0) WRITE(IOUT)   ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IOUT,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ENDIF
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT6EVT6(NEVTOP,IEVT,EVTR,EXDP,SURF,IBOUND,HNEW,
     &  NCOL,NROW,NLAY,KSTP,KPER,BUFF,IOUT)
C ******************************************************************
C SAVE EVAPOTRANSPIRATION LAYER INDICES (IF NLAY>1) AND VOLUMETRIC
C FLOW RATES FOR USE BY MT3D.
C ******************************************************************
C Modified from Harbaugh et al. (2000)
C last modified: 05-01-2002
C
      CHARACTER*16 TEXT
      DOUBLE PRECISION HNEW,HH,XX,DD,SS
      DIMENSION IEVT(NCOL,NROW),EVTR(NCOL,NROW),EXDP(NCOL,NROW),
     &          SURF(NCOL,NROW),IBOUND(NCOL,NROW,NLAY),
     &          HNEW(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='EVT'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
      ENDIF
C
C--CLEAR THE BUFFER.
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.
          ENDDO
        ENDDO
      ENDDO   
C
C--PROCESS EACH HORIZONTAL CELL LOCATION
C--AND STORE ET RATES IN BUFFER (IC,IR,1)
      DO IR=1,NROW
        DO IC=1,NCOL
C
C--IF OPTION 1 SET THE LAYER INDEX EQUAL TO 1
          IF(NEVTOP.EQ.1) THEN
            IL=1
C
C--IF OPTION 2 OR 3 GET LAYER INDEX FROM IEVT ARRAY
          ELSEIF(NEVTOP.NE.1) THEN
            IL=IEVT(IC,IR)
          ENDIF
C
C--IF CELL IS EXTERNAL THEN IGNORE IT.
          IF(IBOUND(IC,IR,IL).LE.0) CYCLE
          C=EVTR(IC,IR)
          S=SURF(IC,IR)
          SS=S
          HH=HNEW(IC,IR,IL)
C
C--IF AQUIFER HEAD => SURF,SET Q=MAX ET RATE
          IF(HH.GE.SS) THEN
            Q=-C
C
C--IF DEPTH=>EXTINCTION DEPTH, ET IS 0
C--OTHERWISE, LINEAR RANGE: Q=-EVTR(H-EXEL)/EXDP
          ELSE
            X=EXDP(IC,IR)
            XX=X
            DD=SS-HH
            IF(DD.GE.XX) THEN
              Q=0
            ELSE
              Q=C*DD/X-C
            ENDIF
          ENDIF
C
C--ADD Q TO BUFFER 1
          BUFF(IC,IR,1)=Q
        ENDDO
      ENDDO
C
C--RECORD THEM.
      IF(NEVTOP.EQ.1) THEN
        IL=1
        IF(ILMTFMT.EQ.0) WRITE(IOUT)   ((IL,J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IOUT,*) ((IL,J=1,NCOL),I=1,NROW)
      ELSEIF(NEVTOP.NE.1) THEN
        IF(ILMTFMT.EQ.0) WRITE(IOUT)   ((IEVT(J,I),J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IOUT,*) ((IEVT(J,I),J=1,NCOL),I=1,NROW)
      ENDIF
C
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ENDIF
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT6GHB6(NBOUND,MXBND,NGHBVL,BNDS,HNEW,
     &  NCOL,NROW,NLAY,IBOUND,KSTP,KPER,IOUT)
C *****************************************************************
C SAVE HEAD-DEPENDENT BOUNDARY CELL LOCATIONS AND VOLUMETRIC FLOW
C RATES FOR USE BY MT3D.
C *****************************************************************
C Modified from Harbaugh et al. (2000)
C last modified: 05-01-2002
C
      CHARACTER*16 TEXT
      DOUBLE PRECISION HNEW,CHB,CC,HHNEW
      DIMENSION BNDS(NGHBVL,MXBND),
     &           HNEW(NCOL,NROW,NLAY),IBOUND(NCOL,NROW,NLAY)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='GHB'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NBOUND
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NBOUND
      ENDIF
C
C--IF NO BOUNDARIES THEN SKIP
      IF(NBOUND.LE.0) RETURN
C
C--FOR EACH GENERAL HEAD BOUND ACCUMULATE FLOW INTO AQUIFER
      DO L=1,NBOUND
C
C--GET LAYER, ROW AND COLUMN OF EACH GENERAL HEAD BOUNDARY.
        IL=BNDS(1,L)
        IR=BNDS(2,L)
        IC=BNDS(3,L)
C
C--RATE=0 IF IBOUND=<0
        RATE=0.
        IF(IBOUND(IC,IR,IL).GT.0) THEN
C
C--GET PARAMETERS FROM BOUNDARY LIST.
          HHNEW=HNEW(IC,IR,IL)
          HB=BNDS(4,L)
          C=BNDS(5,L)
          CHB=C*HB
          CC=C
C
C--CALCULATE THE FOW RATE INTO THE CELL
          RATE=CHB-CC*HHNEW
        ENDIF
C
C--WRITE HEAD DEP. BOUND. LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IOUT) IL,IR,IC,RATE
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IOUT,*) IL,IR,IC,RATE
        ENDIF
      ENDDO
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT6FHB1(IFLLOC,BDFV,NFLW,IBOUND,NCOL,NROW,NLAY,KSTP,
     & KPER,IFHBD4,NFLWDIM,IOUT)
C **********************************************************************
C SAVE SPECIFIED-FLOW CELL LOCATIONS AND VOLUMETRIC FLOW RATES
C FOR USE BY MT3D.
C **********************************************************************
C Modified from Leake and Lilly (1997)
C last modified: 05-01-2002
C
      CHARACTER*16 TEXT
      DIMENSION IBOUND(NCOL,NROW,NLAY),
     & IFLLOC(4,NFLWDIM),BDFV(IFHBD4,NFLWDIM)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='FHB'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NFLW
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NFLW
      ENDIF
C
C--IF NO SPECIFIED-FLOW CELL, RETURN
      IF(NFLW.LE.0) RETURN
C
C--PROCESS SPECIFIED-FLOW CELLS ONE AT A TIME.
      DO L=1,NFLW
C
C--GET LAYER, ROW, AND COLUMN NUMBERS
        IR=IFLLOC(2,L)
        IC=IFLLOC(3,L)
        IL=IFLLOC(1,L)
        Q=0.
C
C--GET FLOW RATE FROM SPECIFIED-FLOW LIST
        IF(IBOUND(IC,IR,IL).GT.0) Q=BDFV(1,L)
C
C--WRITE SPECIFIED-FLOW CELL LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IOUT) IL,IR,IC,Q
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IOUT,*) IL,IR,IC,Q
        ENDIF
      ENDDO
C
C--NORMAL RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT6RES1(IRES,IRESL,BRES,CRES,BBRES,HRES,IBOUND,HNEW,
     &  BUFF,KSTP,KPER,NRES,NRESOP,NCOL,NROW,NLAY,IOUT)
C **********************************************************************
C SAVE RESERVOIR CELL LOCATIONS AND VOLUMETRIC FLOW RATES
C FOR USE BY MT3D.
C **********************************************************************
C Modified from Fenske et al., (1996)
C last modified: 05-01-2002
C
      CHARACTER*16 TEXT
      DOUBLE PRECISION HNEW
      DIMENSION IRES(NCOL,NROW),IRESL(NCOL,NROW),BRES(NCOL,NROW),
     & CRES(NCOL,NROW),BBRES(NCOL,NROW),HRES(NRES),
     & IBOUND(NCOL,NROW,NLAY),HNEW(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='RES'
C
C--CLEAR BUFFER.
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH RESERVOIR REACH ACCUMULATE RESERVOIR FLOW
      DO 200 I=1,NROW
      DO 190 J=1,NCOL
      NR=IRES(J,I)
      IF(NR.LE.0) GO TO 190
      IF(NR.GT.NRES) GO TO 190
      IR=I
      IC=J
C
C--FIND LAYER NUMBER FOR RESERVOIR CELL
      IF(NRESOP.EQ.1) THEN
       IL=1
      ELSE IF(NRESOP.EQ.2) THEN
       IL=IRESL(IC,IR)
      ELSE
       DO 60 K=1,NLAY
       IL=K
C--UPPERMOST ACTIVE CELL FOUND, SAVE LAYER INDEX IN 'IL'
       IF(IBOUND(IC,IR,IL).GT.0) GO TO 70
C--SKIP THIS CELL IF VERTICAL COLUMN CONTAINS A CONSTANT-
C--HEAD CELL ABOVE RESERVOIR LOCATION
       IF(IBOUND(IC,IR,IL).LT.0) GO TO 190
   60  CONTINUE
       GO TO 190
      ENDIF
C
C--IF THE CELL IS EXTERNAL SKIP IT.
      IF(IBOUND(IC,IR,IL).LE.0) GO TO 190
C
C--IF RESERVOIR STAGE IS BELOW RESERVOIR BOTTOM, SKIP IT
   70 HR=HRES(NR)
      IF(HR.LE.BRES(IC,IR))  GO TO 190
C--SINCE RESERVOIR IS ACTIVE AT THIS LOCATION,
C--GET THE RESERVOIR DATA.
      CR=CRES(IC,IR)
      RBOT=BBRES(IC,IR)
      HHNEW=HNEW(IC,IR,IL)
C
C--COMPUTE RATE OF FLOW BETWEEN GROUND-WATER SYSTEM AND RESERVOIR.
C
C--GROUND-WATER HEAD > BOTTOM THEN RATE=CR*(HR-HNEW).
      IF(HHNEW.GT.RBOT) RATE=CR*(HR-HHNEW)
C
C--GROUND-WATER HEAD < BOTTOM THEN RATE=CR*(HR-RBOT)
      IF(HHNEW.LE.RBOT) RATE=CR*(HR-RBOT)
C
C--ADD RATE TO BUFFER.
      BUFF(IC,IR,IL)=BUFF(IC,IR,IL)+RATE
  190 CONTINUE
  200 CONTINUE
C
C--COUNT RES CELLS WITH NONZERO FLOW RATE
      NTEMP=0
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            IF(BUFF(IC,IR,IL).NE.0) NTEMP=NTEMP+1
          ENDDO
        ENDDO
      ENDDO
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NTEMP
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NTEMP
      ENDIF
C
C--IF NO RES CELLS WITH NONZERO Q, RETURN
      IF(NTEMP.EQ.0) RETURN
C
C--WRITE RES CELL LOCATION AND FLOW RATE
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            RATE=BUFF(IC,IR,IL)
            IF(RATE.NE.0) THEN
              IF(ILMTFMT.EQ.0) WRITE(IOUT)   IL,IR,IC,RATE
              IF(ILMTFMT.EQ.1) WRITE(IOUT,*) IL,IR,IC,RATE
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--NORMAL RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT6STR6(NSTREM,STRM,ISTRM,IBOUND,MXSTRM,NCOL,NROW,
     &  NLAY,KSTP,KPER,IOUT,ILMTHEAD)
C **********************************************************************
C SAVE STREAM CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C **********************************************************************
C Modified from Prudic (1989)
C last modified: 05-01-2002
C
      CHARACTER*16 TEXT
      DIMENSION STRM(11,MXSTRM),ISTRM(5,MXSTRM),IBOUND(NCOL,NROW,NLAY)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='RIV'
      IF(ILMTHEAD.EQ.1) TEXT='STR'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NSTREM
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NSTREM
      ENDIF
C
C--IF NO REACHES, SKIP
      IF(NSTREM.EQ.0) RETURN
C
C--FOR EACH STREAM REACH GET LEAKAGE TO OR FROM IT
      DO L=1,NSTREM
C
C--GET REACH LOCATION AND FLOW RATE
        IL=ISTRM(1,L)
        IR=ISTRM(2,L)
        IC=ISTRM(3,L)
        IF(IBOUND(IC,IR,IL).LE.0) THEN
          RATE=0
        ELSE
          RATE=STRM(11,L)
        ENDIF
C
C--WRITE STREAM REACH LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IOUT) IL,IR,IC,RATE
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IOUT,*) IL,IR,IC,RATE
        ENDIF
      ENDDO
C
C--NORMAL RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT6MNW1(MNWsite,nwell2,mxwel2,
     & well2,ibound,ncol,nrow,nlay,nodes,kstp,kper,iout)
C *********************************************************************
C SAVE MNW LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C *********************************************************************
C Modified from MNW1 by K.J. Halford
C last modification: 05-10-2005
C
      DOUBLE PRECISION WELL2   !WELL2 declared doubleprecision for v6.3
      CHARACTER TEXT*16,MNWsite*32
      DIMENSION IBOUND(nodes),WELL2(18,MXWEL2),MNWsite(mxwel2)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='MNW'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NWELL2
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NWELL2
      ENDIF
C
C--IF THERE ARE NO WELLS RETURN
      IF(NWELL2.LE.0) RETURN
C
C--PROCESS WELL LIST
      DO m = 1,nwell2
        n = ifrl( well2(1,m) )
        il = (n-1) / (ncol*nrow) + 1
        ir = mod((n-1),ncol*nrow)/ncol + 1
        ic = mod((n-1),ncol) + 1
        IDwell = ifrl(well2(18,m))  !IDwell in well2(18,m); cdl 4/19/05
        Q = well2(17,m)
C
C--IF CELL IS EXTERNAL Q=0
        IF(IBOUND(n).LE.0) Q=0.
C
C--DUMMY VARIABLE QSW NOT USED, SET TO 0
        QSW=0.
C
C--SAVE TO OUTPUT FILE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IOUT) IL,IR,IC,Q,IDwell,QSW
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IOUT,*) IL,IR,IC,Q,IDwell,QSW
        ENDIF
      ENDDO
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT6ETS1(NETSOP,IETS,ETSR,ETSX,ETSS,IBOUND,HNEW,
     & NCOL,NROW,NLAY,KSTP,KPER,BUFF,IOUT,NETSEG,PXDP,PETM,NSEGAR)
C ********************************************************************
C SAVE SEGMENTED EVAPOTRANSPIRATION LAYER INDICES (IF NLAY>1) AND
C VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C ********************************************************************
C Modified from Banta (2000)
C last modified: 7-15-2003
C
      CHARACTER*16 TEXT
      DOUBLE PRECISION HNEW, QQ, HH, SS, DD, XX, HHCOF, RRHS,
     &                 PXDP1, PXDP2
      DIMENSION IETS(NCOL,NROW), ETSR(NCOL,NROW), ETSX(NCOL,NROW),
     &          ETSS(NCOL,NROW), IBOUND(NCOL,NROW,NLAY),
     &          HNEW(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY), 
     &          PXDP(NCOL,NROW,NSEGAR),PETM(NCOL,NROW,NSEGAR)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='ETS'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT
      ENDIF      
C
C--CLEAR THE BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.
          ENDDO   
        ENDDO   
      ENDDO   
C
C--PROCESS EACH HORIZONTAL CELL LOCATION
      DO IR=1,NROW
        DO IC=1,NCOL
C
C--SET THE LAYER INDEX EQUAL TO 1.
          IL=1
C
C--IF OPTION 2 IS SPECIFIED THEN GET LAYER INDEX FROM IETS ARRAY
          IF (NETSOP.EQ.2) IL=IETS(IC,IR)
C
C--IF CELL IS EXTERNAL THEN IGNORE IT.
          IF (IBOUND(IC,IR,IL).LE.0) CYCLE
C          
          C=ETSR(IC,IR)
          S=ETSS(IC,IR)
          SS=S
          HH=HNEW(IC,IR,IL)
C
C--IF HEAD IN CELL => ETSS,SET Q=MAX ET RATE.
          IF (HH.GE.SS) THEN
            QQ=-C
          ELSE
C
C--IF DEPTH=>EXTINCTION DEPTH, ET IS 0.
            X=ETSX(IC,IR)
            XX=X
            DD=SS-HH
            IF (DD.LT.XX) THEN
C--VARIABLE RANGE.  CALCULATE Q DEPENDING ON NUMBER OF SEGMENTS
C
              IF (NETSEG.GT.1) THEN
C               DETERMINE WHICH SEGMENT APPLIES BASED ON HEAD, AND
C               CALCULATE TERMS TO ADD TO RHS AND HCOF
C
C               SET PROPORTIONS CORRESPONDING TO ETSS ELEVATION
                PXDP1 = 0.0
                PETM1 = 1.0
                DO ISEG = 1,NETSEG
C                 SET PROPORTIONS CORRESPONDING TO LOWER END OF
C                 SEGMENT
                  IF (ISEG.LT.NETSEG) THEN
                    PXDP2 = PXDP(IC,IR,ISEG)
                    PETM2 = PETM(IC,IR,ISEG)
                  ELSE
                    PXDP2 = 1.0
                    PETM2 = 0.0
                  ENDIF
                  IF (DD.LE.PXDP2*XX) THEN
C                   HEAD IS IN DOMAIN OF THIS SEGMENT
                    EXIT
                  ENDIF
C                 PROPORTIONS AT LOWER END OF SEGMENT WILL BE FOR
C                 UPPER END OF SEGMENT NEXT TIME THROUGH LOOP
                  PXDP1 = PXDP2
                  PETM1 = PETM2
                ENDDO   
C--CALCULATE ET RATE BASED ON SEGMENT THAT APPLIES AT HEAD
C--ELEVATION
                HHCOF = -(PETM1-PETM2)*C/((PXDP2-PXDP1)*X)
                RRHS = -HHCOF*(S-PXDP1*X) - PETM1*C
              ELSE
C--SIMPLE LINEAR RELATION.  Q=-ETSR*(HNEW-(ETSS-ETSX))/ETSX, WHICH
C--IS FORMULATED AS Q= -HNEW*ETSR/ETSX + (ETSR*ETSS/ETSX -ETSR).
                HHCOF = -C/X
                RRHS = (C*S/X) - C
              ENDIF
              QQ = HH*HHCOF + RRHS
            ELSE
              QQ = 0.0
            ENDIF
          ENDIF  
C
C--ADD Q TO BUFFER.
          Q=QQ
          BUFF(IC,IR,1)=Q
        ENDDO   
      ENDDO   
C
C--RECORD THEM
      IF(NETSOP.EQ.1) THEN
        IL=1
        IF(ILMTFMT.EQ.0) WRITE(IOUT)   ((IL,J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IOUT,*) ((IL,J=1,NCOL),I=1,NROW)
      ELSEIF(NETSOP.NE.1) THEN
        IF(ILMTFMT.EQ.0) WRITE(IOUT)   ((IETS(J,I),J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IOUT,*) ((IETS(J,I),J=1,NCOL),I=1,NROW)
      ENDIF
C
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ENDIF
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT6DRT1(NDRTCL,MXDRT,DRTF,HNEW,NCOL,NROW,NLAY,
     & IBOUND,KSTP,KPER,IOUT,NDRTVL,IDRTFL,NRFLOW)
C ******************************************************************
C SAVE DRT (Drain with Return Flow) CELL LOCATIONS AND 
C VOLUMETRIC FLOW RATES FOR USE BY MT3D
C ******************************************************************
C Modified from Banta (2000)
C last modified: 7-15-2003
C
      CHARACTER*16 TEXT
      DOUBLE PRECISION HNEW,HHNEW,EEL,CC,CEL,QQ
      DIMENSION DRTF(NDRTVL,MXDRT),HNEW(NCOL,NROW,NLAY),
     &          IBOUND(NCOL,NROW,NLAY)
      COMMON /LINKMT3D/ILMTFMT
      TEXT='DRT'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NDRTCL+NRFLOW
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NDRTCL+NRFLOW
      ENDIF      
C
C--IF THERE ARE NO DRAIN-RETURN CELLS, SKIP.
      IF (NDRTCL+NRFLOW.LE.0) RETURN
C
C--LOOP THROUGH EACH DRAIN-RETURN CELL, CALCULATING FLOW.
      DO L=1,NDRTCL
C
C--GET LAYER, ROW & COLUMN OF CELL CONTAINING DRAIN.
        IL=DRTF(1,L)
        IR=DRTF(2,L)
        IC=DRTF(3,L)
        Q=0.
C
C--IF CELL IS NO-FLOW OR CONSTANT-HEAD, IGNORE IT.
        IF (IBOUND(IC,IR,IL).LE.0) GOTO 99
C
C--GET DRAIN PARAMETERS FROM DRAIN-RETURN LIST.
        EL=DRTF(4,L)
        EEL=EL
        C=DRTF(5,L)
        HHNEW=HNEW(IC,IR,IL)
C
C--IF HEAD HIGHER THAN DRAIN, CALCULATE Q=C*(EL-HHNEW).
C--SUBTRACT Q FROM RATOUT.
        IF (HHNEW.GT.EEL) THEN
          CC=C
          CEL=C*EL
          QQ=CEL - CC*HHNEW
          Q=QQ
          ILR=0
          IF (IDRTFL.GT.0) THEN
            ILR = DRTF(6,L)
            IF (ILR.NE.0) THEN
              IRR = DRTF(7,L)
              ICR = DRTF(8,L)
              RFPROP = DRTF(9,L)
              QQIN = RFPROP*(CC*HHNEW-CEL)
              QIN = QQIN
            ENDIF
          ENDIF
        ENDIF
   99   CONTINUE     
C
C--WRITE DRT LOCATION AND RATE (both host and recipient)
        mhost=0.
        QSW=0.
C       main drain (host to recipient cell)
        IF(ILMTFMT.EQ.0) WRITE(IOUT)   IL,IR,IC,Q,mhost,QSW
        IF(ILMTFMT.EQ.1) WRITE(IOUT,*) IL,IR,IC,Q,mhost,QSW 
C       return flow recipient cell 
        if(ILR.ne.0) then
          mhost = ncol*nrow*(IL-1) + ncol*(IR-1) + IC
          IF(ILMTFMT.EQ.0) WRITE(IOUT)   ILR,IRR,ICR,QIN,mhost,QSW
          IF(ILMTFMT.EQ.1) WRITE(IOUT,*) ILR,IRR,ICR,QIN,mhost,QSW
        endif
      ENDDO   
C
C--RETURN
      RETURN
      END
