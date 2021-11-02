      SUBROUTINE COMPRS (NCLAS,PN1)
      IMPLICIT NONE
C----------
C BASE $Id: comprs.f 2944 2020-02-03 22:59:12Z lancedavid $
C----------
C
C     TREE LIST COMPRESSION ROUTINE FOR THE PROGNOSIS
C     MODEL FOR STAND DEVELOPMENT.
C
C     NICHOLAS L. CROOKSTON                     AUG 1979 & MAY 1980
C     MARCH 1981: ADDED TRUNCATED TREE AND SUBPLOT COMPRESSION.
C     APRIL/JUNE 1982: REWORKED THE SPLITTING RULES WITH ALBERT STAGE.
C     NOV 1995: CHANGED TO USE SUM OF PROB AND TREES DYING IN AVERAGING.
C     INT-FORESTRY SCIENCES LABORATORY-MOSCOW, IDAHO
C
C     THE GOAL OF THIS ROUTINE IS TO REDUCE THE LENGTH OF THE
C     TREE ATTRIBUTE VECTORS FROM THEIR ORIGINIAL LENGTH (ITRN)
C     TO THE LENGTH 'NCLAS'.
C
C     THERE ARE TWO METHODS USED TO FIND THE CLASSES:
C
C     METHOD 1: FIRST, DEFINE A LIST, WK3 (WITH LENGTH ITRN),
C     OF THE SUM OF EACH TREE ATTRIBUTE (IE, SPECIES, DDS, ETC.)
C     MULTIPLIED BY THE APPROPRIATE ATTRIBUTE WEIGHT. THEN,
C     DEFINE THE CLASS BOUNDARYIES AS BEING AT THE MAXIMUM BREAKS
C     IN WK3.
C
C     METHOD 2: REDEFINE THE SCORE TO INCLUDE THE PRINCIPAL COMPONENTS
C     OF THE VARIANCE IN THE RECORD ATTRIBUTES.  THEN FIND THE CLASS
C     WHICH HAS THE GREATEST RANGE OF THE NEW SCORE AND SPLIT IT
C     INTO TWO CLASSES.  REPEATE UNTIL THE NUMBER OF ADDITIONAL
C     CLASSES DESIRED HAVE BEEN FOUND.
C
C     UPON RETURN:
C     1. THE TREE LIST LENGTH IS REDUCED
C     2. THE SPECIES-ORDER SORT IS NOT ALIGNED.
C     3. THE 'IND' DIAMETER SORT IS NOT ALIGNED AND THE MEMBERS
C        OF IND INCLUDE NEGETIVE NUMBERS.
C     4. THE VALUE OF ITRN IS EQUAL TO THE NUMBER OF TREES
C        IN THE TREE LIST...ITRN=NCLAS.
C     5. THE VALUE OF IREC1 IS EQUAL TO THE NEXT AVAILABLE
C        TREE IN THE TREE LIST: IREC1=ITRN
C
C     ARGUMENTS:
C     NCLAS = THE NUMBER OF OUTPUT TREE RECORDS (CLASSES)
C     PN1   = THE PROPORTION OF NCLAS FOUND USING METHOD 1
C     RNGMIN= THE MIN WITHIN CLASS RANGE NEEDED TO CONTINUE SPLITTING.
C     LDEBG = TRUE IF DEBUG OUTPUT IS DESIRED.
C     JOSTND  = OUTPUT DATA SET REF. NUMBER FOR DEDUG MESSAGES.
C
C     NOTEWORTHY INTERNAL VARIABLES:
C     NCLS1 = THE NUMBER OF CLASSES FOUND USING METHOD 1
C     NCLS2 = THE NUMBER OF CLASSES FOUND USING METHOD 2
C     LTRNK = TRUE IF THE CURRENT CLASS IS A 'TRUNCATED-TREE' CLASS.
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
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'ESTREE.F77'
C
C
      INCLUDE 'STDSTK.F77'
C
C
COMMONS
C
C----------
      INTEGER IDF44,IDF33,IDF22,IDF11,IDMR,II,ICL,IREC
      REAL CRWDI,DF44,DF33,DF22,DF11,PHTI,PDBHI,PMCVI,PCFVI,WK2I,WK1I
      REAL PMBVI,PROBI,PCTI,OLDPTI,HTGI,CFVI,BFVI,XNR,XIT,TXP,XP,DIV
      REAL XBAR,SSWC,TSSWC,PRANG,XSMAL,XRANG,X1,X2,DGI,DBHI,TERM1
      INTEGER LN,I1,I2,ISIG,NCLS2,NCLS1,LEN2,LEN3,NCLAS,NRANK1,I,IJ
      INTEGER IOBSRV,JOBSRV,J,JK,K,IZERS,LEN,NRANK,LEN1
      REAL PN1,ALGTOL,RNGMIN,TTPRB,TTWK2,HTI,XICRI,X,CMRANG
      REAL HT2TDBFI,HT2TDCFI
C
      PARAMETER (NRANK=5, NRANK1=NRANK+1, LEN1 = NRANK1*(NRANK1+1)/2,
     >           LEN2 = NRANK*NRANK1/2,   LEN3 = NRANK*NRANK)
C
      DOUBLE PRECISION XTX(LEN2),EIVECT(LEN3),DTRN,XSUM(NRANK)
      DOUBLE PRECISION RMEANS(NRANK),STDDEV(NRANK),VARS(NRANK),
     >                 OBSERV(NRANK)
      LOGICAL LDEBG,LTRNK,L2,LTWO
      EQUIVALENCE (OBSERV,WK6)
      INTEGER*4 IDCMP2
      DATA RNGMIN/0.00001/,ALGTOL/0.066/
      DATA IDCMP2/20000000/
C
C     *******************     EXECUTION BEGINS     ********************
C
C     CHECK FOR DEBUG.
C
      CALL DBCHK (LDEBG,'COMPRS',6,ICYC)
C
C     IF THERE ARE FEWER TREES THAN REQUESTED CLASSES, RETURN.
C
      IF (LDEBG) WRITE (JOSTND,1) NCLAS,ITRN
    1 FORMAT (' IN COMPRS: NCLAS,ITRN=',2I6)
      IF (NCLAS.GE.ITRN) RETURN
