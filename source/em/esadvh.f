      SUBROUTINE ESADVH (EMSQR,I,HHT,DELAY,ELEV,DILATE,IHTSER,
     &  GENTIM,TRAGE)
      IMPLICIT NONE
C----------
C EM $Id: esadvh.f 2447 2018-07-10 16:31:11Z gedixon $
C----------
C     CALCULATES HEIGHTS OF ADVANCED TREES FOR REGENERATION MODEL
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ESPARM.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
C
      INCLUDE 'ESCOM2.F77'
C
C
COMMONS
C----------
C
      REAL THAB(5,MAXSP),TPRE(4,MAXSP),TPHY(5,MAXSP)
      REAL TRAGE,GENTIM,DILATE,ELEV,DELAY,HHT,EMSQR
      REAL AGE,AGELN,BNORM,PN
      INTEGER IHTSER,I,ITIME,N
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
C----------
C
C     CONSTANTS FOR ADVANCED HEIGHTS BY HABITAT TYPE GROUP
C     HAB.TYPE--> WET DFIR  DRY DFIR  GRANDFIR  WRC/WH   SAF
C
      DATA THAB/ 5*0.0,
     2           5*0.0,
     3           -0.00683,  0.12521, 0.16327,  0.26886,   0.0,
     4           5*0.0,
     5           5*0.0,
     6           5*0.0,
     7           5*0.0,
     8           5*0.0,
     9           5*0.0,
     O           5*0.0,
     1           5*0.0,
     &          40*0.0/
C
C     CONSTANTS FOR ADVANCED HEIGHTS BY SITE PREP
C     SITE PREP--> NONE      MECH      BURN      ROAD
C
      DATA TPRE/ 4*0.0,
     2           4*0.0,
     3           4*0.0,
     4           4*0.0,
     9             0.0,  -0.20770, -0.12903,  0.18322,
     6           4*0.0,
     7           4*0.0,
     8           4*0.0,
     9             0.0,  -0.20770, -0.12903,  0.18322,
     O           4*0.0,
     1           4*0.0,
     2           4*0.0,
     3           4*0.0,
     &          16*0.0,
     1             0.0,  -0.10356, -1.23036, -0.40522,
     3           4*0.0/
C
C     CONSTANTS FOR ADVANCED HEIGHTS BY PHYSIOGRAPHIC POSITION
C     PHY.POS--> BOTTOM   LOWER     MID      UPPER   RIDGE
C
      DATA TPHY/ 5*0.0,
     2           5*0.0,
     3           0.04770, 0.41224, 0.25028, 0.23537,  0.0,
     4           5*0.0,
     5           5*0.0,
     6           5*0.0,
     7          -0.28223,-0.99702,-0.47684,-0.20872,  0.0,
     8           5*0.0,
     9           5*0.0,
     O          -0.18689, 0.27119, 0.70375, 0.65555,  0.0 ,
     1           5*0.0,
     &          40*0.0/
      N=INT(DELAY+0.5)
      IF(N.GT.2) N=1
      DELAY=REAL(N)
      TRAGE=3.0-DELAY
      AGE=3.0-DELAY-GENTIM
      IF(AGE.LT.1.0) AGE=1.0
      AGELN=ALOG(AGE)
      ITIME=INT(TIME+0.5)
      BNORM=BNORML(ITIME)
      GO TO (10,20,30,40,50,60,70,80,90,100,110,
     &       120,130,140,150,160,170,180,190),I
C
C     HEIGHT OF TALLEST ADV WHITEBARK PINE (USE NI WP)
C
   10 CONTINUE
      PN=  0.05585 +0.84765*AGELN -0.003824*BAA -0.02835*ELEV
     &    -0.79565*XCOS +0.39278*XSIN -0.68673*SLO
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.51878)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV WESTERN LARCH (USE NI WL)
C
   20 CONTINUE
      PN= -1.80559 +1.24136*AGELN
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.54325)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV DOUGLAS-FIR (USE NI DF)
C
   30 CONTINUE
      PN= -1.15433 +1.09480*AGELN +TPHY(IPHY,3) +THAB(IHTSER,3)
     &    -0.04804*ELEV +0.0004225*ELEV*ELEV
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.63678)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV LIMBER PINE (USE IE LM)
C
   40 CONTINUE
      PN= 0.
      HHT = 5.
      GO TO 300
