      SUBROUTINE CCFCAL(ISPC,D,H,JCR,P,LTHIN,CCFT,CRWDTH,MODE)
      IMPLICIT NONE
C----------
C EM $Id: ccfcal.f 2447 2018-07-10 16:31:11Z gedixon $
C----------
C  THIS ROUTINE COMPUTES CROWN WIDTH AND CCF FOR INDIVIDUAL TREES.
C  CALLED FROM DENSE, REGENT, PRTRLS, SSTAGE, AND CVCW.
C
C  CROWN WIDTH EQUATIONS ARE FROM ANALYSIS BY NICK CROOKSTON USING
C  DATA FROM RENATE BUSH.
C  THESE CROWN WIDTH EQUATIONS ARE NO LONGER USED, REPLACED BY 
C  SUBROUTINE **CWCALC**
C----------
COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
COMMONS
C----------
C  ARGUMENT DEFINITIONS:
C    ISPC = NUMERIC SPECIES CODE
C       D = DIAMETER AT BREAST HEIGHT
C       H = TOTAL TREE HEIGHT
C     JCR = CROWN RATIO IN PERCENT (0-100)
C       P = TREES PER ACRE
C   LTHIN = .TRUE. IF THINNING HAS JUST OCCURRED
C         = .FALSE. OTHERWISE
C    CCFT = CCF REPRESENTED BY THIS TREE
C  CRWDTH = CROWN WIDTH OF THIS TREE
C    MODE = 1 IF ONLY NEED CCF RETURNED
C           2 IF ONLY NEED CRWDTH RETURNED
C
C  DIMENSION AND DATA STATEMENTS FOR INTERNAL VARIABLES.
C
C     CCF COEFFICIENTS FOR TREES THAT ARE GREATER THAN 10.0 IN. DBH:
C      RD1 -- CONSTANT TERM IN CROWN COMPETITION FACTOR EQUATION,
C             SUBSCRIPTED BY SPECIES
C      RD2 -- COEFFICIENT FOR SUM OF DIAMETERS TERM IN CROWN
C             COMPETITION FACTOR EQUATION,SUBSCRIPTED BY SPECIES
C      RD3 -- COEFFICIENT FOR SUM OF DIAMETER SQUARED TERM IN
C             CROWN COMPETITION EQUATION, SUBSCRIPTED BY SPECIES
C
C     CCF COEFFICIENTS FOR TREES THAT ARE LESS THAN 1.0 IN. DBH:
C      RDA -- MULTIPLIER.
C      RDB -- EXPONENT.  CCF(I) = RDA*DBH**RDB
C
C     B1  = BIAS CORRECTION COEFFICIENT
C     B2  = CONSTANT TERM
C     B3  = LOG-NATURAL OF CROWN LENGTH COEFFICIENT
C     B4  = LOG-NATURAL OF DBH COEFFICIENT
C     B5  = LOG-NATURAL OF TOTAL TREE HEIGHT COEFFICIENT
C     B6  = LOG-NATURAL OF BASAL AREA COEFFICIENT
C
C----------
      LOGICAL LTHIN
      REAL CCFT,CRWDTH,P,D,H,BAREA,CL
      INTEGER MODE,JCR,ISPC
      REAL  RD1(MAXSP),RD2(MAXSP),RD3(MAXSP),RDA(MAXSP),RDB(MAXSP)
      REAL  B1(MAXSP),B2(MAXSP),B3(MAXSP),B4(MAXSP),B5(MAXSP),B6(MAXSP)
C----------
C  SPECIES ORDER:
C   1=WB,  2=WL,  3=DF,  4=LM,  5=LL,  6=RM,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=GA, 12=AS, 13=CW, 14=BA, 15=PW, 16=NC,
C  17=PB, 18=OS, 19=OH
C
C  SPECIES EXPANSION
C  LM USES IE LM (ORIGINALLY FROM TT VARIANT)
C  LL USES IE AF (ORIGINALLY FROM NI VARIANT)
C  RM USES IE JU (ORIGINALLY FROM UT VARIANT)
C  AS,PB USE IE AS (ORIGINALLY FROM UT VARIANT)
C  GA,CW,BA,PW,NC,OH USE IE CO (ORIGINALLY FROM CR VARIANT)
C
C
C  SOURCES OF COEFFICIENTS:
C     1 = PAINE AND HANN TABLE 2: WESTERN WHITE PINE
C     2 = PAINE AND HANN TABLE 2: SUGAR PINE
C     3 = PAINE AND HANN TABLE 2: DOUGLAS-FIR
C     4 = 
C     5 = 
C     6 = 
C     7 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE 
C     8 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: ENGELMANN SPRUCE
C     9 = PAINE AND HANN TABLE 2: RED FIR
C    10 = PAINE AND HANN TABLE 2: PONDEROSA PINE
C    18 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C
C      PAINE AND HANN, 1982. MAXIMUM CROWN WIDTH EQUATIONS FOR
C        SOUTHWESTERN OREGON TREE SPECIES. RES PAP 46, FOR RES LAB
C        SCH FOR, OSU, CORVALLIS. 20PP.
C
C      WYKOFF, CROOKSTON, STAGE, 1982. USER'S GUIDE TO THE STAND
C        PROGNOSIS MODEL. GEN TECH REP INT-133. OGDEN, UT:
C        INTERMOUNTAIN FOREST AND RANGE EXP STN. 112P.
C----------
      DATA RD1/  .0186,  .0392,  .0388, .01925,    .03, .01925,
     &  .01925,    .03,  .0172,  .0219,    .03,    .03,    .03,
     &     .03,    .03,    .03,    .03,  .0204,    .03/
      DATA RD2/  .0146,  .0180,  .0269, .01676,  .0216, .01676, 
     &  .01676,  .0173, .00876,  .0169,  .0215,  .0238,  .0215,
     &   .0215,  .0215,  .0215,  .0238,  .0246,  .0215/
      DATA RD3/ .00288, .00207, .00466, .00365, .00405, .00365,
     &  .00365, .00259, .00112, .00325, .00363, .00490, .00363,
     &  .00363, .00363, .00363, .00490,  .0074, .00363/
      DATA RDA/
     &  0.009884, 0.007244, 0.017299, 0.009187, 0.011402, 0.009187,
     &  0.009187, 0.007875, 0.011402, 0.007813, 0.011109, 0.008915,
     &  0.011109, 0.011109, 0.011109, 0.011109, 0.008915, 0.011109,
     &  0.011109/
      DATA RDB/
     &    1.6667,  1.8182,  1.5571,  1.7600,  1.7560,  1.7600,
     &    1.7600,  1.7360,  1.7560,  1.7780,  1.7250,  1.7800,  
     &    1.7250,  1.7250,  1.7250,  1.7250,  1.7800,  1.7250,
     &    1.7250/