C
C     STEP2: CALCULATE THE INITIAL WEIGHTED SCORE FOR EACH TREE RECORD
C            (AND COMPUTE SOME SUMS FOR DEBUG OUTPUT).
C
      TTPRB=0.
      TTWK2=0.
      DO 5 I=1,ITRN
      WK3(I) = 25.0*(PI*ISP(I)+ITRE(I))
      IF (LDEBG) THEN
         TTPRB=TTPRB+PROB(I)
         TTWK2=TTWK2+WK2(I)
      ENDIF
    5 CONTINUE
C
      IF (LDEBG) WRITE (JOSTND,'('' SUM OF PROB (BEFORE)= '',F10.4,
     >                           '' SUM OF MORT= '',F10.4)') TTPRB,TTWK2
C
C     STEP3: REFINE THE SCORE FOR EACH TREE RECORD.
C
C     (A) COMPUTE THE CORELATION MATRIX OF SOME OF THE CLASS-
C     IFICATION VARIABLES.
C
C     FIRST, LET ME DEFINE THE VECTOR STORAGE MODE:
C        CONSIDER THE FOLLOWING MATRIX, XTX:
C             A    B    C
C             D    E    F
C             G    H    I
C        WHERE: D=B, G=C, AND H=F, THAT IS, THE MATRIX IS SYMMETRIC.
C     THEN, XTX IS STORED IN A VECTOR OF LENGTH N*(N+1)/2 (WHERE N IS
C     THE DIMENSION OF THE MATRIX...WHICH IS EQUAL TO THE RANK ON A
C     FULL RANK MATRIX), WITH ONE COLUMN STORED DIRECTLY AFTER
C     THE OTHER: XTX = A, B, E, C, F, I.
C
C     INITIALIZE XTX.
C
      DO 10 I=1,NRANK
      XSUM(I)=0D0
   10 CONTINUE
      DO 15 I=1,LEN2
      XTX(I)=0D0
   15 CONTINUE
C
C     COMPUTE THE MEAN AND STANDARD DEVIATION OF ALL THE
C     CLASSIFICATION VARIABLES.  THE CLASSIFICATION VARIABLES ARE:
C
C     1.  HEIGHT  (HT)
C     2.  MANAGEMENT CODE (IMC)
C     3.  CROWN RATIO (ICR)
C     4.  NATURAL LOG OF DIAMETER AT BREAST HEIGHT (DBH)
C         (TEMPORARILY STORED IN WK4 UNTIL WEIGHTS ARE CALCULATED.)
C     5.  DIAMETER GROWTH (DG)
C
      CALL MEANSD (HT,ITRN,RMEANS(1),VARS(1),STDDEV(1))
      IF (STDDEV(1).LT.1D0) STDDEV(1)=1D0
      DO 20 I=1,ITRN
      WK4(I)=ICR(I)
   20 CONTINUE
      CALL MEANSD (WK4,ITRN,RMEANS(2),VARS(2),STDDEV(2))
      IF (STDDEV(2).LT.0.1D-3) STDDEV(2)=0.1D-3
      DO 25 I=1,ITRN
      WK4(I)=IMC(I)
   25 CONTINUE
      CALL MEANSD (WK4,ITRN,RMEANS(3),VARS(3),STDDEV(3))
      IF (STDDEV(3).LT.0.1D-3) STDDEV(3)=0.1D-3
      DO 30 I=1,ITRN
      WK4(I)=ALOG(DBH(I))
   30 CONTINUE
      CALL MEANSD (WK4,ITRN,RMEANS(4),VARS(4),STDDEV(4))
      IF (STDDEV(4).LT.5D-3) STDDEV(4)=5D-3
      CALL MEANSD (DG,ITRN,RMEANS(5),VARS(5),STDDEV(5))
      IF (STDDEV(5).LT.0.02) STDDEV(5)=0.02
C
C     CENTER AND SCALE THE WEIGHTS.
C
      DO 60 I=1,ITRN
      OBSERV(1)=(HT(I)-RMEANS(1))/STDDEV(1)
      OBSERV(2)=(FLOAT(ICR(I))-RMEANS(2))/STDDEV(2)
      OBSERV(3)=(FLOAT(IMC(I))-RMEANS(3))/STDDEV(3)
      OBSERV(4)=(WK4(I)-RMEANS(4))/STDDEV(4)
      OBSERV(5)=(DG(I)-RMEANS(5))/STDDEV(5)
C
C     COMPUTE X*(TRANSPOSE X), STORE IN XTX.
C
      IJ=0
      DO 40 IOBSRV=1,NRANK
      DO 35 JOBSRV=1,IOBSRV
      IJ=IJ+1
      XTX(IJ)=XTX(IJ)+OBSERV(IOBSRV)*OBSERV(JOBSRV)
   35 CONTINUE
      XSUM(IOBSRV)=XSUM(IOBSRV)+OBSERV(IOBSRV)
   40 CONTINUE
   60 CONTINUE
      IF (LDEBG) WRITE (JOSTND,61) (XSUM(I),I=1,NRANK)
   61 FORMAT (' IN COMPRS, SUMS: ',5D20.10)
C
C     SUBTRACT THE CROSS PRODUCT OF THE STANDARD DEVIATIONS.
C
      DTRN=ITRN
      IJ=0
      DO 63 I=1,NRANK
      DO 62 J=1,I
      IJ=IJ+1
      XTX(IJ)=XTX(IJ)-XSUM(I)*XSUM(J)/DTRN
   62 CONTINUE
   63 CONTINUE
C
C     NORMALIZE XTX TO OBTAIN THE CORRELATION MATRIX.
C
      DTRN=ITRN-1
      DO 65 I=1,LEN2
      XTX(I)=XTX(I)/DTRN
   65 CONTINUE
      IJ=0
      DO 67 I=1,NRANK
      DO 66 J=1,I
      IJ=IJ+1
      IF (I.EQ.J) XTX(IJ)=1D0
   66 CONTINUE
   67 CONTINUE
