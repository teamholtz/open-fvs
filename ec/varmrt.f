      SUBROUTINE VARMRT(TOKILL,DEBUG,SUMKIL)
      IMPLICIT NONE
C----------
C EC $Id: varmrt.f 2447 2018-07-10 16:31:11Z gedixon $
C----------
C SUBROUTINE TO DISTRIBUTE MORTALITY ACCORDING TO PERCENTILE AND
C SPECIES TOLERANCE.
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
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'ESTREE.F77'
C
C
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'PDEN.F77'
C
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER I,JPASS,MINSTP
      INTEGER JSPC,IG,NPASS,ISWTCH
      REAL VARADJ(MAXSP),TEMWK2(MAXTRE),EFFTR(MAXTRE)
      REAL SUMKIL,TOKILL,PEFF,XKILL
      REAL SHORT,TEMKIL,ADJUST,PASS1,TPALFT,OTEM2,TEMSUM
C----------
C  SPECIES LIST FOR EAST CASCADES VARIANT.
C
C   1 = WESTERN WHITE PINE      (WP)    PINUS MONTICOLA
C   2 = WESTERN LARCH           (WL)    LARIX OCCIDENTALIS
C   3 = DOUGLAS-FIR             (DF)    PSEUDOTSUGA MENZIESII
C   4 = PACIFIC SILVER FIR      (SF)    ABIES AMABILIS
C   5 = WESTERN REDCEDAR        (RC)    THUJA PLICATA
C   6 = GRAND FIR               (GF)    ABIES GRANDIS
C   7 = LODGEPOLE PINE          (LP)    PINUS CONTORTA
C   8 = ENGELMANN SPRUCE        (ES)    PICEA ENGELMANNII
C   9 = SUBALPINE FIR           (AF)    ABIES LASIOCARPA
C  10 = PONDEROSA PINE          (PP)    PINUS PONDEROSA
C  11 = WESTERN HEMLOCK         (WH)    TSUGA HETEROPHYLLA
C  12 = MOUNTAIN HEMLOCK        (MH)    TSUGA MERTENSIANA
C  13 = PACIFIC YEW             (PY)    TAXUS BREVIFOLIA
C  14 = WHITEBARK PINE          (WB)    PINUS ALBICAULIS
C  15 = NOBLE FIR               (NF)    ABIES PROCERA
C  16 = WHITE FIR               (WF)    ABIES CONCOLOR
C  17 = SUBALPINE LARCH         (LL)    LARIX LYALLII
C  18 = ALASKA CEDAR            (YC)    CALLITROPSIS NOOTKATENSIS
C  19 = WESTERN JUNIPER         (WJ)    JUNIPERUS OCCIDENTALIS
C  20 = BIGLEAF MAPLE           (BM)    ACER MACROPHYLLUM
C  21 = VINE MAPLE              (VN)    ACER CIRCINATUM
C  22 = RED ALDER               (RA)    ALNUS RUBRA
C  23 = PAPER BIRCH             (PB)    BETULA PAPYRIFERA
C  24 = GIANT CHINQUAPIN        (GC)    CHRYSOLEPIS CHRYSOPHYLLA
C  25 = PACIFIC DOGWOOD         (DG)    CORNUS NUTTALLII
C  26 = QUAKING ASPEN           (AS)    POPULUS TREMULOIDES
C  27 = BLACK COTTONWOOD        (CW)    POPULUS BALSAMIFERA var. TRICHOCARPA
C  28 = OREGON WHITE OAK        (WO)    QUERCUS GARRYANA
C  29 = CHERRY AND PLUM SPECIES (PL)    PRUNUS sp.
C  30 = WILLOW SPECIES          (WI)    SALIX sp.
C  31 = OTHER SOFTWOODS         (OS)
C  32 = OTHER HARDWOODS         (OH)
C----------
C SHADE TOLERANCE LEVELS (SEE **HTGF** AND **MORTS**):
C   VERY TOLERANT: 4=SF,  5=RC, 11=WH, 13=PY, 25=DG
C                  USE SF FOR WH; USE RC FOR PY AND DG
C        TOLERANT: 6=GF,  8=ES,  9=AF, 16=WF, 18=YC 
C                  USE GF FOR WF AND YC
C    INTERMEDIATE: 1=WP,  3=DF, 12=MH, 14=WB, 15=NF, 24=GC, 28=WO, 31=OS
C                  USE WP FOR WB, NF, GC, WO; USE OS FOR MH 
C      INTOLERANT:10=PP, 19=WJ, 22=RA, 23=PB, 29=PL
C                  USE PP FOR WJ, RA, PB, PL
C VERY INTOLERANT: 2=WL,  7=LP, 17=LL, 20=BM, 21=VN, 26=AS, 27=CW, 30=WI, 32=OH
C                  USE LP FOR LL, BM, VN, AS, CW, WI, OH
C----------
      DATA VARADJ/ 
     & 0.85, 1.00, 0.55, 0.60, 0.60, 0.50, 0.90, 0.50, 0.60, 0.85,
     & 0.60, 0.75, 0.60, 0.85, 0.85, 0.50, 0.90, 0.50, 0.85, 0.90,
     & 0.90, 0.85, 0.85, 0.85, 0.60, 0.90, 0.90, 0.85, 0.85, 0.90,
     & 0.75, 0.90/
