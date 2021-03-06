      SUBROUTINE HTDBH (IFOR,ISPC,D,H,MODE)
      IMPLICIT NONE
C----------
C CA $Id: htdbh.f 3758 2021-08-25 22:42:32Z lancedavid $
C----------
C  THIS SUBROUTINE CONTAINS THE DEFAULT HEIGHT-DIAMETER RELATIONSHIPS
C  FROM THE INVENTORY DATA.  IT IS CALLED FROM CRATET TO DUB MISSING
C  HEIGHTS, AND FROM REGENT TO ESTIMATE DIAMETERS (PROVIDED IN BOTH
C  CASES THAT LHTDRG IS SET TO .TRUE.).
C
C  DEFINITION OF VARIABLES:
C         D = DIAMETER AT BREAST HEIGHT
C         H = TOTAL TREE HEIGHT (STUMP TO TIP)
C      IFOR = FOREST CODE
C         505 = KLAMATH
C         506 = LASSEN
C         508 = MENDOCINO
C         511 = PLUMAS
C         514 = SHASTA-TRINITY
C         610 = ROGUE RIVER
C         611 = SISKIYOU
C      MODE = MODE OF OPERATING THIS SUBROUTINE
C             0 IF DIAMETER IS PROVIDED AND HEIGHT IS DESIRED
C             1 IF HEIGHT IS PROVIDED AND DIAMETER IS DESIRED
C----------
C
      REAL CURARN(50,3),SPLINE(50)
      INTEGER ISPC,IFOR,I,MODE
      REAL H,D,P2,P3,P4,Z,HATZ
      INTEGER IDANUW
