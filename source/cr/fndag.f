      SUBROUTINE FNDAG(I,TAGE,SITE,RHT,BAUTBA,ISPC,DEBUG)
      IMPLICIT NONE
C----------
C CR $Id: fndag.f 2444 2018-07-09 16:00:55Z gedixon $
C----------
C
C THIS ROUTINE USES THE LOGIC FROM GENGYM THAT CALCULATES A HEIGHT
C GIVEN A SITE TO FIND AN EFFECTIVE AGE.
C EVEN-AGED LOGIC FROM GEMHT                      
C----------
C  COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C  COMMONS
C----------
      LOGICAL DEBUG
      REAL BAUTBA,RHT,SITE,TAGE,AGETEM,TOL,AP,AGEMAX,HG,HL
      REAL HH,RATIO,HTMAX,CCFTEM,DIFF,TSITE
      INTEGER ISPC,I
C----------
C  SPECIES ORDER:
C   1=AF,  2=CB,  3=DF,  4=GF,  5=WF,  6=MH,  7=RC,  8=WL,  9=BC, 10=LM,
C  11=LP, 12=PI, 13=PP, 14=WB, 15=SW, 16=UJ, 17=BS, 18=ES, 19=WS, 20=AS,
C  21=NC, 22=PW, 23=GO, 24=AW, 25=EM, 26=BK, 27=SO, 28=PB, 29=AJ, 30=RM,
C  31=OJ, 32=ER, 33=PM, 34=PD, 35=AZ, 36=CI, 37=OS, 38=OH
C
C  SPECIES EXPANSION:
C  UJ,AJ,RM,OJ,ER USE CR JU                              
C  NC,PW USE CR CO
C  GO,AW,EM,BK,SO USE CR OA                             
C  PB USES CR AS                              
C  PM,PD,AZ USE CR PI
C  CI USES CR PP                              
C----------
C  USE SHEPPARDS EQN FOR ASPEN AND SURROGATE SPECIES.
C  ALL MODEL TYPES: WB, AS, PB, OH
C  ALSO FOR MODEL TYPE 3: NC, PW, UJ, AJ, RM, OJ, ER, OS
C----------
      IF(ISPC.EQ.20 .OR. ISPC.EQ.28 .OR. ISPC.EQ.38 .OR.
     &   ISPC.EQ.14) GO TO 50
      IF(IMODTY.EQ.3 .AND. (ISPC.EQ.21 .OR. ISPC.EQ.22 .OR.
     &   ISPC.EQ.16 .OR. (ISPC.GE.29 .AND. ISPC.LE.32) .OR.
     &   ISPC.EQ.37)) GO TO 50 
C
      GO TO 90
C
C THIS IS A BREAST HIGH AGE CURVE, ADJUST TO TOTAL AGE
C
   50 CONTINUE
      AGETEM = (RHT*12.0*2.54/26.9825)**0.8509
      AGETEM=AGETEM+(4.5/(0.1+SITE/50.))
      TAGE = AGETEM
      GO TO 9995
C
   90 CONTINUE
      TOL = 2.0
      AP = 10.0
C
      AGEMAX = 210.
      IF(IMODTY .EQ. 3) AGEMAX = 165.
      IF(IMODTY .EQ. 5) AGEMAX = 200.
C
  100 CONTINUE
      AGETEM = AP
C
      GO TO (1000,2000,3000,4000,5000,6000,6000,6000), IMODTY
C----------
C SOUTHWESTERN MIXED CONIFER  --- MODEL TYPE 1
C----------
 1000 CONTINUE
C     IF(SITE .LT. 80.0) AGETEM = AMAX1(AGETEM,(110.0 - SITE))
      IF(AGETEM .GT. AGEMAX) AGETEM = AGEMAX
      IF(DEBUG)WRITE(JOSTND,*)' IN FNDAG1 I,SITE,RHT,BAUTBA,ISPC,',
     &'AGETEM= ',I,SITE,RHT,BAUTBA,ISPC,AGETEM
      HG=109.559129*(1.0-0.975884*EXP(-0.014377*AGETEM))**1.289266
     1      + 4.5
      HL= 72.512644*(1.0-0.876961*EXP(-0.020066*AGETEM))**2.016632
      HH = -((HG - HL) * ((82.488 - SITE) / 26.279)) + HG
C     IF(SITE .LT. 80.0) THEN
C       IF(AP .LT. AGETEM) HH = ((HH - 4.5) / AGETEM) * AP + 4.5
C     ELSE
C       IF(AP .LT. 20.0) HH = (0.02348 * SITE - 0.93429) * AP + 4.5
C     ENDIF
      RATIO = 1.0 - BAUTBA
      IF(RATIO .LT. 0.768) RATIO = 0.768
      HH = HH * RATIO
      GO TO 9900
C----------
C SOUTHWESTERN PONDEROSA PINE -- MODEL TYPE 2
C----------
 2000 CONTINUE