C
C     IF DEBUG IS DESIRED, PRINT THE CORRELATION MATRIX.
C
      IF (LDEBG) WRITE (JOSTND,70) NRANK,(XTX(I),I=1,LEN2)
   70 FORMAT (/' IN COMPRS: CORRELATIONS (WRITTEN IN VECTOR FORMAT)'
     >         ,' RANK = ',I2,5(/1X,5D20.12))
C
C     (B) COMPUTE EIGENVALUES AND EIGENVECTORS.
C         THE EIGENVALUES WILL BE STORED IN THE DIAGONAL ELEMENTS OF
C         XTX, AND THE EIGENVECTORS WILL BE STORED IN EIVECT.
C         NOTE: THE ROUTINE USED HERE IS FORM IBMS SCIENTIFIC SUB-
C         ROUTINE PACKAGE OF 1966 VINTAGE (...REMEMBER THEN]).
C
      CALL EIGEN (XTX,EIVECT,NRANK,0)
C
C     FIX THE SIGN OF THE FIRST AND SECOND EIGENVECTOR.
C
      IF (EIVECT(4).LT.0.) THEN
        IF (LDEBG) WRITE (JOSTND,71)
   71   FORMAT (' IN COMPRS: SIGN CHANGE ON FIRST EIGENVECTOR.')
        DO 72 I=1,NRANK
        EIVECT(I)=-EIVECT(I)
   72   CONTINUE
      ENDIF
      IF (EIVECT(7).GT.0.) THEN
        IF (LDEBG) WRITE (JOSTND,73)
   73   FORMAT (' IN COMPRS: SIGN CHANGE ON SECOND EIGENVECTOR.')
        DO 74 I=NRANK+1,(NRANK*2)
        EIVECT(I)=-EIVECT(I)
   74   CONTINUE
      ENDIF
C
      IF (LDEBG) WRITE (JOSTND,69) ALGTOL
   69 FORMAT (' IN COMPRS: ALGTOL = ',E15.7)
C
C     PRINT THE EIGENVALUES AND VECTORS, IF DESIRED.
C
      IF (.NOT.LDEBG) GOTO 79
      WRITE (JOSTND,75) (XTX(I+(I*I-I)/2),I=1,NRANK)
   75 FORMAT (/' IN COMPRS: EIGENVALUES: ',5D20.12)
      WRITE (JOSTND,76) NRANK,(EIVECT(I),I=1,LEN3)
   76 FORMAT (/' IN COMPRS: EIGENVECTORS, RANK = ',I3,5(/1X,5D20.12))
   79 CONTINUE
      IF (LDEBG) WRITE (JOSTND,78) XTX(1)
   78 FORMAT (' IN COMPRS: FIRST EIGENVALUE = ',D20.12)
C
C     C) SCALE EIGENVECTOR BY SIGMA X(K)
C
      JK=0
      DO J=1,NRANK
        DO K=1,NRANK
          JK=JK+1
          EIVECT(JK)=EIVECT(JK)/STDDEV(K)
        ENDDO
      ENDDO
C
C     (D) ADD A NORMALIZED SCORE FOR EACH TREE RECORD TO THE INITIAL
C         SCORE.  GIVE THE INITIAL SCORE AN ADDITIONAL OVERALL WEIGHT.
C         ADD 4 TO SHIFT THE ORIGIN TO THE MIN VALUE APPROXIMATED BY
C         -4 (ON NORMALIZED SCALE).
C         ALSO, CREATE A NEW SCORE BASED ON THE SECOND PRINCIPAL
C         COMPONENT.
C
      DO I=1,ITRN
        HTI  =REAL(HT(I)-RMEANS(1))
        XICRI=REAL(REAL(ICR(I))-RMEANS(2))
        X    =REAL(REAL(IMC(I))-RMEANS(3))
        DBHI =REAL(WK4(I)-RMEANS(4))
        DGI  =REAL(DG(I)-RMEANS(5))
        TERM1=  REAL((HTI  *EIVECT(1)) +
     >          (XICRI*EIVECT(2)) +
     >          (X    *EIVECT(3)) +
     >          (DBHI *EIVECT(4)) +
     >          (DGI  *EIVECT(5)) + 4.)
        WK3(I)=  WK3(I) + TERM1
        WK4(I)= REAL((HTI  *EIVECT(6)) +
     >          (XICRI*EIVECT(7)) +
     >          (X    *EIVECT(8)) +
     >          (DBHI *EIVECT(9)) +
     >          (DGI  *EIVECT(10)))
      ENDDO
C
C     STEP4:  SORT 'IND' ON 'WK3' USING RDPSRT (DESCENDING ORDER)
C
      IF (ITRN .GT. 0) CALL RDPSRT (ITRN,WK3,IND,.TRUE.)
C*    IF (LDEBG) WRITE (JOSTND,95) (I,WK3(IND(I)),IND(I),I=1,ITRN)
C* 95 FORMAT (' IN COMPRS: INITIAL WEIGHTS = '/((I6,1X,E16.8,1X,I5)))
C
C     STEP5:  FIND THE MAXIMUM DIFFERENCES IN THE WORK ARRAY.  THE
C     POINTS OF MAXIMUM DIFFERENCES WILL DICTATE
C     WHERE THE CLASS BREAKS ARE.
C
C     (A) CALCULATE THE DIFFERENCES.
C
      IZERS=0
      I = IND(1)
      X1 = WK3(I)
      DO 110 J=2,ITRN
      I = IND(J)
      X2 = WK3(I)
      WK6(J-1) = X1-X2
      IF (WK6(J-1).LE.ALGTOL) IZERS=IZERS+1
      X1 = X2
  110 CONTINUE
C
C     (B)  CALCULATE THE NUMBER OF CLASSES FOUND BY METHOD 1.
C
      NCLS1 = INT(REAL(NCLAS)*PN1+.5)
      ISIG=ITRN-IZERS
      IF (ISIG.LT.NCLS1)  NCLS1=ISIG
      IF (NCLS1.LT.1) NCLS1=1
      IF (NCLS1.GT.NCLAS) NCLS1=NCLAS
C
C     (C)  CREATE A SORTED LIST OF POINTERS WHICH POINT TO THE
C          DIFFERENCES IN DESCENDING ORDER.
C
      CALL RDPSRT(ITRN-1,WK6,IND1,.TRUE.)
