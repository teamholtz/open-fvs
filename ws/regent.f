      SUBROUTINE REGENT(LESTB,ITRNIN)
      IMPLICIT NONE
C----------
C WS $Id: regent.f 3758 2021-08-25 22:42:32Z lancedavid $
C----------
C  THIS SUBROUTINE COMPUTES HEIGHT AND DIAMETER INCREMENTS FOR
C  SMALL TREES.  THE HEIGHT INCREMENT MODEL IS APPLIED TO TREES
C  THAT ARE LESS THAN 10 INCHES DBH (5 INCHES FOR LODGEPOLE PINE),
C  AND THE DBH INCREMENT MODEL IS APPLIED TO TREES THAT ARE LESS
C  THAN 3 INCHES DBH.  FOR TREES THAT ARE GREATER THAN 2 INCHES
C  DBH (1 INCH FOR LODGEPOLE PINE), HEIGHT INCREMENT PREDICTIONS
C  ARE AVERAGED WITH THE PREDICTIONS FROM THE LARGE TREE MODEL.
C  HEIGHT INCREMENT IS A FUNCTION OF HABITAT TYPE, SLOPE,
C  ASPECT, TREE HEIGHT, BASAL AREA IN LARGER TREES, AND
C  STAND CROWN COMPETITION FACTOR.  DIAMETER IS ASSIGNED FROM
C  A HEIGHT-DIAMETER FUNCTION WITH ADJUSTMENTS FOR RELATIVE SIZE
C  AND STAND DENSITY.  INCREMENT IS COMPUTED BY SUBTRACTION.
C  THIS ROUTINE IS CALLED FROM **CRATET** DURING CALIBRATION AND
C  FROM **TREGRO** DURING CYCLING.  ENTRY **REGCON** IS CALLED FROM
C  **RCON** TO LOAD MODEL PARAMETERS THAT NEED ONLY BE RESOLVED ONCE.
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
      INCLUDE 'CALCOM.F77'
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
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'ESTCOR.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
COMMONS
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES:
C
C   CORTEM -- A TEMPORARY ARRAY FOR PRINTING CORRECTION TERMS.
C   NUMCAL -- A TEMPORARY ARRAY FOR PRINTING NUMBER OF HEIGHT
C             INCREMENT OBSERVATIONS BY SPECIES.
C    RHCON -- CONSTANT FOR THE HEIGHT INCREMENT MODEL.  ZERO FOR ALL
C             SPECIES IN THIS VARIANT
C     XMAX -- UPPER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM SMALL AND LARGE TREE MODELS
C             ARE AVERAGED.
C     XMIN -- LOWER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM THE SMALL AND LARGE TREE
C             ARE AVERAGED.
C----------
      EXTERNAL RANN
      LOGICAL DEBUG,LESTB,LSKIPH
      CHARACTER SPEC*2
      INTEGER NUMCAL(MAXSP)
      INTEGER SMTMAP(MAXSP)
      INTEGER N,IREFI,KOUT,ISPEC,KK,I3,I
      INTEGER ITRNIN,ISPC,I1,I2,IPCCF,K,L,MSP,IHDW
      REAL CORTEM(MAXSP)
      REAL XMAX(MAXSP),XMIN(MAXSP),DIAM(MAXSP),AB(9)
      REAL REGYR,FNT,BACHLO,BRATIO,DGSM,DDS,HTNEW,SCALE3,CORNEW
      REAL SNP,SNX,SNY,EDH,P,TERM,X,VIGOR,DGMX,BKPT,CCF,AVHT,PCTRED
      REAL SCALE,SCALE2,XRHGRO,XRDGRO,CON,XMX,XMN,SI,D,CR,RAN,BAL,H
      REAL BARK,HTGRR,HTGR,ZZRAN,XWT,HK,BX,AX,DK,DKK,XDWT
      REAL POTHTG,DAT45,LTHG,DGLT
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
C
C    GS AND RW USE NEW RELATIONSHIP FROM CASTLE 2019.
C----------
C  DATA STATEMENTS.
C----------
      DATA XMAX/
     &  3.5,  3.5,  3.5,  10.0,  3.5,  3.5,  3.5,  3.5,  4.0,  4.0, 
     &  3.5,  4.0,  3.5,   4.0,  4.0,  4.0,  4.0,  3.5,  4.0,  4.0, 
     & 199.,  3.5,  10.0,  3.5,  4.0,  4.0,  4.0,  3.5,  3.5,  3.5, 
     &  3.5,  3.5,   3.5,  3.5,  3.5,  3.5,  3.5,  3.5,  3.5,  3.5, 
     &  4.0,  3.5,  3.5/
C
      DATA XMIN/
     &  2.0,  2.0,  2.0,  2.0,  2.0,  2.0,  2.0,  2.0,  2.0,  2.0, 
     &  2.0,  2.0,  2.0,  2.0,  2.0,  2.0,  2.0,  2.0,  2.0,  2.0, 
     &  99.,  2.0,  2.0,  2.0,  2.0,  2.0,  2.0,  1.0,  1.0,  1.0, 
     &  1.0,  1.0,  1.0,  2.0,  2.0,  2.0,  2.0,  2.0,  2.0,  1.0, 
     &  2.0,  2.0,  1.0/
