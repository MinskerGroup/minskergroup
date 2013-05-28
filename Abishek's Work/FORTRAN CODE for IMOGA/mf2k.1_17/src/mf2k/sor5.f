C     Last change:  ERB  22 Aug 2002    4:35 pm
      SUBROUTINE SOR5ALG(ISUM,ISUMI,LCA,LCRES,LCHDCG,LCLRCH,LCIEQP,
     1       MXITER,NCOL,NLAY,NSLICE,MBW,IN,IOUT,IFREFM,IREWND)
C
C-----VERSION 04FEB1998 SOR5ALG
C     ******************************************************************
C     ALLOCATE STORAGE FOR SOR ARRAYS
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*200 LINE
C     ------------------------------------------------------------------
      IREWND=0
C
C1------PRINT A MESSAGE IDENTIFYING SOR PACKAGE
      WRITE(IOUT,1)IN
    1 FORMAT(1X,
     1  /1X,'SOR5 -- SLICE-SUCCESSIVE OVERRELAXATION SOLUTION PACKAGE',
     2  /20X,'VERSION 5, 9/1/93 INPUT READ FROM UNIT ',I4)
C
C2------READ AND PRINT COMMENTS AND MXITER (MAXIMUM # OF ITERATIONS)
      CALL URDCOM(IN,IOUT,LINE)
      IF(IFREFM.EQ.0) THEN
         READ(LINE,'(I10)') MXITER
      ELSE
         LLOC=1
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,MXITER,R,IOUT,IN)
      END IF
      WRITE(IOUT,3) MXITER
    3 FORMAT(1X,I5,' ITERATIONS ALLOWED FOR SOR CLOSURE')
C
C3------ALLOCATE SPACE FOR THE SOR ARRAYS
      ISOLD=ISUM
      ISOLDI=ISUMI
      NSLICE=NCOL*NLAY
      MBW=NLAY+1
      LCA=ISUM
      ISUM=ISUM+NSLICE*MBW
      LCRES=ISUM
      ISUM=ISUM+NSLICE
      LCIEQP=ISUMI
      ISUMI=ISUMI+NSLICE
      LCHDCG=ISUM
      ISUM=ISUM+MXITER
      LCLRCH=ISUMI
      ISUMI=ISUMI+3*MXITER
      ISP=ISUM-ISOLD
      ISPI=ISUMI-ISOLDI
C
C4------PRINT THE SPACE USED.
      WRITE(IOUT,4) ISP
    4 FORMAT(1X,I10,' ELEMENTS IN X ARRAY ARE USED BY SOR')
      WRITE(IOUT,4) ISPI
    5 FORMAT(1X,I10,' ELEMENTS IN IX ARRAY ARE USED BY SOR')
C
C5------RETURN
      RETURN
      END
      SUBROUTINE SOR5RPG(MXITER,ACCL,HCLOSE,IN,IPRSOR,IOUT,IFREFM)
C
C
C-----VERSION 0817 21FEB1996 SOR5RPG
C     ******************************************************************
C     READ PARAMETERS FOR SOR
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
C     ------------------------------------------------------------------
C
C1------READ THE ACCELERATION PARAMETER/RELAXATION FACTOR (ACCL) THE
C1------CLOSURE CRITERION (HCLOSE) AND THE NUMBER OF TIME STEPS
C1------BETWEEN PRINTOUTS OF MAXIMUM HEAD CHANGES (IPRSOR).
      IF(IFREFM.EQ.0) THEN
         READ(IN,'(2F10.0,I10)') ACCL,HCLOSE,IPRSOR
      ELSE
         READ(IN,*) ACCL,HCLOSE,IPRSOR
      END IF
      ZERO=0.
      IF(ACCL.EQ.ZERO) ACCL=1.
      IF(IPRSOR.LT.1) IPRSOR=999
C
C2------PRINT ACCL, HCLOSE, IPRSOR
      WRITE(IOUT,100)
  100 FORMAT(1X,///10X,'SOLUTION BY SLICE-SUCCESSIVE OVERRELAXATION'
     1    /10X,43('-'))
      WRITE(IOUT,115) MXITER
  115 FORMAT(1X,'MAXIMUM ITERATIONS ALLOWED FOR CLOSURE =',I9)
      WRITE(IOUT,120) ACCL
  120 FORMAT(1X,16X,'ACCELERATION PARAMETER =',G15.5)
      WRITE(IOUT,125) HCLOSE
  125 FORMAT(1X,5X,'HEAD CHANGE CRITERION FOR CLOSURE =',E15.5)
      WRITE(IOUT,130) IPRSOR
  130 FORMAT(1X,5X,'SOR HEAD CHANGE PRINTOUT INTERVAL =',I9)
