      SUBROUTINE ESSUBH (I,HHT,EMSQR,DILATE,DELAY,ELEV,IHTSER,GENTIM,
     &  TRAGE,SI,LOSTND)
      IMPLICIT NONE
C----------
C CS $Id: essubh.f 2879 2019-12-07 00:03:48Z lancedavid $
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'ESPARM.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
C
COMMONS
C
      INTEGER MAPCS(96)
      REAL SI,TRAGE,GENTIM,ELEV,DELAY,DILATE,EMSQR,HHT,CARAGE,YRS,H
      REAL AGET,HTG1,HTMAX,AGE
      INTEGER LOSTND,IHTSER,I,IAGE,IVAR,MODE0,N,ITIME
      LOGICAL DEBUG
      REAL RDANUW
      INTEGER IDANUW
C
      DATA MAPCS/
     &  10,   10,   10,   15,   20,   10,    5,   20,   20,   25,
     &  25,   25,   25,   20,   20,   20,   20,   20,   20,   20,
     &  20,   10,   20,   20,   20,   35,   20,   15,   20,   10,
     &  15,   20,   20,   20,   10,   20,   20,   20,   20,   20,
     &  20,   20,   20,   20,   20,   35,   10,   20,   10,   10,
     &  10,   10,   10,   30,   10,   30,   10,   10,   10,   10,
     &  20,   10,   35,   30,   10,   10,   20,   10,   10,   20,
     &  20,   10,   10,   20,   20,   20,   10,   20,   20,   20,
     &  20,   10,   10,   10,   10,   10,   10,   10,   10,   20,
     &  10,   20,   25,   20,   10,   10/
C
C----------
C  ASSIGNS HEIGHTS TO SUBSEQUENT AND PLANTED TREE RECORDS
C  CREATED BY THE ESTABLISHMENT MODEL.
C
C  COMING INTO ESSUBH, TRAGE IS THE AGE OF THE TREE AS SPECIFIED ON 
C  THE PLANT OR NATURAL KEYWORD.  LEAVING ESSUBH, TRAGE IS THE NUMBER 
C  OF YEARS BETWEEN PLANTING (OR NATURAL REGENERATION) AND THE END OF 
C  THE CYCLE.  AGE IS TREE AGE UP TO THE TIME REGENT WILL BEGIN GROWING 
C  THE TREE.
C
C  FIRST CALL HTCALC TO GET THE HT AT THE LOWEST REFERENCE AGE, GIVEN A
C  SITE INDEX FROM CARMEAN'S CURVES. THEN INTERPOLATE HT GIVEN THE AGE
C  OF THE TREE ASSUMING A STRAIGHT LINE RELATIONSHIP THROUGH THE ORIGIN.
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      HTMAX  = 0.0
      RDANUW = DILATE
      RDANUW = ELEV
      RDANUW = EMSQR
      IDANUW = IHTSER
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'ESSUBH',6,ICYC)
      IF(DEBUG) WRITE(LOSTND,9980)ICYC
 9980 FORMAT(' ENTERING SUBROUTINE ESSUBH  CYCLE =',I5)
      IAGE = MAPCS(I)
      CARAGE=FLOAT(IAGE)
      MODE0=1
      IVAR=2
      YRS=0.
      H=0.
      AGET=CARAGE
      CALL HTCALC (MODE0,IVAR,I,SI,YRS,H,AGET,HTMAX,
     &               HTG1,LOSTND,DEBUG)
      HHT = (H/CARAGE)*MIN(5.0,TIME-DELAY)
      IF(DEBUG) WRITE(LOSTND,*)' IN ESSUBH SI,CARAGE,TRAGE,H,HHT= ',
     &SI,CARAGE,TRAGE,H,HHT
C
      IF(DEBUG) WRITE(LOSTND,*)' IN ESSUBH DELAY,TIME,GENTIM,TRAGE= ',
     &DELAY,TIME,GENTIM,TRAGE
      N=INT(DELAY+0.50)
      IF(N.LT.-3) N=-3
      DELAY=FLOAT(N)
      ITIME=INT(TIME+0.5)
      IF(N.GT.ITIME) DELAY=TIME
      AGE=TIME-DELAY-GENTIM+TRAGE
      IF(AGE.LT.1.0) AGE=1.0
      TRAGE=TIME-DELAY
      IF(DEBUG)WRITE(LOSTND,*)' LEAVING ESSUBH AGE,TRAGE= ',AGE,TRAGE
C
      RETURN
      END