C
      DATA SMTMAP/
     &    1,    2,    2,    0,    1,    1,    2,    1,    0,    0, 
     &    1,    0,    2,    0,    0,    0,    0,    1,    0,    0, 
     &    0,    2,    0,    1,    0,    0,    0,    3,    3,    3, 
     &    3,    3,    3,    4,    4,    4,    4,    4,    4,    3, 
     &    0,    1,    3/
C
      DATA DIAM/
     &  0.3,  0.3,  0.3,  0.2,  0.2,  0.3,  0.3,  0.5,  0.4,  0.4, 
     &  0.3,  0.5,  0.3,  0.5,  0.5,  0.5,  0.5,  0.5,  0.5,  0.5, 
     &  0.4,  0.3,  0.2,  0.3,  0.5,  0.5,  0.5,  0.4,  0.4,  0.4, 
     &  0.4,  0.4,  0.4,  0.2,  0.2,  0.2,  0.2,  0.2,  0.2,  0.4, 
     &  0.2,  0.4,  0.4/
C
      DATA AB/
     & 1.11436,-.011493,.43012E-4,-.72221E-7,.5607E-10,-.1641E-13,3*0./
C-----------
C  CHECK FOR DEBUG.
C-----------
      LSKIPH=.FALSE.
      CALL DBCHK (DEBUG,'REGENT',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,9980)ICYC
 9980 FORMAT('ENTERING SUBROUTINE REGENT  CYCLE =',I5)
C----------
C  IF THIS IS THE FIRST CALL TO REGENT, BRANCH TO STATEMENT 40 FOR
C  MODEL CALIBRATION.
C----------
      IF(LSTART) GOTO 40
      CALL MULTS (3,IY(ICYC),XRHMLT)
      CALL MULTS(6,IY(ICYC),XRDMLT)
      IF (ITRN.LE.0) GO TO 91
C----------
C  HEIGHT INCREMENT IS DERIVED FROM A HEIGHT-AGE CURVE AND IS NOMINALLY
C  BASED ON A 5-YEAR GROWTH PERIOD FOR SPECIES USING EQUATIONS FROM THE
C  CA AND WS VARIANTS; 10-YEAR GROWTH PERIOD FOR SPECIES USING EQUATIONS
C  FROM THE SO AND UT VARIANTS.  SCALE IS USED TO CONVERT
C  HEIGHT INCREMENT PREDICTIONS TO A FINT-YEAR PERIOD.  DIAMETER
C  INCREMENT IS PREDICTED FROM CHANGE IN HEIGHT, AND IS SCALED TO A 10-YEAR
C  PERIOD USING THE VARIABLE SCALE2.  
C  DIAMETER INCREMENT IS CONVERTED TO A FINT-YEAR BASIS IN **GRADD**.
C----------
      FNT=FINT
      IF(LESTB) THEN
        IF(FINT.LE.5.0) THEN
          LSKIPH=.TRUE.
        ELSE
          FNT=FNT-5.0
        ENDIF
      ENDIF
C----------
C  IF CALLED FROM **ESTAB** INTERPOLATE MID-PERIOD CCF AND TOP HT
C  FROM VALUES AT START AND END OF PERIOD.
C  THIS IS NEEDED FOR SPECIES USING EQUATIONS FROM THE SO AND UT VARIANTS.
C----------
      CCF=RELDEN
      AVHT=AVH
      IF(LESTB.AND.FNT.GT.0.0) THEN
        CCF=(5.0/FINT)*RELDEN +((FINT-5.0)/FINT)*ATCCF
        AVHT=(5.0/FINT)*AVH +((FINT-5.0)/FINT)*ATAVH
      ENDIF
C---------
C COMPUTE DENSITY MODIFIER FROM CCF AND TOP HEIGHT.
C---------
      X=AVHT*(CCF/100.0)
      IF(X .GT. 300.0) X=300.0
      PCTRED=AB(1)
     & + X*(AB(2) + X*(AB(3) + X*(AB(4) + X*(AB(5)+ X*AB(6)))))
      IF(PCTRED .GT. 1.0) PCTRED = 1.0
      IF(PCTRED .LT. 0.01) PCTRED = 0.01
      IF(DEBUG) WRITE(JOSTND,9982) AVHT,CCF,X,PCTRED
 9982 FORMAT('IN REGENT AVHT,CCF,X,PCTRED = ',4F10.4)
C----------
C  ENTER GROWTH PREDICTION LOOP.  PROCESS EACH SPECIES AS A GROUP;
C  LOAD CONSTANTS FOR NEXT SPECIES.
C----------
      DO 30 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 30
      I2=ISCT(ISPC,2)
      XRHGRO=XRHMLT(ISPC)
      XRDGRO=XRDMLT(ISPC)
      CON=RHCON(ISPC) * EXP(HCOR(ISPC))
      XMX=XMAX(ISPC)
      XMN=XMIN(ISPC)
      SI=SITEAR(ISPC)
      MSP=SMTMAP(ISPC)
      IF(ISPC.EQ.21 .OR. ISPC.EQ.41)THEN
        REGYR=10.
      ELSE
        REGYR=5.
      ENDIF
      SCALE=FNT/REGYR
      SCALE2=YR/FNT
