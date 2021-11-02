      SUBROUTINE BWESIT 
      IMPLICIT NONE
C----------
C WSBWE $Id: bwesit.f 2460 2018-07-24 14:41:48Z gedixon $
C----------
C
C     INITIALIZES ONE STAND AT THE BEGINNING OF A CYCLE.
C
C     PART OF THE WESTERN SPRUCE BUDWORM MODEL/PROGNOSIS LINKAGE CODE.
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB, MOSCOW, ID--JANUARY 1984
C
C     THIS ROUTINE CONVERTS A PROGNOSIS MODEL STAND REPRESENTATION
C     TO AN EQUIVALENT BUDWORM MODEL STAND REPRESENTATION.  IT IS
C     THE ROUTINE WHICH PASSES MOST OF THE INFORMATION FROM PROGNOSIS
C     TO BUDWORM.
c
c   major revision by K.A.Sheehan to strip out Pop.Dyn.stuff 7/96+
C
C     CALLED FROM :
C
C       BWECUP - SINGLE STAND BUDWORM MODEL LINK TO PROGNOSIS.
C
C     FUNCTIONS CALLED :
C
C       BWESLP  - LINEAR INTERPOLATION FUNCTION.
C
C     SUBROUTINES CALLED :
C
C       OPFIND - FIND OPTION IN OPTION LIST.
C       OPGET  - RETRIEVE OPTION.
C       OPDONE - SIGNAL THAT OPTION HAS BEEN ACCOMPLISHED.
C       OPDEL1 - DELETE OPTION FROM OPTION LIST.
C       OPADD
C       OPINCR
C       BWESIN - SET DO LOOP INDICES FOR DEFOL AND SETPRBIO OPTIONS.
C       BWEBMS - COMPUTE FOLIAGE BIOMASS FOR INDIVIDUAL TREES.
C       BWECRC - SELECT THE HEIGHT AND CROWN CLASS INDICES FOR A TREE.
C       BWEADV - COMPUTE SUCCESSIONAL STAGE INDEX AND WEATHER PARAMETERS
C
C     PARAMETERS :
C
C   LCALBW = TRUE IF BUDLITE MODEL IS CALLED
C   LDEFOL = TRUE IF USER SUPPLIES ANNUAL DEFOLIATION RATES
C   LREGO  - TRUE IF A REGIONAL OUTBREAK IS ACTIVE, FALSE IF NOT
C   LSPRAY - TRUE IF INSECTICIDES ARE TO BE SPRAYED IN THE CURRENT YEAR[BWECM2]
C
C
C Revision History:
C   25-MAY-00 Lance David (FHTET)
C      .Added debug handling.
C      .Initialize local variables.
C   30-NOV-00 Lance David (FHTET)
C      .Added debug statement for option processing.
C      .Added call to opdone for setprbio between statement lables 80 & 90.
C   14-JUL-2010 Lance R. David (FMSC)
C       Added IMPLICIT NONE and declared variables as needed.
C----------
C
COMMONS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'COEFFS.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'BWESTD.F77'
      INCLUDE 'BWECOM.F77'
      INCLUDE 'BWECM2.F77'
C
COMMONS
C
      LOGICAL LSKBIO, LPRBIN, DEBUG
      INTEGER I, I1, I2, IACTK, ICRC1, ICRC2, ICRC3, ICRI, ICROWN,
     &        IDT, IELEV, IFAGE, IHOST, IS1, IS2, ISPI, ISZI, ITREE,
     &        IYR1, J, K, KODE, MYACT(8), MYALL(9), NP, NSPYR
      REAL    BIO, BWESLP, CRM, DIV, HTI, PROBI,
     &        HTSCL(6), CRNMIN(6), CRT(7,3), HTT(7,3), PRMS(1)

      DATA HTSCL/0.,2.5,5.0,10.,20.,22./,CRNMIN/1.,.9,.7,.5,.3,.2/
      DATA MYACT/2150,2152,2153,2154,2155,2156,2157,2159/
      DATA MYALL/2150,2151,2152,2153,2154,2155,2156,2157,2159/
