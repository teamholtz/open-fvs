      SUBROUTINE CRATET
      IMPLICIT NONE
C----------
C OC $Id: cratet.f 2453 2018-07-12 22:20:53Z gedixon $
C----------
C  THIS SUBROUTINE IS CALLED PRIOR TO PROJECTION.  IT HAS THE
C  FOLLOWING FUNCTIONS:
C
C    1)  CALL **RCON** TO LOAD SITE DEPENDENT MODEL COEFFICIENTS.
C    2)  REGRESSION TO ESTIMATE COEFFICIENTS OF LOCAL HEIGHT-
C        DIAMETER RELATIONSHIP.
C    3)  DUB IN MISSING HEIGHTS.
C    4)  CALL **DENSE** TO COMPUTE STAND DENSITY.
C    5)  SCALE CROWN RATIOS AND CALL **CROWN** TO DUB IN ANY MISSING
C        VALUES.
C    6)  DEFINE DG BASED ON CALIBRATION CONTROL PARAMETERS AND
C        CALL **DGDRIV** TO CALIBRATE DIAMETER GROWTH EQUATIONS.
C    7)  DELETE DEAD TREES FROM INPUT TREE LIST AND REALIGN IND1
C        AND ISCT.
C    8)  PRINT A TABLE DESCRIBING CONTROL PARAMETERS AND INPUT
C        VARIABLES.
C----------
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
      INCLUDE 'PLOT.F77'
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
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'ORGANON.F77'
C
C
COMMONS
C
C----------
C  INTERNAL VARIABLES.
C
C      KNT2 -- USED TO STORE COUNTS FOR PRINTING IN CONTROL
C              SUMMARY TABLE.
C     SPCNT -- USED TO ACCUMULATE NUMBER OF TREES PER ACRE BY
C              SPECIES AND TREE CLASS FOR CALCULATION OF
C              INITIAL SPECIES-TREE CLASS COMPOSITION VECTOR.
C----------
      LOGICAL DEBUG,MISSCR,TKILL
      CHARACTER*4 UNDER
      INTEGER KNT2(MAXSP),KNT(MAXSP)
      INTEGER I,J,II,ISPC,IPTR,I1,I2,I3,K1,K2,K3,K4,NH,JJ,IS,IM
      REAL AX,Q,SUMX,H,D,BX,XX,YY,XN,HS,SPCNT(MAXSP,3)
      REAL SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,D1,D2
C----------
C  ORGANON:  
C    ACALIB(i,j) IS AN ARRAY IN THE ORGANON.F77 COMMON BLOCK THAT IS
C                USED TO STORE CALIBRATION VALUES READ IN VIA KEYWORDS
C                OR CALCULATED IN **PREPARE** AND PASSED TO **EXECUTE**
C    TMPCAL(i,j) IS A LOCAL VARIABLE USED TO STORE CALIBRATION VALUES RETURNED
C                FROM **PREPARE**. IF THE USER ENTERED CALIBRATION VALUES, THEN
C                KEEP THOSE; IF THE USER DID NOT ENTER CALIBRATION VALUES, USE
C                THE ONES FROM **PREPARE**.
C    NEWCAL(j)   AN ARRAY INDICATING THAT SOME NEW CALIBRATION VALUES CAME
C                FROM **PREPARE** WHICH NEED TO BE PRINTED IN THE 
C                CALIBRATION STATISTICS TABLE
C----------
      CHARACTER*21 LABEL(18)
      INTEGER*4   IEVEN          ! ORGANON::INDS(4)
      INTEGER*4   IRAD
      INTEGER     NEWCAL(18),ITEM(2000),KG
      INTEGER     KNTOHT(MAXSP),KNTOCR(MAXSP)
      INTEGER     NBIG6,NVALID,NLOAD,NUNLOAD,ORGFIA,IHFLAG
      REAL*4      RADGRO(2000)   
      REAL*4      GROWTH(2000)
      REAL*4      TMPCAL(3,18)
C----------
C     THE SPECIES ORDER IS VARIANT SPECIFIC, SEE BLKDATA FOR A LIST.
C----------
C  INITIALIZE INTERNAL VARIABLES:
C----------
      DATA UNDER/'----'/
C
      DATA LABEL/
     &  '         DOUGLAS FIR:',
     &  '     WHITE/GRAND FIR:',
     &  '      PONDEROSA PINE:',
     &  '          SUGAR PINE:',
     &  '       INCENSE-CEDAR:',
     &  '     WESTERN HEMLOCK:',
     &  '    WESTERN REDCEDAR:',
     &  '         PACIFIC YEW:',
     &  '     PACIFIC MADRONE:',
     &  '    GIANT CHINQUAPIN:',
     &  '              TANOAK:',
     &  '     CANYON LIVE OAK:',
     &  '       BIGLEAF MAPLE:',
     &  '    OREGON WHITE OAK:',
     &  'CALIFORNIA BLACK OAK:',
     &  '           RED ALDER:',
     &  '     PACIFIC DOGWOOD:',
     &  '      WILLOW SPECIES:'/
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CRATET',6,ICYC)
C----------
C  ORGANON
C  IF NECESSARY, CALL PREPARE TO FILL IN THE MISSING VALUES
C  LORGPREP=.TRUE. IF DATA HAS ALREADY BEEN PREPARED/EDITED
C  IF THIS IS A BARE GROUND PLANT, THEN SKIP THIS SECTION
C----------
      DO I=1,18
         TMPCAL(1,I)  = 1.0 
         TMPCAL(2,I)  = 1.0
         TMPCAL(3,I)  = 1.0
         NEWCAL(I)    = 0
      ENDDO
      IF( DEBUG ) THEN
        WRITE(JOSTND,124) ICYC,IMODTY,LORGPREP
  124   FORMAT(' PREPARE FROM CRATET, CYCLE=',I2,', IMODTY= ',I2,
     &  ', LORGPREP= ',L7)
      END IF
      DO I=1,MAXSP
        KNTOHT(I) = 0
        KNTOCR(I) = 0
      ENDDO
      NVALID = 0
      NBIG6 = 0
      IF(LORGPREP .OR. ITRN.LE.0 .OR. (.NOT. LORGANON)) GO TO 261