C
C     HEIGHT OF TALLEST SUBALPINE LARCH (USE IE AF)
C
   50 CONTINUE
      PN= -1.69509 +0.87242*AGELN -0.001107*BAA +TPRE(IPREP,5)
     &    -0.06402*BWB4 +0.02299*BWAF -0.01189*XCOS +0.15379*XSIN
     &    +0.44637*SLO
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.59957)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV ROCKY MTN JUNIPER (USE IE JU)
C
   60 CONTINUE
      PN= 0.
      HHT = 5.
      GO TO 300
C
C     HEIGHT OF TALLEST ADV LODGEPOLE PINE (USE NI LP)
C
   70 CONTINUE
      PN= -0.59267 +0.88997*AGELN +TPHY(IPHY,7) +0.79158*XCOS
     &    +0.49060*XSIN +0.49071*SLO
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.68842)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV ENGELMANN SPRUCE (USE NI ES)
C
   80 CONTINUE
      PN= -2.19638 +1.12147*AGELN -0.002270*BAA
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.59475)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV SUBALPINE FIR (USE NI AF)
C
   90 CONTINUE
      PN= -1.69509 +0.87242*AGELN -0.001107*BAA +TPRE(IPREP,9)
     &    -0.06402*BWB4 +0.02299*BWAF -0.01189*XCOS +0.15379*XSIN
     &    +0.44637*SLO
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.59957)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV PONDEROSA PINE (USE NI PP)
C
  100 CONTINUE
      PN= -6.33095 +0.79936*AGELN +TPHY(IPHY,10) +0.06347*BWAF
     &    +0.19305*ELEV -0.0020058*ELEV*ELEV
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.53813)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV GREEN ASH (USE IE CO)
C
  110 CONTINUE
      PN= 0.
      HHT = 5.
      GO TO 300
C
C     HEIGHT OF TALLEST ADV QUAKING ASPEN (USE IE AS)
C 
  120 CONTINUE
      PN= 0.
      HHT = 5.
      GO TO 300
C
C     HEIGHT OF TALLEST ADV BLACK COTTONWOOD (USE IE CO)
C 
  130 CONTINUE
      PN = 0.0
      HHT = 0.5
      GO TO 300
C
C     HEIGHT OF TALLEST ADV BALSAM POPLAR (USE IE CO)
C 
  140 CONTINUE
      PN= 0.
      HHT = 5.
      GO TO 300
C
C     HEIGHT OF TALLEST ADV PLAINS COTTONWOOD (USE IE CO)
C 
  150 CONTINUE
      PN = 0.0
      HHT = 0.5
      GO TO 300
C
C     HEIGHT OF TALLEST ADV NARROWLEAF COTTONWOOD (USE IE CO)
C 
  160 CONTINUE
      PN = 0.0
      HHT = 0.5
      GO TO 300
C
C     HEIGHT OF TALLEST ADV PAPER BIRCH (USE IE PB)
C 
  170 CONTINUE
      PN = 0.0
      HHT = 0.5
      GO TO 300
C
C     HEIGHT OF TALLEST ADV OTHER SOFTWOODS (USE NI OT)
C 
  180 CONTINUE
      PN= -0.43269 +0.77433*AGELN -0.00378*BAA +TPRE(IPREP,18)
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.54794)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV OTHER HARDWOODS (USE IE CO)
C 
  190 CONTINUE
      PN = 0.0
      HHT = 5.0
C
  300 CONTINUE
      RETURN
      END
