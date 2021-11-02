      SUBROUTINE GRADD (DEBUG,IPMODI,LTMGO,LMPBGO,LDFBGO,
     1                  LBWEGO,LCVATV)
      IMPLICIT NONE
C----------
C BASE $Id: gradd.f 3751 2021-08-19 15:02:28Z lancedavid $
C----------
C
C     UPDATES TREE DESCRIPTIONS, COMPUTES END-OF-CYCLE SHRUB AND
C     CVBROW STATISTICS, ESTABLISHIES NEW TREES, AND COMPUTES OTHER
C     END-OF-CYCLE STATISTICS.
C
C     CALLED FROM: TREGRO
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
COMMONS
C
      LOGICAL LTMGO,LMPBGO,LDFBGO,LBWEGO,LCVATV,DEBUG
C
C     DIMENSION SPCNT -- CUMULATIVE TREES PER ACRE BY SPECIES AND
C                        TREE CLASS.
C
      REAL SPCNT(MAXSP,3)
      INTEGER IPMODI,I,IS,IYR1,IYR2,IFIRES,IDT,ISTAT,KODE,
     >        NPRMS,ILE,IM,ISTOPRES,IRTNCD
      REAL SCALE,D,BARK,BRATIO,DDS
C
C     GET THE RESTART CODE AND BRANCH ACCORDINGLY
C
      CALL fvsGetRestartCode (ISTOPRES)
C
      IF (DEBUG) WRITE (JOSTND,10) NPLT,ICYC,ISTOPRES
   10 FORMAT (/' IN GRADD, NPLT=',A26,'; ICYC=',I2,'; ISTOPRES=',I2)
      IF (ISTOPRES.EQ.5) GOTO 57
      IF (ISTOPRES.EQ.6) GOTO 97

C----------
C  CALL **MPBCUP** IF THERE IS A MOUNTAIN PINE BEETLE OUTBREAK THIS
C  CYCLE. NOTE THAT DG MUST BE ON A YR-PERIOD BASIS FOR MPBMOD.
C----------
      IF (IPMODI.EQ.1 .AND.LMPBGO) THEN
         IF (DEBUG) WRITE(JOSTND,20) ICYC
   20    FORMAT (' CALLING MPBCUP, CYCLE=',I2)
         CALL MPBCUP
      ENDIF
C
C     CALL DFBDRV IF THERE IS A DOUGLAS-FIR BEETLE OUTBREAK THIS
C     CYCLE.
C
      CALL DFBWIN(LDFBGO)
      IF (IPMODI .EQ. 1 .AND. LDFBGO) THEN
         CALL DFBDRV
      ENDIF
C
C     SCALE DIAMETER GROWTH TO A FINT-YEAR BASIS.
C
      IF (ITRN.GT.0 .AND. FINT.NE.YR) THEN
         SCALE=FINT/YR
         DO 30 I=1,ITRN
         IS=ISP(I)
         D=DBH(I)
         BARK=BRATIO(IS,D,HT(I))
         IF(DG(I) .GT. 0.) THEN
           DDS=(DG(I)*(2.0*BARK*D+DG(I)))*SCALE
           DG(I)=SQRT((D*BARK)**2+DDS)-BARK*D
         ELSE
           DG(I)=0.0
         ENDIF
   30    CONTINUE
      ENDIF
C
C     CALL MISTLETOE SUBROUTINE
C
      CALL MISTOE
C
C     CALL **TMCOUP** IF THERE IS A TUSSOCK MOTH OUTBREAK THIS CYCLE.
C
      IF (IPMODI.EQ.1 .AND. LTMGO) THEN
         IF (DEBUG) WRITE (JOSTND,40) ICYC
   40    FORMAT(' CALLING TMCOUP, CYCLE=',I2)
         CALL TMCOUP
      ENDIF
C
C     CALL THE WESTERN SPRUCE BUDWORM (BUDLITE) MODEL INTERFACE.
C
      IF (IPMODI.EQ.1 .AND. LBWEGO) THEN
         IF (DEBUG) WRITE(JOSTND,50) ICYC
   50    FORMAT (' CALLING BWECUP, CYCLE=',I2)
         CALL BWECUP
      ENDIF
C
C     CALL THE FIRE MODEL
C
      IF (DEBUG) WRITE(JOSTND,51) ICYC
   51 FORMAT (' CALLING FMMAIN, CYCLE=',I2)
      CALL FMMAIN
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

      CALL FMKILL(1)
C
C     CALL BLISTER RUST SUBROUTINE TO BEGIN SIMULATION.
C
      CALL BRTREG