C----------
C     ASSIGN THE SPECIES SPECIFIC VALUES FOR THE STAND LEVEL VARIABLES
C     SO THAT ORGANON WILL IMPUTE THE VALUES WHEN IT CALLS PREPARE 
C      
C     ORGANON VARIANT: SWO
C-----------
      IF(DEBUG)WRITE(JOSTND,*)' RVARS(1-5)= ',(RVARS(I),I=1,5)
      IF(DEBUG)WRITE(JOSTND,*)' INDS(1-10)= ',(INDS(I),I=1,10)
C----------
C  SET ORGANON TREE INDICATOR (0 = NO, 1 = YES). 
C  VALID TREE:
C    SPECIES 2=IC,  3=RC,  4=GF/WF, 7=DF,  8=WH, 16=SP, 18=PP, 24=PY, 
C           27=CY, 30=WO, 31=BO,   34=BM, 36=RA, 37=MA, 38=GC, 39=DG, 
C           42=TO, 46=WI 
C    HEIGHT HT > 4.5 FEET
C    DBH    DBH >= 0.1 INCH
C
C THE CALL TO PREPARE IS TO EDIT THE DATA, DUB MISSING VALUES, AND CALIBRATE THE
C ORGANON EQUATIONS TO THE INPUT DATA. WE WILL ONLY PASS VALID ORGANON TREES TO
C PREPARE FOR THIS PURPOSE. 
C
C ALSO CHECK FOR MAJOR TREE SPECIES; IF NONE, SKIP CALL TO PREPARE AND
C USE FVS LOGIC.
C----------
      DO I=1,IREC1
C----------
C CHECK TO SEE IF TREE MEETS DIAMETER LOWER LIMITS
C TREES WITH MEASURED HEIGHTS NEED TO MEET HEIGHT LOWER LIMITS FOR CALL TO PREPARE
C IHFLAG = 1 IF TREE MEETS MEASURED HEIGHT REQUIREMENTS OR THE HEIGHT IS MISSING
C----------
        IHFLAG = 0
        IF((HT(I).EQ.0.0) .OR. (HT(I).GT.4.5)) THEN
          IHFLAG = 1
        ENDIF
        IF(DBH(I) .GE. 0.1 .AND. IHFLAG .EQ. 1)THEN
C----------
C CHECK TO SEE IF THIS IS A BIG6 SPECIES
C----------
          SELECT CASE (ISP(I))
          CASE(2,4,7,16,18)
            NBIG6 = NBIG6 + 1
          END SELECT
C----------
C SET VALID SPECIES FLAG, IORG(I).
C----------
          SELECT CASE (ISP(I))
          CASE(2,3,4,7,8,16,18,24,27,30,31,34,36,37,38,39,42,46)
            IORG(I) = 1
            NVALID = NVALID + 1
          CASE DEFAULT
            IORG(I) = 0
          END SELECT
        ELSE
          IORG(I) = 0
        ENDIF
      ENDDO
      IF(DEBUG)WRITE(JOSTND,*)' IN CRATET IREC1,NVALID,NBIG6= ',
     &IREC1,NVALID,NBIG6 
C----------
C IF THERE ARE NO "BIG 6" TREES ORGANON WON'T RUN. FLAG ALL TREES AS
C NON-VALID ORGANON TREES AND SKIP CALL TO PREPARE.
C ALL TREES WILL GO INTO FVS DUBBING AND CALIBRATION LOGIC
C
C NOTE: EVEN TREES THAT GET DUBBED VALUES IN ORGANON WILL GO INTO THE
C FVS DUBBING AND CALIBATION LOGIC. ORGANON DUBBED VALUES WON'T GET
C OVERWRITTEN AND INCLUDING THOSE VALUES IN FVS CALIBRATION SHOULD BRING
C FVS AND ORGANON EQUATIONS MORE IN SYNC
C----------
      IF(NBIG6 .EQ. 0)THEN
        DO I=1,ITRN
        IORG(I) = 0
        END DO
        GO TO 261
      ENDIF
C-----------
C  FOR ALL LIVE TREE RECORDS, MOVE THE DATA FROM THE EXISTING FVS TREE  
C  ARRAYS INTO THE FORMAT THAT ORGANON REQUIRES.
C  ASSIGNMENT OF FVS-VARIABLES TO ORGANON-VARIABLES
C  ORGANON VARIABLE = FVS VARIABLE
C-----------
      NLOAD = 0
      DO I = 1, IREC1
        TREENO(I) = I                  ! FVS TREE NUMBER
        PTNO(I)= ITRE(I)               ! POINT NUMBER OF THE TREE RECORD          
        DBH1(I)= DBH(I)                ! DBH 
        IF(DBH1(I) .LT. 0.1) DBH1(I)=0.1
        HT1OR(I)= HT(I)                ! TOTAL HEIGHT AT BEGINNING OF PERIOD
        IF(HT(I).GT.0. .AND. HT1OR(I).LT.4.6) HT1OR(I)=4.6
        CR1(I)= REAL(ICR(I)) / 100.0   ! MEASURED/PREDICTED CROWN RATIO
        EXPAN1(I)= PROB(I) * PI        ! POINT-LEVEL EXPANSION FACTOR
        RADGRO(I)= DG(I)/2.0           ! INSIDE BARK RADIAL GROWTH 
        USER(I)= KUTKOD(I)             ! USER CODE AT BEGINNING OF PERIOD   
        NLOAD = NLOAD + 1
        ITEM(NLOAD) = I