C----------
C  PROCESS NEXT TREE RECORD.
C----------
      DO 25 I3=I1,I2
      I=IND1(I3)
      D=DBH(I)
      IF(D .GE. XMX) GO TO 25
C----------
C  BYPASS INCREMENT CALCULATIONS IF CALLED FROM ESTAB AND THIS IS NOT A
C  NEWLY CREATED TREE.
C----------
      IF(LESTB) THEN
        IF(I.LT.ITRNIN) GO TO 25
C----------
C  CALCULATE CROWN RATIO FOR NEWLY REGENERATED TREES.
C----------
        IPCCF=ITRE(I)
        CR = 0.89722 - 0.0000461*PCCF(IPCCF)
    1   CONTINUE
        RAN = BACHLO(0.0,1.0,RANN)
        IF(RAN .LT. -1.0 .OR. RAN .GT. 1.0) GO TO 1
        CR = CR + 0.07985 * RAN
        IF(CR .GT. .90) CR = .90
        IF(CR .LT. .20) CR = .20
        ICR(I)=INT((CR*100.0)+0.5)
      ENDIF
      K=I
      L=0
      CR=REAL(ICR(I))/10.
      BAL=((100.0-PCT(I))/100.0)*BA
      H=HT(I)
      BARK=BRATIO(ISPC,D,H)

      IF(LSKIPH) THEN
        HTG(K)=0.0
        GO TO 4
      ENDIF
C
      SELECT CASE (ISPC)
C----------
C  SPECIES USING EQUATIONS FROM THE SO VARIANT: 41=MC
C----------
      CASE(41)
        X=REAL(ICR(I))/100.
        VIGOR = (150.0 * (X**3.0)*EXP(-6.0*X))+0.3
        IF(VIGOR .GT. 1.0)VIGOR=1.0
        POTHTG = ((1.47043 + 0.23317*SI)/(31.56252 - 0.05586*SI))*10.
        HTGRR = POTHTG*PCTRED*VIGOR
        IF(DEBUG) WRITE(JOSTND,9981) I,X,VIGOR,POTHTG,PCTRED,HTGRR
 9981   FORMAT('IN REGENT I,X,VIGOR,POTHTG,PCTRED,HTGRR= ',I5,5F10.4)
C----------
C  SPECIES USING EQUATIONS FROM THE CR VARIANT (VIA UT): 21=GB
C----------
      CASE(21)
        X=REAL(ICR(I))/100.
        VIGOR = (150.0 * (X**3.0)*EXP(-6.0*X))+0.3
        IF(VIGOR .GT. 1.0)VIGOR=1.0
        VIGOR=1.-((1.-VIGOR)/3.)
        POTHTG = ((SI/5.0)*(SI*1.5-H)/(SI*1.5))* 0.83
        HTGRR = POTHTG*PCTRED*VIGOR
        IF(DEBUG) WRITE(JOSTND,9981) I,X,VIGOR,POTHTG,PCTRED,HTGRR
C----------
C  ALL OTHER SPECIES
C----------
      CASE DEFAULT
        CALL SMHTGF(ISPC,D,CR,BA,BAL,SI,H,JOSTND,DEBUG,HTGRR)

        IF(DEBUG)WRITE(JOSTND,*)'AFTER CALL SMHTGF MSP,D,CR,BA,BAL,SI,'
     &  ,'HTGRR =',MSP,D,CR,BA,BAL,SI,HTGRR
      END SELECT
C----------
C     RETURN HERE TO PROCESS NEXT TRIPLE.
C----------
    2 CONTINUE
      HTGR=HTGRR * CON
      IF(DEBUG) WRITE(JOSTND,9983) HTGR,HTGRR,CON
 9983 FORMAT('IN REGENT HTGR,HTGRR,CON = ',3F10.4)
    3 CONTINUE
      ZZRAN = 0.0
      IF(DGSD.GE.1.0) ZZRAN=BACHLO(0.0,1.0,RANN)
      IF((ZZRAN .GT. 0.5) .OR. (ZZRAN .LT. -2.0)) GO TO 3
      IF(DEBUG)WRITE(JOSTND,9984) HTGR,ZZRAN,XRHGRO,SCALE,WK4(I)
 9984 FORMAT('IN REGENT 9984 FORMAT',5(F10.4,2X))
C
      SELECT CASE (ISPC)
      CASE(21)
        HTGR = (HTGR +ZZRAN*0.2)*XRHGRO * SCALE * WK4(I)
      CASE DEFAULT
        HTGR = (HTGR +ZZRAN*0.1)*XRHGRO * SCALE
      END SELECT
C
C-------------
C     COMPUTE WEIGHTS FOR THE LARGE AND SMALL TREE HEIGHT INCREMENT
C     ESTIMATES.  IF DBH IS LESS THAN OR EQUAL TO XMN, THE LARGE TREE
C     PREDICTION IS IGNORED (XWT=0.0).
C----------
      XWT=(D-XMN)/(XMX-XMN)
      IF(D.LE.XMN .OR. LESTB) XWT = 0.0