C
C     CALL WESTERN ROOT DISEASE VER. 3.0 SUBROUTINE TO BEGIN DISEASE
C     SIMULATION
C
      CALL RDTREG
C
C     CALL THE FIRE MODEL MORTALITY ROUTINE
C
      CALL FMKILL(2)
C----------
C  SET LFIRE=.TRUE. IF A SIMFIRE KEYWORD WAS USED THIS CYCLE
C  LFIRE CONTROLS USE OF OLDBA, OLDTPA AND ORMSQD IN POST-DISTURBANCE
C  COVER CALCULATIONS IN THE **CVCBMS AND CCFCAL** ROUTINES
C----------
      IF(ICYC.LE.0)THEN
        IYR1=IY(1)
        IYR2=IY(1)
      ELSE
        IYR1=IY(ICYC)
        IYR2=IY(ICYC+1)
      ENDIF
      IFIRES=0
      IDT=0
      ISTAT=0
      CALL OPSTUS (2506,IYR1,IYR2,0,IFIRES,IDT,NPRMS,ISTAT,KODE)
      IF((ISTAT.GT.0).AND.(IDT.GE.IYR1).AND.(IDT.LE.IYR2))THEN
        LFIRE=.TRUE.
      ENDIF
C
C     CALL HTGSTP TO PROCESS HTGSTOP OPTION, IF USED.
C
      CALL HTGSTP
C
C     UPDATE THE VISULIZATION FOR MORTALITY
C
      IF (DEBUG) WRITE (JOSTND,55) ICYC
   55 FORMAT(' CALLING SVMORT, CYCLE=',I2)
      CALL SVMORT (0,WK2,IY(ICYC))
C
C     UPDATE TREE DESCRIPTIONS.
C
C     IS THIS A STOPPING POINT?
C
      CALL fvsStopPoint (5,ISTOPRES)
      IF (ISTOPRES.NE.0) RETURN
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
C
C     BRANCH HERE IF RESTARTING FROM STOPCODE=5.
C
   57 CONTINUE
      IF (DEBUG) WRITE (JOSTND,60) ICYC
   60 FORMAT(' CALLING UPDATE, CYCLE=',I2)
      CALL UPDATE
C
C     RESORT THE TREE RECORDS BY DIAMETER.
C
      IF (DEBUG) WRITE (JOSTND,70) ICYC
   70 FORMAT(' CALLING RDPSRT, CYCLE=',I2)
      IF(ITRN.GT.0)CALL RDPSRT(ITRN,DBH,IND,.TRUE.)
C
C     CALL **DENSE** TO CALCULATE POST-MORTALITY AND BAI DENSITY STATS.
C
      IF (DEBUG) WRITE (JOSTND,80) ICYC
   80 FORMAT(' CALLING DENSE, CYCLE=',I2)
      CALL DENSE
C
C     CALL **CVBROW** TO COMPUTE SHRUB DENSITY AND WILDLIFE CVBROW
C     STATISTICS.
C
      CALL CVGO (LCVATV)
      IF (DEBUG.AND.LCVATV) WRITE (JOSTND,90) ICYC
   90 FORMAT(' CALLING CVBROW, CYCLE=',I2)
      IF (LCVATV) CALL CVBROW (.FALSE.)
C
C     INCREMENT ABIRTH ARRAY
C
      DO 95 I= 1, ITRN
      ABIRTH(I)= ABIRTH(I) + FINT
   95 CONTINUE
C
C     IS THIS A STOPPING POINT?
C
      CALL fvsStopPoint (6,ISTOPRES)
      IF (ISTOPRES.NE.0) RETURN
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
C
C     BRANCH HERE IF RESTARTING FROM STOPCODE=6.
C
   97 CONTINUE
C
C     CALL CLIMATE-DRIVEN ESTABLISHMENT
C
      IF (DEBUG) WRITE(JOSTND,99) ICYC
   99 FORMAT(' CALLING CLAUESTB, CYCLE=',I2)
      CALL CLAUESTB
C
C     CALL THE REGENERATION ESTABLISHMENT SUBSYSTEM.
C
      IF (DEBUG) WRITE(JOSTND,100) ICYC
  100 FORMAT(' CALLING ESNUTR, CYCLE=',I2)
      CALL ESNUTR
C
C     UPDATE THE VISULIZATION FOR NEW TREES
C
      IF (DEBUG) WRITE (JOSTND,105) ICYC
  105 FORMAT(' CALLING SVESTB, CYCLE=',I2)
      CALL SVESTB(1)