C----------
C SET FIA SPECIES CODE (ACTUAL FOR VALID ORGANON SPECIES, SURROGATE
C FOR NON-VALID SPECIES.
C----------
        CALL ORGSPC(ISP(I),ORGFIA)
        SPECIES(I) = ORGFIA
C
        IF(DEBUG)WRITE(JOSTND,*)
     &  ' I,PTNO,SPECIES,DBH1,HT1OR,CR1,EXPAN1,USER,NLOAD,ITEM= ',
     &  I,PTNO(I),SPECIES(I),DBH1(I),HT1OR(I),CR1(I),EXPAN1(I),
     &  USER(I),NLOAD,ITEM(NLOAD)
      ENDDO
      IF(DEBUG)WRITE(JOSTND,*)' NVALID,NLOAD= ',NVALID,NLOAD
C----------
C  TOTAL STAND AGE (EVEN AGED ONLY)
C----------
      IEVEN = INDS(4)
      IF(INDS(4) .EQ. 1 ) THEN
        STAGE = IAGE+IY(ICYC)-IY(1)
        BHAGE     = STAGE - 6   ! BREAST HEIGHT AGE
      ELSE
        STAGE     = 0
        BHAGE     = 0           ! BREAST HEIGHT AGE
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)' STAGE,BHAGE= ',STAGE,BHAGE
C----------
C  CALL PREPARE
C----------
      CALL PREPARE(IMODTY, IPTINV, IREC1, STAGE, BHAGE, SPECIES, 
     1              USER, IEVEN, DBH1, HT1OR, CR1, EXPAN1, 
     2              RADGRO, RVARS, SERROR, TERROR, 
     3              SWARNING, TWARNING, IERROR, IRAD, 
     4              GROWTH, TMPCAL )
      LORGPREP = .TRUE.
C----------
C  IF DEBUGGING, REPORT ANY ERRORS TO THE OUTPUT FILE.
C----------
      IF( DEBUG .AND. IERROR .NE. 0 ) THEN
        WRITE(JOSTND,9125) ICYC, IERROR
 9125   FORMAT(' CRATET ORGANON ERROR CODE, CYCLE= ',I2,' IERROR= ',I2)
        DO I = 1, 9
          IF( SWARNING(I) .NE. 0 ) THEN
            WRITE(JOSTND,9127) ICYC, SWARNING(I)
 9127       FORMAT(' CRATET ORGANON ERROR CODE, CYCLE= ',I2,
     &      ' SWARNING= ',I2 )
          END IF
        END DO
C
        DO I = 1, 35
          IF( SERROR(I) .NE. 0 ) THEN
C----------          
C  IGNORE THE FOLLOWING ERRORS:
C     6 -- BHAGE HAS BEEN SET TO 0 FOR AN UNEVEN-AGED STAND
C     7 -- BHAGE > 0 FOR AN UNEVEN-AGED STAND
C     8 -- STAGE IS TOO SMALL FOR THE BHAGE
C     9 --
C    11 --
C----------
            IF( ( I .EQ. 6  ) .OR. 
     &          ( I .EQ. 7  ) .OR. 
     &          ( I .EQ. 8  ) .OR.
     &          ( I .EQ. 9  ) .OR.
     &          ( I .EQ. 11 ) ) THEN
              WRITE(JOSTND,9136) ICYC, I, SERROR(I)
 9136         FORMAT(' CRATET ORGANON ERROR CODE, CYCLE= ',I2,
     &           ' IDX= ',I2, ' SERROR= ',I2, ' ERROR IGNORED.')
              IERROR = 0
              SERROR(I) = 0
            ELSE
               
              WRITE(JOSTND,9126) ICYC, I, SERROR(I)
 9126         FORMAT(' CRATET ORGANON ERROR CODE, CYCLE= ',I2,
     &              ' IDX= ',I2, ' SERROR= ',I2 )
            END IF
          END IF
        END DO
C
        DO I = 1, 2000
          IF( TWARNING(I) .NE. 0 ) THEN
            WRITE(JOSTND,9128) ICYC, TWARNING(I)
 9128       FORMAT(' CRATET ORGANON ERROR CODE, CYCLE= ',I2,
     &           ' TWARNING= ',I2 )
          END IF
C         
          DO J = 1, 6
            IF( TERROR(I,J) .NE. 0 ) THEN
              WRITE(JOSTND,9129) ICYC, TERROR(I,J), I, J
 9129         FORMAT(' CRATET ORGANON ERROR CODE, CYCLE=' ,I2,
     &              ', TERROR(I,J)= ',I2,
     &              ', TREE NUMBER= ',I4, 
     &              ', ERROR NUMBER= ',I4 )
            END IF
          END DO
        END DO
      ELSE
        IF(DEBUG)WRITE(JOSTND,9130) ICYC, IERROR
 9130   FORMAT(' CRATET ORGANON ERROR CODE, CYCLE= ',I2,
     &        ' IERROR= ',I2 )
      END IF