C
C3------RETURN
      RETURN
      END
      SUBROUTINE SOR5AP(HNEW,IBOUND,CR,CC,CV,HCOF,RHS,A,RES,IEQPNT,
     1      HDCG,LRCH,KITER,HCLOSE,ACCL,ICNVG,KSTP,KPER,
     2      IPRSOR,MXITER,NSTP,NCOL,NROW,NLAY,NSLICE,MBW,IOUT,MUTSOR)
C-----VERSION 1537 31OCT1995 SOR5AP
C     ******************************************************************
C     SOLUTION BY SLICE-SUCCESSIVE OVERRELAXATION -- 1 ITERATION
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DOUBLE PRECISION HNEW,DIFF,DP,EE,R,HHCOF,DZERO
C
      DIMENSION HNEW(NCOL,NROW,NLAY), IBOUND(NCOL,NROW,NLAY),
     1   CR(NCOL,NROW,NLAY), CC(NCOL,NROW,NLAY),
     1   CV(NCOL,NROW,NLAY), HCOF(NCOL,NROW,NLAY), RHS(NCOL,NROW,NLAY),
     2   HDCG(MXITER), LRCH(3,MXITER),A(MBW,NSLICE),RES(NSLICE),
     3   IEQPNT(NLAY,NCOL)
C     ------------------------------------------------------------------
C
C1------CALCULATE # OF ELEMENTS IN COMPRESSED MATRIX A AND
C1------INITIALIZE FIELDS TO SAVE LARGEST HEAD CHANGE.
      NA=MBW*NSLICE
      ZERO=0.
      DZERO=ZERO
      BIG=ZERO
      ABSBIG=ZERO
      IB=0
      JB=0
      KB=0
C
C2------PROCESS EACH SLICE.
      DO 500 I=1,NROW
C
C3------CLEAR A.
      DO 110 J=1,NSLICE
      DO 110 K=1,MBW
  110 A(K,J)=ZERO
C
C4------ASSIGN A SEQUENCE # TO EACH VARIABLE HEAD CELL.
      NEQT=0
      DO 200 J=1,NCOL
      DO 200 K=1,NLAY
      IEQPNT(K,J)=0
      IF(IBOUND(J,I,K).LE.0) GO TO 200
      NEQT=NEQT+1
      IEQPNT(K,J)=NEQT
  200 CONTINUE
C
C5------FOR EACH CELL LOAD MATRIX A AND VECTOR RES.
      DO 300 J=1,NCOL
      DO 300 K=1,NLAY
C
C5A-----IF SEQUENCE # IS 0 (CELL IS EXTERNAL) GO ON TO NEXT CELL.
      NEQ=IEQPNT(K,J)
      IF(NEQ.EQ.0) GO TO 300
C
C5B-----INITIALIZE ACCUMULATORS EE AND R.
      EE=DZERO
      R=RHS(J,I,K)
C
C5C-----IF NODE TO LEFT SUBTRACT TERMS FROM EE AND R.
      IF(J.EQ.1) GO TO 120
      DP=CR(J-1,I,K)
      R=R-DP*HNEW(J-1,I,K)
      EE=EE-DP
C
C5D-----IF NODE TO RIGHT SUBTRACT TERMS FROM EE & R, MOVE COND TO A.
  120 IF(J.EQ.NCOL) GO TO 125
      SP=CR(J,I,K)
      DP=SP
      R=R-DP*HNEW(J+1,I,K)
      EE=EE-DP
      NXT=IEQPNT(K,J+1)
      IF(NXT.GT.0) A(1+NXT-NEQ,NEQ)=SP
C
C5E-----IF NODE TO REAR SUBTRACT TERMS FROM EE AND R.
  125 IF(I.EQ.1) GO TO 130
      DP=CC(J,I-1,K)
      R=R-DP*HNEW(J,I-1,K)
      EE=EE-DP
C
C5F-----IF NODE TO FRONT SUBTRACT TERMS FROM EE AND R.
  130 IF(I.EQ.NROW) GO TO 132
      DP=CC(J,I,K)
      R=R-DP*HNEW(J,I+1,K)
      EE=EE-DP
