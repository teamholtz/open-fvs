      SUBROUTINE HTGF
      IMPLICIT NONE
C----------
C CI $Id: htgf.f 2441 2018-07-05 22:31:42Z gedixon $
C----------
C  THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT
C  INCREMENT FOR EACH CYCLE AND LOADS IT INTO THE ARRAY HTG.
C  HEIGHT INCREMENT IS PREDICTED FROM SPECIES, HABITAT TYPE,
C  HEIGHT, DBH, AND PREDICTED DBH INCREMENT.  THIS ROUTINE
C  IS CALLED FROM **TREGRO** DURING REGULAR CYCLING.  ENTRY
C  **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE DEPENDENT
C  CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
C----------
COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CALCOM.F77'
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
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'HTCAL.F77'
C
C
COMMONS
C----------
C   MODEL COEFFICIENTS AND CONSTANTS:
C
C    BIAS -- THE AVERAGE RESIDUAL.
C
C   HTCON -- AN ARRAY CONTAINING HABITAT TYPE CONSTANTS FOR
C            HEIGHT GROWTH MODEL (SUBSCRIPTED BY SPECIES)
C
C  HDGCOF -- COEFFICIENT FOR DIAMETER GROWTH TERMS.
C
C    HGLD -- AN ARRAY, SUBSCRIPTED BY SPECIES, OF THE
C             COEFFICIENTS FOR THE DIAMETER TERM IN THE HEIGHT
C             GROWTH MODEL.
C
C   H2COF -- COEFFICIENT FOR HEIGHT SQUARED TERMS.
C    IND2 -- ARRAY OF POINTERS TO SMALL TREES.
C
C   SCALE -- TIME FACTOR DERIVED BY DIVIDING FIXED POINT CYCLE
C            LENGTH BY GROWTH PERIOD LENGTH FOR DATA FROM
C            WHICH MODELS WERE DEVELOPED.
C------------
      LOGICAL DEBUG
      INTEGER ISPC,I1,I2,I3,I,ITFN,IICR,K,IXAGE
      REAL HGLD(MAXSP),HGHC(30),HGLDD(30),HGSC(MAXSP),HGH2(30)
      REAL HGLH,BIAS,SCALE,XHT,D,CON,HTNEW,HTI,COF1,COF2,COF3,COF4,COF5
      REAL COF6,COF7,COF8,COF9,TEMD,Y1,Y2,FBY1,FBY2,Z,ZADJ,CLOSUR
      REAL DIA,BRATIO,PSI,H,TEMHTG,MISHGF
      REAL COFLM(9,3),COFAS(9,3)
      REAL SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,D1,D2,SINDX,BAL,POTHTG,AGP10
      REAL HGUESS,RELHT,HGMDCR,RHB,RHR,RHM,RHYXS,RHX,RHK,FCTRKX,FCTRRB
      REAL RHXS,FCTRXB,FCTRM,HGMDRH,WTCR,WTRH,HTGMOD,HTNOW,TEMPH