C
C.... Check for DEBUG
C
      CALL DBCHK(DEBUG,'BWESIT',6,ICYC)

      IF (DEBUG) WRITE (JOSTND,*) 'ENTER BWESIT: ICYC = ',ICYC

C     ********************** EXECUTION BEGINS **************************
C
C     ****NOTE****NOTE****NOTE****NOTE****NOTE****NOTE****NOTE****
C     FVS COMMON ARRAYS WK3, WK4 AND WK6 ARE USED HERE
C     WK6 IS LOADED WITH VALUES AND NEEDS TO BE INITIALIZED FIRST, MAYBE(?)
C     LANCE DAVID  25-MAY-00

      DO I1 = 1, MAXTRE
         WK6(I1) = 0.0
      END DO

      DO I1 = 1,6
        HTSCL(I1)  = 0.0
        CRNMIN(I1) = 0.0
      END DO

      DO I1 = 1,7
        DO I2 = 1,3
          CRT(I1,I2) = 0.0
          HTT(I1,I2) = 0.0
          BWTPHA(I1,I2) = 0.0
        END DO
      END DO
C
C     RESET INITIAL STAND CONDITIONS IF NOT
C     IN THE MIDDLE OF A CONTINUING OUTBREAK.
C     THIS INCLUDES ALL BUDWORM MODEL VARIABLES WHICH
C     ARE ALTERED VIA THE PROGNOSIS OPTION PROCESSOR.
C
      IYR1=IY(ICYC)
C
C     SET LSKBIO TRUE IF THE RDDSM1, RHTGM1, AND PRBIO ARRAYS ARE
C     INITIALIZED OR ARE BEING CARRIED OVER FROM THE PREVIOUS CYCLE.
C
      LSKBIO=IY(ICYC).LE.IPRBYR
C
C     INITIALIZE OPTION SWITCHES
C
      LPRBIN = .FALSE.
      LSPRAY = .FALSE.
      NSPYR  = 0
      HOSTST = 0.0
C
C     IF DEFOL EXISTS, THEN CALLBW IS ILLEGAL.  SET LDEFOL TRUE IF DEFOL
C     EXISTS.
C
      CALL OPFIND (1,MYALL(2),I)
      LDEFOL=I.GT.0
      IF (LDEFOL) THEN
         LREGO=.FALSE.
         LCALBW=.FALSE.
      ENDIF
C
C     PROCESS ALL ACTIVITIES EXCEPT DEFOL.
C
      CALL OPFIND (8,MYACT,NTODO)
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWESIT: OPFIND NTODO=',NTODO
C
C     IF THERE ARE NO ACTIVITIES, BRANCH PAST ACTIVITY PROCESSING.
C
      IF (NTODO.LE.0) GOTO 100

      DO 90 ITODO=1,NTODO
C
C       GET THE ACTIVITY AND SIGNAL THAT IT IS ACCOMPLISHED.
C
        CALL OPGET (ITODO,6,IDT,IACTK,NP,WK3)
        IF (DEBUG) WRITE (JOSTND,*) 'IN BWESIT: OPGET ',
     >             'ITODO,IDT,IACTK,NP,WK3=',ITODO,IDT,IACTK,NP,WK3
C
C       ACTIVITIES ARE:
C
C       2150 - GENDEFOL
C       2151 - DEFOL
C       2153 - SETPRBIO
C       2152, 2154, 2155, 2156 - NOT CURRENTLY USED
C       2157 - SPRAY INSECTICIDE IN A GIVEN YEAR
C       2159 - SPRAY INSECTICIDE WHEN TRIGGER CONDITIONS ARE MET
C
        IF (IACTK.EQ.2150) GOTO 10
        IF (IACTK.EQ.2153) GOTO 40
        IF (IACTK.EQ.2157) GOTO 20
        IF (IACTK.EQ.2159) GOTO 30