C
C5G-----IF NODE ABOVE SUBTRACT TERMS FROM EE AND R.
  132 IF(K.EQ.1) GO TO 134
      DP=CV(J,I,K-1)
      R=R-DP*HNEW(J,I,K-1)
      EE=EE-DP
C
C5H-----IF NODE BELOW SUBTRACT TERMS FROM EE & R AND MOVE COND TO A.
  134 IF(K.EQ.NLAY) GO TO 136
      SP=CV(J,I,K)
      DP=SP
      R=R-DP*HNEW(J,I,K+1)
      EE=EE-DP
      IF(IEQPNT(K+1,J).GT.0) A(2,NEQ)=SP
C
C5I-----MOVE EE INTO A, SUBTRACT EE TIMES LAST HEAD FROM R TO GET RES.
  136 HHCOF=HCOF(J,I,K)
      EE=EE+HHCOF
      A(1,NEQ)=EE
      RES(NEQ)=R-EE*HNEW(J,I,K)
  300 CONTINUE
C
C6------IF NO EQUATIONS GO TO NEXT SLICE, IF ONE EQUATION SOLVE
C6------DIRECTLY, IF 2 EQUATIONS CALL SSOR5B TO SOLVE FOR FIRST
C6------ESTIMATE OF HEAD CHANGE FOR THIS ITERATION.
      IF(NEQT.LT.1) GO TO 500
      IF(NEQT.EQ.1) RES(1)=RES(1)/A(1,1)
      IF(NEQT.GE.2) CALL SSOR5B(A,RES,NEQT,NA,MBW)
C
C7------FOR EACH CELL IN SLICE CALCULATE FINAL HEAD CHANGE THEN HEAD.
      DO 400 J=1,NCOL
      DO 400 K=1,NLAY
      NEQ=IEQPNT(K,J)
      IF(NEQ.EQ.0) GO TO 400
C
C7A-----MULTIPLY FIRST ESTIMATE OF HEAD CHANGE BY RELAX FACTOR TO
C7A-----GET FINAL ESTIMATE OF HEAD CHANGE FOR THIS ITERATION.
      DH=RES(NEQ)*ACCL
      DIFF=DH
C
C7B-----ADD FINAL ESTIMATE TO HEAD FROM LAST ITERATION TO GET HEAD
C7B-----FOR THIS ITERATION.
      HNEW(J,I,K)=HNEW(J,I,K)+DIFF
C
C7C-----SAVE FINAL HEAD CHANGE IF IT IS THE LARGEST.
      ABSDH=ABS(DH)
      IF(ABSDH.LE.ABSBIG) GO TO 400
      ABSBIG=ABSDH
      BIG=DH
      IB=I
      JB=J
      KB=K
  400 CONTINUE
C
C
  500 CONTINUE
C
C8------SAVE LARGEST HEAD CHANGE FOR THIS ITERATION.
      HDCG(KITER)=BIG
      LRCH(1,KITER)=KB
      LRCH(2,KITER)=IB
      LRCH(3,KITER)=JB
C
C9------IF LARGEST HEAD CHANGE IS SMALLER THAN CLOSURE THEN SET
C9------CONVERGE FLAG (ICNVG) EQUAL TO 1.
      ICNVG=0
      IF(ABSBIG.LE.HCLOSE) ICNVG=1
C
C10-----IF NOT CONVERGED AND NOT EXCEDED ITERATIONS THEN RETURN.
      IF(ICNVG.EQ.0 .AND. KITER.NE.MXITER) RETURN
      IF(MUTSOR.LT.2) THEN
         IF(KSTP.EQ.1) WRITE(IOUT,600)
  600    FORMAT(1X)
C
C11-----PRINT NUMBER OF ITERATIONS.
         WRITE(IOUT,601) KITER,KSTP,KPER
  601    FORMAT(1X,I5,' ITERATIONS FOR TIME STEP',I4,
     1        ' IN STRESS PERIOD ',I4)
      END IF