C----------
C  END OF THE CRATET ERROR REPORTING SECTION
C
C  NOW RELOAD THE FVS ARRAYS WITH DBH, HT, AND CR FOR ALL VALID
C  ORGANON TREES
C  COUNT THE NUMBER OF RECORDS WITH MISSING CR OR HT FOR VALID ORGANON TREES
C----------
      NUNLOAD = 0
      KG = 0
      DO I = 1, IREC1
        IF(IORG(I) .EQ. 1)THEN
          NUNLOAD = NUNLOAD + 1
          KG = ITEM(I)
          DBH(I)= DBH1(KG)
          IF(HT(I).LE.0.0 .AND. HT1OR(KG).GT.0.0)
     &      KNTOHT(ISP(I))=KNTOHT(ISP(I))+1
          HT(I)= HT1OR(KG)
          IF(ICR(I).LE.0 .AND. CR1(KG).GT.0.0)
     &      KNTOCR(ISP(I))=KNTOCR(ISP(I))+1
          ICR(I) = NINT( CR1(KG) * 100.0 )
          IF(DEBUG)WRITE(JOSTND,*)
     &    ' KG,I,ITRE,ISP,DBH,HT,ICR,PROB,ISPECL,NUNLOAD,KNTOHT,',
     &    'KNTOCR= ',KG,I,ITRE(I),ISP(I),DBH(I),HT(I),ICR(I),PROB(I),
     &    ISPECL(I),NUNLOAD,KNTOHT(ISP(I)),KNTOCR(ISP(I))
        ENDIF
      ENDDO
      IF(DEBUG)WRITE(JOSTND,*)' NVALID,NUNLOAD= ',NVALID,NUNLOAD
C----------      
C  IF DEBUGGING PRINT OUT THE CALIBRATION VALUES.
C----------
      IF( DEBUG) THEN
        DO I=1,18
          WRITE(JOSTND,9220) I, ACALIB(1,I), 
     >           I, ACALIB(2,I), 
     >           I, ACALIB(3,I)
 9220       FORMAT ('   ORGANON ', 
     >           ' ACALIB(1,',I2,') = ',F9.6,
     >           ' ACALIB(2,',I2,') = ',F9.6,
     >           ' ACALIB(3,',I2,') = ',F9.6 )
          WRITE(JOSTND,9221) I, TMPCAL(1,I),
     >           I, TMPCAL(2,I), 
     >           I, TMPCAL(3,I), I, NEWCAL(I)
 9221       FORMAT ('   ORGANON ', 
     >           ' TMPCAL(1,',I2,') = ',F9.6,
     >           ' TMPCAL(2,',I2,') = ',F9.6,
     >           ' TMPCAL(3,',I2,') = ',F9.6,
     >           ' NEWCAL('I2') = ',I3)
        ENDDO         
      ENDIF
C----------
C  LOAD ACALIB(I,J) WITH ANY CALIBRATION VALUES COMPUTED IN **PREPARE**
C  WHICH WERE NOT LOADED BY KEYWORD ENTRY
C----------
      DO I=1,18
        DO J=1,3
          IF((ACALIB(J,I) .EQ. 1.0) .AND. 
     &    ((TMPCAL(J,I) .GT. 0.0) .AND. (TMPCAL(J,I) .NE. 1.0))) THEN
            ACALIB(J,I) = TMPCAL(J,I)
            NEWCAL(I) = 1
          ENDIF
        END DO
      END DO
C-------
C     ORGANON - END
C-------
  261 CONTINUE
C-------
C  IF THERE ARE TREE RECORDS, BRANCH TO PREFORM CALIBRATION.
C-------
      AX=0.
      IF (ITRN.GT.0) GOTO 1
C----------
C   CALL MAICAL TO CALCULATE MAI
C----------
      CALL MAICAL
      CALL RCON
      ONTREM(7)=0.
      CALL DENSE
      CALL DGDRIV
      CALL REGENT(.FALSE.,1)
    1 CONTINUE
      DO 5 I=1,MAXSP
      SPCNT(I,1)=0.0
      SPCNT(I,2)=0.0
      SPCNT(I,3)=0.0
      IF (ISCT(I,1).EQ.0) GOTO 5
      J=IREF(I)
      IUSED(J)=NSP(I,1)
    5 CONTINUE
      IF((ITRN.LE.0).AND.(IREC2.GE.MAXTP1))GO TO 245
C----------
C  PRINT SPECIES LABELS AND NUMBER OF OBSERVATIONS IN CONTROL
C  TABLE.  THEN, RESET COUNTERS TO ZERO.
C----------
      WRITE(JOSTND,'(//''CALIBRATION STATISTICS:''//)')
      WRITE(JOSTND,9000) (IUSED(I), I=1,NUMSP)
 9000 FORMAT ((T49,11(1X,A2,3X)/))
      IF(NUMSP .LE. 11) THEN
        WRITE(JOSTND,9001) (UNDER, I=1,NUMSP)
      ELSE
        WRITE(JOSTND,9001) (UNDER, I=1,11)
      ENDIF
 9001 FORMAT (T49,11(A4,2X))
      WRITE(JOSTND,9002) (KOUNT(I), I=1,NUMSP)
 9002 FORMAT(/,'NUMBER OF RECORDS PER SPECIES',
     &        ((T49,11(I4,2X)/)))
      DO 10 I=1,MAXSP
      KNT(I)=0
      KNT2(I)=0
   10 CONTINUE
C----------
C   CALL MBACAL TO IDENTIFY SITE SPECIES
C----------
      CALL MBACAL
C----------
C   CALL MAICAL TO CALCULATE MAI
C----------
      CALL MAICAL
C----------
C  CALL **RCON** TO INITIALIZE SITE DEPENDENT MODEL COEFFICIENTS.
C----------
      CALL RCON
C----------
C  CALL **RDPSRT** AND **DENSE** TO COMPUTE INITIAL STAND DENSITY
C  STATISTICS.  ONTREM(7) IS SET TO ZERO HERE TO ASSURE THAT RELDM1
C  WILL BE ASSIGNED IN **DENSE** IN THE FIRST CYCLE.
C----------
      DO 15 I=1,ITRN
      IND(I)=IND1(I)
   15 CONTINUE
      CALL RDPSRT(ITRN,DBH,IND,.FALSE.)
      ONTREM(7)=0.0