C
C     CALL ECCALC TO CALCULATE COSTS & REVENUES FOR ECON EXTENSION
C
      CALL ECCALC(IY, ICYC, JSP, MGMID, NPLT, ITITLE)
C
C     CALL DENSE TO CALCULATE POST-ESTABLISHMENT DENSITY.
C
      IF (DEBUG) WRITE(JOSTND,80) ICYC
      CALL DENSE
C
C     CALCULATE CHANGE IN CROWN RATIOS.
C
      IF (DEBUG) WRITE (JOSTND,110) ICYC,NPLT
  110 FORMAT(' CALLING CROWN, CYCLE=',I2,'  NPLT= ',A)
      CALL CROWN
C
C     UPDATE CROWN WIDTHS
C
      CALL CWIDTH
C
C     CALL **CVCNOP** TO COMPUTE CROWN AREA AND FOLIAGE BIOMASS
C     STATISTICS.
C
      IF (DEBUG.AND.LCVATV) WRITE (JOSTND,120) ICYC
  120 FORMAT (' CALLING CVCNOP, CYCLE=',I3)
      IF (LCVATV) CALL CVCNOP (.FALSE.)
C
C     SAVE PCT IN OLDPCT TO RETAIN AN OLD PCTILE VALUE
C
      IF (ITRN.GT.0) THEN
         DO 130 ILE=1,ITRN
         OLDPCT(ILE)= PCT(ILE)
  130    CONTINUE
         DO 140 I=1,MAXSP
         SPCNT(I,1)=0.0
         SPCNT(I,2)=0.0
         SPCNT(I,3)=0.0
  140    CONTINUE
C
C        ACCUMULATE TREES PER ACRE BY SPECIES AND TREE CLASS.
C
         DO 150 I=1,ITRN
         IS=ISP(I)
         IM=IMC(I)
         SPCNT(IS,IM)=SPCNT(IS,IM)+PROB(I)
  150    CONTINUE
      ENDIF
C
C     COMPUTE DISTRIBUTION OF DIAMETERS AND SPECIES-TREE CLASS COMPOS.
C     FOR TREES PER ACRE.  IF NEW TREES HAVE BEEN ADDED VIA THE
C     ESTABLISHMENT SUBSYSTEM AND/OR THE TREE COMPRESSION HAS
C     TAKEN PLACE, INS WILL BE REDEFINED IN THE NEXT CALL TO DIST.
C
      CALL PCTILE(ITRN,IND,PROB,WK3,ONTCUR(7))
      CALL DIST(ITRN,ONTCUR,WK3)
      CALL COMP(OSPCT,IOSPCT,SPCNT)
C
C     COMPUTE PERCENTILE POINTS IN THE DISTRIBUTION OF DIAMETERS FOR
C     TOTAL CUBIC VOLUME.  THIS CALL IS PLACED HERE SO THAT ACCRETION
C     DISTRIBUTION RELATES TO DIAMETERS AT THE START OF THE CYCLE AND
C     TOTAL VOLUME DISTRIBUTION RELATES TO UPDATED DIAMETERS. FIRST
C     CONVERT VOLUMES TO A PER ACRE REPRESENTATION.
C
      IF (ITRN.GT.0) THEN
         DO 160 I=1,ITRN
         CFV(I)=CFV(I)*PROB(I)
         BFV(I)=BFV(I)*PROB(I)
         WK1(I)=WK1(I)*PROB(I)
  160    CONTINUE
      ENDIF
      CALL PCTILE(ITRN,IND,CFV,WK3,OCVCUR(7))
      CALL DIST(ITRN,OCVCUR,WK3)
      CALL PCTILE(ITRN,IND,BFV,WK3,OBFCUR(7))
      CALL DIST(ITRN,OBFCUR,WK3)
      CALL PCTILE(ITRN,IND,WK1,WK3,OMCCUR(7))
      CALL DIST(ITRN,OMCCUR,WK3)
C
C     CONVERT CFV BACK TO A PER TREE REPRESENTATION. ALLOW FOR THE
C     FACT THAT SOME PROBS MAY BE ZERO (NL CROOKSTON, 06/11/91).
C
      IF (ITRN.GT.0) THEN
         DO 170 I=1,ITRN
         IF (PROB(I).GT.0.0) THEN
            CFV(I)=CFV(I)/PROB(I)
            WK1(I)=WK1(I)/PROB(I)
            BFV(I)=BFV(I)/PROB(I)
         ENDIF
  170    CONTINUE
      ENDIF
      RETURN
      END
