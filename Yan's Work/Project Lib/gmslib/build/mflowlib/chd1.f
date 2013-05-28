      SUBROUTINE CHD1AL(ISUM,LENX,LCCHDS,NCHDS,MXCHD,IN,IOUT)
C
C-----VERSION 0000 23SEP1987 CHD1AL
C     ******************************************************************
C     ALLOCATE ARRAY STORAGE FOR TIME-VARIANT SPECIFIED-HEAD CELLS
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
C     ------------------------------------------------------------------
C
C1------IDENTIFY PACKAGE AND INITIALIZE # OF SPECIFIED-HEAD CELLS
      WRITE(IOUT,1)IN
    1 FORMAT(1H0,'CHD1 -- CHD PACKAGE, VERSION 1, 09/23/87',
     2' INPUT READ FROM UNIT',I3)
      NCHDS=0
C
C2------READ AND PRINT MXCHD (MAXIMUM NUMBERR OF SPECIFIED-HEAD
C2------CELLS TO BE SPECIFIED EACH STRESS PERIOD)
      READ(IN,2) MXCHD
    2 FORMAT(I10)
      WRITE(IOUT,3) MXCHD
    3 FORMAT(1H ,'A TOTAL OF',I5,' CONSTANT-HEAD CELLS MAY BE',
     2 ' SPECIFIED EACH STRESS PERIOD.')
C
C3------SET LCCHDS EQUAL TO ADDRESS OF FIRST UNUSED SPACE IN X.
      LCCHDS=ISUM
C
C4------CALCULATE AMOUNT OF SPACE USED BY THE CONSTANT-HEAD LIST.
      ISP=5*MXCHD
      ISUM=ISUM+ISP
C
C5------PRINT AMOUNT OF SPACE USED BY THE CHD PACKAGE
      WRITE(IOUT,4) ISP
    4 FORMAT(1X,I6,' ELEMENTS IN X ARRAY ARE USED FOR CONSTANT',
     1      '-HEAD CELLS')
      ISUM1=ISUM-1
      WRITE(IOUT,5) ISUM1,LENX
    5 FORMAT(1X,I6,' ELEMENTS OF X ARRAY USED OUT OF',I7)
      IF(ISUM1.GT.LENX) WRITE(IOUT,6)
    6 FORMAT(1X,'   ***X ARRAY MUST BE DIMENSIONED LARGER***')
C
C6------RETURN
      RETURN
      END
      SUBROUTINE CHD1RP(CHDS,NCHDS,MXCHD,IBOUND,NCOL,NROW,NLAY,
     2  PERLEN,DELT,NSTP,TSMULT,IN,IOUT,ifrefm)
C
C
C-----VERSION 0000 23SEP1987 CHD1RP
C     ******************************************************************
C     READ DATA FOR CHD
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION CHDS(5,MXCHD),IBOUND(NCOL,NROW,NLAY)

      character*256  line             !emrl 7/17/00
      integer*4      ival,jval,kval   !emrl 7/17/00
      real           startval,endval  !emrl 7/17/00
C     ------------------------------------------------------------------
C
C1------READ ITMP(FLAG TO REUSE DATA.)
      READ(IN,8) ITMP
    8 FORMAT(I10)
C
C2------TEST ITMP
      IF(ITMP.GE.0) GO TO 50
C
C2A-----IF ITMP<0 THEN REUSE DATA FROM LAST STRESS PERIOD
      WRITE(IOUT,7)
    7 FORMAT(1H0,'REUSING CONSTANT-HEAD CELLS FROM LAST STRESS',
     1      ' PERIOD')
      GO TO 260
C
C3------IF ITMP=>0 THEN IT IS THE # OF CONSTANT-HEAD CELLS.
   50 NCHDS=ITMP
