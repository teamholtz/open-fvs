      SUBROUTINE HTGF
      IMPLICIT NONE
C----------
C AK $Id: htgf.f 3617 2021-05-28 17:02:44Z lancedavid $
C----------
C   THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT
C   INCREMENT FOR EACH CYCLE AND LOADS IT INTO THE ARRAY HTG.
C   CALLED FROM **TREGRO** DURING REGULAR CYCLING.
C   ENTRY **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE
C   DEPENDENT CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
C----------
C
C Number  V  Code  Common Name         FIA  PLANTS Scientific Name
C   1        SF   Pacific silver fir  011  ABAM   Abies amabilis
C   2        AF   subalpine fir       019  ABLA   Abies lasiocarpa
C   3        YC   Alaska cedar        042  CANO9  Callitropsis nootkatensis
C   4     P  TA   tamarack            071  LALA   Larix laricina
C   5     P  WS   white spruce        094  PIGL   Picea glauca
C   6     P  LS   Lutz�s spruce            PILU   Picea lutzii
C   7     P  BE   black spruce        095  PIMA   Picea mariana
C   8        SS   Sitka spruce        098  PISI   Picea sitchensis
C   9        LP   lodgepole pine      108  PICO   Pinus contorta
C  10        RC   western redcedar    242  THPL   Thuja plicata
C  11        WH   western hemlock     263  TSHE   Tsuga heterophylla
C  12        MH   mountain hemlock    264  TSME   Tsuga mertensiana
C  13     P  OS   other softwoods     298  2TE
C  14        AD   alder species       350  ALNUS  Alnus species
C  15        RA   red alder           351  ALRU2  Alnus rubra
C  16     P  PB   paper birch         375  BEPA   Betula papyrifera
C  17     P  AB   Alaska birch        376  BENE4  Betula neoalaskana
C  18     P  BA   balsam poplar       741  POBA2  Populus balsamifera
C  19     P  AS   quaking aspen       746  POTR5  Populus tremuloides
C  20     P  CW   black cottonwood    747  POBAT  Populus trichocarpa
C  21     P  WI   willow species      920  SALIX  Salix species
C  22     P  SU   Scouler�s willow    928  SASC   Salix scouleriana
C  23     P  OH   other hardwoods     998  2TD
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
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
COMMONS
C
C------------
C  VARIABLE DECLARATIONS:
C----------
C
      LOGICAL DEBUG
C
      INTEGER I,I1,I2,I3,ISPC,ITFN
C
      REAL D
      REAL H,MISHGF,POTHTG,SCALE
      REAL TEMHTG,XHT,XSITE,TEMEL
      REAL NOPERMH1(MAXSP),NOPERMH2(MAXSP),NOPERMH3(MAXSP)
      REAL NOPERMH4(MAXSP),NOPERMH5(MAXSP),NOPERMH6(MAXSP)
      REAL PERMH1(MAXSP),PERMH2(MAXSP),PERMH3(MAXSP)
      REAL PERMH4(MAXSP),PERMH5(MAXSP),PERMH6(MAXSP)      
      REAL B1,B2,B3,B4,B5,B6
      REAL BASEHG,PFHMOD
      REAL HTLO(MAXSP),HTHI(MAXSP),HGBND
      REAL DG10,DGLT,BRAT,BRATIO

C----------
C  DATA STATEMENTS:
C----------

C      BASE HG INTERCEPT COEFFICIENTS
      DATA NOPERMH1/
     & -2.18236,  -2.18236,  -2.955092, -0.663746, -0.501134,
     & -0.501134, -0.663746, -2.18236,  -3.19512,  -2.979661,
     & -2.404892, -2.770793, -0.501134, -0.174905, -0.710501, 
     & -0.306839, -0.306839, -0.174905, -0.630114, -0.174905,
     & -0.174905, -0.174905, -0.174905/

C      BASE HG DBH^2 COEFFICIENTS
      DATA NOPERMH2/
     & -0.000447, -0.000447, -0.000447, -0.003814, -0.003814,
     & -0.003814, -0.003814, -0.000447, -0.000447, -0.000447,
     & -0.000447, -0.000447, -0.003814, -0.003814, -0.003814,
     & -0.003814, -0.003814, -0.003814, -0.003814, -0.003814,
     & -0.003814, -0.003814, -0.003814/

