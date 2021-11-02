      SUBROUTINE HTCALC (IFOR,SINDX,ISPC,AG,HGUESS,JOSTND,DEBUG)
      IMPLICIT NONE
C----------
C WS $Id: htcalc.f 2459 2018-07-22 22:04:44Z gedixon $
C----------
C THIS ROUTINE CALCULATES A POTENTIAL HT GIVEN AN SPECIES SITE AND AGE
C IT IS USED TO CALL POTHTG AND SITE
C----------
C
      LOGICAL DEBUG
      INTEGER JOSTND,ISPC,IFOR,INDX
      REAL HGUESS,AG,SINDX,A,B,TERM,TERM2,B50
      REAL DUNL1(6),DUNL2(6),DUNL3(6)
      INTEGER IDANUW
C----------
C  DATA STATEMENTS
C----------
      DATA DUNL1/ -88.9, -82.2, -78.3, -82.1, -56.0, -33.8 /
      DATA DUNL2/ 49.7067, 44.1147, 39.1441,
     &            35.4160, 26.7173, 18.6400 /
      DATA DUNL3/ 2.375, 2.025, 1.650, 1.225, 1.075, 0.875 /
C----------
C     SPECIES LIST FOR WESTERN SIERRAS VARIANT.
C
C     1 = SUGAR PINE (SP)                   PINUS LAMBERTIANA
C     2 = DOUGLAS-FIR (DF)                  PSEUDOTSUGA MENZIESII
C     3 = WHITE FIR (WF)                    ABIES CONCOLOR
C     4 = GIANT SEQUOIA (GS)                SEQUOIADENDRON GIGANTEAUM
C     5 = INCENSE CEDAR (IC)                LIBOCEDRUS DECURRENS
C     6 = JEFFREY PINE (JP)                 PINUS JEFFREYI
C     7 = CALIFORNIA RED FIR (RF)           ABIES MAGNIFICA
C     8 = PONDEROSA PINE (PP)               PINUS PONDEROSA
C     9 = LODGEPOLE PINE (LP)               PINUS CONTORTA
C    10 = WHITEBARK PINE (WB)               PINUS ALBICAULIS
C    11 = WESTERN WHITE PINE (WP)           PINUS MONTICOLA
C    12 = SINGLELEAF PINYON (PM)            PINUS MONOPHYLLA
C    13 = PACIFIC SILVER FIR (SF)           ABIES AMABILIS
C    14 = KNOBCONE PINE (KP)                PINUS ATTENUATA
C    15 = FOXTAIL PINE (FP)                 PINUS BALFOURIANA
C    16 = COULTER PINE (CP)                 PINUS COULTERI
C    17 = LIMBER PINE (LM)                  PINUS FLEXILIS
C    18 = MONTEREY PINE (MP)                PINUS RADIATA
C    19 = GRAY PINE (GP)                    PINUS SABINIANA
C         (OR CALIFORNIA FOOTHILL PINE)
C    20 = WASHOE PINE (WE)                  PINUS WASHOENSIS
C    21 = GREAT BASIN BRISTLECONE PINE (GB) PINUS LONGAEVA
C    22 = BIGCONE DOUGLAS-FIR (BD)          PSEUDOTSUGA MACROCARPA
C    23 = REDWOOD (RW)                      SEQUOIA SEMPERVIRENS
C    24 = MOUNTAIN HEMLOCK (MH)             TSUGA MERTENSIANA
C    25 = WESTERN JUNIPER (WJ)              JUNIPERUS OCIDENTALIS
C    26 = UTAH JUNIPER (UJ)                 JUNIPERUS OSTEOSPERMA
C    27 = CALIFORNIA JUNIPER (CJ)           JUNIPERUS CALIFORNICA
C    28 = CALIFORNIA LIVE OAK (LO)          QUERCUS AGRIFOLIA
C    29 = CANYON LIVE OAK (CY)              QUERCUS CHRYSOLEPSIS
C    30 = BLUE OAK (BL)                     QUERCUS DOUGLASII
C    31 = CALIFORNIA BLACK OAK (BO)         QUERQUS KELLOGGII
C    32 = VALLEY OAK (VO)                   QUERCUS LOBATA
C         (OR CALIFORNIA WHITE OAK)
C    33 = INTERIOR LIVE OAK (IO)            QUERCUS WISLIZENI
C    34 = TANOAK (TO)                       LITHOCARPUS DENSIFLORUS
C    35 = GIANT CHINQUAPIN (GC)             CHRYSOLEPIS CHRYSOPHYLLA
C    36 = QUAKING ASPEN (AS)                POPULUS TREMULOIDES
C    37 = CALIFORNIA-LAUREL (CL)            UMBELLULARIA CALIFORNICA
C    38 = PACIFIC MADRONE (MA)              ARBUTUS MENZIESII
C    39 = PACIFIC DOGWOOD (DG)              CORNUS NUTTALLII
C    40 = BIGLEAF MAPLE (BM)                ACER MACROPHYLLUM
C    41 = CURLLEAF MOUNTAIN-MAHOGANY (MC)   CERCOCARPUS LEDIFOLIUS
C    42 = OTHER SOFTWOODS (OS)
C    43 = OTHER HARDWOODS (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C    FROM EXISTING WS EQUATIONS --
C      USE 1(SP) FOR 11(WP) AND 24(MH) 
C      USE 2(DF) FOR 22(BD)
C      USE 3(WF) FOR 13(SF)
C      USE 4(GS) FOR 23(RW)
C      USE 8(PP) FOR 18(MP)
C      USE 34(TO) FOR 35(GC), 36(AS), 37(CL), 38(MA), AND 39(DG)
C      USE 31(BO) FOR 28(LO), 29(CY), 30(BL), 32(VO), 33(IO), 40(BM), AND
C                     43(OH)
C
C    FROM CA VARIANT --
C      USE CA11(KP) FOR 12(PM), 14(KP), 15(FP), 16(CP), 17(LM), 19(GP), 20(WE), 
C                       25(WJ), 26(WJ), AND 27(CJ)
C      USE CA12(LP) FOR 9(LP) AND 10(WB)
C
C    FROM SO VARIANT --
C      USE SO30(MC) FOR 41(MC)
C
C    FROM UT VARIANT --
C      USE UT17(GB) FOR 21(GB)
C      ALEXANDER 1967 RM32 USED AS A SITE REFERENCE; COEFFICIENTS WERE
C      COPIED FROM THE SO VARIANT SPECIES 8=ES FOR THIS ROUTINE AND
C      **SICHG**.
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = IFOR
C----------
      IF(DEBUG) WRITE(JOSTND,10)
   10 FORMAT(' ENTERING HTCALC')
      IF(DEBUG)WRITE(JOSTND,30)SINDX,ISPC,AG
   30 FORMAT(' IN HTCALC SINDX,ISPC,AG =',F10.2,I5,F10.3)
C----------
C GO TO A DIFFERENT POTENTIAL HEIGHT CURVE DEPENDING ON THE SPECIES
C----------
      SELECT CASE (ISPC)
C----------
C  IN 11 SPECIES WS, KING WAS USED FOR 1:6, 8, 11, 13, 18, 22:24, AND 42;
C  THESE WERE CHANGED TO USE DUNNING IN THE 43 SPECIES VERSION.
C
C  USE DUNNING-LEVITAN
C----------
      CASE(1:6,8:20,22:27,42)
C----------
C SET UP MAPPING TO THE CORRECT DUNNING-LEVITAN SITE CURVE
C----------
        IF(SINDX .LE. 44.) THEN
          INDX=6
        ELSEIF (SINDX.GT.44. .AND. SINDX.LE.52.) THEN
          INDX=5
        ELSEIF (SINDX.GT.52. .AND. SINDX.LE.65.) THEN
          INDX=4
        ELSEIF (SINDX.GT.65. .AND. SINDX.LE.82.) THEN
          INDX=3
        ELSEIF (SINDX.GT.82. .AND. SINDX.LE.98.) THEN
          INDX=2
        ELSE
          INDX=1
        ENDIF
        IF(AG .LE. 40.) THEN
          HGUESS = DUNL3(INDX) * AG
        ELSE
          HGUESS = DUNL1(INDX) + DUNL2(INDX)*ALOG(AG)
        ENDIF
C----------
C KING WAS USED FOR THESE SPECIES IN 11 SPECIES WS;
C CHANGED TO POWERS (1972) IN 43 SPECIES VERSION.
C 0.8 SCALER ADDED BY SMITH-MATEJA IN NC VARIANT SO TREES WOULD HIT THE
C SITE HEIGHT
C----------
      CASE(28:40,43)
        A = SQRT(AG) - SQRT(50.0)
        HGUESS = SINDX*(1.0+0.322*(A))-6.413*A
        HGUESS = HGUESS*.80
C----------
C DOLPH RED FIR CURVES PSW 206
C----------
      CASE(7)
        TERM=AG*EXP(AG*(-0.0440853))*1.4151E-6
        B = SINDX*TERM - 3.0495E6*TERM*TERM + 5.72474E-4
        TERM2 = 50.0 * EXP(50.0*(-0.0440853)) * 1.4151E-6
        B50 = SINDX*TERM2 - 3.0495E6*TERM2*TERM2 + 5.72474E-4
        HGUESS = ((SINDX-4.5)*(1.0-EXP(-B*(AG**1.51744)))) /
     &           (1.0-EXP(-B50*(50.0**1.51744)))
        HGUESS = HGUESS+4.5
C----------
C 41=MC - USE CURTIS, FOR. SCI. 20:307-316.  CURTIS CURVES
C ARE PRESENTED IN METRIC (3.2808 ?)
C
C BECAUSE OF EXCESSIVE HT GROWTH -- APPROX 30-40 FT/CYCLE, TOOK OUT 
C THE METRIC MULTIPLIER. DIXON 11-05-92
C----------
      CASE(41)
        HGUESS = (SINDX - 4.5) / (0.6192 - 5.3394/(SINDX - 4.5)
     &         + 240.29*AG**(-1.4) +(3368.9/(SINDX - 4.5))*AG**(-1.4))
        HGUESS = HGUESS + 4.5
C----------
C  21=GB FROM THE CR VARIANT VIA UT.
C  USE ALEXANDER 1967 RM32
C----------
       CASE(21)
        HGUESS = 4.5+((2.75780*SINDX**0.83312)*(1.0-EXP(-0.015701*AG))
     &           **(22.71944*SINDX**(-0.63557)))
C
      END SELECT
C
      IF(DEBUG)WRITE(JOSTND,*)' LEAVING HTCALC HGUESS= ',HGUESS
C
      RETURN
      END