C----------
C     COMPUTE WEIGHTED HEIGHT INCREMENT FOR NEXT TRIPLE.
C----------
      IF(DEBUG)WRITE(JOSTND,9985)XWT,HTGR,HTG(K),I,K
 9985 FORMAT('IN REGENT 9985 FORMAT',3(F10.4,2X),2I7)
      IF(ISPC .EQ. 4 .OR. ISPC .EQ. 23) THEN
        LTHG = HTG(K)
        IF(LESTB) THEN
          HTGR = HTGR
        ELSE
          HTGR = (HTGR + LTHG)/2.0
        ENDIF
        HTG(K)=HTGR*(1.0-XWT) + XWT*LTHG
        IF(DEBUG)WRITE(JOSTND,*)'IN REGENT - RW/GS DEBUG: ',' LESTB=',
     &    LESTB,' D=',D,' XWT=',XWT,' HTGR=',HTGR,' LTHG=',LTHG,
     &    ' HTG FINAL=', HTG(K)
      ELSE
        HTG(K)=HTGR*(1.0-XWT) + XWT*HTG(K)
      ENDIF
      IF(HTG(K) .LT. .1) HTG(K) = .1
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((H+HTG(K)).GT.SIZCAP(ISPC,4))THEN
        HTG(K)=SIZCAP(ISPC,4)-H
        IF(HTG(K) .LT. 0.1) HTG(K)=0.1
      ENDIF
C
    4 CONTINUE
C----------
C     ASSIGN DBH AND COMPUTE DBH INCREMENT FOR TREES WITH DBH LESS
C     THAN 3 INCHES (COMPUTE 10-YEAR DBH INCREMENT REGARDLESS OF
C     PROJECTION PERIOD LENGTH).
C----------
      IF(ISPC .EQ. 21)THEN
        BKPT = 99.0
      ELSE IF(ISPC .EQ. 4 .OR. ISPC .EQ. 23) THEN
        BKPT = 7.0
      ELSE
        BKPT = 3.0
      ENDIF
      IF(D .GE. BKPT) GO TO 23
      HK=H + HTG(K)
      IF(HK .LE. 4.5) THEN
        DG(K)=0.0
        DBH(K)=D+0.001*HK
      ELSE
C
        SELECT CASE (ISPC)
C----------
C  SPECIES USING EQUATIONS FROM THE CA VARIANT
C----------
        CASE(4,9:10,12,14:17,19:20,23,25:27)
          BX=HT2(ISPC)
          IF(IABFLG(ISPC).EQ.1) THEN
            AX=HT1(ISPC)
          ELSE
            AX=AA(ISPC)
          ENDIF
          DK=(BX/(ALOG(HK-4.5)-AX))-1.0
          IF(H .LE. 4.5) THEN
            DKK=D
          ELSE
            DKK=(BX/(ALOG(H-4.5)-AX))-1.0
          ENDIF
C----------
C  SPECIES USING EQUATIONS FROM THE SO VARIANT
C----------
        CASE(41)
          BX=HT2(ISPC)
          IF(IABFLG(ISPC).EQ.1) THEN
            AX=HT1(ISPC)
          ELSE
            AX=AA(ISPC)
          ENDIF
          DAT45 = 3.1020 + 0.0210*4.5
C
          DKK = 3.1020 + 0.0210*H
          IF(DKK .LT. 0.0) DKK=D
C
          DK = 3.1020 + 0.0210*HK
          IF(DK .LT. DKK) DK=DKK+.01
          IF(DEBUG)WRITE(JOSTND,*)'I,ISPC,DBH,H,HK,DK,DKK,= ',
     &    I,ISPC,DBH(I),H,HK,DK,DKK
C----------
C  SPECIES USING EQUATIONS FROM THE CR VARIANT, VIA UT
C----------
        CASE(21)
          DK=(HK-4.5)*10./(SITEAR(ISPC)-4.5)
          IF(DK .LT. 0.1) DK=0.1
          DKK=(H-4.5)*10./(SITEAR(ISPC)-4.5)
          IF(DKK .LT. 0.1) DKK=0.1
          IF(H .LT. 4.5) DKK=D
          IF(DEBUG)WRITE(JOSTND,*)'I,ISPC,DBH,H,HK,DK,DKK= ',
     &    I,ISPC,DBH(I),H,HK,DK,DKK
C----------
C  SPECIES USING EQUATIONS FROM THE WS VARIANT
C----------
        CASE DEFAULT
          IHDW=0
C
          SELECT CASE (MSP)
C----------
C   PINES
C----------
          CASE(1)
            AX= -0.6197
            BX= 0.2626
C----------
C   FIRS
C----------
          CASE(2)
            AX= -0.6096
            BX=  0.2433
C----------
C   BLACKOAK AND TANOAK
C   EQUATIONS FOR HDW FROM NC VARIANT BO
C----------
          CASE(3,4)
            AX=  4.80420
            BX=  -9.92422
            IHDW=1
C            
          END SELECT
C
          IF(IHDW .EQ. 0) THEN
            DK=AX + BX*HK
          ELSE
            DK=BX/(ALOG(HK-4.5)-AX)-1.0
          ENDIF
          IF(H .LE. 4.5) THEN
            DKK=D
          ELSE
            IF(IHDW.EQ.0)THEN
              DKK=AX + BX*H
            ELSE
              DKK=BX/(ALOG(H-4.5)-AX)-1.0
            ENDIF
          ENDIF
C
        END SELECT