C----------
C  PREPARE INPUT DATA FOR DIAMETER GROWTH MODEL CALIBRATION.  IF
C  IDG IS 1, CONVERT THE PAST DIAMETER MEASUREMENT CARRIED IN DG TO
C  DIAMETER GROWTH.  IF IDG IS 3, CONVERT THE CURRENT DIAMETER
C  MEASUREMENT CARRIED IN DG TO DIAMETER GROWTH.  ACTUAL DIAMETER
C  INCREMENT MEASUREMENTS WILL BE CORRECTED FOR BARK GROWTH IN
C  THE CALIBRATION ROUTINE. (THIS CODE WAS MOVED HERE SO THAT THE
C  BACKDATING ALGORITHM IN **DENSE**, INVOKED DURING CALIBRATION,
C  IS CORRECT.)
C----------
      Q=1.0
      IF(IDG.EQ.3) Q=-1.0
      DO 230 II=1,ITRN
      I=IND1(II)
      IF(I.GE.IREC2) GO TO 230
      IF(DG(I).LE.0.0) GO TO 220
      IF(IDG.EQ.0.OR.IDG.EQ.2) GO TO 230
      DG(I)=Q*(DBH(I)-DG(I))
      GO TO 230
  220 CONTINUE
      DG(I)=-1.0
  230 CONTINUE
C---------
C  SET LBKDEN TRUE IF DIAMETERS ARE TO BE BACKDATED FOR DENSITY
C  CALCULATIONS.  AFTER THIS CALL TO DENSE, INSURE LBKDEN=FALSE.
C---------
      LBKDEN= IDG.LT.2
      CALL DENSE
      LBKDEN= .FALSE.
C----------
C  DELETE NON-PROJECTABLE RECORDS, AND REALIGN POINTERS TO THE
C  SPECIES ORDERED SORT.
C----------
      IF(IREC2.EQ.MAXTP1) GO TO 60
      DO 50 I=IREC2,MAXTRE
      ISPC=ISP(I)
      IPTR=IREF(ISPC)
      IF(IMC(I).EQ.7)KNT(IPTR)=KNT(IPTR)+1
      IF (DEBUG) WRITE(JOSTND,9003) I,IMC(I),ISPC
 9003 FORMAT('IN CRATET: DEAD TREE RECORD:  I=',I4,',  IMC=',I2,
     &       ',  SPECIES=',I2,' (9003 CRATET)')
      IF(ITRN.GT.0)THEN
        I1=ISCT(ISPC,1)
        I2=ISCT(ISPC,2)
        DO 30 I3=I1,I2
        IF(IND1(I3).EQ.I) GO TO 40
   30   CONTINUE
   40   IND1(I3)=IND1(I2)
        ISCT(ISPC,2)=I2-1
        IF(ISCT(ISPC,2).GE.ISCT(ISPC,1)) GO TO 50
        ISCT(ISPC,1)=0
        ISCT(ISPC,2)=0
      ENDIF
   50 CONTINUE
C----------
C  WRITE CALIBRATION TABLE ENTRY FOR NON-PROJECTABLE RECORDS AND RESET
C  KNT ARRAY TO ZERO.
C----------
      WRITE(JOSTND,9004) (KNT(I),I=1,NUMSP)
 9004 FORMAT(/,'NUMBER OF RECORDS CODED AS RECENT MORTALITY',
     &        ((T49,11(I4,2X)/)))
C---------
C  RESET TREE RECORD COUNTERS AND SAVE THE NUMBER OF SPECIES.
C----------
      ITRN=IREC1
      IF((ITRN.LE.0).AND.(IREC2.GE.MAXTP1))GOTO 245
      IF(ITRN.LE.0)GOTO 60
      ISPC=NUMSP
C---------
C  MAKE SURE THAT ALL THE SPECIES ORDER SORTS AND THE IND2 ARRAY
C  ARE IN THE PROPER ORDER. FIRST, SAVE THE SPECIES REFERENCES.
C---------
      DO 51 I=1,MAXSP
      KNT(I)=IREF(I)
   51 CONTINUE
      CALL SPESRT
C---------
C  IF THE NUMBER OF SPECIES HAS CHANGED, WE MUST REWRITE THE
C  COLUMN HEADINGS.
C---------
      IF (ISPC.NE.NUMSP) THEN
         WRITE(JOSTND,52)
   52    FORMAT (/'***** NOTE:  SPECIES HAVE BEEN DROPPED.')
         DO 55 I=1,MAXSP
         IF (ISCT(I,1).EQ.0) GOTO 55
         J=IREF(I)
         IUSED(J)=NSP(I,1)
   55    CONTINUE
         WRITE(JOSTND,9000) (IUSED(I), I=1, NUMSP)
         WRITE(JOSTND,9001) (UNDER, I=1, NUMSP)
      ELSE
C
C        RESET THE REFERENCES.
C
         DO 57 I=1,MAXSP
         IREF(I)=KNT(I)
   57    CONTINUE
      ENDIF
C----------
C  SORT REMAINING TREE RECORDS IN ORDER OF DESCENDING DIAMETER.
C  STORE POINTERS TO SORTED ORDER IN IND.
C----------
      CALL RDPSRT(ITRN,DBH,IND,.TRUE.)
   60 CONTINUE
      DO 65 I=1,MAXSP
      KNT(I)=0
   65 CONTINUE
C----------
C  ENTER LOOP TO ADJUST HEIGHT-DBH MODEL FOR LOCAL CONDITIONS.  IF
C  THERE ARE 3 OR MORE TREES WITH MEASURED HEIGHTS FOR A GIVEN
C  SPECIES, ADJUST THE INTERCEPT (ASYMPTOTE) IN THE MODEL SO THAT
C  THE MEAN RESIDUAL FOR THE MEASURED TREES IS ZERO.
C  IF LHTDRG IS FALSE FOR A GIVEN SPECIES THEN ALL DUBBING IS DONE WITH
C  DEFAULT VALUES.
C----------
      DO 150 ISPC=1,MAXSP
      AA(ISPC)=0.
      BB(ISPC)=0.
      I1=ISCT(ISPC,1)
      IF(I1.LE.0) GO TO 141
      I2=ISCT(ISPC,2)
      IPTR=IREF(ISPC)