C----------
C     SPECIES LIST FOR CENTRAL IDAHO VARIANT.
C
C     1 = WESTERN WHITE PINE (WP)          PINUS MONTICOLA
C     2 = WESTERN LARCH (WL)               LARIX OCCIDENTALIS
C     3 = DOUGLAS-FIR (DF)                 PSEUDOTSUGA MENZIESII
C     4 = GRAND FIR (GF)                   ABIES GRANDIS
C     5 = WESTERN HEMLOCK (WH)             TSUGA HETEROPHYLLA
C     6 = WESTERN REDCEDAR (RC)            THUJA PLICATA
C     7 = LODGEPOLE PINE (LP)              PINUS CONTORTA
C     8 = ENGLEMANN SPRUCE (ES)            PICEA ENGELMANNII
C     9 = SUBALPINE FIR (AF)               ABIES LASIOCARPA
C    10 = PONDEROSA PINE (PP)              PINUS PONDEROSA
C    11 = WHITEBARK PINE (WB)              PINUS ALBICAULIS
C    12 = PACIFIC YEW (PY)                 TAXUS BREVIFOLIA
C    13 = QUAKING ASPEN (AS)               POPULUS TREMULOIDES
C    14 = WESTERN JUNIPER (WJ)             JUNIPERUS OCCIDENTALIS
C    15 = CURLLEAF MOUNTAIN-MAHOGANY (MC)  CERCOCARPUS LEDIFOLIUS
C    16 = LIMBER PINE (LM)                 PINUS FLEXILIS
C    17 = BLACK COTTONWOOD (CW)            POPULUS BALSAMIFERA VAR. TRICHOCARPA
C    18 = OTHER SOFTWOODS (OS)
C    19 = OTHER HARDWOODS (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C  FROM THE IE VARIANT:
C      USE 17(PY) FOR 12(PY)             (IE17 IS REALLY TT2=LM)
C      USE 18(AS) FOR 13(AS)             (IE18 IS REALLY UT6=AS)
C      USE 13(LM) FOR 11(WB) AND 16(LM)  (IE13 IS REALLY TT2=LM)
C      USE 19(CO) FOR 17(CW) AND 19(OH)  (IE19 IS REALLY CR38=OH)
C
C  FROM THE UT VARIANT:
C      USE 12(WJ) FOR 14(WJ)
C      USE 20(MC) FOR 15(MC)             (UT20 = SO30=MC, WHICH IS
C                                                  REALLY WC39=OT)
C----------
C  DATA STATEMENTS
C----------
      DATA HGLD/
     & -.04935,  -.3899,  -.4574, -.09775,  -.1555,
     &  -.1219,  -.2454,  -.5720,  -.1997,  -.5657,
     &     0.0,     0.0,     0.0,      0.,      0.,
     &     0.0,     0.0,  -.1219,     0.0/
C
      DATA (COFLM(I,1),I=1,9)/
     +37.0,85.0,1.77836,-0.51147,1.88795,1.20654,0.57697,
     +3.57635,0.90283/
      DATA (COFLM(I,2),I=1,9)/
     +45.0,100.0,1.66674,0.25626,1.45477,1.11251,0.67375,
     +2.17942,0.88103/
      DATA (COFLM(I,3),I=1,9)/
     +45.0,90.0,1.64770,0.30546,1.35015,0.94823,0.70453,
     +2.46480,1.00316/
C
       DATA (COFAS(I,1),I=1,9)/
     +30.0,85.0,2.00995,0.03288,1.81059,1.28612,0.72051,
     +3.00551,1.01433/
      DATA (COFAS(I,2),I=1,9)/
     +30.0,85.0,2.00995,0.03288,1.81059,1.28612,0.72051,
     +3.00551,1.01433/
      DATA (COFAS(I,3),I=1,9)/
     +35.0,85.0,1.80388,-0.07682,1.70032,1.29148,0.72343,
     +2.91519,0.95244/
C
      DATA BIAS/ .4809 /, HGLH/ 0.23315 /
C      
      DATA RHK /1.0/, RHXS /0.0/
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      SCALE=FINT/YR
      ISMALL=0
C----------
C  GET THE HEIGHT GROWTH MULTIPLIERS.
C----------
      CALL MULTS (2,IY(ICYC),XHMULT)
C----------
C   BEGIN SPECIES LOOP:
C----------
      DO 40 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 40
      I2 = ISCT(ISPC,2)
      XHT=1.0
      XHT=XHMULT(ISPC)
C-----------
C   BEGIN TREE LOOP WITHIN SPECIES LOOP
C-----------
      DO 30 I3=I1,I2
      I=IND1(I3)
      HTG(I)=0.
      IF(PROB(I).LE.0.0)THEN
        IF(LTRIP)THEN
          ITFN=ITRN+2*I-1
          HTG(ITFN)=0.
          HTG(ITFN+1)=0.
        ENDIF
        GO TO 30
      ENDIF
      HTI=HT(I)
      D = DBH(I)
C----------
C   HEIGHT GROWTH EQUATION, EVALUATED FOR EACH TREE EACH CYCLE
C----------
      SELECT CASE (ISPC)
C
C  11=WB, 12=PY, 13=AS, 16=LM, 17=CW, 19=OH
C
      CASE(11:13,16,17,19)
        IICR= INT(REAL(ICR(I))/10.0 + 0.5)
        IF(IICR .GT. 9) IICR=9
        GO TO(101,101,102,102,102,102,102,103,103),IICR
  101   K=1
        GO TO 110
  102   K=2
        GO TO 110
  103   K=3
  110   CONTINUE
        SELECT CASE (ISPC)
        CASE(11,12,16)
          COF1=COFLM(1,K)
          COF2=COFLM(2,K)
          COF3=COFLM(3,K)
          COF4=COFLM(4,K)
          COF5=COFLM(5,K)
          COF6=COFLM(6,K)
          COF7=COFLM(7,K)
          COF8=COFLM(8,K)
          COF9=COFLM(9,K)       
        CASE(13,17,19)
          COF1=COFAS(1,K)
          COF2=COFAS(2,K)
          COF3=COFAS(3,K)
          COF4=COFAS(4,K)
          COF5=COFAS(5,K)
          COF6=COFAS(6,K)
          COF7=COFAS(7,K)
          COF8=COFAS(8,K)
          COF9=COFAS(9,K)         
        END SELECT
C
C  CHECK IF HEIGHT OR DBH EXCEED PARAMETERS
C
        IF (HTI.LE. 4.5) GOTO 180
        IF((0.1 + COF1) .LE. D) GO TO 180
        IF((4.5 + COF2) .LE. HTI) GO TO 180
        GO TO 490
  180   CONTINUE
C
C    THE SBB IS UNDEFINED IF CERTAIN INPUT VALUES EXCEED PARAMETERS IN
C    THE FITTED DISTRIBUTION.  IN INPUT VALUES ARE EXCESSIVE THE HEIGHT
C    GROWTH IS TAKEN TO BE ZERO.
C
        HTG(I) = 0.1
        GO TO 60
  490   CONTINUE
C
C CALCULATE ALPHA FOR THE TREE USING SCHREUDER + HAFLEY
C
        TEMD=D
        IF(TEMD .LE. 0.2)TEMD=0.2
        Y1=(TEMD - 0.1)/COF1
        Y2=(HTI - 4.5)/COF2
        FBY1=ALOG(Y1/(1.0 - Y1))
        FBY2= ALOG(Y2/(1.0 - Y2))
        Z=( COF4 + COF6*FBY2 - COF7*( COF3 +
     +   COF5*FBY1))*(1.0 - COF7**2)**(-0.5)
C
C THE HT DIA MODEL NEEDS MODIFICATION TO CORRECT KNOWN BIAS
C
        SELECT CASE (ISPC)
        CASE(13,17,19)
          ZADJ = .1 - .10273*Z + .00273*Z*Z
          IF(ZADJ .LT. 0.0)ZADJ=0.0
          Z=Z+ZADJ
        END SELECT
C
C YOUNG SMALL LODGEPOLE HTG ACCELLERATOR BASED ON TARGHEE HTG
C
        IF(IAGE .EQ. 0 .OR. ICYC .GT. 1)GO TO 184
        IXAGE=IAGE + IY(ICYC) -IY(1)
        IF(IXAGE .LT. 40. .AND. IXAGE .GT. 10. .AND. D
     &     .LT. 9.0)THEN
          IF(Z .GT. 2.0) GO TO 184
          ZADJ=.3564*DG(I)*FINT/YR
          CLOSUR=PCT(I)/100.0
          IF(RELDEN .LT. 100.0)CLOSUR=1.0
          IF(DEBUG)WRITE(JOSTND,9650)ELEV,IXAGE,ZADJ,FINT,YR,
     &     DG(I),CLOSUR
 9650     FORMAT(' ELEV',F6.1,'IXAGE',F5.0,'ZADJ',
     &    F10.4,'FINT',F6.0,'YR',F6.0,'DG',F10.3,'CLOSUR',F10.1)
          ZADJ=ZADJ*CLOSUR
C
C ADJUSTMENT IS HIGHER FOR LONG CROWNED TREES
C
          IF(IICR .EQ. 9 .OR. IICR .EQ. 8)ZADJ=ZADJ*1.1
          Z=Z + ZADJ
          IF(Z .GT. 2.0)Z=2.0
        ENDIF
  184   CONTINUE
C
C CALCULATE DIAMETER AFTER 10 YEARS
C
        DIA= D + DG(I)/BRATIO(ISPC,D,HTI)
        IF((0.1 + COF1) .GT. DIA) GO TO 185
        HTG(I) = 0.1
        GO TO 60
  185   CONTINUE
C
C  CALCULATE HEIGHT AFTER 10 YEARS
C
        PSI= COF8*((DIA-0.1)/(0.1 + COF1 - DIA))**COF9
     +     * (EXP(Z*((1.0 - COF7**2  ))**0.5/COF6))
C
        H= ((PSI/(1.0 + PSI))* COF2) + 4.5
C 
        IF(.NOT. DEBUG)GO TO 191
        WRITE(JOSTND,9631)D,DIA,HTI,DG(I),Z ,H
 9631   FORMAT(1X,'IN HTGF DIA=',F7.3,'DIA+10=',F7.3,'H=',F7.1,
     &  'DIA GR=',F8.3,'Z=',E15.8,'NEW H=',F8.1)
  191   CONTINUE
C
C  CALCULATE HEIGHT GROWTH
C  NEGATIVE HEIGHT GROWTH IS NOT ALLOWED
C
        IF(H .LT. HT(I)) H=HT(I)
        HTG(I)= (H - HT(I))
C
C 14=WJ WILL GET HEIGHT ESTIMATE IN **REGENT**
C
      CASE(14)
        HTG(I)=0.1
C
C 15=MC WILL GET HEIGHT ESTIMATE IN **REGENT**
C THIS IS OLD STUFF
C
      CASE(15)
        SITAGE = 0.0
        SITHT = 0.0
        AGMAX = 0.0
        HTMAX = 0.0
        HTMAX2 = 0.0
        D1 = DBH(I)
        D2 = 0.0
        IF(DEBUG)WRITE(JOSTND,*)' IN HTGF, CALLING FINDAG I= ',I
        CALL FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,
     &              DEBUG)