C*    IF (LDEBG) WRITE (JOSTND,112) (I,WK6(IND1(I)),IND1(I),I=1,ITRN-1)
C*112 FORMAT (' IN COMPRS: 1ST SCORE DIFFS = '/((I6,1X,E16.8,1X,I5)))
C
C     (D)  SORT THE FIRST 'NCLS1-1' MEMBERS OF THE POINTER LIST INTO
C          ASCENDING ORDER.
C
      IF (NCLS1.GT.1) CALL IQRSRT (IND1,NCLS1-1)
      IND1(NCLS1)=ITRN
C
C     (E) CALCULATE THE NUMBER OF CLASSES TO BE FOUND BY METHOD 2.
C
      NCLS2 = NCLAS-NCLS1
      IF (LDEBG) WRITE (JOSTND,114) NCLAS,PN1,ITRN,NCLS1,NCLS2,RNGMIN
  114 FORMAT(' IN COMPRS: NCLAS=',I4,' PN1=',F5.2,' ITRN=',I4,' NCLS1=',
     >       I4,' NCLS2=',I4,' RNGMIN=',E14.6)
C
C     STEP6:  DEFINE NCLS2 MORE CLASSES USING METHOD 2.
C
C     (A) SKIP IF NCLS2 IS ZERO.
C
      IF (NCLS2 .LE. 0) GOTO 200
C
C     (B) COMPUTE THE SCORE RANGE ON THE FIRST EIGENVECTOR PRODUCT
C         WITHIN EACH CLASS AND THE NUMBER OF TREE RECORDS PER CLASS.
C
      I1=1
      DO 120 I=1,NCLS1
      I2=IND1(I)
      J=IND(I2)
      K=IND(I1)
      WK6(I)=WK3(K)-WK3(J)
      LEN=I2-I1+1
      IND2(I)=LEN
C
C     COMPUTE THE RANGE ON THE SECOND EIGENVECTOR PRODUCT
C
      WK5(I)=CMRANG(LEN,IND(I1),WK4)
C*    IF (LDEBG) WRITE (JOSTND,115) I,K,J,WK6(I),WK5(I)
C*115 FORMAT (' IN COMPRS: I,K,J,WK6(I),WK5(I)=',3I5,2F10.3)
      I1=I2+1
  120 CONTINUE
C
C     (C) CREATE NEW CLASSES BY SPLITTING THE CLASSES WITH THE LARGEST
C     RANGE.  THE SPLIT IS AT ONE OF THE RECORDS NEXT TO THE CLASS
C     MID-RANGE.
C
      DO 190 K=1,NCLS2
C
C     FIND THE LARGEST RANGE
C
      IREC=0
      XRANG=0.
      DO 130 J=1,NCLS1
C
C     LET: XRANG BE THE RANGE OF THE LARGEST CLASS,
C          L2 AND LTWO BE TRUE IF THE RANGE IN THE SECOND COMPONENT
C          IS LARGER THAN IN THE FIRST, AND
C          IREC POINT TO THE LARGEST CLASS.
C
      X=WK6(J)
      L2=WK5(J).GT.X
      IF (L2) X=WK5(J)
      IF (X.LE.XRANG) GOTO 130
      LTWO=L2
      XRANG=X
      IREC=J
  130 CONTINUE
C
C*    IF (LDEBG) WRITE (JOSTND,131) LTWO,XRANG,IREC,LEN
C*131 FORMAT (' IN COMPRS: LTWO,XRANG,IREC,LEN=',L3,F10.3,2I5)
C
C     IF THE LARGEST RANGE IS VERY SMALL, THEN: EXIT THE SPLITTING
C     LOOP (DO NOT DEFINE ANY MORE CLASSES VIA METHOD 2).
C
      IF ((XRANG.LE.RNGMIN).OR.(IREC.EQ.0)) GOTO 195
      LEN=IND2(IREC)
      JK=0
      I1=IND1(IREC)-LEN+1
C
C     IF LTWO IS TRUE (OPERATING ON SECOND EIGENVECTOR); THEN: SORT
C     THE WITHIN CLASS POINTERS ON THE SECOND SCORE.
C
      IF (LTWO) CALL RDPSRT (LEN,WK4,IND(I1),.FALSE.)
C
C     FIND THE CLASS MID-RANGE.
C
C     LET LEN INITIALLY EQUAL HALF THE NUMBER OF RECORDS IN THE CLASS.
C     I, POINTS TO THE LAST RECORD IN THE CLASS.
C     REMEMBER THAT THE LIST IS SORTED IN DESCENDING ORDER.  THEREFORE,
C     THE MID-RANGE POINT IS HALF THE RANGE PLUS THE LAST OBSERVATION.
C
      I2=IND1(IREC)
      I=IND(I2)
      XSMAL=WK3(I)
      IF (LTWO) XSMAL=WK4(I)
C
C     IF THERE ARE ONLY 2 RECORDS IN THE CLASS, THE LOCATION OF THE
C     SPLIT IS KNOWN; THEN: SET THE SPLIT POINT AND BRANCH. ELSE: SET
C     SPLIT POINT TO THE MEDIAN.
C
      IF (LEN.LE.2) THEN
         LEN=1
         PRANG=0.
      ELSE
         X=XSMAL+(XRANG/2.)
         PRANG=XRANG/FLOAT(LEN-1)
         LN=LEN
         LEN=(LEN+1)/2
      ENDIF
C
C     MAKE SURE THAT THE LOCATION OF THE SPLIT IS AWAY FROM A VERY
C     SMALL CLASS BOUNDRY.  THIS IS DONE BY LOOKING "DOWN" THE LIST
C     OF ENTRIES TO INSURE THAT A VERY SMALL CLASS BOUNDRY IS NOT
C     USED.  WE COULD ALSO LOOK "UP"...BUT WE ARE NOT GOING TO FOR NOW.
C
C     JK IS THE NUMBER OF POSSIBLE SPLIT LOCATION "BELOW" THE ONE
C     FOUND ABOVE. (WK3 & WK4 ARE INDEXED IN DESCENDING ORDER).
C
      JK=IND2(IREC)-LEN-1
      IF (JK.GE.1) THEN
         DO 165 J=1,JK
         I=IND1(IREC)-LEN
         IF (LTWO) THEN
            IF (WK4(IND(I))-WK4(IND(I+1)).GT. .001 ) GOTO 170
         ELSE
            IF (WK3(IND(I))-WK3(IND(I+1)).GT. .001 ) GOTO 170
         ENDIF
         LEN=LEN+1
  165    CONTINUE
  170    CONTINUE
      ENDIF