C       ALL OTHER ACTIVITY CODES IN MYACT LISTED BELOW ARE NOT USED.
C       IF (IACTK.EQ.2152) GOTO 90
C       IF (IACTK.EQ.2154) GOTO 90
C       IF (IACTK.EQ.2155) GOTO 90
C       IF (IACTK.EQ.2156) GOTO 90

        GOTO 90

   10   CONTINUE
C
C       GENDEFOL 
C       IF DEFOL OPTION EXISTS, THEN DELETE GENDEFOL.

        IF (LDEFOL) THEN
          CALL OPDEL1 (ITODO)
        ELSE
C
C         SET MAX YEAR, TURN ON OPTION [THIS SECTION MAY NOT BE NEC.?]
C
          PRMS(1)=IYREND-IY(ICYC+1)+1
          IF (PRMS(1).GT.0) THEN
            CALL OPADD (IY(ICYC+1),2150,0,1,PRMS(1),KODE)
            CALL OPINCR (IY,ICYC,NCYC)
          ENDIF
        ENDIF  
        GOTO 90
C
C       BWSPRAY - SPRAY OPTION 1, APPLY IN SPECIFIED YEAR.
C
   20   CONTINUE
        NSPYR=NSPYR+1
        ISPYR(NSPYR)=IDT
        SPEFFS(NSPYR)=WK3(2)
        SPINST(NSPYR)=WK3(1)
        CALL OPDONE(ITODO,IDT)
        GOTO 90
C
C       BWSPRAY - SPRAY OPTION 2, APPLICATION TRIGGERED BY % DEFOLIATION.
C
   30   CONTINUE
C        have not quite figured this out and am not sure if this activity
C        can be set to done or deleted based on defoliation values at this
C        point. This code is really just a placeholder, the 2159 activity
C        code had no associated processing before. Lance David 8-dec-00
C        NSPYR=NSPYR+1
C        ISPYR(NSPYR)=IDT
C        SPEFFS(NSPYR)=WK3(2)
C        SPINST(NSPYR)=WK3(1)
C        CALL OPDONE(ITODO,IDT)
        GOTO 90
C
C       SET THE SETPRBIO OPTION.
C
   40   CONTINUE

C       PRBIO ARRAY IS INITIALIZED FOR FIRST OCCURENCE OF SETPRBIO ONLY.
C       
        IF (LPRBIN) GOTO 60
C
C       INITIALIZE PRBIO.  
C
        DO 50 I=1,6
          DO 50 J=1,9
            DO 50 K=1,4
              PRBIO(I,J,K)=1.0
   50   CONTINUE
   60   CONTINUE
        IPRBYR=IYR1
        LPRBIN=.TRUE.
C
C       LOAD INDEXING BOUNDS FOR THE OPTION.
C
        CALL BWESIN (WK3,IBWSPM,IS1,IS2,ICRC1,ICRC2,ICRC3)

C       IF THE SPECIES CODE MAPS TO NON-HOST, THEN DELETE OPTION.
C       IF VALID HOST, LOAD PRBIO FROM WK3 AND SET OPTION COMPLETE.
C
        IF (IS1 .GT. 6) THEN
          CALL OPDEL1 (ITODO)
        ELSE
          DO 80 ICROWN=ICRC1,ICRC2,ICRC3
            DO 80 IHOST=IS1,IS2
              DO 80 IFAGE=2,4
                PRBIO(IHOST,ICROWN,IFAGE)=WK3(IFAGE+2)
   80     CONTINUE
          CALL OPDONE(ITODO,IDT)
        ENDIF

   90 CONTINUE
  100 CONTINUE