C
        SINDX = SITEAR(ISPC)
        BAL=((100.0-PCT(I))/100.0)*BA
        H=HT(I)
        D=DBH(I)
        IF(H .GE. HTMAX)THEN
          HTG(I)=0.1
          GO TO 161
        ENDIF
        IF (SITAGE .GT. AGMAX) THEN
          POTHTG= 0.10
          GO TO 1320
        ELSE
          AGP10= SITAGE+10.0
        ENDIF
        HGUESS = (SINDX - 4.5) / ( 0.6192 - 5.3394/(SINDX - 4.5)
     &   + 240.29 * AGP10**(-1.4) +(3368.9/(SINDX - 4.5))*AGP10**(-1.4))
        HGUESS = HGUESS + 4.5
        IF(DEBUG)WRITE(JOSTND,*)' SINDX,ISPC,AGP10,I,HGUESS= '
        IF(DEBUG)WRITE(JOSTND,*) SINDX,ISPC,AGP10,I,HGUESS
C
        POTHTG= HGUESS-SITHT
C
        IF(DEBUG)WRITE(JOSTND,*)' I, ISPC, AGP10, SITHT,HGUESS= ',
     &  I, ISPC, AGP10, SITHT,HGUESS
C
 1320   CONTINUE
C
C  HEIGHT GROWTH MODIFIERS
C
        IF(DEBUG)WRITE(JOSTND,*) ' AT 1320 CONTINUE FOR TREE',I,' HT= ',
     &  HT(I),' AVH= ',AVH 
        RELHT = 0.0
        IF(AVH .GT. 0.0) RELHT=HT(I)/AVH
        IF(RELHT .GT. 1.5)RELHT=1.5
