      SUBROUTINE VARMRT(TOKILL,DEBUG,SUMKIL,DQ10)
      IMPLICIT NONE
C----------
C CANADA-ON $Id: varmrt.f 3788 2021-09-13 23:08:03Z donrobinson $
C----------
C SUBROUTINE TO DISTRIBUTE MORTALITY ACCORDING TO PERCENTILE AND
C SPECIES TOLERANCE.
C----------
COMMONS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'OUTCOM.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'COEFFS.F77'
      INCLUDE 'ESTREE.F77'
      INCLUDE 'MULTCM.F77'
      INCLUDE 'PDEN.F77'
      INCLUDE 'METRIC.F77'
 
      LOGICAL DEBUG

      INTEGER I,IG,ISWTCH,J,JPASS,JSPC,MINSTP,NPASS
      INTEGER ITM_MAP(MAXSP)

      REAL ADJUST,BALM,DM,DQM,DQ10,OTEM2,PASS1,PEFF,SHORT,SUMKIL
      REAL TEMKIL,TEMSUM,TOKILL,TPALFT,XKILL
      REAL EFFTR(MAXTRE),MB0(18),MB1(18),MB2(18),MB3(18),MB4(18),MB5(18)
      REAL MB6(18),MB7(18),SIM,TEMWK2(MAXTRE),X

C  DATA STATEMENTS

C     INDIVIDUAL TREE MORTALITY COEFFICIENTS FROM MARGARET PENNER
C     MB0..MB7;
C     Source: FVS_Mortality_Report.docx, Table 5
C     MAPPED BY ITM_MAP (INDIVIDUAL TREE MAP)
      DATA MB0 /
     >   1.56759,    -1.75438,     -3.67221,    -0.3542,    -0.83917,
     >  -0.22749,    -2.70186,     -1.05177,    -3.27602,   -2.27416,
     >  -3.67336,    -3.89531,     -4.5782,     -6.64434,   -3.39803,
     >  -1.84346,    -4.63558,     -3.60002 /
      DATA MB1 /
     >  -0.35954,    -0.13439,      0.13553,    -0.29402,   -0.075347,
     >  -0.17368,    -0.15224,      0.18688,    -0.06409,   -0.75413,
     >  -0.015301,   -0.39851,     -0.11127,    -0.60664,   -0.016078,
     >  -0.54492,    -0.10752,      0.035019 /
      DATA MB2 /
     > -18.2223,      0.05,         0.0,        -4.41248,   -3.61772,
     >  -2.87478,    -1.77768,     -7.79339,    -2.26039,   -5.44546,
     >  -1.04581,    -0.028481,     2.24759,     0.0,       -1.73506,
     >   0.0,        -0.17508,     -1.79863 /
      DATA MB3 /
     >   0.004729459, 0.003717782, -0.007633363, 0.007291,   0.00429437,
     >   0.013202,    0.003566943, -0.000771621, 0.003381,   0.030003,
     >   0.000577445, 0.00392894,   0.0,         0.009326974,0.00275289,
     >   0.005057465, 0.002772803,  0.000206976 /
      DATA MB4 /
     >  -0.73227,    -2.54341,     -2.98566,    -7.32994,   -4.10504,
     >  -5.39914,    -0.53056,     -6.43672,    -1.18764,   -1.28947,
     >  -0.10899,     2.34899,      1.98514,     4.61152,   -1.8512,
     >   2.90385,     0.25158,     -1.3242 /
      DATA MB5 /
     >  -0.046773,    0.0,          0.029072,    0.04226,    0.018135,
     >  -0.038558,   -0.057377,     0.049045,   -0.030958,   0.031923,
     >  -0.018726,    0.0,          0.0,         0.0,        0.01346,
     >   0.0,         0.016405,     0.0 /
      DATA MB6 /
     >   0.0,        -1.833,        0.0,         0.5563,     0.0,
     >   0.0,         0.0,          0.0,         0.0,        0.0,
     >   0.0,         0.0,          0.0,         0.0,       -0.2,
     >   0.0,        -0.1917,       0.0 /
      DATA MB7 /
     >   0.0357,      0.034951,     0.026167,    0.085012,   0.064902,
     >   0.11252,     0.050818,     0.032482,    0.0381,     0.11331,
     >   0.020787,    0.078816,     0.024981,    0.13838,    0.019736,
     >   0.0,         0.055896,     0.018238 /

C     MAP EACH SPECIES TO ONE OF 18 FITTED EQUATIONS 
C     ITM = INDIVIDUAL TREE MORTALITY
      DATA ITM_MAP /
     >   5, 4, 3, 4, 1, 7, 8,11, 9, 5, ! 10
     >   9,11, 3, 9,18,18,17,13,13,15,
     >  13,13,13,16,13,12,13,14,18,16, ! 30
     >  16,16,16,16,16,16,15,16,16,17,
     >  17,17,15,16,16,16,13,17,16,13, ! 50
     >  13,13,13,13,16,13,15,15,13,16,
     >  15,15,15,16,17,17,15,16, 6, 2, ! 70
     >   8, 10 /

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
C EACH TREE RECORD.
C CALCULATE HOW MANY TPA WILL BE KILLED IN ONE PASS THROUGH THE TREELIST
C WITH EFFICIENCY VALUES SET AT THIS LEVEL.
C
C PENNER INDIVIDUAL MORT MODEL
C START-QMD CONSTRAINED TO 1CM. "FOR SPECIES WITH A LARGE, POSITIVE MB4
C COEFFICIENT, INCREASING THE MINIMUM WILL LEAD TO LOWER MORTALITY RATES
C (HIGHER SURVIVAL) WHEN THE DBHQ IS SMALL.  FOR SPECIES WITH A NEGATIVE
C MB4 COEFFICIENT, THE EFFECT IS MINIMAL." (MARGARET PENNER)
C----------
      DO I=1,ITRN
        JSPC=ISP(I)
        SIM = SITEAR(JSPC) * FTtoM
        J   = ITM_MAP(JSPC)
        DM  = DBH(I) * INtoCM
        DQM = MAX(1.0, DQ10 * INtoCM)
        BALM = (1.0 - (PCT(I)/100.)) * BA * FT2pACRtoM2pHA

        X   =  MB0(J)
     >      + (MB1(J) * DM)
     >      + (MB2(J) /(DM+MB6(J)))
     >      + (MB3(J) * DM**2)
     >      + (MB4(J) * DM / DQM)
     >      + (MB5(J) * BALM)
     >      + (MB7(J) * SIM)
        PEFF = 1.0/(1.0+EXP(MAX(-88.0,MIN(88.0,X)))) ! SURV/YR
        IF(DEBUG)WRITE(JOSTND,*)' PEFF,X,DM,DQM,BALM,SIM= ',
     &  PEFF,X,DM,DQM,BALM,SIM
        PEFF = 1.0 - PEFF                              ! MORT/YR

        IF(PEFF .GT. 1.0) PEFF = 1.0
        IF(PEFF .LT. 0.01) PEFF = 0.01
        EFFTR(I) = PEFF
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
          TEMWK2(I)=PROB(I)
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