C----------
C ADJUST = FINAL SCALAR ADJUSTMENT NEEDED TO SCALE MORTALITY VALUES
C          TO ACHIEVE THE DESIRED MORTALITY LEVEL
C  SHORT = TPA SHORT OF REACHING THE DESIRED MORTALITY LEVEL (DUE TO
C          ALL THE TREE'S PROB BEING ATTRIBUTED TO MORTALITY BEFORE THE 
C          DESIRED STAND LEVEL MORTALITY LEVEL IS REACHED)
C TOKILL = NUMBER OF TREES TO KILL THIS CYCLE
C SUMKIL = RUNNING TOTAL OF NUMBER OF TREES KILLED SO FAR
C  PASS1 = NUMBER OF TREES KILLED IN ONE PASS THROUGH THE TREELIST
C          WITH THE SPECIFIED TREE LEVEL MORTALITY EFFICIENCIES
C VARADJ = TREE SHADE TOLERANCE (1.0 = MOST INTOLERANT)
C  JPASS = VARIABLE TO TRACK THE NUMBER OF PASSES THROUGH THE LOGIC
C TPALFT = DIFFERENCE BETWEEN INITIAL TPA AND MORTALITY TPA
C----------
      IF(DEBUG)WRITE(JOSTND,20)ICYC,TOKILL
   20 FORMAT('0ENTERING VARMRT CYCLE =',I3,' DENSITY RELATED TOKILL = ',
     &F6.1)
C----------
C DETERMINE TOTAL NUMBER OF TREES TO KILL IF BACKGROUND MORTALITY
C IS STILL IN EFFECT.
C----------
      IF(TOKILL .EQ. 0.0) THEN
        DO I=1,ITRN
          TOKILL = TOKILL+WK2(I)
        ENDDO
        IF(DEBUG)WRITE(JOSTND,*)' BACKGROUND TOKILL = ',TOKILL
      ENDIF
C----------
C INITIALIZE SCALARS AND ARRAYS.
C----------
      TEMKIL=TOKILL
      JPASS=0
      PASS1=0.
      SUMKIL=0.
      DO I=1,ITRN
        WK2(I)=0.
        TEMWK2(I)=0.
        EFFTR(I)=0.
      ENDDO
C----------
C PASS THROUGH THE TREELIST AND LOAD MORTALITY EFFICIENCY VALUES FOR
C EACH TREE RECORD. RAMP DOWN THE CROWN RATIO EFFECT FOR THE OAKS.
C CALCULATE HOW MANY TPA WILL BE KILLED IN ONE PASS THROUGH THE TREELIST
C WITH EFFICIENCY VALUES SET AT THIS LEVEL.
C----------
      DO I=1,ITRN
        JSPC=ISP(I)
        PEFF = 0.84525 - 0.01074*PCT(I) + 0.0000002*PCT(I)**3.0
        IF(PEFF .GT. 1.0) PEFF = 1.0
        IF(PEFF .LT. 0.01) PEFF = 0.01
        EFFTR(I) = PEFF * VARADJ(JSPC) * 0.1
        PASS1 = PASS1 + PROB(I)*EFFTR(I)
      ENDDO    
      IF(DEBUG)WRITE(JOSTND,30)ITRN,(EFFTR(IG),IG=1,ITRN)
   30 FORMAT(' MORTALITY EFFICIENCY VALUES, ITRN = ',I7,
     &(/10F10.5))
      IF(DEBUG)WRITE(JOSTND,*)' TREES KILLED IN ONE PASS = ',PASS1
C----------
C  CALCULATE THE APPROXIMATE NUMBER OF PASSES NEEDED TO ACHIEVE THE
C  DESIRED MORTALITY.
C----------
      NPASS = IFIX(TOKILL/PASS1)+1
      IF(DEBUG)WRITE(JOSTND,*)' APPROXIMATE NUMBER OF PASSES NEEDED = ',
     &NPASS