C
C     REVISED HEIGHT GROWTH MODIFIER APPROACH.
C
C     CROWN RATIO CONTRIBUTION.  DATA AND READINGS INDICATE HEIGHT
C     GROWTH PEAKS IN MID-RANGE OF CR, DECREASES SOMEWHAT FOR LARGE
C     CROWN RATIOS DUE TO PHOTOSYNTHETIC ENERGY PUT INTO CROWN SUPPORT
C     RATHER THAN HT. GROWTH.  CROWN RATIO FOR THIS COMPUTATION NEEDS
C     TO BE IN (0-1) RANGE; DIVIDE BY 100.  FUNCTION IS HOERL'S
C     SPECIAL FUNCTION (REF. P.23, CUTHBERT&WOOD, FITTING EQNS. TO DATA
C     WILEY, 1971).  FUNCTION OUTPUT CONSTRAINED TO BE 1.0 OR LESS.
C
        HGMDCR = (100.0*(ICR(I)/100.0)**3.0)* EXP((-5.0)*(ICR(I)/100.0))
        IF (HGMDCR .GT. 1.0) HGMDCR = 1.0
C
C     RELATIVE HEIGHT CONTRIBUTION.  DATA AND READINGS INDICATE HEIGHT
C     GROWTH IS ENHANCED BY STRONG TOP LIGHT AND HINDERED BY HIGH
C     SHADE EVEN IF SOME LIGHT FILTERS THROUGH.  ALSO RESPONSE IS
C     GREATER FOR GIVEN LIGHT AS SHADE TOLERANCE INCREASES.  FUNCTION
C     IS GENERALIZED CHAPMAN-RICHARDS (REF. P.2 DONNELLY ET AL. 1992.
C     THINNING EVEN-AGED FOREST STANDS...OPTIMAL CONTROL ANALYSES.
C     USDA FOR. SERV. RES. PAPER RM-307).
C     PARTS OF THE GENERALIZED CHAPMAN-RICHARDS FUNCTION USED TO
C     COMPUTE HGMDRH BELOW ARE SEGMENTED INTO FACTORS
C     FOR PROGRAMMING CONVENIENCE.
C
        RHB = (-1.45)
        RHR = 15.0
        RHM = 1.10
        RHYXS = 0.10
        RHX = RELHT
        FCTRKX = ( (RHK/RHYXS)**(RHM-1.0) ) - 1.0
        FCTRRB = -1.0*( RHR/(1.0-RHB) )
        FCTRXB = RHX**(1.0-RHB) - RHXS**(1.0-RHB)
        FCTRM  = -1.0/(RHM-1.0)
