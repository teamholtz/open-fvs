      SUBROUTINE HTGF
      IMPLICIT NONE
C----------
C NC $Id: htgf.f 3758 2021-08-25 22:42:32Z lancedavid $
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
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'VARCOM.F77'
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER I,ISPC,I1,I2,I3,ITFN
      REAL AGP05,HGUESS,SCALE,P1,P2,P3,P4,SINDX,XHT,H,POTHTG
      REAL XMOD,RELHT,CR,TEMHTG
      REAL HD1(MAXSP),HD2(MAXSP),HD3(MAXSP),HD4(MAXSP)
      REAL D1,D2,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2
      REAL MISHGF,PBAL,LTHTG,CRATIO,DGLT
      REAL BRAT,BRATIO,DG10,HGBND
C----------
C  DATA STATEMENTS
C----------
      DATA HD1/4*0.0,4.4666 ,0.0, 4.80758, 4.9684, 0.0,0.0,4.9684,
     &         0.0/

      DATA HD2/4*0.0,-0.00179,0.0,-0.00224,-0.004057,2*0.0,-0.004057,
     &         0.0/

      DATA HD3/4*0.0,0.002048,0.0,-0.000513,0.000924,2*0.0,0.000924,
     &         0.0/

      DATA HD4/4*0.0,-7.9428,0.0,-7.729644,-10.45158,2*0.0,-10.45158,
     &         0.0/
C----------
C   MODEL COEFFICIENTS AND CONSTANTS:
C
C    IND2 -- ARRAY OF POINTERS TO SMALL TREES.
C
C   SCALE -- TIME FACTOR DERIVED BY DIVIDING FIXED POINT CYCLE
C            LENGTH BY GROWTH PERIOD LENGTH FOR DATA FROM
C            WHICH MODELS WERE DEVELOPED.
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE HTGF  CYCLE =',I5)
      IF(DEBUG)WRITE(JOSTND,*) 'IN HTGF AT BEGINNING,HTCON=',
     *HTCON,'RMAI=',RMAI,'ELEV=',ELEV
C
      AGP05=0.0
      SCALE=FINT/YR
C----------
C  GET THE HEIGHT GROWTH MULTIPLIERS.
C----------
      CALL MULTS (2,IY(ICYC),XHMULT)
C----------
C   BEGIN SPECIES LOOP. LOAD BETA COEFFICIENTS.
C----------
      DO 4000 ISPC=1,MAXSP
C----------
C FOLLOWING ARE COEFS FOR THE HT DIA BASED HTG FCN
C----------
      P1 = HD1(ISPC)
      P2 = HD2(ISPC)
      P3 = HD3(ISPC)
      P4 = HD4(ISPC)
      SINDX = SITEAR(ISPC)
      XHT=1.0
      XHT=XHMULT(ISPC)
C
      IF(DEBUG)WRITE(JOSTND,*)'HTDIACOF',ISPC,P1,P2,P3,P4
C----------
C END OF BETS COEFS
C----------
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 4000
      I2 = ISCT(ISPC,2)
C-----------
C   BEGIN TREE LOOP WITHIN SPECIES LOOP
C-----------
      DO 3000 I3=I1,I2
      I=IND1(I3)
      HTG(I)=0.
      IF(PROB(I) .LE. 0.0)GO TO 2600
      H=HT(I)
C
      HGUESS=0.0
      SITAGE = 0.0
      SITHT = 0.0
      AGMAX = 0.0
      HTMAX = 0.0
      HTMAX2 = 0.0
      D1 = DBH(I)
      D2 = 0.0
      DGLT=DG(I)
      CRATIO=ICR(I)
      PBAL=PTBAA(ITRE(I))*(1.0-(PCT(I)/100.))

C BEGIN PROCESSING SPECIES
C DETERMINE HTG CALCULATION METHOD BASED ON SPECIES
      SELECT CASE(ISPC)

C BRANCH FOR RW
        CASE(12)

C--------
C  CALCULATE HTG FOR REDWOOD USING THE FOLLOWING FUNCTIONAL FORM
C
C  HI = EXP(X)
C  X = B1 + D1^2 + LOG(D1) + LOG(SI) + LOG(DGLT) + LOG(H)
C
C  WHERE
C  HI = ANNUAL HEIGHT INCREMENT
C  D1 = DIAMETER AT BREAST HEIGHT
C  SI = SITE INDEX (BASE AGE 50)
C  DGLT = 10-YEAR OUTSIDE BARK DIAMETER GROWTH
C  H = TOTAL TREE HEIGHT
C--------

C SCALE DGLT TO 10 YEAR DIAMETER GROWTH
          DGLT = DGLT * 2.0

C CONVERT DGLT TO OUTSIDE BARK DIAMETER GROWTH
          BRAT = BRATIO(ISPC,D1,H)
          DG10 = DGLT/BRAT

C APPLY CONSTRAINTS IF H OF INCOMING TREE IS LESS THAN 4.5 FT
C HERE DG10 IS ASSUMED TO BE 0.1
          IF(H .LT. 4.5) DG10=0.1

          IF(DEBUG)WRITE(JOSTND,*)' IN HTGF - RW DEBUG',' I=',I,
     &    ' ISPC=',ISPC,' D=',D1,' BRAT=',BRAT,' DGLT=', DGLT,
     &    ' DG10=',DG10

          LTHTG=EXP(1.412947 - 0.000204*D1**2 + 0.31971*LOG(D1) +
     &    0.394005*LOG(SINDX) + 0.399888*LOG(DG10) - 0.451708*LOG(H))

C SCALE LTHTG TO 5 YEARS
          LTHTG =LTHTG * 0.5