C
C     END OPTION PROCESSING.
C
C     RESET LSKBIO.  LSKBIO STAYS TRUE IF RDDSM1 AND RHTGM1 WERE SET
C     BEFORE THE ROUTINE WAS CALLED AND IF PRBIO HAS NOT BEEN ALTERED.
C
      LSKBIO=LSKBIO .AND. .NOT.LPRBIN
      IF (LSKBIO) GOTO 140
      DO 120 I=1,6
        DO 117 J=1,3
          RDDSM1(I,J)=1.0
          RHTGM1(I,J)=1.0
  117   CONTINUE
        DO 119 J=1,9
          DO 119 K=1,4
            POFPOT(I,J,K)=1.0
  119   CONTINUE 
  120 CONTINUE
      ICUMYR=0
      NCUMYR=0
C
C     IF SETPRBIO HAS BEEN PROCESSED, SKIP INITIALIZATION OF PRBIO.
C
      IF (LPRBIN) GOTO 140
      DO 130 I=1,6
        DO 130 J=1,9
          DO 130 K=1,4
            PRBIO(I,J,K)=1.0
  130 CONTINUE
      IPRBYR=IYR1
  140 CONTINUE
C
C     ARE WE DONE?  RETURN IF THERE IS NOTHING ELSE TO DO.
C
      IF (.NOT. (LREGO.OR.LDEFOL)) GOTO 9000
C
C     LOAD SPECIES PRESENT/ABSENCE ARRAY (IFHOST)
C
      DO 150 I=1,7
        IFHOST(I)=0
  150 CONTINUE
      DO 160 I=1,MAXSP
        K=IBWSPM(I)
        IF (ISCT(I,1).GT.0) IFHOST(K)=1
  160 CONTINUE
C
C     ZERO OUT ACCUMULATORS.
C
      DO 165 IHOST=1,6
        DO 164 ITREE=1,3
          PEDDS(IHOST,ITREE)=0.0
          PEHTG(IHOST,ITREE)=0.0
          BWMXCD(IHOST,ITREE)=0.0
          AVYRMX(IHOST,ITREE)=0.0
  164   CONTINUE
  165 CONTINUE
C
      DO 170 ICROWN=1,9
        FOLNH(ICROWN)=0.
  170 CONTINUE
      DO 180 I=1,6
        DO 180 J=1,9
          DO 180 K=1,4
            FOLPOT(I,J,K)=0.
  180 CONTINUE

CLRD  MOVED TO TOP
CLRD      DO 190 ISZI=1,3
CLRD      DO 190 IHOST=1,7
CLRD      BWTPHA(IHOST,ISZI)=0.
CLRD  190 CONTINUE
C
C     ****** CALL THE CROWN BIOMASS MODEL ****** (LOAD WK4).
C
      CALL BWEBMS (WK4,2)
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWESIT: bwebms WK4=',WK4
C
C     INITIALIZE AVERAGE DBH, CROWNRATIO, AND HEIGHT.
C
      DO 205 IHOST=1,7
        DO 204 ISZI=1,3
          CRT(IHOST,ISZI)=0.0
          HTT(IHOST,ISZI)=0.0
  204   CONTINUE
  205 CONTINUE
C
C     DO FOR ALL TREES.
C
      IF (ITRN.LE.0) GOTO 262
      DO 260 I=1,ITRN
        HTI=HT(I)
        ICRI=ICR(I)
C
C       FIND THE CROWN CLASS INDICIES
C
        CALL BWECRC (HTI,ISZI,ICRC1,ICRC2)
C
C       LOAD TREE SAMPLING WEIGHT, CONVERT TO TREES PER HA.
C
        PROBI=PROB(I)*2.47103
C
C       LOAD SPECIES CODE AND MAP TO HOST CODE.
C
        ISPI=ISP(I)
        IHOST=IBWSPM(ISPI)
C
C       ACCUMULATE TREES PER HA BY TREE CLASS AND HOST SPECIES.
C
        BWTPHA(IHOST,ISZI)=BWTPHA(IHOST,ISZI)+PROBI
        WK6(ISZI)=WK6(ISZI)+PROBI