C
        IF (DEBUG)
     &  WRITE(JOSTND,*) ' HTGF-HGMDRH FACTORS = ',
     &  ISPC, RHX, FCTRKX, FCTRRB, FCTRXB, FCTRM
C
        HGMDRH = RHK * (1.0 + FCTRKX*EXP(FCTRRB*FCTRXB))**FCTRM
C
C     APPLY WEIGHTED MODIFIER VALUES.
C
        WTCR = .25
        WTRH = 1.0 - WTCR
        HTGMOD = WTCR*HGMDCR + WTRH*HGMDRH
C
        IF(DEBUG) THEN
          WRITE(JOSTND,*)' IN HTGF, I= ',I,' ISPC= ',ISPC,'HTGMOD= ',
     &    HTGMOD,' ICR= ',ICR(I),' HGMDCR= ',HGMDCR
          WRITE(JOSTND,*)' HT(I)= ',HT(I),' AVH= ',AVH,' RELHT= ',RELHT,
     &   ' HGMDRH= ',HGMDRH
        ENDIF
C
        IF (HTGMOD .GE. 2.0) HTGMOD= 2.0
        IF (HTGMOD .LE. 0.0) HTGMOD= 0.1
C
        HTG(I) = POTHTG * HTGMOD
C
        HTNOW=HT(I)+POTHTG
        IF(DEBUG)WRITE(JOSTND,901)ICR(I),PCT(I),BA,DG(I),HT(I),
     &  POTHTG,BAL,AVH,HTG(I),DBH(I),RMAI,HGUESS
  901   FORMAT(' HTGF',I5,13F9.2)