C
        IF(DEBUG)WRITE(JOSTND,9986) AX,BX,ISPC,HK,BARK,
     &                              XRDGRO,DK,DKK
 9986   FORMAT('IN REGENT 9986 FORMAT AX,BX,ISPC,HK',
     &  ' BARK,XRDGRO,DK,DKK= ',/,T12, F10.3,2X,F10.3,2X,I5,2X,
     &  5F10.3)
C
        SELECT CASE (ISPC)
C----------
C  SPECIES USING EQUATIONS FROM THE CA AND SO VARIANTS
C  USE INVENTORY EQUATIONS IF CALIBRATION OF THE HT-DBH FUNCTION IS TURNED
C  OFF, OR IF WYKOFF CALIBRATION DID NOT OCCUR.
C  NOTE: THIS SIMPLIFIES TO IF(IABFLB(ISPC).EQ.1) BUT IS SHOWN IN IT'S
C        ENTIRITY FOR CLARITY.
C----------
        CASE(4,9:10,12,14:17,19:20,23,25:27,41)
          IF(.NOT.LHTDRG(ISPC) .OR. 
     &       (LHTDRG(ISPC) .AND. IABFLG(ISPC).EQ.1))THEN
            CALL HTDBH (IFOR,ISPC,DK,HK,1)
            IF(H .LE. 4.5) THEN
              DKK=D
            ELSE
              CALL HTDBH (IFOR,ISPC,DKK,H,1)
            ENDIF
            IF(DEBUG)WRITE(JOSTND,*)'INV EQN DUBBING IFOR,ISPC,H,HK,',
     &      'DK,DKK= ',IFOR,ISPC,H,HK,DK,DKK
            IF(DEBUG)WRITE(JOSTND,*)'ISPC,LHTDRG,IABFLG= ',
     &      ISPC,LHTDRG(ISPC),IABFLG(ISPC)
          ENDIF
C
        END SELECT
C----------
C       IF CALLED FROM **ESTAB** ASSIGN DIAMETER
C----------
        IF(LESTB) THEN
          SELECT CASE(ISPC)
C----------
C  SO VARIANT SPECIES (REALLY WC VARIANT)
C  ADJUST REGRESSION TO PASS THROUGH BUD WIDTH AT 4.5 FEET.
C----------
          CASE(41)
C----------
C  ADJUST REGRESSION TO PASS THROUGH BUD WIDTH AT 4.5 FEET.
C----------
            IF(DAT45.GT.0.0 .AND. HK.GE.4.5 .AND. LHTDRG(ISPC) .AND.
     &         IABFLG(ISPC).EQ.0) THEN
             DBH(K)=DK - DAT45 + DIAM(ISPC)
            ELSE
              DBH(K)=DK
            ENDIF
          CASE DEFAULT
            DBH(K)=DK
          END SELECT
C
          IF(DBH(K).LT.DIAM(ISPC) .OR. HK.LT.4.5) DBH(K)=DIAM(ISPC)
          DBH(K)=DBH(K)+0.001*HK
          DG(K)=DBH(K)
        ELSE
C
          SELECT CASE (ISPC)
C----------
C  FROM UT (ORIGINALLY FROM CR)
C----------
          CASE(21)
            DGMX = 2.0 * SCALE
            IF(DK.LT.0.0 .OR. DKK.LT.0.0)THEN
              DG(K)=HTG(K)*0.2*BARK*XRDGRO
              DK=D+DG(K)
            ELSE
              DG(K)=(DK-DKK)*BARK*XRDGRO
            ENDIF
            IF(DEBUG)WRITE(JOSTND,*)'K,D,DK,DKK,DG= ',K,D,DK,DKK,DG(K)
            IF(DG(K) .LT. 0.0) DG(K)=0.0
            IF (DG(K) .GT. DGMX) DG(K)=DGMX
            DDS = DG(K)*(2.0*BARK*D + DG(K))*SCALE2
            DG(K) = SQRT((D*BARK)**2.0 + DDS) - BARK*D
            IF(DEBUG)WRITE(JOSTND,*)'K,DG= ',K,DG(K)
C----------
C  FROM SO (ORIGINALLY FROM WC)
C  COMPUTE DIAMETER INCREMENT BY SUBTRACTION, APPLY USER
C  SUPPLIED MULTIPLIERS, AND CHECK TO SEE IF COMPUTED VALUE
C  IS WITHIN BOUNDS.
C
C IF THE TREE JUST REACHED 4.5 FEET, SET DKK TO PRESENT DBH.
C RJ 12/6/91
C PROBLEM WITH HARDWOOD EQN, REDUCES TO .021*HG. SET TO RULE
C OF THUMB VALUE .1*HG FOR NOW. DIXON 11-04-92
C DON'T USE R.O.T. IF USING INVENTORY EQNS.  DIXON 03-31-98
C----------
          CASE(41)
            IF(H .LT. 4.5 )DKK = D
            BARK=BRATIO(ISPC,D,H)
            DGMX = 5.0 * SCALE
            IF(DEBUG)WRITE(JOSTND,*)'BARK,XRDGRO,DGMX= ',
     &       BARK,XRDGRO,DGMX