C
C       ACCUMULATE THE HEIGHT AND CROWN RATIO OF THE TREES BY HOST
C       AND CROWN LEVEL.
C
        HTT(IHOST,ISZI)=HTT(IHOST,ISZI)+HT(I)*PROBI
        CRT(IHOST,ISZI)=CRT(IHOST,ISZI)+ICRI*PROBI
C
C       LOAD TREE BIOMASS IN GRAMS PER HA
C
        BIO=WK4(I)*453.6*PROBI
C
C       IF IHOST IS LESS THAN 7, THE TREE IS HOST, BRANCH TO HOST
C       FOLIAGE CALCULATIONS.
C
        IF (IHOST.LT.7) GOTO 230
C
C       ELSE: THE TREE IS NON-HOST, ACCUMULATE NON-HOST FOLIAGE.
C
        DO 220 ICROWN=ICRC1,ICRC2
          FOLNH(ICROWN)=FOLNH(ICROWN)+(PRCRN3(ICROWN)*BIO)
  220   CONTINUE
        GOTO 250
  230   CONTINUE
C
C       ACCUMULATE THE BIOMASS OF HOST FOLIAGE.
C
        DO 240 ICROWN=ICRC1,ICRC2
          DO 240 IFAGE=1,4
            FOLPOT(IHOST,ICROWN,IFAGE)=FOLPOT(IHOST,ICROWN,IFAGE)+
     >        (THEOFL(IFAGE,ICROWN)*PRCRN3(ICROWN)*BIO)
  240     CONTINUE
  250   CONTINUE
  260 CONTINUE
  262 CONTINUE
C
C     COMPUTE THE AVERAGE CROWN LENGTH AND HEIGHT OF CROWN CLASSES.
C
      DO 267 IHOST=1,7
        IF (IFHOST(IHOST).EQ.0) GOTO 267
        DO 265 ISZI=1,3
          DIV=BWTPHA(IHOST,ISZI)
C
C         CALC. THE NUMBER OF HOST STEMS PER ACRE. BWTPHA=NO. OF TREES
C         PER HECTARE BY HOST.
C
          IF (IHOST.NE.7) HOSTST=HOSTST+(BWTPHA(IHOST,ISZI)*0.4047)
C
          IF (DIV.LE. 0.0) GOTO 265
C
C         COMPUTE THE AVERAGE HEIGHT, DBH, AND CROWN RATIO OF TREES
C         BY TREE SIZE AND HOST.  .3048 CONVERTS FEET TO METERS, AND
C         .01 CONVERTS CROWN RATIO FROM 1 TO 90 TO CROWN RATIO OF
C         .01 TO .9, WHICH IS USED TO PROPORTION OUT THE CROWN LEVELS.
C
          HTT(IHOST,ISZI)=HTT(IHOST,ISZI)*.3048/DIV
          CRT(IHOST,ISZI)=CRT(IHOST,ISZI)*.01/DIV
C
C         CHECK TO SEE IF THE CROWN RATIO FALLS BELOW THE MINIMUM FOR THIS
C         HEIGHT CLASS.  IF SO, USE THE MINIMUM AS THE CROWN RATIO.
C
          CRM=BWESLP(HTT(IHOST,ISZI),HTSCL,CRNMIN,6)
          IF (CRT(IHOST,ISZI).LT.CRM) CRT(IHOST,ISZI)=CRM
  265   CONTINUE
  267 CONTINUE
C
C     COMPUTE THE PER TREE (AVERAGE) POTENTIAL FOLIAGE.
C
      DO 330 IHOST=1,6
C
C     IF THERE IS NO HOST OF THIS SPECIES, THEN: SKIP CALCULATIONS.
C
      IF (IFHOST(IHOST).EQ.0) GOTO 330
      DO 320 ICROWN=1,9
      ISZI=(ICROWN+2)/3
      DIV=BWTPHA(IHOST,ISZI)