C
C4------PRINT # OF SPECIFIED-HEAD CELLS THIS STRESS PERIOD
  100 WRITE(IOUT,1) NCHDS
    1 FORMAT(1H0,//1X,I5,' SPECIFIED-HEAD CELLS')
C
C5------IF THERE ARE NO SPECIFIED-HEAD CELLS THEN RETURN.
      IF(NCHDS.EQ.0) GO TO 260
C
C6------READ & PRINT DATA FOR EACH SPECIFIED-HEAD CELL.
      WRITE(IOUT,3)
    3 FORMAT(1H0,15X,'LAYER',5X,'ROW',5X
     1,'COL   STRT HEAD   ENDING HEAD'/1X,15X,48('-'))
      DO 250 II=1,NCHDS
      if (ifrefm.eq.0) then  !emrl ff
        READ (IN,4) kval,ival,jval,startval,endval    !emrl 7/17/00
    4   FORMAT(3I10,2F10.0)                        !emrl 7/17/00
      else  !emrl ff
        read(in,'(a)') line
        lloc=1
        call URWORD(line,LLOC,ISTART,ISTOP,2,kval,R,IOUT,in)      !emrl 7/17/00
        call URWORD(line,LLOC,ISTART,ISTOP,2,ival,R,IOUT,in)      !emrl 7/17/00
        call URWORD(line,LLOC,ISTART,ISTOP,2,jval,R,IOUT,in)      !emrl 7/17/00
        call URWORD(line,LLOC,ISTART,ISTOP,3,N,startval,IOUT,in)  !emrl 7/17/00
        call URWORD(line,LLOC,ISTART,ISTOP,3,N,endval,IOUT,in)    !emrl 7/17/00
      endif  !emrl ff

C      WRITE (IOUT,5) K,I,J,CHDS(4,II),CHDS(5,II)               !emrl 7/17/00
      WRITE (IOUT,5) kval,ival,jval,startval,endval             !emrl 7/17/00
    5 FORMAT(1X,15X,I4,I9,I8,G13.4,G14.4)
c      CHDS(1,II)=K                                             !emrl 7/17/00                               
c      CHDS(2,II)=I                                             !emrl 7/17/00
c      CHDS(3,II)=J                                             !emrl 7/17/00
      CHDS(1,II)=kval                                           !emrl 7/17/00                          
      CHDS(2,II)=ival                                           !emrl 7/17/00
      CHDS(3,II)=jval                                           !emrl 7/17/00
      CHDS(4,II)=startval                                       !emrl 7/17/00
      CHDS(5,II)=endval                                         !emrl 7/17/00
c      IF(IBOUND(J,I,K).NE.0) IBOUND(J,I,K)=-IABS(IBOUND(J,I,K))!emrl 7/17/00
      IF(IBOUND(jval,ival,kval).NE.0) THEN
        IBOUND(jval,ival,kval)= -IABS(IBOUND(jval,ival,kval))   !emrl 7/17/00
      ENDIF
  250 CONTINUE
C
C7------RECOMPUTE LENGTH OF PERIOD, PERLEN, A LOCAL VARIABLE IN
C7------SUBROUTINE BAS1AD
      PERLEN=DELT*FLOAT(NSTP)
      IF(TSMULT.NE.1.) PERLEN=DELT*(1.-TSMULT**NSTP)/(1.-TSMULT)
C8------RETURN
  260 RETURN
      END
      SUBROUTINE CHD1FM(NCHDS,MXCHD,CHDS,IBOUND,HNEW,
     1         HOLD,PERLEN,PERTIM,DELT,NCOL,NROW,NLAY)
C
C-----VERSION 0000 23SEP1987 CHD1FM
C     ******************************************************************
C     COMPUTE HEAD FOR TIME STEP AT EACH SPECIFIED HEAD CELL
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      DOUBLE PRECISION HNEW
C
      DIMENSION CHDS(5,MXCHD),IBOUND(NCOL,NROW,NLAY),
     2          HNEW(NCOL,NROW,NLAY),HOLD(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C1------IF NCHDS<=0 THEN THERE ARE NO SPECIFIED-HEAD CELLS. RETURN.
      IF(NCHDS.LE.0) RETURN
C
C2------COMPUTE PROPORTION OF STRESS PERIOD TO CENTER OF THIS TIME STEP
      FRAC=PERTIM/PERLEN
C
C2------PROCESS EACH ENTRY IN THE SPECIFIED-HEAD CELL LIST (CHDS)
      DO 100 L=1,NCHDS
C
C3------GET COLUMN, ROW AND LAYER OF CELL CONTAINING BOUNDARY
      IL=CHDS(1,L)
      IR=CHDS(2,L)
      IC=CHDS(3,L)
C
C5------COMPUTE HEAD AT CELL BY LINEAR INTERPOLATION.
      HB=CHDS(4,L)+(CHDS(5,L)-CHDS(4,L))*FRAC
C
C6------UPDATE THE APPROPRIATE HNEW VALUE
      HNEW(IC,IR,IL)=HB
      HOLD(IC,IR,IL)=HB
  100 CONTINUE
C
C7------RETURN
      RETURN
      END