C
C SPECIES ORDER IN CA VARIANT:
C  1=PC  2=IC  3=RC  4=WF  5=RF  6=SH  7=DF  8=WH  9=MH 10=WB
C 11=KP 12=LP 13=CP 14=LM 15=JP 16=SP 17=WP 18=PP 19=MP 20=GP
C 21=JU 22=BR 23=GS 24=PY 25=OS 26=LO 27=CY 28=BL 29=EO 30=WO
C 31=BO 32=VO 33=IO 34=BM 35=BU 36=RA 37=MA 38=GC 39=DG 40=FL
C 41=WN 42=TO 43=SY 44=AS 45=CW 46=WI 47=CN 48=CL 49=OH
C----------
C
C    1 = CHLA     PORT ORFORD CEDAR         CHAMAECYPARIS LAWSONIANA
C    2 = LIDE     INCENSE CEDAR             LIBOCEDRUS DECURRENS
C    3 = THPL     WESTERN REDCEDAR          THUJA PLICATA
C
C    4 = ABCO     WHITE FIR                 ABIES CONCOLOR
C    5 = ABMA     CALIFORNIA RED FIR        ABIES MAGNIFICA (MAGNIFICA)
C    6 = ABSH     SHASTA RED FIR            ABIES MAGNIFICA (SHASTENSIS)
C    7 = PSME     DOUGLAS-FIR               PSEUDOTSUGA MENZIESII
C
C    8 = TSHE     WESTERN HEMLOCK           TSUGA HETEROPHYLLA
C    9 = TSME     MOUNTAIN HEMLOCK          TSUGA MERTENSIANA
C
C   10 = PIAL     WHITEBARK PINE            PINUS ALBICAULIS
C   11 = PIAT     KNOBCONE PINE             PINUS ATTENUATA
C   12 = PICO     LODGEPOLE PINE            PINUS CONTORTA
C   13 = PICO3    COULTER PINE              PINUS COULTERI
C   14 = PIFL2    LIMBER PINE               PINUS FLEXILIS (FLEXILIS)
C   15 = PIJE     JEFFREY PINE              PINUS JEFFREYI
C   16 = PILA     SUGAR PINE                PINUS LAMBERTIANA
C   17 = PIMO3    WESTERN WHITE PINE        PINUS MONTICOLA
C   18 = PIPO     PONDEROSA PINE            PINUS PONDEROSA
C   19 = PIRA2    MONTEREY PINE             PINUS RADIATA
C   20 = PISA2    GRAY PINE                 PINUS SABINIANA
C
C   21 = JUOC     WESTERN JUNIPER           JUNIPERUS OCCIDENTALIS
C   22 = PIBR     BREWER SPRUCE             PICEA BREWERIANA
C   23 = SEGI2    GIANT SEQUOIA             SEQUOIADENDRON GIGANTIUM
C   24 = TABR2    PACIFIC YEW               TAXUS BREVIFOLIA
C
C   25 =          OTHER SOFTWOODS
C
C
C
C   26 = QUAG     COAST LIVE OAK            QUERCUS AGRIFOLIA
C   27 = QUCH2    CANYON LIVE OAK           QUERCUS CHRYSOLEPSIS
C   28 = QUDO     BLUE OAK                  QUERCUS DOUGLASII
C   29 = QUEN     ENGELMANN OAK             QUERCUS ENGELMANNI
C   30 = QUGA4    OREGON WHITE OAK          QUERCUS GARRYANA
C   31 = QUKE     CALIFORNIA BLACK OAK      QUERCUS KELLOGGII
C   32 = QULO     VALLEY WHITE OAK          QUERCUS LOBATA
C   33 = QUWI2    INTERIOR LIVE OAK         QUERCUS WISLIZENII
C
C   34 = ACMA3    BIGLEAF MAPLE             ACER MACROPHYLLUM
C   35 = AECA     CALIFORNIA BUCKEYE        AESCULUS CALIFORNICA
C   36 = ALRU2    RED ALDER                 ALNUS RUBRA
C   37 = ARME     PACIFIC MADRONE           ARBUTUS MENZIESII
C   38 = CHCHC4   GIANT CHINQUAPIN          CHRYSOLEPIS CHRYSOPHYLLA
C   39 = CONU4    PACIFIC DOGWOOD           CORNUS NUTTALLII
C   40 = FRLA     OREGON ASH                FRAXINUS LATIFOLIA
C   41 = JU__     WALNUT                    JUGLANS sp.
C   42 = LIDE3    TANOAK                    LITHOCARPUS DENSIFLORUS
C   43 = PLRA     CALIFORNIA SYCAMORE       PLATANUS RACEMOSA
C   44 = POTR5    QUAKING ASPEN             POPULUS TREMULOIDES
C   45 = POBAT    BLACK COTTONWOOD          POPULUS TRICHOCARPA
C   46 = SA__     WILLOW                    SALIX sp.
C   47 = TOCA     CALIFORNIA NUTMEG         TORREYA CALIFORNICA
C   48 = UMCA     CALIFORNIA LAUREL         UMBELLULARIA CALIFORNICA
C
C   49 =          OTHER HARDWOODS
C   50 =          COAST REDWOOD             SEQUIOA SEMPERVIRENS
C----------
C SPECIES WITH CURTIS/ARNEY EQNS FIT FROM DATA FOR THIS VARIANT ---
C       DF, IC, KP, GP, LP, MA, BO, WO, PP, JP, RF/SF, SP, WF, WP
C COEFFICIENTS FOR OTHER SPECIES ARE FROM OTHER R6 VARIANTS
C----------
      DATA (CURARN(I,1),I=1,50)/
     & 8532.9026,  695.4196,  487.5415,  467.3070,  606.3002,
     &  606.3002,  408.7614,  263.1274,  233.6987,   89.5535,
     &  101.5170,   99.1568,  514.1013,  514.1013,  744.7718,
     &  944.9299,  422.0948, 1267.7589,  113.7962,79986.6348,
     &   60.6009,   91.7438,  595.1068,  127.1698,79986.6348,
     &  105.0771,  105.0771,   59.0941,   59.0941,   40.3812,
     &  120.2372,  126.7237,   55.0   ,  143.9994,   55.0   ,
     &   94.5048,  117.7410, 1176.9704,  403.3221,   97.7769,
     &  105.0771,  679.1972,   55.0   ,   47.3648,  179.0706,
     &  149.5861,   55.0   ,  114.1627,   40.3812,  595.1068 /