C
C12-----IF FAILED TO CONVERGE, OR LAST TIME STEP, OR PRINTOUT
C12-----INTERVAL SPECIFIED BY USER IS HERE; THEN PRINT MAXIMUM
C12-----HEAD CHANGES FOR EACH ITERATION.
      IF(ICNVG.NE.0 .AND. KSTP.NE.NSTP .AND. MOD(KSTP,IPRSOR).NE.0)
     1      GO TO 700
      IF(MUTSOR.EQ.0 .OR. (MUTSOR.EQ.3 .AND. ICNVG.EQ.0)) THEN
         WRITE(IOUT,5)
    5    FORMAT(1X,/1X,'MAXIMUM HEAD CHANGE FOR EACH ITERATION:',/
     1       1X,/1X,5('   HEAD CHANGE'),/
     2           1X,5(' LAYER,ROW,COL')/1X,70('-'))
         NGRP=(KITER-1)/5 +1
         DO 620 K=1,NGRP
            L1=(K-1)*5 +1
            L2=L1+4
            IF(K.EQ.NGRP) L2=KITER
            WRITE(IOUT,618) (HDCG(J),J=L1,L2)
            WRITE(IOUT,619) ((LRCH(I,J),I=1,3),J=L1,L2)
  618       FORMAT(1X,5G14.4)
  619       FORMAT(1X,5(:' (',I3,',',I3,',',I3,')'))
  620    CONTINUE
         WRITE(IOUT,11)
   11    FORMAT(1X)
      END IF
C
C13-----RETURN.
  700 RETURN
C
      END
      SUBROUTINE SSOR5B(A,B,N,NA,MBW)
C
C
C-----VERSION 1634 29OCT1992 SSOR5B
C     ******************************************************************
C     SOLVE A SYMMETRIC SET OF EQUATIONS
C        A IS COEFFICIENT MATRIX IN COMPRESSED FORM
C        B IS RIGHT HAND SIDE AND IS REPLACED BY SOLUTION
C        N IS NUMBER OF EQUATIONS TO BE SOLVED
C        MBW IS BANDWIDTH OF A
C        NA IS ONE-DIMENSION SIZE OF A
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION A(NA),B(N)
C     ------------------------------------------------------------------
C
      NM1=N-1
      MBW1=MBW-1
      ID=1-MBW
      ZERO=0.
      ONE=1.
C
C1------SEQUENTIALLY USE EACH OF THE FIRST N-1 ROWS AS
C1------THE PIVOT ROW.
      DO 20 I=1,NM1
C
C2------CALCULATE THE INVERSE OF THE PIVOT.
      ID=ID+MBW
      C1=ONE/A(ID)
      LD=ID
      L=I
C
C3------FOR EACH ROW AFTER THE PIVOT ROW (THE TARGET ROW)
C3------ELIMINATE THE COLUMN CORRESPONDING TO THE PIVOT.
      DO 15 J=1,MBW1
      L=L+1
      IF(L.GT.N) GO TO 20
      IB=ID+J
C
C4------CALCULATE THE FACTOR NEEDED TO ELIMINATE A TERM IN THE
C4------TARGET ROW.
      C=A(IB)*C1
      LD=LD+MBW
      LB=LD-1
C
C5------MODIFY THE REST OF THE TERMS IN THE TARGET ROW.
      DO 10 K=J,MBW1
C
C6------SUBTRACT THE FACTOR TIMES A TERM IN THE PIVOT ROW
C6------FROM THE CORRESPONDING COLUMN IN THE TARGET ROW.
      LB=LB+1
      A(LB)=A(LB)-C*A(ID+K)
   10 CONTINUE
C
C7------MODIFY THE RIGHT SIDE OF THE EQUATION CORRESPONDING
C7------TO THE TARGET ROW.
      B(I+J)=B(I+J)-C*B(I)
   15 CONTINUE
   20 CONTINUE
      ID=ID+MBW
C
C8------SOLVE THE LAST EQUATION.
      B(N)=B(N)/A(ID)
C
C9------WORKING BACKWARDS SOLVE THE REST OF THE EQUATIONS.
      DO 70 I=1,NM1
      ID=ID-MBW
C
C10-----CLEAR THE ACCUMULATOR SUM.
      SUM=ZERO
      L=N-I
      MBW1M=MIN(MBW1,I)
C
C11-----ADD THE KNOWN TERMS IN EQUATION L TO SUM.
      DO 60 J=1,MBW1M
      SUM=SUM+A(ID+J)*B(L+J)
   60 CONTINUE
C
C12-----SOLVE FOR THE ONE UNKNOWN IN EQUATION L.
      B(L)=(B(L)-SUM)/A(ID)
   70 CONTINUE
C
C13-----RETURN.
      RETURN
      END