C      BASE HG LN(DBH) COEFFICIENTS
      DATA NOPERMH3/
     & -0.00488,  -0.00488,   0.125393, 0.176358,  0.209621,
     &  0.209621,  0.176358, -0.00488,  0.166453,  0.130947, 
     &  0.044809,  0.099358,  0.209621, -0.051622,  0.396143,
     &  0.062956,  0.062956, -0.051622, 0.068496, -0.051622,
     & -0.051622, -0.051622, -0.051622/

C      BASE HG ELEV COEFFICIENTS
      DATA NOPERMH4/
     &  0.0,       0.0,       0.0,      -0.000075, -0.000075, 
     & -0.000075, -0.000075,  0.0,       0.0,       0.0,
     &  0.0,       0.0,      -0.000075, -0.000075, -0.000075,
     & -0.000075, -0.000075, -0.000075, -0.000075, -0.000075,
     & -0.000075, -0.000075, -0.000075/

C      BASE HG LN(SITEINDEX) COEFFICIENTS
      DATA NOPERMH5/
     & 0.429243, 0.429243, 0.429243, 0.0,      0.0,
     & 0.0,      0.0,      0.429243, 0.429243, 0.429243, 
     & 0.429243, 0.429243, 0.0,      0.0,      0.0,
     & 0.0,      0.0,      0.0,      0.0,      0.0,
     & 0.0,      0.0,      0.0/
     
C      BASE HG LN(DG) COEFFICIENTS
      DATA NOPERMH6/
     & 0.489281, 0.489281, 0.376732, 0.560124, 0.517799,
     & 0.517799, 0.560124, 0.489281, 0.342411, 0.374658, 
     & 0.469563, 0.408836, 0.517799, 0.539313, 0.195472,
     & 0.392915, 0.392915, 0.539313, 0.367413, 0.539313,
     & 0.539313, 0.539313, 0.539313/

C      HG PERMAFROST MOD INTERCEPT COEFFICIENTS
      DATA PERMH1/
     &  0.0,       0.0,       0.0,      -0.661722, -0.509243,
     & -0.509243, -0.661722,  0.0,       0.0,       0.0,
     &  0.0,       0.0,      -0.509243,  0.0,       0.0, 
     & -0.299268, -0.299268, -0.148618, -0.617425, -0.148618,
     & -0.148618, -0.148618, -0.148618/

C      HG PERMAFROST MOD - PERMFROST EFFECT COEFFICIENTS
      DATA PERMH2/
     &  0.0,       0.0,       0.0,      -0.130016, -0.130016,
     & -0.130016, -0.130016,  0.0,       0.0,       0.0,
     &  0.0,       0.0,      -0.130016,  0.0,       0.0,
     & -0.130016, -0.130016, -0.130016, -0.130016, -0.130016,
     & -0.130016, -0.130016, -0.130016/

C      HG PERMAFROST MOD DBH^2 COEFFICIENTS
      DATA PERMH3/
     &  0.0,       0.0,       0.0,      -0.003807, -0.003807,
     & -0.003807, -0.003807,  0.0,       0.0,       0.0,
     &  0.0,       0.0,      -0.003807,  0.0,       0.0,
     & -0.003807, -0.003807, -0.003807, -0.003807, -0.003807,
     & -0.003807, -0.003807, -0.003807/

C      HG PERMAFROST MOD LN(DBH) COEFFICIENTS
      DATA PERMH4/
     & 0.0,        0.0,       0.0,      0.17915,   0.221303,
     & 0.221303,   0.17915,   0.0,      0.0,       0.0,
     & 0.0,        0.0,       0.221303, 0.0,       0.0,
     & 0.057156,   0.057156, -0.075692, 0.060586, -0.075692,
     & -0.075692, -0.075692, -0.075692/ 

C      HG PERMAFROST ELEV COEFFICIENTS
      DATA PERMH5/
     &  0.0,       0.0,       0.0,      -0.000067, -0.000067,
     & -0.000067, -0.000067,  0.0,       0.0,       0.0,
     &  0.0,       0.0,      -0.000067,  0.0,       0.0,
     & -0.000067, -0.000067, -0.000067, -0.000067, -0.000067,
     & -0.000067, -0.000067, -0.000067/