C----------
C  INITIALIZE SUMS FOR THIS SPECIES.
C----------
      K1=0
      K2=0
      K3=0
      K4=0
      SUMX=0.0
C----------
C  ENTER TREE LOOP WITHIN SPECIES.
C----------
      DO 80 I3=I1,I2
      I=IND1(I3)
      H=HT(I)
      NH=NORMHT(I)
      D=DBH(I)
      BX=HT2(ISPC)
C----------
C  BYPASS SUMS FOR TREES WITH MISSING HEIGHT OR TRUNCATED TOPS.
C----------
      IF(H.LE.4.5 .OR. NH.LT.0 .OR. D.LT.3.0) GO TO 70
      K1=K1+1
      XX = BX/(D+1.)
      YY = ALOG(H-4.5)
      SUMX=SUMX+YY-XX
      GO TO 80
C----------
C  COUNT NUMBER OF MISSING HEIGHTS AND BROKEN OR DEAD TOPS.  LOAD THE
C  ARRAY IND2 WITH SUBSCRIPTS TO THE RECORDS WITH MISSING HEIGHTS.
C----------
   70 CONTINUE
      IF(NH.LT.0) K3=K3+1
      IF(H.GT.0.0 .AND. NH.EQ.0) GO TO 80
      K2=K2+1
      IND2(K2)=I
C----------
C  END OF SUMMATION LOOP FOR THIS SPECIES.
C----------
C*** ONE LINE FIX FOR GROWTH METHOD 1 PROBLEM. DIXON 11-16-90.
      IF(HT(I) .LE. 0.1) HTG(I)=0.0
   80 CONTINUE
C----------
C  IF THERE ARE LESS THAN THREE OBSERVATIONS OR LHTDRG IS FALSE THEN
C   DUB HEIGHTS USING DEFAULT COEFFICIENTS FOR THIS SPECIES.
C----------
      KNT(IPTR)=K3
      IF(K1 .LT.3 .OR. .NOT. LHTDRG(ISPC)) GO TO 100
      XN=REAL(K1)
      AA(ISPC)=SUMX/XN
C----------
C  IF THE INTERCEPT IS NEGATIVE, USE THE DEFAULT VALUE.
C----------
      IF(AA(ISPC).GE.0.0) THEN
        IABFLG(ISPC)=0
      ENDIF
C----------
C  DUB IN MISSING HEIGHTS.
C  A VALUE LESS THAN ZERO STORED IN 'HT' => THAT TREE WAS TOP KILLED.
C  CONSEQUENTLY, A VALUE OF 80% OF THE PREDICTED HEIGHT IS STORED AS
C  THE TRUNCATED HEIGHT.
C----------
  100 CONTINUE
      AX=HT1(ISPC)
      BX=HT2(ISPC)
      IF (IABFLG(ISPC) .EQ. 0) AX=AA(ISPC)
      IF(K2.EQ.0) GO TO 140
      DO 130 JJ=1,K2
      II=IND2(JJ)
      D=DBH(II)
      TKILL = NORMHT(II) .LT. 0
C
      IF(D .LE. 0.1)THEN
        H=1.01
        GO TO 115
      ENDIF
C
      H=EXP(AX+BX/(D+1.0))+4.5
      IF (DEBUG) WRITE(JOSTND,88) AX,BX,D,H
  88  FORMAT('CRATET DUBBED HEIGHT: AX,BX,D,H=',4F8.2)
C----------
C  USE INVENTORY EQUATIONS IF CALIBRATION OF THE HT-DBH FUNCTION IS TURNED
C  OFF, OR IF WYKOFF CALIBRATION DID NOT OCCUR.
C  NOTE: THIS SIMPLIFIES TO IF(IABFLB(ISPC).EQ.1) BUT IS SHOWN IN IT'S
C        ENTIRITY FOR CLARITY.
C----------
      IF(.NOT.LHTDRG(ISPC) .OR. 
     &   (LHTDRG(ISPC) .AND. IABFLG(ISPC).EQ.1))THEN
        CALL HTDBH (IFOR,ISPC,D,H,0)
        IF(DEBUG)WRITE(JOSTND,*)'INVENTORY EQN DUBBING IFOR,ISPC,D,H= '
     &  ,IFOR,ISPC,D,H
      ENDIF
C
      IF(H .LT. 4.5) H=4.5
  115 CONTINUE
      IF(TKILL) GO TO 120
      HT(II)=H
      K4=K4+1
      GO TO 125
  120 CONTINUE
      NORMHT(II)=INT(H*100.0+0.5)
      IF(ITRUNC(II).EQ.0) THEN
         IF(HT(II).GT.0.0) THEN
            ITRUNC(II)=INT(80.0*HT(II)+0.5)
         ELSE
            ITRUNC(II)=INT(80.0*H+0.5)
            HT(II)=H
         ENDIF
      ELSE
         IF(HT(II).GT.0.0) THEN
            IF(HT(II).LT.(REAL(ITRUNC(II))*0.01)) 
     &       HT(II)=REAL(ITRUNC(II))*0.01
         ELSE
            HT(II)=REAL(ITRUNC(II))*0.01
         ENDIF
      ENDIF
      IF(REAL(NORMHT(II))*0.01.LT.HT(II)) NORMHT(II)=INT(HT(II)*100.0)
  125 CONTINUE
  130 CONTINUE
  140 CONTINUE
      KNT2(IPTR)=K4 + KNTOHT(ISPC)
      IF(DEBUG)WRITE(JOSTND,*)' ISPC,IPTR,K4,KNTOHT,KNT2= ',
     &ISPC,IPTR,K4,KNTOHT(ISPC),KNT2(IPTR) 