C
      IF (LDEBG) WRITE (JOSTND,162) XRANG,PRANG,LN,LEN,I1,I2
  162 FORMAT (' IN COMPRS: NEW WAY: XRANG,PRANG,LN,LEN,I1,I2=',
     >        2E15.7,4I5)
C
C     PERFORM THE SPLIT. INCREMENT THE CLASS COUNTER AND SPLIT CLASS
C     IREC, ASSIGN THE SPLIT TO CLASS NCLS1. UPDATE THE LIST OF CLASS
C     RANGES STORED IN WK6 AND WK5. (I POINTS TO THE LAST MEMBER OF THE
C     UPPER CLASS.
C
      NCLS1=NCLS1+1
      IND1(NCLS1)=IND1(IREC)
      I=IND1(IREC)-LEN
      IND1(IREC)=I
      IND2(NCLS1)=LEN
      IND2(IREC) =IND2(IREC)-LEN
      JK=IND(I1)
C
C     IF THE SPLIT IS BASED ON THE FIRST SCORE; THEN:
C
      IF (.NOT.LTWO) THEN
C
C        (A) UPDATE THE CLASS RANGE VECTOR BY COMPUTING THE
C            RANGES USING THE POINTERS (REMEMBER, THE LIST IS SORTED).
C        (B) UPDATE THE CLASS RANGE VECTOR FOR THE SECOND BY SEARCHING
C            FOR MAX AND MIN WITHIN EACH CLASS AND COMPUTE THE RANGES.
C
         J=IND(I+1)
         WK6(NCLS1)=WK3(J)-XSMAL
         J=IND(I)
         WK6(IREC)=WK3(JK)-WK3(J)
         LEN=IND2(IREC)
         WK5(IREC)=CMRANG(LEN,IND(I1),WK4)
         LEN=IND2(NCLS1)
         WK5(NCLS1)=CMRANG(LEN,IND(I+1),WK4)
      ELSE
C
C        ELSE (THE SPLIT IS BASED ON THE SECOND SCORE):
C
C        (A) UPDATE THE CLASS RANGE VECTOR FOR THE SECOND BY COMPUTING
C            THEN RANGE (THE SORT IS ON THE SECOND SCORE).
C        (B) RESORT THE POINTERS ON THE FIRST SCORE -- SORT EACH NEW
C            CLASS SEPERATELY.
C        (C) UPDATE THE CLASS RANGE VECTOR FOR THE FIRST BY COMPUTING
C            THE RANGE.
C
         J=IND(I+1)
         WK5(NCLS1)=WK4(J)-XSMAL
         J=IND(I)
         WK5(IREC)=WK4(JK)-WK4(J)
         LEN=IND2(IREC)
         CALL RDPSRT (LEN,WK3,IND(I1),.FALSE.)
         LEN=IND2(NCLS1)
         CALL RDPSRT (LEN,WK3,IND(I+1),.FALSE.)
         JK=IND(I1)
         J=IND(I)
         WK6(IREC)=WK3(JK)-WK3(J)
         J=IND(I2)
         JK=IND(I+1)
         WK6(NCLS1)=WK3(JK)-WK3(J)
      ENDIF
  190 CONTINUE
  195 CONTINUE
      NCLAS=NCLS1
C
C     (E) RESORT THE CLASS POINTERS
C
      CALL IQRSRT(IND1,NCLAS)
  200 CONTINUE
C
C     WRITE DEBUG IF REQUESTED (LDEBG=.TRUE.)
C
      IF (.NOT.LDEBG) GOTO 209
      WRITE (JOSTND,201)
  201 FORMAT (//' CLASS TREE#   SCORES',7X,'PROB',8x,'  MORT(WK2) IMC ',
     > '   ISP ICR ITRUNC NORMHT  DBH HT    PCT   DG   CFV ',
     >'       HT2TDBF HT2TDCF   ITRE')
      I1=1
      TSSWC=0.
      DO 207 I=1,NCLAS
      SSWC=0.
      I2=IND1(I)
      JK=I2-I1+1
      J=IND(I1)
      K=IND(I2)
      X1=WK3(J)-WK3(K)
      X2=CMRANG(JK,IND(I1),WK4)
C*    WRITE (JOSTND,202) I,X1,X2,JK
C*202 FORMAT (/1X,I4,'; FIRST SCORE RANGE=',F15.4,'; SECOND RANGE=',
C*   >       F15.4,'; NUMBER OF RECORDS=',I4)
C
C     FIND THE WITHIN CLASS MEAN
C
      XBAR=0.
      DO 203 ICL=I1,I2
      K=IND(ICL)
      XBAR=XBAR+WK3(K)
  203 CONTINUE
      DIV=I2-I1+1
      XBAR=XBAR/DIV
C
C     CALCULATE THE WITHIN CLASS SUM OF SQUARES
C
      DO 205 ICL=I1,I2
      K=IND(ICL)
      IF (I2-I1.GT.0) SSWC=SSWC+ (WK3(K)-XBAR)**2
      IF (LDEBG) WRITE (JOSTND,204) K,WK3(K),WK4(K),PROB(K),WK2(K),
     >   IMC(K),ISP(K),ICR(K),ITRUNC(K),NORMHT(K),DBH(K),HT(K),
     >   PCT(K),DG(K),CFV(K),HT2TD(K,2),HT2TD(K,1),ITRE(K)
  204 FORMAT (T8,I4,2E15.7,1X,F7.3,F9.5,I3,2I4,2I7,2(1X,F6.2),1X,
     >        F5.1,1X,F5.2,1X,F8.2,1X,F8.2,1X,F8.2,I6)
  205 CONTINUE
      TSSWC=TSSWC+SSWC
      I1=I2+1
C*    WRITE(JOSTND,206)SSWC
C*206 FORMAT(' CORRECTED SUM OF SQUARES WITHIN THIS CLASS=',E15.6)
  207 CONTINUE
      WRITE (JOSTND,208) TSSWC
  208 FORMAT (/' TOTAL WITHIN CLASS SUM OF SQUARES=',E15.6)
  209 CONTINUE
C
C     STEP7:  DO THE AVERAGEING OF ALL THE TREES IN EACH CLASS
C     AND MOVE THE AVERAGE TREE INTO THE FIRST-TREES'S POSITION
C     IN THE TREE ATTRIBUTE VECTOR (ARRAYS).  FIND THE MODE OF THE
C     DISTRIBUTION OF NOMINAL VARIABLES AND MOVE THE MODE FOR EACH
C     CLASS TO THE FIRST-TREES'S POSITION IN THE TREE ATTRIBUTE VECTOR.
C
C     NOV 1995: CHANGED THE USE OF PROB TO PROB+WK2...AND STORED THIS
C     SUM IN WK5.
C
C     THERE ARE TWO SPECIAL CASSES (CODE ADDED IN MARCH 1981):
C     1.  TRUNCATED TREES, AND
C     2.  THE COMPRESSION OF POINTS, ALSO KNOWN AS SUBPOLTS.
C
C     TO COMPRESS A CLASS WHICH INCLUDES ONE OR MORE TRUNCATED
C     TREES:
C     A.  SUM THE PROB+WK2 FOR THE CLASS. CALL A RANDOM NUMBER BETWEEN
C     ZERO AND THE SUM OF THE PROB+WK2.
C     B.  PRODUCE A CUMULATIVE ARRAY OF PROB+WK2 (STORED IN WK3). IF
C     THE RANDOM NUMBER IS LESS THAN OR EQUAL TO A CUMULATIVE VALUE,
C     THEN THE "TRUNCATED" OR "UNTRUNCATED" STATUS OF THE TREE IS
C     USED FOR THE CLASS (SAMPLING PROPORTIONAL TO SIZE).
C     C.  IF THE TREE CLASS IS NOT "TRUNCATED", THEN:  USE THE VALUE
C     HT FROM NON-TURNCATED TREES AND NORMHT FOR TRUNCATED TREES
C     IN COMPUTING THE AVERAGE HEIGHT. THEN SET NORMHT AND ITRUNC
C     EQUAL TO ZERO.  OTHERWISE, THE TREE CLASS IS TRUNCATED,
C     SO FOR THE VALUE OF HT SIMPLY AVERAGE THE VALUES OF HT FROM
C     ALL OF THE TREES IN THE CLASS.  FOR NORMHT, USE THE VALUE
C     OF NORMHT FOR TRUNCATED TREES AND HT FOR NONTRUNCATED TREES.
C     FOR ITRUNC, WE MUST FIRST "TRUNCATE" THE NONTRUNCATED TREES.
C     THE POINT OF TRUNCATION IS PROPORTIONALLY THE SAME AS THE
C     AVERAGE PROPORTION OF TRUNCATION ON THE TRUNCATED TREES.
C     THEN THE AVERAGE VALUES OF ITRUNC FOR ALL OF THE TREES IN THE
C     CLASS ARE USED TO COMPUTE THE VALUE OF ITRUNC FOR THE CLASS.
C
C     COMPRESSION OF POINTS (SUBPLOTS) IS DONE BY FOLLOWING STEPS
C     A & B, ABOVE EXCEPT THAT THE POINT CORRESPONDING TO THE TREE
C     RECORD SELECTED BECOMES THE POINT FOR THE CLASS.
C
C     MAKE SURE THAT THE TARGET TREE RECORD IS ALWAYS THE ONE
C     THAT IS CLOSEST TO THE TOP OF THE LIST, IE THE MIN.
C
      I1=1
      DO 211 ICL=1,NCLAS
      I2=IND1(ICL)
      IF (I1.LT.I2) THEN
         DO 210 II=I1+1,I2
         IF (IND(I1).GT.IND(II)) THEN
            I=IND(I1)
            IND(I1)=IND(II)
            IND(II)=I
         ENDIF
  210    CONTINUE
      ENDIF
      I1=I2+1
  211 CONTINUE
C
C     CREATE THE SUM OF PROB+WK2, STORE IN WK5.
C
      DO 212 I=1,ITRN
      WK5(I)=PROB(I)+WK2(I)
  212 CONTINUE
C
C     CALL THE WESTERN ROOT DISEASE VER. 3.0 SUBROUTINE TO COMPRESS
C     ROOT DISEASE TREE LISTS.
C
      CALL RDCMPR (NCLAS,WK5,IND,IND1)
C
C     CALL THE BLISTER RUST MODEL SUBROUTINE TO COMPRESS
C     BLISTER RUST TREE ATTRIBUTES.
C
      CALL BRCMPR (NCLAS,WK5,IND,IND1)
C
C     CALL THE FIRE/SNAG MODEL SUBROUTINE TO COMPRESS THE
C     FIRE/SNAG ATTRIBUTES.
C
      CALL FMCMPR (NCLAS)
C
C     CALL VISULIZATION COMPRESSION INITIALIZATION
C
      CALL SVCMP1
C
      TTPRB=0.
      TTWK2=0.
      I1=1
      DO 500 ICL=1,NCLAS
C
C     SET THE POINTERS TO THE TREES IN THE CLASS
C
      I2 = IND1(ICL)
      IREC1=IND(I1)
C
C     IF THERE IS ONLY ONE RECORD IN CLASS ICL, THEN: SKIP THE CLASS
C
      IF (I1 .EQ. I2) GOTO 480
C
C     CREATE A COMULATIVE PROB+WK2 FOR ALL THE TREES IN THE CLASS.
C
      XP=WK5(IREC1)
      TXP=XP
      WK3(IREC1)=XP
      K=I1+1
      DO 213 I=K,I2
      IREC=IND(I)
      XP=WK5(IREC)
      TXP=TXP+XP
      WK3(IREC)=TXP
  213 CONTINUE
C
C     ALL OF THE PROB+WK2 IS ZERO (THIS SHOULD NEVER HAPPEN), BRANCH
C     TO STMT 480 TO SKIP PROCESSING THE TREE RECORD.
C
      IF (TXP.EQ.0.0) GOTO 480
C
C     CALL A RANDOM NUMBER WHICH WILL BE USED TO SELECT THE
C     TRUNCATED STATUS, PLOT LOCATION, SPECIES, MANAGEMENT CODE,
C     CUT CODE STATUS OF THE CLASS, SPECIAL TREE STATUS,
C     AND DETERMINE VALUE OF IESTAT.
C
      CALL RANN(X)
      X=X*TXP
      DO 216 I=I1,I2
      IREC=IND(I)
      IF (X.LE.WK3(IREC)) GOTO 217
  216 CONTINUE
  217 CONTINUE
      LTRNK=NORMHT(IREC).GT.0
      ITRE(IREC1)=ITRE(IREC)
      ISP(IREC1)=ISP(IREC)
      KUTKOD(IREC1)=KUTKOD(IREC)
      ISPECL(IREC1)=ISPECL(IREC)
      IMC(IREC1)=IMC(IREC)
      IESTAT(IREC1)=IESTAT(IREC)
      IDTREE(IREC1)=IDCMP2+IY(MAX(1,ICYC))
      NCFDEF(IREC1)=NCFDEF(IREC)
      NBFDEF(IREC1)=NBFDEF(IREC)
C
C     POST THE COMPRESS TO THE VISULIZATION
C
      CALL SVCMP2(IREC1,IREC)
C
C     GET DWARF MISTLETOE RATING FOR IREC AND PUT IT INTO IREC1.
C
      CALL MISGET(IREC,IDMR)
      CALL MISPUT(IREC1,IDMR)
C
C     COMPUTE THE AVERAGE HT, NORMHT, AND ITRUNC FOR THE TREE CLASS.
C     IF THE TREE CLASS IS NOT A "TRUNCATED" CLASS (LTRNK=FALSE),
C     SIMPLY AVERAGE THE HEIGHT.
C
      IF (LTRNK) GOTO 221
      HTI=HT(IREC1)
      IF (NORMHT(IREC1) .GT. 0)HTI=NORMHT(IREC1)/100.
      HTI=HTI*WK5(IREC1)
      NORMHT(IREC1)=0
      ITRUNC(IREC1)=0
      DO 220 I=K,I2
      IREC=IND(I)
      X=HT(IREC)
      IF (NORMHT(IREC).GT.0) X=NORMHT(IREC)/100.
      HTI=HTI+X*WK5(IREC)
  220 CONTINUE
      HT(IREC1)=HTI/WK3(IREC)
      GOTO 226
  221 CONTINUE
C
C     THE TREE CLASS IS A "TRUNCATED" CLASS.  COMPUTE THE AVERAGE
C     PROPORTION OF TRUNCATION.
C
      X=0.
      XP=0.
      DO 222 I=I1,I2
      IREC=IND(I)
      IF (NORMHT(IREC).LE.0) GOTO 222
      X=X+ITRUNC(IREC)/100.*WK5(IREC)
      XP=XP+HT(IREC)*WK5(IREC)
  222 CONTINUE
      X=X/XP
C
C     NOW, COMPUTE THE AVERAGE HT,ITRUNC,NORMHT FOR THE "TRUNCATED"
C     TREE CLASS.
C
      XIT=0.
      XNR=0.
      HTI=0.
      DO 225 I=I1,I2
      IREC=IND(I)
      XP=WK5(IREC)
      HTI=HTI+HT(IREC)*XP
      IF (NORMHT(IREC).GT.0) THEN
         XNR=XNR+NORMHT(IREC)/100.*XP
         XIT=XIT+ITRUNC(IREC)/100.*XP
      ELSE
         XNR=XNR+HT(IREC)*XP
         XIT=XIT+HT(IREC)*X*XP
      ENDIF
  225 CONTINUE
      TXP=WK3(IREC)
      HT(IREC1)=HTI/TXP
      NORMHT(IREC1)=IFIX(XNR/TXP*100.)
      ITRUNC(IREC1)=IFIX(XIT/TXP*100.)
  226 CONTINUE
C
C     LOAD THE SCALARS AND INITIALIZE THE VARIABLES
C     NECESSARY TO FIND THE AVERAGE F0R THE CONTINOUS VARIABLES.
C
      XP     = WK5   (IREC1)
      BFVI   = BFV   (IREC1) * XP
      CFVI   = CFV   (IREC1) * XP
      HT2TDBFI=HT2TD(IREC1,1)* XP
      HT2TDCFI=HT2TD(IREC1,2)* XP
      DBHI   = DBH   (IREC1)
      DBHI   = DBHI*DBHI     * XP
      DGI    = DG    (IREC1) * XP
      HTGI   = HTG   (IREC1) * XP
      OLDPTI = OLDPCT(IREC1) * XP
      PCTI   = PCT   (IREC1) * XP
      WK1I   = WK1   (IREC1) * XP
      WK2I   = WK2   (IREC1)
      PROBI  = PROB  (IREC1)
      PCFVI  = PTOCFV(IREC1) * XP
      PMCVI  = PMRCFV(IREC1) * XP
      PMBVI  = PMRBFV(IREC1) * XP
      PDBHI  = PDBH(IREC1) * XP
      PHTI   = PHT(IREC1) * XP
      IF (LDEBG) WRITE (JOSTND,'('' IREC1='',I4,'' PROB='',F7.3,
     >                           '' PROBI='',F7.3)')
     >           IREC1,PROB(IREC1),PROBI
      XICRI  = ICR   (IREC1) * XP
      DF11   = FLOAT(DEFECT(IREC1)/1000000) * XP
      DF22   = FLOAT((DEFECT(IREC1)/10000) -
     &         (DEFECT(IREC1)/1000000)*100)*XP
      DF33   = FLOAT((DEFECT(IREC1)/100) - (DEFECT(IREC1)/10000)*100)*XP
      DF44   = FLOAT(DEFECT(IREC1) - (DEFECT(IREC1)/100)*100)*XP
      CRWDI  = CRWDTH(IREC1) * XP
C
C     ADD IN THE OTHER TREES WHICH FORM THE CLASS.
C
      I1 = I1+1
      DO 300 I=I1,I2
      IREC = IND(I)
C
C     SET THE SIGN NEGATIVE FOR INDICES TO VACANT POSITIONS.
C
      IND(I) = -IND(I)
      XP     = WK5(IREC)
C
      BFVI   = BFVI   + BFV   (IREC) * XP
      CFVI   = CFVI   + CFV   (IREC) * XP
      HT2TDBFI=HT2TDBFI+HT2TD(IREC,1)* XP
      HT2TDCFI=HT2TDCFI+HT2TD(IREC,2)* XP
      X      = DBH(IREC)
      DBHI   = DBHI   + X*X          * XP
      DGI    = DGI    + DG    (IREC) * XP
      HTGI   = HTGI   + HTG   (IREC) * XP
      OLDPTI = OLDPTI + OLDPCT(IREC) * XP
      PCTI   = PCTI   + PCT   (IREC) * XP
      WK1I   = WK1I   + WK1   (IREC) * XP
      WK2I   = WK2I   + WK2   (IREC)
      PROBI  = PROBI  + PROB  (IREC)
      PCFVI  = PCFVI  + PTOCFV(IREC) * XP
      PMCVI  = PMCVI  + PMRCFV(IREC) * XP
      PMBVI  = PMBVI  + PMRBFV(IREC) * XP
      PDBHI  = PDBHI  + PDBH(IREC) * XP
      PHTI   = PHTI   + PHT(IREC) * XP
      IF (LDEBG) WRITE (JOSTND,'('' IREC ='',I4,'' PROB='',F7.3,
     >                           '' PROBI='',F7.3)')
     >           IREC,PROB(IREC),PROBI
      XICRI  = XICRI  + ICR   (IREC) * XP
      DF11   = DF11 +FLOAT(DEFECT(IREC)/1000000) * XP
      DF22   = DF22 +FLOAT((DEFECT(IREC)/10000) -
     &          (DEFECT(IREC)/1000000)*100)*XP
      DF33   = DF33 +FLOAT((DEFECT(IREC)/100) -
     &        (DEFECT(IREC)/10000)*100)*XP
      DF44   = DF44 +FLOAT(DEFECT(IREC) - (DEFECT(IREC)/100)*100)*XP
      CRWDI  = CRWDI + CRWDTH(IREC) * XP
C
C     POST THE COMPRESS TO THE VISULIZATION
C
      CALL SVCMP2(IREC1,IREC)
  300 CONTINUE
C
C     DIVIDE BY THE TOTAL PROB+WK2 AND MOVE THE VALUES INTO
C     THE 'IREC1' POSITION IN THE ARRAYS.
C
      TXP           = WK3(IREC)
      BFV(IREC1)    = BFVI / TXP
      CFV(IREC1)    = CFVI / TXP
      HT2TD(IREC1,1)= HT2TDBFI / TXP
      HT2TD(IREC1,2)= HT2TDCFI / TXP
      DBH(IREC1)    = SQRT(DBHI/TXP)
      DG(IREC1)     = DGI / TXP
      HTG(IREC1)    = HTGI / TXP
      OLDPCT(IREC1) = OLDPTI / TXP
      PCT(IREC1)    = PCTI / TXP
      WK1(IREC1)    = WK1I / TXP
      WK2(IREC1)    = WK2I
      ICR(IREC1)    = NINT(XICRI / TXP)
      PROB(IREC1)   = PROBI
      IDF11         = IFIX(DF11 / TXP + .5)
      IDF22         = IFIX(DF22 / TXP + .5)
      IDF33         = IFIX(DF33 / TXP + .5)
      IDF44         = IFIX(DF44 / TXP + .5)
      DEFECT(IREC1) = IDF11*1000000 + IDF22*10000 + IDF33*100 + IDF44
      PTOCFV(IREC1) = PCFVI / TXP
      PMRCFV(IREC1) = PMCVI / TXP
      PMRBFV(IREC1) = PMBVI / TXP
      PDBH(IREC1) = PDBHI / TXP
      PHT(IREC1)  = PHTI  / TXP
      CRWDTH(IREC1) = CRWDI / TXP
      ZRAND(IREC1) = -999.0  ! reset the serial correlation
C
C     END OF COMPRESSION LOOP
C
  480 CONTINUE
C
C     PRINT DEBUG OUTPUT, IF DESIRED.
C
      IF (LDEBG) THEN
         TTPRB=TTPRB+PROB(IREC1)
         TTWK2=TTWK2+WK2(IREC1)
         WRITE (JOSTND,485) ICL,IREC1,PROB(IREC1),WK2(IREC1),
     >    IMC(IREC1),ISP(IREC1),ICR(IREC1),ITRUNC(IREC1),NORMHT(IREC1),
     >    DBH(IREC1),HT(IREC1),PCT(IREC1),DG(IREC1),CFV(IREC1),
     >    HT2TD(IREC1,2),HT2TD(IREC1,1),ITRE(IREC1)
  485 FORMAT (1X,I6,I4,T43,F7.3,F9.5,I3,2I4,2I7,2(1X,F6.2),1X,F5.1,
     >        1X,F5.2,1X,F8.2,1X,F8.2,F8.2,I3)
      ENDIF
C
C     REDEFINE I1 SUCH THAT IT POINTS TO THE FIRST
C     INDEX IN THE NEXT CLASS.
C
      I1 = I2+1
  500 CONTINUE
      IF (LDEBG) WRITE (JOSTND,'('' SUM OF PROB (AFTER)= '',F10.4,
     >                           '' SUM OF MORT= '',F10.4)') TTPRB,TTWK2
C
C     RE-REFERENCE THE POINTERS IN THE VISULIZATION DATA
C
      CALL SVCMP3
C
C     STEP8:  MOVE THE TREES IN THE BOTTOM OF THE ATTRIBUTE VECTORS
C     TO THE UPPER-MOST VACANT POSITIONS.
C
      CALL TREDEL (ITRN-NCLAS,IND)
C
      RETURN
      END