C      HG PERMAFROST LN(DG) COEFFICIENTS
      DATA PERMH6/
     &  0.0,      0.0,      0.0,      0.537482, 0.509459,
     &  0.509459, 0.537482, 0.0,      0.0,      0.0,
     &  0.0,      0.0,      0.509459, 0.0,      0.0,
     &  0.397696, 0.397696, 0.556616, 0.375558, 0.556616,
     &  0.556616, 0.556616, 0.556616/
     
C  LOWER BOUNDING VALUES FOR HTG BOUNDING. THESE VALUES ARE BASED ON THE
C  99TH PERCENTILE OF HT VALUES OBSERVED IN THE DATASET USED TO FIT 
C  HEIGHT GROWTH EQUATIONS.
      DATA HTLO/
     & 131.0,  83.0,  92.0, 47.0, 78.0, 78.0, 47.0, 131.0,
     &  70.0, 102.0, 130.0, 83.0, 78.0, 38.0, 86.0,  77.0,
     &  77.0,  84.0,  76.0, 84.0, 38.0, 55.0, 38.0/

C  UPPER BOUNDING VALUES USED FOR HTG BOUNDING. THESE VALUES ARE BASED ON 
C  THE MAXIMUM HT VALUES OBSERVED IN THE DATASET USED TO FIT HEIGHT DIAMETER
C  RELATIONSHIPS.
      DATA HTHI/
     & 211.0, 150.0, 139.0,  77.0, 123.0, 123.0,  77.0, 211.0,
     &  98.0, 151.0, 214.0, 150.0, 123.0,  59.0, 120.0, 102.0,
     & 102.0, 130.0, 102.0, 130.0,  59.0,  85.0,  59.0/

C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE HTGF  CYCLE =',I5)
C
      IF(DEBUG)WRITE(JOSTND,*) 'IN HTGF AT BEGINNING,HTCON=',
     *HTCON,'RMAI=',RMAI,'ELEV=',ELEV
C
      SCALE=FINT/YR
C----------
C  GET THE HEIGHT GROWTH MULTIPLIERS.
C----------
      CALL MULTS (2,IY(ICYC),XHMULT)
C----------
C  SCALE ELEVATION TERM REQUIRED FOR HG CALCULATION
C----------
      TEMEL=ELEV*100
C----------
C   BEGIN SPECIES LOOP:
C----------
      DO 40 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 40
      I2 = ISCT(ISPC,2)
      XSITE = SITEAR(ISPC)
      XHT=XHMULT(ISPC)
C-----------
C   BEGIN TREE LOOP WITHIN SPECIES LOOP
C-----------
      DO 30 I3=I1,I2
      I=IND1(I3)
      H=HT(I)
      D=DBH(I)
      DGLT = DG(I)
      HTG(I)=0.
      IF(DG(I) .LE. 0.)DG(I)=0.0001
      IF (PROB(I).LE.0.) GO TO 161

C CALCULATE OUTSIDE BARK DIAMETER GROWTH WHICH USED FOR HTG EQUATIONS
      BRAT = BRATIO(ISPC,D,H)
      DG10 = DGLT/BRAT

C CONSTRAIN DIAMETER GROWTH TO SMALL VALUE WHEN H OF INCOMING RECORD IS
C LESS THAN 4.5 FT.
      IF(H .LT. 4.5) DG10=0.1

      IF(DEBUG)WRITE(JOSTND,*)' I=',I,' ISPC=',ISPC,' D=',D,' BRAT=',
     & BRAT,' DGLT=',DGLT,' DG10=',DG10