C
C     IF THE SAMPLING WEIGHT IS ZERO, BRANCH TO ZERO OUT THE
C     FOLIAGE ARRAY.
C
      IF (DIV.LE. 0.0) GOTO 300
      DO 290 IFAGE=1,4
      FOLPOT(IHOST,ICROWN,IFAGE)=FOLPOT(IHOST,ICROWN,IFAGE)/DIV
  290 CONTINUE
      GOTO 320
  300 CONTINUE
      DO 310 IFAGE=1,4
      FOLPOT(IHOST,ICROWN,IFAGE)=0.
  310 CONTINUE
  320 CONTINUE
  330 CONTINUE
C
C     COMPUTE THE PER TREE (AVERAGE) NON-HOST FOLIAGE.
C
      DO 350 ICROWN=1,9
      ISZI=(ICROWN+2)/3
      DIV=BWTPHA(7,ISZI)
      IF (DIV.LE. 0.0) GOTO 340
      FOLNH(ICROWN)=FOLNH(ICROWN)/DIV
      GOTO 350
  340 CONTINUE
      FOLNH(ICROWN)=0.
  350 CONTINUE
C
C     WRITE THE POTENTIAL FOLIAGE, TREES PER HA, AND CROWN DIMENSION
C     ARRAYS.
C
C     LOAD THE ADJUSTED FOLIAGE ARRAYS.  THE ADJUSTMENT IS DONE TO
C     ACCOUNT FOR THE EFFECT DEFOLIATION HAS ON THE PREVIOUS YEARS TREE
C     GROWTH.
C
C     THE AMOUNT OF THE ADJUSTMENT IS A FUNCTION OF THE ACTUAL
C     PROPORTION OF RETAINED BIOMASS IN THE PREVIOUS YEAR.  NOTE THAT
C     THE ACTUAL BUDWORM MODEL FOLIAGE ARRAYS ARE LOADED IN BWADPV.
C
      DO 550 IHOST=1,6
      IF (IFHOST(IHOST).EQ.0) GOTO 550
      DO 540 ICROWN=1,9
      DO 530 IFAGE=1,4
      FOLADJ(IHOST,ICROWN,IFAGE)=FOLPOT(IHOST,ICROWN,IFAGE)*
     >                           POFPOT(IHOST,ICROWN,IFAGE)
  530 CONTINUE
  540 CONTINUE
  550 CONTINUE
C
C     IF FOLIAGE PROFILE AND SITE DATA ARE REQUESTED, THEN:
C     WRITE IT (80 CHAR, FIRST COL IS BLANK).
C
      IELEV=IFIX(ELEV+.5)
      CALL BWEADV(IYR1)
C
C     SET TIMING OF MODEL. IBWYR1 AND IBWYR2
C     ARE THE VARIABLES WHICH CONTROL HOW LONG THE BUDWORM MODEL
C     WILL RUN ( YEAR 1 TO YEAR 2 ).  NTODO IS THE NUMBER OF DEFOLS,
C     IF ANY, THAT THE BUDWORM MODEL WILL DO.  BWFINT IS THE CYCLE
C     INTERVAL.
C
      IBWYR1=IY(ICYC)
      IBWYR2=IBWYR1+IFINT-1
      BWFINT=FINT
      IF (BWFINT.LT.1.0) BWFINT=1.0
      IF (.NOT.LDEFOL) GOTO 700
      ITODO=1
      CALL OPFIND(1,MYALL(2),NTODO)
  700 CONTINUE
C
 9000 CONTINUE
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWESIT: WK6=',WK6
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWESIT: FOLPOT=',FOLPOT
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWESIT: POFPOT=',POFPOT
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWESIT: FOLADJ=',FOLADJ
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWESIT: FOLNH=',FOLNH
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWESIT: BWTPHA=',BWTPHA
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWESIT: HTT=',HTT
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWESIT: CRT=',CRT
      
      IF (DEBUG) WRITE (JOSTND,*) 'EXIT BWESIT: ICYC = ',ICYC
      RETURN
      END