C
C    CHECK FOR HT GT MAX HT FOR THE SITE AND SPECIES
C
        TEMPH=H + HTG(I)
        IF(TEMPH .GT. HTMAX)THEN
          HTG(I)=HTMAX - H
        ENDIF
        IF(HTG(I).LT.0.1)HTG(I)=0.1
C
  161   CONTINUE
        IF(DEBUG)WRITE(JOSTND,*)
     &  ' I,SCALE,HTG,HTMAX, H= ',I,SCALE,HTG(I),HTMAX, H
C
C  ORIGINAL CI SPECIES
C
      CASE DEFAULT
        CON=HTCON(ISPC)+H2COF*HTI*HTI+HGLD(ISPC)*ALOG(D)+
     &      HGLH*ALOG(HTI)
        HTG(I)=EXP(CON+HDGCOF*ALOG(DG(I)))+BIAS
        IF(HTG(I).LT.0.1)HTG(I)=0.1
C
      END SELECT
C
   60 CONTINUE
C
C    MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
C    MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS (HTGMULT).
C    MULTIPLIED BY EXP(HTCON()) FOR SPECIES WHERE HCOR2 MULTIPLIER 
C    HAS NOT ALREADY BEEN ACCOUNTED FOR (READCORH).
C
      SELECT CASE (ISPC)
      CASE(11:17,19)
        HTG(I)=HTG(I)*SCALE*XHT*EXP(HTCON(ISPC))
      CASE DEFAULT
        HTG(I)=HTG(I)*SCALE*XHT
      END SELECT
C----------
C    APPLY DWARF MISTLETOE HEIGHT GROWTH IMPACT HERE,
C    INSTEAD OF AT EACH FUNCTION IF SPECIAL CASES EXIST.
C----------
      HTG(I)=HTG(I)*MISHGF(I,ISPC)
C
      TEMHTG=HTG(I)
C
      IF(DEBUG) THEN
        HTNEW=HT(I)+HTG(I)
        WRITE (JOSTND,9000) HTG(I),CON,HTCON(ISPC),H2COF,D,
     &  WK1(I),HGLH,HTNEW,HDGCOF,I,ISPC
 9000   FORMAT(' 9000 HTGF, HTG=',F8.4,' CON=',F8.4,' HTCON=',F8.4,
     &  ' H2COF=',F12.8,' D*BARK=',F8.4/' WK1=',F8.4,' HGLH=',F8.4,
     &  ' HTNEW=',F8.4,' HDGCOF=',F8.4,' I=',I4,' ISPC=',I2)
      ENDIF      
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(I)+HTG(I)).GT.SIZCAP(ISPC,4))THEN
        HTG(I)=SIZCAP(ISPC,4)-HT(I)
        IF(HTG(I) .LT. 0.1) HTG(I)=0.1
      ENDIF