C----------
C  CALCULATE HEIGHT GROWTH FOR ALL SPECIES
C
C  ANNUAL HEIGHT INCREMENT (FT/YEAR) IS CALCULATED USING THE FOLLOWING
C  FUNCTIONAL FORM:
C
C  HI = EXP(X)
C  X = B1 + B2*DBH^2 + B3*LN(DBH) + B4*ELEV + B5*XSITE + B6*DG10
C
C  WHERE 
C  HI: ANNUAL HEIGHT INCREMENT
C  DBH: DIAMETER AT BREAST HEIGHT
C  ELEV: ELEVATION OF THE STAND
C  XSITE: SITE INDEX
C  DG10: 10 YEAR OUTSIDE BARK DIAMETER GROWTH.
C
C  HI IS CONVERTED TO 10 YEAR HEIGHT INCREMENT BY HI * 10 (YR)
C----------

C  LOAD HG COEFFICIENTS FOR SPECIES
      B1=NOPERMH1(ISPC)
      B2=NOPERMH2(ISPC)
      B3=NOPERMH3(ISPC)
      B4=NOPERMH4(ISPC)
      B5=NOPERMH5(ISPC)
      B6=NOPERMH6(ISPC)
      BASEHG=EXP(B1 + B2*D**2 + B3*LOG(D) + B4*TEMEL +
     &           B5*LOG(XSITE) + B6*LOG(DG10))

C----------
C  CALCULATE PERMAFROST HEIGHT GROWTH MODIFIER IF LPERM IS TRUE
C
C  COMPUTE PERMAFROST MODIFIER BY COMPUTING THE NUMERATOR AND
C  DENOMINATOR WITH THE EQUATION BELOW. NUMERATOR INCLUDES PERM
C  FACTOR AND DENOMINATOR DOES NOT. THE RESULTING MODIFIER
C  SHOULD BE LESS THAN 1.0 IF PERMAFROST IS NOT PRESENT, PFMOD
C  WILL BE 1.0, NO AFFECT.
C
C  HI = EXP(X)
C  X = B1 + PERM(B2) + B3*DBH^2 + B4*LN(DBH) + B5*ELEV + B6*LOG(DG10)
C
C  WHERE 
C  HI: ANNUAL HEIGHT INCREMENT
C  PERM: PERMAFORST PRESENCE VARIABLE
C  DBH: DIAMETER AT BREAST HEIGHT
C  ELEV: ELEVATION OF THE STAND
C  DG10: 10 YEAR OUTSIDE BARK DIAMETER GROWTH.
C----------

      SELECT CASE (ISPC)
        CASE (4:7, 13, 16:23)
          B1=PERMH1(ISPC)
          B2=PERMH2(ISPC)
          B3=PERMH3(ISPC)
          B4=PERMH4(ISPC)
          B5=PERMH5(ISPC)
          B6=PERMH6(ISPC)
          IF(LPERM) THEN
            PFHMOD=EXP(B1 + B2 + B3*(D)**2 + B4*LOG(D) + 
     &             B5*TEMEL + B6*LOG(DG10))/BASEHG
            IF (PFHMOD.GT.1.0)PFHMOD=1.0
          ELSE
            PFHMOD=EXP(B1 + B3*(D)**2 + B4*LOG(D) + B5*TEMEL +
     &             B6*LOG(DG10))/BASEHG
            IF (PFHMOD.LT.1.0)PFHMOD=1.0
          ENDIF
        CASE DEFAULT
          PFHMOD = 1.0
      END SELECT
      IF(DEBUG)WRITE(JOSTND,*)
     &    'IN HTGF, ISPC= ',ISPC,' ISCT= ',I1, ' BASEHG=', BASEHG,
     &    ' PFHMOD= ', PFHMOD

C     ANNUAL HEIGHT GROWTH WITH PERMAFROST MODIFIER
C     EXPANDED TO PERIOD.      
      POTHTG = YR * BASEHG * PFHMOD

C  ADJUST HEIGHT GROWTH BASED ON SPECIES
C  AD, WI, OH: ASSUME MULTIPLIER OF 0.45
C  SU: ASSUME MULTIPLIER OF 0.65
C  ALL OTHER SPECIES: ASSUME A MULTIPLIER OF 1.00
      SELECT CASE (ISPC)
        CASE(14,21,23)
          POTHTG = POTHTG * 0.45
        CASE(22)
          POTHTG = POTHTG * 0.65
        CASE DEFAULT
          POTHTG = POTHTG * 1.00
      END SELECT

      IF(DEBUG) WRITE(JOSTND,9)
     & I, ISPC, DBH(I), HT(I), TEMEL, XSITE, DG10, PFHMOD, POTHTG
    9 FORMAT(' IN HTGF: I=',I5,' ISPC=',I5,' DBH=',F7.4,' HT=',F8.4,
     & ' TEMEL=',F7.2,' XSITE=',F7.2, ' DG10=',F7.4, ' PFHMOD=',F7.4,
     & ' POTHTG=',F8.4)