C
            IF(DK.LT.0.0 .OR. DKK.LT.0.0)THEN
              DG(K)=HTG(K)*0.2*BARK*XRDGRO
              DK=D+DG(K)
            ELSE
              DG(K)=(DK-DKK)*BARK*XRDGRO
            ENDIF
            IF(DEBUG)WRITE(JOSTND,*)'K,DK,DKK,DG,BARK,XRDGRO= ',
     &       K,DK,DKK,DG(K),BARK,XRDGRO
            IF(LHTDRG(ISPC) .AND. IABFLG(ISPC).EQ.0) 
     &         DG(K)=0.1*HTG(K)*XRDGRO
            IF(DG(K) .LT. 0.0) DG(K)=0.1
            IF (DG(K) .GT. DGMX) DG(K)=DGMX
            IF(DEBUG)WRITE(JOSTND,*)'HARDWOOD EQU DG(K),DGMX,LHTDRG= '
            IF(DEBUG)WRITE(JOSTND,*)DG(K),DGMX,LHTDRG(ISPC)
C
          CASE DEFAULT
C----------
C         COMPUTE DIAMETER INCREMENT BY SUBTRACTION, APPLY USER
C         SUPPLIED MULTIPLIERS, AND CHECK TO SEE IF COMPUTED VALUE
C         IS WITHIN BOUNDS.  FOR SPECIES FROM THE CA AND WS VARIANTS,
C         THE INCREMENT FOR TREES BETWEEN 1.5 AND 3 INCHES DBH IS A 
C         WEIGHTED AVERAGE OF PREDICTIONS FROM THE LARGE AND SMALL 
C         TREE MODELS. SCALE ADJUSTMENT IS ON GROWTH IN DDS TERMS RATHER 
C         THAN INCHES OF DG TO MAINTAIN CONSISTENCY WITH GRADD.
C         
C         NOTE: LARGE TREE DG IS ON A 10-YR BASIS; SMALL TREE DG IS ON A 
C         FINT-YR BASIS. CONVERT SMALL TREE DG TO A 10-YR BASIS BEFORE
C         WEIGHTING. DG GETS CONVERTED BACK TO A FINT-YR BASIS IN **GRADD**.
C----------
            IF(ISPC.EQ.4 .OR. ISPC.EQ.23) THEN
              XDWT=(D-XMN)/(BKPT-XMN)
              IF(D.LE.XMN) XDWT=0.0
            ELSE
              XDWT=(D-1.5)/1.5
              IF(D.LE.1.5) XDWT=0.0
              IF(D.GE.3.0) XDWT=1.0
            ENDIF
            DGSM=(DK-DKK)*BARK*XRDGRO
            IF(DGSM .LT. 0.0) DGSM=0.0
            DDS=DGSM*(2.0*BARK*D+DGSM)*SCALE2
            DGSM=SQRT((D*BARK)**2.0+DDS)-BARK*D
            IF(DGSM.LT.0.0) DGSM=0.0
            DGLT=DG(K)
            DG(K)=DGSM*(1.0-XDWT)+DGLT*XDWT
            IF(DEBUG)WRITE(JOSTND,*)'IN REGENT',' ISPC=',ISPC,' D=',D,
     &      ' XDWT=',XDWT,' DKK=', DKK,' DK=',DK,' BARK=', BARK,
     &      ' DGSM=',DGSM,' DGLT=', DGLT,' DGSM FINAL=',DG(K)
          END SELECT
        ENDIF
        IF((DBH(K)+DG(K)).LT.DIAM(ISPC))THEN
          DG(K)=DIAM(ISPC)-DBH(K)
        ENDIF
      ENDIF
C----------
C  CHECK FOR TREE SIZE CAP COMPLIANCE
C----------
      CALL DGBND(ISPC,DBH(K),DG(K))
C
   23 CONTINUE
C----------
C  RETURN TO PROCESS NEXT TRIPLE IF TRIPLING.  OTHERWISE,
C  PRINT DEBUG AND RETURN TO PROCESS NEXT TREE.
C----------
      IF(LESTB .OR. .NOT.LTRIP .OR. L.GE.2) GO TO 22
      L=L+1
      K=ITRN+2*I-2+L
      GO TO 2
C----------
C  END OF GROWTH PREDICTION LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
   22 CONTINUE
      IF(DEBUG)THEN
      HTNEW=HT(I)+HTG(I)
      WRITE(JOSTND,9987) I,ISPC,HT(I),HTG(I),HTNEW,DBH(I),DG(I)
 9987 FORMAT('IN REGENT, I=',I4,',  ISPC=',I3,'  CUR HT=',F7.2,
     &       ',  HT INC=',F7.4,',  NEW HT=',F7.2,',  CUR DBH=',F10.5,
     &       ',  DBH INC=',F7.4)
      ENDIF
   25 CONTINUE
   30 CONTINUE
      GO TO 91
C
C
C----------
C  SMALL TREE HEIGHT CALIBRATION SECTION.
C----------
   40 CONTINUE
      DO 45 ISPC=1,MAXSP
      HCOR(ISPC)=0.0
      CORTEM(ISPC)=1.0
      NUMCAL(ISPC)=0
   45 CONTINUE
      IF (ITRN.LE.0) GO TO 91
      IF(IFINTH .EQ. 0)  GOTO 95