C----------
C  END OF SPECIES LOOP.  PRINT HEIGHT-DIAMETER COEFFICIENTS ON
C  DEBUG UNIT IF DESIRED.
C----------
      IF(DEBUG)THEN
      WRITE(JOSTND,9005) ISPC,AX,BX,IABFLG(ISPC)
 9005 FORMAT('HEIGHT-DIAMETER COEFFICIENTS FOR SPECIES ',I2,
     &      ':  INTERCEPT=',F10.6,'  SLOPE=',F10.6,'  FLAG=',I3,
     & ' (9005 CRATET)')
      ENDIF
C----------
C  LOOP THROUGH DEAD TREES AND DUB MISSING HEIGHTS FOR THIS SPECIES.
C----------
  141 CONTINUE
      IF(IREC2 .GT. MAXTRE) GO TO 150
      DO 145 II=IREC2,MAXTRE
      IF(ISP(II).NE.ISPC) GO TO 145
      AX=HT1(ISPC)
      BX=HT2(ISPC)
      IF (IABFLG(ISPC) .EQ. 0) AX=AA(ISPC)
      D=DBH(II)
      TKILL = NORMHT(II) .LT. 0
      IF(HT(II).GT.0. .AND. TKILL) GO TO 142
      IF(HT(II).GT.0.) GO TO 146
C
      IF(D .LE. 0.1)THEN
        H=1.01
        GO TO 144
      ENDIF
C
      H=EXP(AX+BX/(D+1.0))+4.5
C----------
C  USE INVENTORY EQUATIONS IF CALIBRATION OF THE HT-DBH FUNCTION IS TURNED
C  OFF, OR IF WYKOFF CALIBRATION DID NOT OCCUR.
C  NOTE: THIS SIMPLIFIES TO IF(IABFLB(ISPC).EQ.1) BUT IS SHOWN IN IT'S
C        ENTIRITY FOR CLARITY.
C----------
      IF(.NOT.LHTDRG(ISPC) .OR. 
     &   (LHTDRG(ISPC) .AND. IABFLG(ISPC).EQ.1))THEN
        CALL HTDBH (IFOR,ISPC,D,H,0)
        IF(DEBUG)WRITE(JOSTND,*)'INVENTORY EQN DUBBING IFOR,ISPC,D,H= '
     &  ,IFOR,ISPC,D,H
      ENDIF
C
      IF(H .LT. 4.5) H=4.5
  144 CONTINUE
      IF(TKILL) GO TO 142
      HT(II)=H
      GO TO 146
  142 CONTINUE
      IF(HT(II) .GT. 0.) THEN
        NORMHT(II)=INT(HT(II)*100.0+0.5)
      ELSE
        NORMHT(II)=INT(H*100.0+0.5)
      ENDIF
      IF(ITRUNC(II).EQ.0) THEN
         IF(HT(II).GT.0.0) THEN
            ITRUNC(II)=INT(80.0*HT(II)+0.5)
         ELSE
            ITRUNC(II)=INT(80.0*H+0.5)
            HT(II)=H
         ENDIF
      ELSE
         IF(HT(II).GT.0.0) THEN
            IF(HT(II).LT.(REAL(ITRUNC(II))*0.01)) 
     &       HT(II)=REAL(ITRUNC(II))*0.01
         ELSE
            HT(II)=REAL(ITRUNC(II))*0.01
         ENDIF
      ENDIF
      IF(REAL(NORMHT(II))*0.01.LT.HT(II)) NORMHT(II)=INT(HT(II)*100.0)
C----------
C   CALL FIRE SNAG MODEL TO ADD THE DEAD TREES TO THE
C   SNAG LIST; DEFLATE PROB(II), WHICH WAS TEMPORARILY
C   ADJUSTED TO ALLOW BACKDATING FOR CALIBRATION PURPOSES,
C   IN **NOTRE**
C----------
  146 CONTINUE
      IF (TKILL) THEN
        HS = REAL(ITRUNC(II)) * 0.01
      ELSE
        HS = HT(II)
      ENDIF
      CALL FMSSEE (II,ISPC,D,HS,
     >  (PROB(II)/(FINT/FINTM)),3,.FALSE.,JOSTND)
C
  145 CONTINUE
C----------
  150 CONTINUE
C----------
C  END OF HEIGHT DUBBING SEGMENT.  PRINT CONTROL TABLE ENTRIES FOR
C  USEABLE HEIGHTS AND MISSING HEIGHTS, AND REINITIALIZE COUNTERS.
C----------
      WRITE(JOSTND,9006) (KNT2(I),I=1,NUMSP)
 9006 FORMAT(/,'NUMBER OF RECORDS WITH MISSING HEIGHTS',
     &       ((T49,11(I4,2X)/)))
      WRITE(JOSTND,9007) (KNT(I),I=1,NUMSP)
 9007 FORMAT(/,'NUMBER OF RECORDS WITH BROKEN OR DEAD TOPS',
     &       ((T49,11(I4,2X)/)))
      DO 160 I=1,MAXSP
      KNT(I)=0
      KNT2(I)=0
  160 CONTINUE
C----------
C  ADD THE NUMBER OF MISSING CROWN RATIOS DUBBED BY ORGANON TO THE
C  NUMBER BEING DUBBED BY FVS.
C----------
      DO ISPC=1,MAXSP
      IF(IREF(ISPC) .EQ. 0) CYCLE
      IPTR = IREF(ISPC)
      KNT2(IPTR) = KNT2(IPTR) + KNTOCR(ISPC)
      IF(DEBUG)WRITE(JOSTND,*)' ISPC,IPTR,KNTOCR,KNT2= ',
     &ISPC,IPTR,KNTOCR(ISPC),KNT2(ISPC) 
      ENDDO