C----------
C  CROWN WIDTH
C  NOTE: 1=WB USES WL, 18=OS USES LP
C----------
      DATA B1/
     &   1.02478, 1.02478, 1.01685, 1.03992, 1.02886, 1.03992,
     &   1.03992, 1.02687, 1.02886, 1.02687, 1.02460, 1.03597,
     &   1.02460, 1.02460, 1.02460, 1.02460, 1.03597, 1.03992,
     &   1.02460/
      DATA B2/
     &   0.99889, 0.99889, 1.48372, 1.58777, 1.01255, 1.58777,
     &   1.58777, 1.28027, 1.01255, 1.49085, 1.35223, 1.46111,
     &   1.35223, 1.35223, 1.35223, 1.35223, 1.46111, 1.58777,
     &   1.35223/
      DATA B3/
     &   0.19422, 0.19422, 0.27378, 0.30812, 0.30374, 0.30812,
     &   0.30812, 0.22490, 0.30374, 0.18620, 0.24844, 0.26289,
     &   0.24844, 0.24844, 0.24844, 0.24844, 0.26289, 0.30812,
     &   0.24844/
      DATA B4/
     &   0.59423, 0.59423, 0.49646, 0.64934, 0.37093, 0.64934,
     &   0.64934, 0.47075, 0.37093, 0.68272, 0.41212, 0.18779,
     &   0.41212, 0.41212, 0.41212, 0.41212, 0.18779, 0.64934,
     &   0.41212/
      DATA B5/
     &  -0.09078,-0.09078,-0.18669,-0.38964,-0.13731,-0.38964,
     &  -0.38964,-0.15911,-0.13731,-0.28242,-0.10436, 0.00000,
     &  -0.10436,-0.10436,-0.10436,-0.10436, 0.00000,-0.38964,
     &  -0.10436/
      DATA B6/
     &  -0.02341,-0.02341,-0.01509, 0.00000, 0.00000, 0.00000,
     &   0.00000, 0.00000, 0.00000, 0.00000, 0.03539, 0.00000,
     &   0.03539, 0.03539, 0.03539, 0.03539, 0.00000, 0.00000,
     &   0.03539/
C----------
C  INITIALIZE RETURN VARIABLES.
C----------
      CCFT = 0.
      CRWDTH = 0.
C----------
C  COMPUTE CCF
C----------
      IF(MODE.EQ.1) THEN
        SELECT CASE (ISPC)
        CASE(5)
        IF (D.GE.10.0) THEN
          CCFT = RD1(ISPC) + D*RD2(ISPC) + D*D*RD3(ISPC)
        ELSE
          CCFT = RDA(ISPC) * (D**RDB(ISPC))
        ENDIF
C
        CASE(1:4,6:10,12,17,18)
        IF (D .GE. 1.0) THEN
          CCFT = RD1(ISPC) + D*RD2(ISPC) + D*D*RD3(ISPC)
        ELSEIF (D .GT. 0.1) THEN
          CCFT = RDA(ISPC) * (D**RDB(ISPC))
        ELSE
          CCFT = 0.001
        ENDIF
C
        CASE(11,13:16,19)
        IF (D .GE. 10.0) THEN
          CCFT = RD1(ISPC) + D*RD2(ISPC) + D*D*RD3(ISPC)
        ELSEIF (D .GT. 0.1) THEN
          CCFT = RDA(ISPC) * (D**RDB(ISPC))
        ELSE
          CCFT = 0.001
        ENDIF
        END SELECT
      ENDIF
      CCFT = CCFT * P
C----------
C  COMPUTE CROWN WIDTH.
C----------
      IF(JCR .LE. 0) GO TO 100
      IF(MODE.EQ.2) THEN
        CL = FLOAT(JCR)*H*.01
        BAREA = BA
        IF(LTHIN.OR.LFIRE) BAREA=OLDBA
        IF(BAREA.LE.0. .OR. CL.LE.0. .OR. H.LE.0. .OR.D.LE.0.)GOTO 100
C
        IF(BAREA.LE.1.)BAREA=1.
        CRWDTH=B1(ISPC)*EXP(B2(ISPC)+B3(ISPC)*ALOG(CL)+B4(ISPC)*
     &           ALOG(D)+B5(ISPC)*ALOG(H)+B6(ISPC)*ALOG(BAREA))
C
        IF(CRWDTH .GT. 99.9) CRWDTH=99.9
      ENDIF
C
  100 CONTINUE
      RETURN
      END