C---------
C COMPUTE DENSITY MODIFIER FROM CCF AND TOP HEIGHT.
C THIS IS NEEDED FOR SPECIES USING EQUATIONS FROM THE SO VARIANT (42=MC)
C---------
      X=AVH*(RELDEN/100.0)
      IF(X .GT. 300.0) X=300.0
      PCTRED=AB(1)
     & + X*(AB(2) + X*(AB(3) + X*(AB(4) + X*(AB(5)+ X*AB(6)))))
      IF(PCTRED .GT. 1.0) PCTRED = 1.0
      IF(PCTRED .LT. 0.01) PCTRED = 0.01
      IF(DEBUG)WRITE(JOSTND,9988)AVH,RELDEN,X,PCTRED
 9988 FORMAT('IN REGENT AVH,RELDEN,X,PCTRED = ',4F10.4)
C----------
C  BEGIN PROCESSING TREE LIST IN SPECIES ORDER.  DO NOT CALCULATE
C  CORRECTION TERMS IF THERE ARE NO TREES FOR THIS SPECIES.
C----------
      DO 100 ISPC=1,MAXSP
      CORNEW=1.0
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0 .OR. .NOT. LHTCAL(ISPC)) GO TO 100
      N=0
      SNP=0.0
      SNX=0.0
      SNY=0.0
      I2=ISCT(ISPC,2)
      IREFI=IREF(ISPC)
      SI=SITEAR(ISPC)
      MSP=SMTMAP(ISPC)
      IF(ISPC.EQ.21 .OR. ISPC.EQ.41)THEN
        REGYR=10.
      ELSE
        REGYR=5.
      ENDIF
      SCALE3 = REGYR / FINTH
C----------
C  BEGIN TREE LOOP WITHIN SPECIES.  IF MEASURED HEIGHT INCREMENT IS
C  LESS THAN OR EQUAL TO ZERO, OR DBH IS LESS THAN 5.0, THE RECORD
C  WILL BE EXCLUDED FROM THE CALIBRATION.
C----------
      DO 60 I3=I1,I2
      I=IND1(I3)
      D=DBH(I)
      H=HT(I)
      BAL=((100.0-PCT(I))/100.0)*BA
      CR=REAL(ICR(I))/10.0
C----------
C  DIA GT 3 INCHES INCLUDED IN OVERALL MEAN
C----------
      IF(IHTG.LT.2) H=H-HTG(I)
      IF(DBH(I).GE.5.0.OR.H.LT.0.01) GO TO 60
C----------
C  COMPUTE VIGOR MODIFIER FROM CROWN RATIO.
C----------
      X=REAL(ICR(I))/100.
      VIGOR = (150.0 * (X**3.0)*EXP(-6.0*X))+0.3
      IF(VIGOR .GT. 1.0)VIGOR=1.0
      VIGOR=1.-((1.-VIGOR)/3.)
C
      SELECT CASE (ISPC)
C----------
C  SPECIES USING EQUATIONS FROM THE SO VARIANT: 41=MC
C----------
      CASE(41)
        X=REAL(ICR(I))/100.
        VIGOR = (150.0 * (X**3.0)*EXP(-6.0*X))+0.3
        IF(VIGOR .GT. 1.0)VIGOR=1.0
        POTHTG = ((1.47043 + 0.23317*SI)/(31.56252 - 0.05586*SI))*10.
        EDH = POTHTG*PCTRED*VIGOR
        IF(DEBUG) WRITE(JOSTND,9989) I,X,VIGOR,POTHTG,PCTRED,EDH
 9989   FORMAT('IN REGENT I,X,VIGOR,POTHTG,PCTRED,EDH= ',I5,5F10.4)
C----------
C  SPECIES USING EQUATIONS FROM THE CR VARIANT (VIA UT): 21=GB
C----------
      CASE(21)
        POTHTG = ((SI/5.0)*(SI*1.5-H)/(SI*1.5))* 0.83
        EDH=POTHTG*PCTRED*VIGOR
C----------
C  ALL OTHER SPECIES
C----------
      CASE DEFAULT
        CALL SMHTGF(ISPC,D,CR,BA,BAL,SI,H,JOSTND,DEBUG,EDH)
        IF(DEBUG)WRITE(JOSTND,*)'AFTER CALL SMHTGF MSP,D,CR,BA,BAL,',
     &  'SI,EDH =',MSP,D,CR,BA,BAL,SI,EDH
C
      END SELECT
C
      EDH=EDH*RHCON(ISPC)
      IF(DEBUG)WRITE(JOSTND,9990) I,ISPC,EDH,RHCON(ISPC)
 9990 FORMAT('IN REGENT I,ISPC,EDH,RHCON = ',2I5,2F10.4)
      P=PROB(I)
      IF(HTG(I).LT.0.001) GO TO 60
      TERM=HTG(I) * SCALE3
      SNP=SNP+P
      SNX=SNX+EDH*P
      SNY=SNY+TERM*P
      N=N+1
C----------
C  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG)WRITE(JOSTND,9991) NPLT,I,ISPC,H,DBH(I),ICR(I),
     & PCT(I),RELDM1,RHCON(ISPC),EDH,TERM
 9991 FORMAT('NPLT=',A26,',  I=',I5,',  ISPC=',I3,',  H=',F6.1,
     & ',  DBH=',F5.1,',  ICR',I5,',  PCT=',F6.1,',  RELDEN=',
     & F6.1 / 12X,'RHCON=',F10.3,',  EDH=',F10.3,', TERM=',F10.3)