C     IF(SITE .LT. 80.0) AGETEM = AMAX1(AGETEM,(120.0 - SITE))
      IF(AGETEM .GT. AGEMAX) AGETEM = AGEMAX
      IF(DEBUG)WRITE(JOSTND,*)' IN FNDAG2 I,SITE,RHT,BAUTBA,ISPC,',
     &'AGETEM= ',I,SITE,RHT,BAUTBA,ISPC,AGETEM
      HG=106.493954*(1.0-0.938775*EXP(-0.016066*AGETEM))**1.550720
     1   + 4.5
      HL= 78.078735*(1.0-0.843715*EXP(-0.020412*AGETEM))**2.280435
      HH = -((HG - HL) * ((81.5585 - SITE) / 21.7149)) + HG
C     IF(SITE .LT. 80.0) THEN
C       IF(AP .LT. AGETEM) HH = ((HH - 4.5) / AGETEM) * AP + 4.5
C     ELSE
C       IF(AP .LT. 20.0) HH = (0.02463 * SITE - 1.1025) * AP + 4.5
C     ENDIF
      RATIO = 1.0 - BAUTBA
      IF(RATIO .LT. 0.768) RATIO = 0.768
      HH = HH * RATIO
      GO TO 9900
C----------
C BLACK HILLS PONDEROSA PINE -- MODEL TYPE 3
C----------
 3000 CONTINUE
C
C CARL'S AMAX FUNCTION BLOWS UP AT AGE 180. THE CONSTANT
C 1.2999886 IS CARL'S FUNCTION EVALUATED AT AGE 179.
C SITE CURVES FLATTEN OFF AT AGE 180.
C
      HTMAX = (SITE + 0.3846) * 1.2999886
      IF(RHT .GE. HTMAX) THEN
        TAGE = 165.
        GO TO 9995
      ENDIF
C
      HH = (SITE + 0.3846) * (-0.5234 + 1.8234 *
     & EXP(-(1.0989 - 0.006105 * AGETEM) ** 2.35))
      RATIO = 1.0 - BAUTBA
      IF(RATIO .LT. 0.793) RATIO = 0.793
      HH = HH * RATIO
      GO TO 9900
C----------
C SPRUCE-FIR -- MODEL TYPE 4
C----------
 4000 CONTINUE
      IF(AGETEM .LT. 30.0) AGETEM=30.
      HH = (2.75780*SITE**0.83312) * ((1.0-EXP(-0.015701*AGETEM))
     &      **(22.71944*SITE**(-0.63557))) + 4.5
C     IF(AP .LT. AGETEM) HH = ((HH-4.5) / AGETEM) * AP + 4.5
      RATIO = 1.0 - BAUTBA
      IF(RATIO .LT. 0.728) RATIO = 0.728
      HH = HH * RATIO
      GO TO 9900
C----------
C LODGEPOLE PINE -- MODEL TYPE 5
C----------
 5000 CONTINUE
      IF(AGETEM .LT. 30.0) AGETEM = 30.
      CCFTEM = RELDEN - 125.0
      IF(CCFTEM .LT. 0.0) CCFTEM = 0.0
      HH = 9.89331 - 0.19177*AGETEM + 0.00124*AGETEM*AGETEM
     &   - 0.00082*CCFTEM*SITE + 0.01387*AGETEM*SITE
     &   - 0.0000455*AGETEM*AGETEM*SITE
C     IF(AP .LE. 30.0) HH = (HH / AGETEM) * AP
      RATIO = 1.0 - BAUTBA
      IF(RATIO .LT. 0.742) RATIO = 0.742
      HH = HH * RATIO
      GO TO 9900
C----------
C SPACE FOR FUTURE MODEL TYPES INCLUDING ASPEN.
C----------
 6000 CONTINUE
      GO TO 1000
C
 9900 CONTINUE
      DIFF = ABS(HH - RHT)
      IF(DIFF .LT. TOL) GO TO 9990
      IF(HH .GT. RHT) GO TO 9990
      AP = AP + 5.0
      IF(AP .GT. AGEMAX)THEN
        TAGE  = AGEMAX
        GO TO 9995
      END IF
      GO TO 100
 9990 CONTINUE
      TAGE = AGETEM
C----------
C CURVES FOR MODEL TYPES 1,2, & 4 ARE BREAST HEIGHT AGE CURVES. ADD AGE
C TO BREAST HEIGHT TO CALCULATED AGE TO GET TOTAL AGE.
C----------
      IF(IMODTY.EQ.1)THEN
        TSITE=SITE
        IF(TSITE.LT.30.)TSITE=30.
        TAGE=TAGE+4.5/(-0.642+0.02285*TSITE)
      ELSEIF(IMODTY.EQ.2)THEN
        TAGE=TAGE+4.5/(0.25+0.00467*SITE)
      ELSEIF(IMODTY.EQ.4)THEN
        TSITE=SITE
        IF(TSITE.LT.20.)TSITE=20.
        TAGE=TAGE+4.5/(-0.22+0.0155*TSITE)
      ENDIF
 9995 CONTINUE
      RETURN
      END