C----------
C  CHECK FOR MISSING CROWNS ON LIVE TREES.
C  SAVE PCT IN OLDPCT TO RETAIN AN OLD PCTILE VALUE.
C----------
      MISSCR = .FALSE.
      DO 190 I=1,ITRN
      OLDPCT(I)= PCT(I)
      IF(ICR(I).LE.0)THEN
        MISSCR = .TRUE.
        ISPC=ISP(I)
        IPTR=IREF(ISPC)
        KNT2(IPTR)=KNT2(IPTR)+1
      ENDIF
      IF(ITRE(I).LE.0) ITRE(I) = 9999
  190 CONTINUE
C----------
C  CHECK FOR MISSING CROWNS ON CYCLE 0 DEAD TREES.
C----------
      IF(IREC2 .GT. MAXTRE) GO TO 192
      DO 191 I=IREC2,MAXTRE
      IF(ICR(I).LE.0)MISSCR=.TRUE.
  191 CONTINUE
  192 CONTINUE
C----------
C  CALL **CROWN** IF ANY CROWN RATIOS ARE MISSING.
C----------
      IF(MISSCR)CALL CROWN
C----------
C  PRINT CONTROL TABLE ENTRY FOR MISSING CROWN RATIOS; RESET COUNTERS.
C----------
      WRITE(JOSTND,9008) (KNT2(I),I=1,NUMSP)
 9008 FORMAT(/,'NUMBER OF RECORDS WITH MISSING CROWN RATIOS',
     &       ((T49,11(I4,2X)/)))
      DO 200 I=1,MAXSP
      KNT2(I)=0
  200 CONTINUE
C----------
C   CALL AVHT40 TO CALCULATE AVERAGE HEIGHT. THIS CALL IS NEEDED
C   IN SORNEC BECAUSE DGF ROUTINE USES AVH IN CALCULATION OF DDS.
C----------
      CALL AVHT40
C----------
C  CALL DGDRIV TO CALIBRATE DIAMETER GROWTH EQUATIONS.
C----------
      IF(DEBUG)WRITE(JOSTND,*)'CALL DGDRIV FROM CRATET SECOND TIME'
      CALL DGDRIV
C----------
C  PREPARE INPUT DATA FOR HEIGHT GROWTH MODEL CALIBRATION; IT'S DONE
C  THE SAME AS THE DIAMETER GROWTH MODEL SEEN ABOVE.
C----------
      IF(IHTG.EQ.0 .OR. IHTG.EQ.2) GOTO 236
      Q = 1.
      IF(IHTG.EQ.3) Q = -1.
      DO 233 I=1,ITRN
      IF(HTG(I).LE.0.) GOTO 233
      HTG(I) = Q * (HT(I)-HTG(I))
      IF(HT(I) .LE. 0.0) HTG(I)=0.0
  233 CONTINUE
  236 CONTINUE
C----------
C  ESTIMATE MISSING TOTAL TREE AGES
C----------
      IF(DEBUG)WRITE(JOSTND,*)'IN CRATET, CALLING FINDAG'
      DO I=1,ITRN
      IF(ABIRTH(I) .LE. 0.)THEN
        SITAGE = 0.0
        SITHT = 0.0
        AGMAX = 0.0
        HTMAX = 0.0
        HTMAX2 = 0.0
        ISPC = ISP(I)
        D1 = DBH(I)
        H = HT(I)
        D2 = 0.0
        CALL FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,
     &              DEBUG)
        IF(SITAGE .GT. 0.)ABIRTH(I)=SITAGE
      ENDIF
      ENDDO
C----------
C  CALL REGENT TO CALIBRATE THE SMALL TREE HEIGHT INCREMENT MODEL.
C----------
      CALL REGENT(.FALSE.,1)
C----------
C  LOAD SPCNT WITH NUMBER OF TREES PER ACRE BY SPECIES AND TREE
C  CLASS.
C----------
      DO 240 I=1,ITRN
      IS=ISP(I)
      IM=IMC(I)
      SPCNT(IS,IM)=SPCNT(IS,IM)+PROB(I)
  240 CONTINUE
C----------
C  COMPUTE DISTRIBUTION OF TREES PER ACRE AND SPECIES-TREE CLASS
C  COMPOSITION BY TREES PER ACRE.
C----------
  245 CONTINUE
      CALL PCTILE(ITRN,IND,PROB,WK3,ONTCUR(7))
      CALL DIST(ITRN,ONTCUR,WK3)
      CALL COMP(OSPCT,IOSPCT,SPCNT)
      IF (ITRN.LE.0) GO TO 500
C----------
C  CALL **DENSE** TO CALCULATE STAND DENSITY STATISTICS FOR
C  INITIAL INVENTORY.
C----------
      IF(DEBUG) WRITE(JOSTND,9013) ICYC
 9013 FORMAT('CALLING DENSE, CYCLE=',I2)
      CALL DENSE
C----------
C  COUNT AND PRINT NUMBER OF RECORDS WITH MISTLETOE.
C----------
      CALL MISCNT(KNT)
      WRITE(JOSTND,248) (KNT(I),I=1,NUMSP)
  248 FORMAT(/,'NUMBER OF RECORDS WITH MISTLETOE',((T49,11(I4,2X)/)))
C----------
C  CALL **SDICHK** TO SEE IF INITIAL STAND SDI IS ABOVE THE SPECIFIED
C  MAXIMUM SDI.  RESET MAXIMUM SDI IF THIS IS THE CASE.
C----------
      CALL SDICHK
C----------
C  WRITE THE ORGANON SETTINGS TABLE FOR FVS-ORGANON VARIANTS
C----------
      CALL ORGTAB
C
  500 CONTINUE
      IF(DEBUG)WRITE(JOSTND,510)ICYC
  510 FORMAT('LEAVING SUBROUTINE CRATET  CYCLE =',I5)
C
      RETURN
      END
