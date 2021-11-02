      SUBROUTINE DGSCOR (SSIG,FRM,RHO,RHOCP,IT)
      IMPLICIT NONE
C----------
C BASE $Id: dgscor.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C  THIS SUBROUTINE CALCULATES THE ERROR IN DIAMETER GROWTH PREDICTION
C  THAT WILL BE CARRIED OVER INTO THE NEXT CYCLE.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
      EXTERNAL RANN
C
      INTEGER IT
      REAL RHOCP,RHO,FRM,SSIG,BACHLO,DDS
C
C----------
C   IF NOT TRIPLING, ASSIGN DIAMETER GROWTH FROM A NORMAL
C   DISTRIBUTION ABOUT PREDICTED LN(DDS). DISTRIBUTION IS BOUNDED
C   TO + OR - DGSD STANDARD DEVIATIONS.
C----------
      FRM=0.0
      IF (DGSD .LT. 1.0) GO TO 25
   20 CONTINUE
      FRM=BACHLO(0.0,SSIG,RANN)
      FRM=FRM*RHOCP+RHO*OLDRN(IT)
      IF(ABS(FRM).GT.DGSD*SSIG) GO TO 20
   25 CONTINUE
      DDS=WK2(IT)
      IF(DDS.GT.5.0) THEN
        FRM=0.0
      ELSE
        IF(DDS.GT.4.) FRM=(DDS-4.)*FRM
      ENDIF
      OLDRN(IT)=FRM
      FRM=EXP(FRM)
      RETURN
      END