C
      DATA (CURARN(I,2),I=1,50)/
     &    8.0343,    7.5021,    5.4444,    6.1195,    6.2936,
     &    6.2936,    5.4044,    6.9356,    6.9059,    4.2281,
     &    4.7066,   12.1300,    5.5983,    5.5983,    7.6793,
     &    6.2428,    6.0404,    7.4995,    4.7726,    9.9284,
     &    4.1543,   17.1081,    5.8103,    4.8977,    9.9284,
     &    5.6647,    5.6647,    6.1195,    6.1195,    3.7653,
     &    4.1713,    3.1800,    5.5   ,    3.5124,    5.5   ,
     &    4.0657,    4.0764,    6.3245,    4.3271,    8.8202,
     &    5.6647,    5.5698,    5.5   ,   15.6276,    3.6238,
     &    2.4231,    5.5   ,    6.0210,    3.7653,    5.8103 /
C
      DATA (CURARN(I,3),I=1,50)/
     &   -0.1831,   -0.3852,   -0.3801,   -0.4325,   -0.3860,
     &   -0.3860,   -0.4426,   -0.6619,   -0.6166,   -0.6438,
     &   -0.9540,   -1.3272,   -0.2734,   -0.2734,   -0.3779,
     &   -0.3087,   -0.4525,   -0.3286,   -0.7601,   -0.1013,
     &   -0.6277,   -1.4429,   -0.3821,   -0.4668,   -0.1013,
     &   -0.6822,   -0.6822,   -1.0552,   -1.0552,   -1.1224,
     &   -0.6113,   -0.6324,   -0.95  ,   -0.5511,   -0.95  ,
     &   -0.9592,   -0.6151,   -0.2739,   -0.2422,   -1.0534,
     &   -0.6822,   -0.3074,   -0.95  ,   -1.9266,   -0.5730,
     &   -0.1800,   -0.95  ,   -0.7838,   -1.1224,   -0.3821 /
C
      DATA SPLINE /
     & 3., 6., 3., 3., 3., 3., 3., 3., 3., 3.,
     & 2., 5., 3., 3., 5., 5., 3., 2., 3., 2.,
     & 3., 3., 3., 3., 3., 3., 3., 3., 3., 3.,
     & 3., 3., 3., 3., 3., 3., 3., 3., 3., 3.,
     & 3., 3., 3., 3., 3., 3., 3., 3., 3., 3./
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = IFOR
C----------
C  SET EQUATION PARAMETERS ACCORDING TO SPECIES.
C----------
      P2 = CURARN(ISPC,1)
      P3 = CURARN(ISPC,2)
      P4 = CURARN(ISPC,3)
      Z = SPLINE(ISPC)
      IF(MODE .EQ. 0) H=0.
      IF(MODE .EQ. 1) D=0.
C----------
C  PROCESS ACCORDING TO MODE
C----------
      IF(MODE .EQ. 0) THEN
        IF(D .GE. Z) THEN
          H = 4.5 + P2 * EXP(-1.*P3*D**P4)
        ELSE
          H = ((4.5+P2*EXP(-1.*P3*(Z**P4))-4.51)*(D-0.3)/(Z-0.3))+4.51
        ENDIF
      ELSE
        HATZ = 4.5 + P2 * EXP(-1.*P3*Z**P4)
        IF(H .GE. HATZ) THEN
          D = EXP( ALOG((ALOG(H-4.5)-ALOG(P2))/(-1.*P3)) * 1./P4)
        ELSE
          D=(((H-4.51)*(Z-0.3))/(4.5+P2*EXP(-1.*P3*(Z**P4))-4.51))+0.3
        ENDIF
      ENDIF
C
      RETURN
      END