C----------
C  LOOP THROUGH THE TREES AND LOAD THE FIRST GUESS AT TREE RECORD
C  MORTALITY BASED ON THE MORTALITY EFFICIENCY (r) AND APPROXIMATE NUMBER
C  OF PASSES NEEDED (n). THIS IS A GEOMETRIC PROGRESSION WHERE THE RATE
C  IS THE MORTALITY EFFICIENCY (r) AND THE STARTING VALUE IS THE INITIAL
C  PROB VALUE (a). THE Nth TERM IN THE PROGRESSION IS a*r*(1-r)**(n-1)
C  AND THE SUM OF N TERMS IS -a*((1-r)**n - 1).
C  ACCUMULATE THE MORTALITY ACHIEVED WITH THIS FIRST PASS.
C----------
  100 CONTINUE
      JPASS=JPASS+1
      IF(JPASS .GT. 1)TEMKIL=SHORT
      ISWTCH=0
  105 CONTINUE
      TEMSUM=0.
      DO I=1,ITRN
        TPALFT = PROB(I)-WK2(I)
        IF(TPALFT .GT. 0.)THEN
          OTEM2 = TEMWK2(I)
          TEMWK2(I) = (-TPALFT*((1.0-EFFTR(I))**NPASS - 1.0))
          IF(DEBUG)WRITE(JOSTND,*)' I,PROB,WK2,TPALFT,EFFTR,TEMWK2,',
     &    'OTEM2= ',I,PROB(I),WK2(I),TPALFT,EFFTR(I),TEMWK2(I),OTEM2
          TEMSUM=TEMSUM+TEMWK2(I)
        ENDIF
      ENDDO
      IF(DEBUG)WRITE(JOSTND,*)' AFTER GUESS ',JPASS,' TEMSUM= ',TEMSUM,
     &'  TOKILL= ',TOKILL
C----------
C ADJUST MORTALITY VALUES TO ACHIEVE DESIRED MORTALITY.
C IF AN ENTIRE TREE RECORD PROB GETS KILLED, ADJUST PASS1 VALUE FOR
C THE NEXT PASS.
C----------
      IF(NPASS .GT. 50)THEN
        MINSTP=5
      ELSEIF(NPASS .GT. 20)THEN
        MINSTP=2
      ELSE
        MINSTP=1
      ENDIF
      ADJUST=TEMKIL/TEMSUM
      IF(ADJUST .LT. 0.8)THEN
        IF(ISWTCH .EQ. 2) GO TO 110
        IF(DEBUG)WRITE(JOSTND,*)' TEMKIL,TEMSUM,PASS1,NPASS= ',
     &  TEMKIL,TEMSUM,PASS1,NPASS 
        NPASS=NPASS-MAX(MINSTP,IFIX((TEMSUM-TEMKIL)/PASS1))
        IF(DEBUG)WRITE(JOSTND,*)' ADJUST= ',ADJUST,'  IS TO SMALL,',
     &  ' MIN STEP= ',MINSTP,' NEW NPASS= ',NPASS
        ISWTCH=1
        IF(NPASS .LE. 0)GO TO 110
        GO TO 105
      ELSEIF(ADJUST .GT. 1.2)THEN
        IF(ISWTCH .EQ. 1) GO TO 110
        NPASS=NPASS+MAX(MINSTP,IFIX((TEMKIL-TEMSUM)/PASS1))
        IF(DEBUG)WRITE(JOSTND,*)' ADJUST= ',ADJUST,'  IS TO BIG,',
     &  ' MIN STEP= ',MINSTP,' NEW NPASS= ',NPASS
        ISWTCH=2
        GO TO 105
      ENDIF
  110 CONTINUE
      SHORT=0.
      IF(DEBUG)WRITE(JOSTND,*)' TEMKIL= ',TEMKIL,'  TEMSUM= ',
     &TEMSUM,'  ADJUSTMENT= ',ADJUST   
      DO 150 I=1,ITRN
        TPALFT = PROB(I)-WK2(I)
        IF(TPALFT .LT. 0.00001)GO TO 150
        XKILL=TEMWK2(I)*ADJUST
        IF((PROB(I)-WK2(I)-XKILL) .LE. 0.00001) THEN
          TEMWK2(I)=PROB(I)-WK2(I)
          IF(DEBUG)WRITE(JOSTND,*)' SHORT,I,XKILL,PROB,WK2= ',
     &    SHORT,I,XKILL,PROB(I),WK2(I) 
          SHORT=SHORT+(XKILL-PROB(I)+WK2(I))
          IF(DEBUG)WRITE(JOSTND,*)' SHORT= ',SHORT
          PASS1=PASS1-EFFTR(I)
          GO TO 140
        ENDIF
        TEMWK2(I)=XKILL
  140 CONTINUE
      WK2(I)=WK2(I)+TEMWK2(I)
      SUMKIL=SUMKIL+TEMWK2(I)
  150 CONTINUE
      IF(DEBUG)WRITE(JOSTND,23)ITRN,(WK2(IG),IG=1,ITRN)
   23 FORMAT(' ADJUSTED MORTALITY VALUES, ITRN = ',I7,
     &(/10F10.5))
      IF(DEBUG)WRITE(JOSTND,*)' SHORT = ',SHORT
      IF(SHORT .GT. 0.)THEN
        NPASS=IFIX(SHORT/PASS1)+1
        IF(DEBUG)WRITE(JOSTND,*)' SHORT,PASS1, ADJUSTED PASSES NEEDED',
     &  '= ',SHORT,PASS1,NPASS
        GO TO 100
      ENDIF
C
      RETURN
      END