C----------
C  END OF TREE LOOP WITHIN SPECIES.
C----------
   60 CONTINUE
      IF(DEBUG) WRITE(JOSTND,9992) ISPC,SNP,SNX,SNY
 9992 FORMAT(/'SUMS FOR SPECIES ',I2,':  SNP=',F10.2,
     & ';  SNX=',F10.2,';  SNY=',F10.2)
C----------
C  COMPUTE CALIBRATION TERMS.  CALIBRATION TERMS ARE NOT COMPUTED
C  IF THERE WERE FEWER THAN NCALHT (DEFAULT=5) HEIGHT INCREMENT
C  OBSERVATIONS FOR A SPECIES.
C----------
      IF(N.LT.NCALHT) GO TO 80
C----------
C  CALCULATE MEANS FOR THE POPULATION AND FOR THE SAMPLE ON THE
C  NATURAL SCALE.
C----------
      SNX=SNX/SNP
      SNY=SNY/SNP
C----------
C  CALCULATE RATIO ESTIMATOR.
C----------
      CORNEW = SNY/SNX
      IF(CORNEW.LE.0.0) CORNEW=1.0E-4
      HCOR(ISPC)=ALOG(CORNEW)
C----------
C  TRAP CALIBRATION VALUES OUTSIDE 2.5 STANDARD DEVIATIONS FROM THE 
C  MEAN. IF C IS THE CALIBRATION TERM, WITH A DEFAULT OF 1.0, THEN
C  LN(C) HAS A MEAN OF 0.  -2.5 < LN(C) < 2.5 IMPLIES 
C  0.0821 < C < 12.1825
C----------
      IF(CORNEW.LT.0.0821 .OR. CORNEW.GT.12.1825) THEN
        CALL ERRGRO(.TRUE.,27)
        WRITE(JOSTND,9194)ISPC,JSP(ISPC),CORNEW
 9194   FORMAT(T28,'SMALL TREE HTG: SPECIES = ',I2,' (',A3,
     &  ') CALCULATED CALIBRATION VALUE = ',F8.2)
        CORNEW=1.0
        HCOR(ISPC)=0.0
      ENDIF
   80 CONTINUE
      CORTEM(IREFI) = CORNEW
      NUMCAL(IREFI) = N
  100 CONTINUE
C----------
C  END OF CALIBRATION LOOP.  PRINT CALIBRATION STATISTICS AND RETURN
C----------
      WRITE(JOSTND,9993) (NUMCAL(I),I=1,NUMSP)
 9993 FORMAT(/'NUMBER OF RECORDS AVAILABLE FOR SCALING'/
     >       'THE SMALL TREE HEIGHT INCREMENT MODEL',
     >        ((T48,11(I4,2X)/)))
   95 CONTINUE
      WRITE(JOSTND,9994) (CORTEM(I),I=1,NUMSP)
 9994 FORMAT(/'INITIAL SCALE FACTORS FOR THE SMALL TREE'/
     >      'HEIGHT INCREMENT MODEL',
     >       ((T48,11(F5.2,1X)/)))
C----------
C OUTPUT CALIBRATION TO DATABASE.
C----------
      CALL DBSCALIB(2,CORTEM,NUMCAL,CORTEM) ! LAST ARG IGNORED
C----------
C OUTPUT CALIBRATION TERMS IF CALBSTAT KEYWORD WAS PRESENT.
C----------
      IF(JOCALB .GT. 0) THEN
        KOUT=0
        DO 207 K=1,MAXSP
        IF(CORTEM(K).NE.1.0 .OR. NUMCAL(K).GE.NCALHT) THEN
          SPEC=NSP(MAXSP,1)(1:2)
          ISPEC=MAXSP
          DO 203 KK=1,MAXSP
          IF(K .NE. IREF(KK)) GO TO 203
          ISPEC=KK
          SPEC=NSP(KK,1)(1:2)
          GO TO 2031
  203     CONTINUE
 2031     WRITE(JOCALB,204)ISPEC,SPEC,NUMCAL(K),CORTEM(K)
  204     FORMAT(' CAL: SH',1X,I2,1X,A2,1X,I4,1X,F6.3)
          KOUT = KOUT + 1
        ENDIF
  207   CONTINUE
        IF(KOUT .EQ. 0)WRITE(JOCALB,209)
  209   FORMAT(' NO SH VALUES COMPUTED')
        WRITE(JOCALB,210)
  210   FORMAT(' CALBSTAT END')
      ENDIF
   91 IF(DEBUG)WRITE(JOSTND,9995)ICYC
 9995 FORMAT('LEAVING SUBROUTINE REGENT  CYCLE =',I5)
      RETURN
C
C
      ENTRY REGCON
C----------
C  ENTRY POINT FOR LOADING OF REGENERATION GROWTH MODEL
C  CONSTANTS  THAT REQUIRE ONE-TIME RESOLUTION.
C---------
      DO 90 ISPC=1,MAXSP
      RHCON(ISPC) = 1.0
      IF(LRCOR2.AND.RCOR2(ISPC).GT.0.0) RHCON(ISPC)=RCOR2(ISPC)
   90 CONTINUE
C
      DO I=1,MAXTRE
      ZRAND(I)=-999.0
      ENDDO
C
      RETURN
      END