C BOUND HEIGHT GROWTH BASED ON THE HEIGHT OF RECORD. BOUNDING IS
C APPLIED TO AVOID HAVING TREES REACH UNREALISTIC HEIGHTS.THE HEIGHT
C GROWTH BOUNDING FUNCTION PROPORTIONALLY ADJUSTS HEIGHT GROWTH VALUES
C SO HEIGHTS OF A RECORD WILL EVENTUALLY CONVERGE TO THE UPPER HEIGHT
C BOUNDING VALUE. LOWER BOUNDING VALUE (217 FT) IS BASED ON MAXIMUM TREE
C HEIGHT FOUND IN THE DATASET USED TO FIT THE RW HEIGHT GROWTH EQUATION.
C UPPER BOUNDING VALUE FOUND IN THE DATASET IS BASED ON CURRENT HEIGHT
C MAXIMUM FOUND IN NATURE: HYPERION REDWOOD (~380 FT).
C 
C BOUNDING LOGIC:
C 1) IF HT IS BETWEEN 217 FT AND 380 FT, THEN HEIGHT GROWTH IS
C    BOUND.
C 2) IF THE HT IS BELOW 217 FT THEN HEIGHT GROWTH IS NOT
C    BOUND.
C 3) IF THE HT IS ABOVE 380 FT, THEN HEIGHT GROWTH BOUNDING
C    VALUE IS SET TO 0.1.
          IF(H .GE. 217.0 .AND. H .LT. 380.0) THEN
            HGBND= 1.0 - ((H - 217.0)/(380.0 - 217.0))
            IF(HGBND .LT. 0.1) HGBND=0.1
          ELSEIF (H .LT. 217.0) THEN
            HGBND=1.0
          ELSE
            HGBND=0.1
          ENDIF

          IF(DEBUG)WRITE(JOSTND,*)'IN HTGF - RW DEBUG',' H=',H,
     &    ' HGBND=',HGBND,' LTHTG=',LTHTG

          HTG(I)=LTHTG * HGBND

C DEBUG
          IF(DEBUG)WRITE(JOSTND,*)'IN HTGF - RW DEBUG',' D=', D1,
     &    ' H=',H,' SI=',SINDX, ' DG10=', DG10,' HTG5YR=',HTG(I)

C  BEGIN PROCESSING OF ALL OTHER SPECIES IN NC
        CASE DEFAULT
          IF(DEBUG)WRITE(JOSTND,*)' IN HTGF, CALLING FINDAG I= ',I
          CALL FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,
     &                DEBUG)
C----------
C   CALCULATE THE HTG VIA SITE AND MODIFER TECHNIQUE
C----------
          IF(H .GE. HTMAX)THEN
            HTG(I)=0.1
            HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
            GO TO 2600
          END IF
C----------
C  NORMAL HEIGHT INCREMENT CALCULATON BASED ON TREE AGE
C  FIRST CHECK FOR MAXIMUM TREE AGE
C----------
          IF (SITAGE .GE. AGMAX) THEN
            POTHTG= 0.10
            GO TO 140
          ELSE
            AGP05= SITAGE + 5.0
          ENDIF
C----------
C  CALL HTCALC FOR NORMAL CYCLING
C----------
          CALL HTCALC(SINDX,ISPC,AGP05,HGUESS,JOSTND,DEBUG)
          POTHTG = HGUESS - SITHT
          IF(DEBUG)WRITE(JOSTND,*)' AGP05, HGUESS, H= ',AGP05,HGUESS,H
C----------
C ASSIGN A POTENTIAL HTG FOR THE ASYMPTOTIC AGE
C----------
  140     CONTINUE
          XMOD=1.0
          IF(PCCF(ITRE(I)) .LT. 50.0)GO TO 170
          RELHT = H/AVH
C----------
C LESSEN THE IMPACT OF RELHT FOR MODERATELY STOCKED STANDS
C----------
          IF(PCCF(ITRE(I)) .LT. 100.0) RELHT = (RELHT + 1.0) / 2.0
          IF(RELHT .GT. 1.0)RELHT = 1.0
          CR = ICR(I)/10.
C----------
C FOLLOWING MODIFIER IS BASED ON DF DATA
C----------
          XMOD = -0.02647 + 0.71338*RELHT*RELHT + 0.06851*CR
  170     CONTINUE
          HTG(I) = POTHTG * XMOD
      END SELECT

C CONSTRAIN HTG IF NEEDED
      IF(HTG(I) .LE. 0.1)HTG(I)=0.01
C-----------
C   HEIGHT GROWTH EQUATION, EVALUATED FOR EACH TREE EACH CYCLE
C   MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
C   MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
C----------
      HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
      IF(DEBUG)WRITE(JOSTND,*)' I,ISPC,XHT,SCALE,HTG,HTCON= ',
     & I,ISPC,XHT,SCALE,HTG(I),HTCON(ISPC)
 2600 CONTINUE
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
      IF(.NOT.LTRIP) GO TO 3000
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
C
 3000 CONTINUE
C----------
C   END OF SPECIES LOOP
C----------
 4000 CONTINUE
      IF(DEBUG)WRITE(JOSTND,60)ICYC
   60 FORMAT(' LEAVING SUBROUTINE HTGF   CYCLE =',I5)
      RETURN
C
      ENTRY HTCONS
C----------
C  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT
C  ARE SITE DEPENDENT AND REQUIRE ONE-TIME RESOLUTION.
C----------
      DO 50 ISPC=1,MAXSP
      HTCON(ISPC)=0.0
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)=
     &    HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
C
      RETURN
      END