C----------
C BOUND HEIGHT GROWTH BASED ON THE HEIGHT OF THE SPECIES. BOUNDING IS
C APPLIED TO AVOID HAVING TREES REACH UNREALISTIC HEIGHTS. HEIGHT GROWTH 
C IS BOUND BETWEEN VALUES IN HTLO AND HTHI ARRAYS. THE HEIGHT GROWTH
C BOUNDING FUNCTION PROPORTIONALLY ADJUSTS HEIGHT GROWTH VALUES SO 
C HEIGHTS OF SPECIES WILL EVENTUALLY CONVERGE TO THE UPPER HEIGHT
C BOUNDING VALUE. 
C 
C BOUNDING LOGIC:
C 1) IF HT IS BETWEEN HTLO AND HTHI VALUES, THEN HEIGHT GROWTH IS
C    BOUND.
C 2) IF THE HT IS BELOW THE HTLO VALUE, THEN HEIGHT GROWTH IS NOT
C    BOUND.
C 3) IF THE HT IS ABOVE THE HTHI VALUE, THEN HEIGHT GROWTH BOUNDING
C    VALUE IS SET TO 0.1.
C----------

      IF(HT(I) .GE. HTLO(ISPC) .AND. HT(I) .LT. HTHI(ISPC)) THEN
        HGBND= 1.0 - ((HT(I) - HTLO(ISPC))/(HTHI(ISPC) - HTLO(ISPC)))
        IF(HGBND .LT. 0.1) HGBND=0.1
      ELSEIF (HT(I) .LT. HTLO(ISPC)) THEN
        HGBND=1.0
      ELSE
        HGBND=0.1
      ENDIF

      IF(DEBUG)WRITE(JOSTND,*)' HT=',HT(I),' HTLO=',HTLO(ISPC),' HTHI=',
     & HTHI(ISPC),' HGBND=',HGBND

C APPLY BOUNDING VALUE TO POTHTG VALUE
      POTHTG = POTHTG * HGBND

C ENFORCE MINIMUM HEIGHT GROWTH VALUE IF NECCESARY
      HTG(I)= POTHTG
      IF(HTG(I) .LE. 0.1) HTG(I) = 0.1
C----------
C IF SMALL DG THEN MINIMAL HTG
C----------
      IF(DG(I) .LE. 0.04) HTG(I) = 0.1
      IF(DEBUG) WRITE(JOSTND,120)
     & HT(I),HTG(I),DBH(I),DG(I)
  120 FORMAT(' HTGF 120F HT,HTG,DBH,DG =',6F10.4)
C
  161 CONTINUE
C-----------
C   HEIGHT GROWTH EQUATION, EVALUATED FOR EACH TREE EACH CYCLE
C   MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
C   MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
C----------
      HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
C----------
C    APPLY DWARF MISTLETOE HEIGHT GROWTH IMPACT HERE,
C    INSTEAD OF AT EACH FUNCTION IF SPECIAL CASES EXIST.
C----------
      HTG(I)=HTG(I)*MISHGF(I,ISPC)
      TEMHTG=HTG(I)
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
      HTG(ITFN)=TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF
C
      HTG(ITFN+1)=TEMHTG
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
      IF(DEBUG)WRITE(JOSTND,9002)ICYC
 9002 FORMAT(' LEAVING SUBROUTINE HTGF  CYCLE =',I5)
C
      RETURN
C
      ENTRY HTCONS
C----------
C  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT
C  ARE SITE DEPENDENT AND REQUIRE ONE-TIME RESOLUTION.
C----------
C  LOAD OVERALL INTERCEPT FOR EACH SPECIES.
C----------
      DO 50 ISPC=1,MAXSP
      HTCON(ISPC)=0.0
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)=
     &    HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
C
      RETURN
      END
