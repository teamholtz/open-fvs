      SUBROUTINE CCFCAL(ISPC,D,H,JCR,P,LTHIN,CCFT,CRWDTH,MODE)
      IMPLICIT NONE
C----------
C AK $Id: ccfcal.f 3836 2021-10-11 20:57:12Z lancedavid $
C----------
C  THIS ROUTINE COMPUTES CCF FOR INDIVIDUAL TREES.
C  CALLED FROM DENSE.
C
C***** NOTE *****
C***   THIS ROUTINE DOES NOT USE THE 'H' ARGUMENT IN PROCESS AND CROWN WIDTH
C***   IS NOT CALCULATED HERE AS IN OTHER VARIANTS. MODE ARGUEMENT ALSO
C***   SERVES NO PURPOSE BECUASE ONLY CCF IS EVER RETURNED. THESE REMAIN
C***   IN THE SUBROUTINE ARGUMENT LIST ONLY FOR COMPATIBILITY WITH CALL
C***   FROM base/dense.f
C****************
C
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
C           2 IF ONLY NEED CRWDTH RETURNED'
C  **NOTE: MODE 2 IS NEVER USED IN AK VARIANT
C
C  SPECIES ORDER:
C  1   2   3   4   5   6   7   8   9   10  11  12
C  SF  AF  YC  TA  WS  LS  BE  SS  LP  RC  WH  MH
C
C  13  14  15  16  17  18  19  20  21  22  23
C  OS  AD  RA  PB  AB  BA  AS  CW  WI  SU  OH
C
C  REFERENCES
C      PAINE AND HANN, 1982. MAXIMUM CROWN WIDTH EQUATIONS FOR
C        SOUTHWESTERN OREGON TREE SPECIES. RES PAP 46, FOR RES LAB
C        SCH FOR, OSU, CORVALLIS. 20PP.
C      RITCHIE AND HANN, 1985. EQUATIONS FOR PREDICTING BASAL AREA
C        INCREMENT IN DOUGLAS-FIR AND GRAND FIR. RES PAP 51, FOR RES
C        LAB SCH FOR, OSU, CORVALLIS. 9PP. (TABLE 2 PG 8)
C      SMITH 1966. STUDIES OF CROWN DEVELOPMENT ARE IMPROVING CANADIAN
C        FOREST MANAGEMENT. PROCEEDINGS, SIXTH WORLD FORESTRY CONGRESS.
C        MADRID, SPAIN. VOL 2:2309-2315. (TABLES 1 & 2, PG 2310)
C      RUSSELL, M.B. AND WEISKITTEL, A.R., 2011. MAXIMUM AND LARGEST
C        CROWN WIDTH EQUATIONS FOR 15 TREE SPECIES IN MAINE. NORTHERN
C        JOURNAL OF APPLIED FORESTRY, 28(2), PP.84-91.
C----------
C  VARIABLE DEFINITIONS
C----------
C      B1 - CONTAINS INTERCEPT COEFFICIENTS FOR OPEN GROWN CROWN WIDTH EQUATIONS
C      B2 - CONTAINS DBH COEFFICIENTS FOR OPEN GROWN CROWN WIDTH EQUATIONS
C   EQMAP - CONTAINS INDICATOR FLAGS WHICH ARE USED TO DETERMINE WHAT OPEN GROWN
C           CROWN WIDTH EQUATION SHOULD BE USED TO CALCULATE CCFT BASED ON SPECIES
C  EQFORM - INDICATOR VARIABLE THAT RECIEVES FLAG FROM EQMAP
C  IDANUW - DUMMY VARIABLE (STORES JCR)
C  LDANUW - DUMMY VARIABLE (STORES LTHIN)
C     MCW - OPEN GROWN CROWN WIDTH OF TREE
C     MCA - CROWN AREA OF TREE
C----------
C  VARIABLE DECLARATIONS:
C----------
C
      LOGICAL LDANUW,LTHIN

      INTEGER EQFORM,IDANUW,ISPC,JCR,MODE

      REAL CCFT,CRWDTH,D,H,P,MCW,MCA

      REAL B1(23),B2(23)

      INTEGER EQMAP(23)

C----------
C  DATA STATEMENTS
C----------
C  INTERCEPT COEFFICIENTS
      DATA B1/6.1880, 6.1880, 4.0,  0.535,  1.50,
     &        1.50,   0.535,  6.5,  6.1880, 4.0,
     &        4.5652, 4.5652, 1.50, 8.0,    8.0,
     &        1.48,   1.48,   0.5,  1.31,   0.5,
     &        0.5,    0.5,    0.5/
C
C  DBH COEFFICENTS
      DATA B2/1.0069, 1.0069, 1.6,   0.742,  0.496,
     &        0.496,  0.742,  1.8,   1.0069, 1.6,
     &        1.4147, 1.4147, 0.496, 1.53,   1.53,
     &        0.623,  0.623,  1.62,  0.586,  1.62,
     &        1.62,   1.62,   1.62/
C
C  ARRAY CONTAING MCW EQUATION FORM FLAGS BY SPECIES
      DATA EQMAP/1, 1, 1, 2, 2,
     &           2, 2, 1, 1, 1,
     &           1, 1, 2, 1, 1,
     &           2, 2, 1, 2, 1,
     &           1, 1, 1/
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = JCR
      LDANUW = LTHIN
C----------
C  INITIALIZE RETURN VARIABLES.
C----------
      CCFT = 0.0
      CRWDTH = 0.0
C----------
C  COMPUTE THE FOLLOWING:
C  1) OPEN GROWN CROWN WIDTH (MCW)
C  2) CROWN AREA (MCA)
C  3) CCFT
C
C  MCW IS CALCUATED IN ONE OF TWO WAYS:
C  SMITH/PAINE AND HANN EQ FORM: MCW = B1 + B2*DBH    (1)
C  RUSSELL AND WEISKITTEL EQ FORM: MCW = B1 + DBH**B2 (2)
C----------
C  DETERMINE WHICH MCW EQUATION FORM TO USE BASED ON SPECIES
      EQFORM = EQMAP(ISPC)
C
C  SMITH/PAINE AND HANN EQUATION FORM
      IF(EQFORM .EQ. 1) THEN
       MCW = B1(ISPC) + B2(ISPC)*D
C  RUSSELL AND WEISKITTEL EQUATION FORM (D IN CM, CONVERT TO FEET)
      ELSE
       MCW = B1(ISPC)*(D*2.54)**B2(ISPC)
       MCW = MCW * 3.28
      ENDIF
C
C  CALCUALTE MCA
      MCA = 3.14159*(MCW/2)**2
C
C  CALCULATE CCFT
      CCFT = (MCA/43560)*100
C
C  CONSTRAIN CCFT BASED ON DBH
      IF(D .LE. 0.1) CCFT = 0.001
C
C  EXPAND CCFT TO A PER ACRE BASIS
      CCFT=CCFT*P

      RETURN
      END