C
      IF(.NOT.LTRIP) GO TO 30
      ITFN=ITRN+2*I-1
      SELECT CASE (ISPC)
      CASE(11:17,19)
        HTG(ITFN)=TEMHTG
      CASE DEFAULT
        HTG(ITFN)=EXP(CON+HDGCOF*ALOG(DG(ITFN)))+BIAS
        IF(HTG(ITFN).LT.0.1)HTG(ITFN)=0.1
        HTG(ITFN)=HTG(ITFN)*SCALE*XHT
      END SELECT
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF
C
      SELECT CASE (ISPC)
      CASE(11:17,19)
        HTG(ITFN+1)=TEMHTG
      CASE DEFAULT
        HTG(ITFN+1)=EXP(CON+HDGCOF*ALOG(DG(ITFN+1)))+BIAS
        IF(HTG(ITFN+1).LT.0.1)HTG(ITFN+1)=0.1
        HTG(ITFN+1)=HTG(ITFN+1)*SCALE*XHT
      END SELECT
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN+1)+HTG(ITFN+1)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN+1)=SIZCAP(ISPC,4)-HT(ITFN+1)
        IF(HTG(ITFN+1) .LT. 0.1) HTG(ITFN+1)=0.1
      ENDIF
C
      IF(DEBUG) WRITE(JOSTND,9001) HTG(ITFN),HTG(ITFN+1)
 9001 FORMAT( ' UPPER HTG =',F8.4,' LOWER HTG =',F8.4)
C----------
C   END OF TREE LOOP
C----------
   30 CONTINUE
C----------
C   END OF SPECIES LOOP
C----------
   40 CONTINUE
      RETURN
C
      ENTRY HTCONS
C----------
C  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT
C  ARE SITE DEPENDENT AND REQUIRE ONE-TIME RESOLUTION.  HGHC
C  CONTAINS HABITAT TYPE INTERCEPTS, HGLDD CONTAINS HABITAT
C  DEPENDENT COEFFICIENTS FOR THE DIAMETER INCREMENT TERM, HGH2
C  CONTAINS HABITAT DEPENDENT COEFFICIENTS FOR THE HEIGHT-SQUARED
C  TERM, AND HGHC CONTAINS SPECIES DEPENDENT INTERCEPTS.  HABITAT
C  TYPE IS INDEXED BY ITYPE (SEE /PLOT/ COMMON AREA).
C----------
      DATA  HGHC/
     & 2*2.03035,7*1.72222,2*1.19728,1.81759,2.14781,1.76998,4*2.21104,
     & 2*1.81759,2.03035,2*1.81759,3*1.74090,4*2.03035/
      DATA  HGLDD/
     & 2*0.62144,7*1.02372,2*0.85493,0.75756,0.46238,0.49643,4*0.37042,
     & 2*0.75756,0.62144,2*0.75756,3*0.34003,4*0.62144/
      DATA  HGH2/
     & 2*-13.358E-05,7*-3.809E-05,2*-3.715E-05,-2.607E-05,-5.200E-05,
     & -1.605E-05,4*-3.631E-05,2*-2.607E-05,-13.358E-05,2*-2.607E-05,
     & 3*-4.460E-05,4*-13.358E-05/
      DATA  HGSC/
     & -.5342,  .1433,  .1641, -.6458, -.6959,
     & -.9941, -.6004,  .2089, -.5478,  .7316,
     &    0.0,    0.0,    0.0,    0.0,    0.0,
     &    0.0,    0.0, -.9941,    0.0/
C----------
C  ASSIGN COEFFICIENTS THAT ARE INDEPENDENT OF SPECIES.
C----------
      HGHCH=HGHC(ITYPE)
      H2COF=HGH2(ITYPE)
      HDGCOF=HGLDD(ITYPE)
C----------
C  LOAD OVERALL INTERCEPT FOR EACH SPECIES.
C----------
      DO 50 ISPC=1,MAXSP
C
      SELECT CASE (ISPC)
C
      CASE(11:17,19)
        HTCON(ISPC) = 0.0
C
      CASE DEFAULT
        HTCON(ISPC)=HGHCH+HGSC(ISPC)
C
      END SELECT
C
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)=
     &    HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
C
      RETURN
      END
