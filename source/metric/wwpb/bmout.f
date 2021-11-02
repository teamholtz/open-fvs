      SUBROUTINE BMOUT (I,IYEAR)
C----------
C METRIC-WWPB $Id: bmout.f 2464 2018-07-27 15:36:37Z gedixon $
C----------
C     Westwide Pine Beetle model stand state variables.
C     Most output variables reflect conditions at the *beginning* of reported year 
C     (or cycle) *after* WWPBM-specific management activities (sanitize, salvage, 
C     pheromones), and *after* other WWPBM-specific phenomena /submodels 
C     (other BB, defoliators, fire, windthrow, other mort [QMORT]).
C     Reported removals (from WWPBM-specific management) and beetle-induced 
C     mortalities represent during-the-year conditions, *after* beetles
C     have dispersed and *after* beetle induced mortality has occurred but 
C     *before* trees and BA have been removed from the tree lists.
C     There are some exceptions to this, as noted.   
C
C     CALLED FROM -- BMDRV
C
C     This routine writes 6 different output files, 4 of which are now 
C     schedulable as stand level activities and are thus writable to DataBase.
C
C     Top two in list below are not DB-writable (flat text files only)
C
C                          FILENAME          UNIT   UNIT #   ACTVTY  DB
C          FILE           EXTENSION   LOGICAL NUM   VARIABLE  CODE   LOGICAL

C   Landscape output file   (*.bml)   LBMLPY   29   JBMLPY
C   Cycle output file       (*.bmc)   LBMCYC   25   JBMCYC
C   Main output file        (*.bmn)   ------   26   JBMAIN    2301   JBMDB(1,STAND#)
C   Detailed By Size-Class  (*.bmt)   ------   27   JBMTRE    2302   JBMDB(2
C   Detailed BKP            (*.bmb)   ------   28   JBMBKP    2302   JBMDB(3
C   Detailed Vol by SC      (*.bmv)   ------   30   JBMVOL    2304   JBMDB(4
C
C NOTE: THE METHODOLOGY USED TO DETEMINE IF WRITING IS TO OCCUR IS NEW. 
C       WE ARE *NOT* USING THE GLOBAL PROCESSOR.  INSTEAD, WE QUERY THE STANDARD 
C       STAND-LEVEL OPTION PROCESSOR IN BMSDIT AND FETCH THE ACTIVITY PARAMETERS 
C       (DATES, INTERVALS) FOR WRITING, WHICH WE SAVE AS WWPBM VARIABLES ARRAYED
C       BY STAND (IBEG(1-4,STAND) IEND(1-4,STAND),ISTP(1-4,STAND).  
C       WE ALSO QUERY DB TO FETCH THE DBFLAG VARIABLES INDICATING IF USER IS
C       REQUESTING WRITING TO DB-ONLY (FLAG=2) OR TO DB IN ADDITION TO THE STANDARD
C       OUTPUT (FLAG=1).  THE DBFLAG IS SET IN DBSIN VIA NEW TABLE-REQUEST KEWYORDS :
C       PPBMMAIN,PPBMTREE,PPBMBKP,PPBMVOL, SETTING THE DBFLAG VARIABLES:
C       IBMMMAIN,IBMTREE,IBMBKP,AND IBMVOL, RESPECTIVELY.  THESE ARE TRANSLATED 
C       IN BMSDIT TO WWPBM VARS (INDEXED BY STAND): JBMDB(1-4, STAND) 
C==============================================================================
C
C     LANDSCAPE OUTPUT FILE CONTENTS: 
C     "LS AVG" = LANDSCAPE AVERAGE
C     ALL AVERAGES ARE (STOCKABLE) STAND AREA WEIGHTED
C
C      LS_BKP:  LS AVG BKP (POST REPRODN, POST-DISPERSAL)
C      LS_RV:   LS AVG RATING VALUE
C      LS_BA:   LS AVG STAND TOTAL BASAL AREA (SQ FT PER ACRE)
C      LS_BAH:  LS AVG BA HOST (SQ FT/ACRE)
C      LS_BAK:  LS AVG BA BEETLE KILLED THIS YEAR, SQ FT/ACRE
C      LS_TPA:  LS AVG TREES PER ACRE (TPA) TOTAL
C      LS_TPAH: LS AVG TPA HOST
C      LS_TPAK: LS AVG TPA BEETLE KILLED
C      LS_VOL:  LS AVG WWPBM-ESTIMATED STAND VOLUME
C      LS_VOLH: LS AVG WWPBM-ESTIMATED VOLUME OF HOST
C      LS_VOLK: LS AVG WWPBM-ESTIMATED VOLUME BEETLE KILLED THIS YEAR
C      LS_BASP: LS AVG BASAL AREA OF SPECIAL TREES (SQ FT / ACRE)
C      LS_SPCLT: LS AVG TPA SPECIAL TREES
C      LS_IPSLS: LS AVG IPS SLASH (TONS/ACRE)
C      LS_BASAN: LS AVG BASAL AREA OF *LIVE* TREES SANITIZED (SQ FT / ACRE TREATED)
C      LSTPASAN: LS AVG TPA SANITIZED ( * ! LIVE + DEAD ! * ) PER TREATED ACRE
C      LSVOLSAN: LS AVG VOLUME SANITIZED (LIVE PLUS DEAD) PER TREATED ACRE
C      SANACRES: ACRES SANITIZED
C      LSVOLSAL: LS AVG VOLUME SALVAGED (DEAD, BY DEFINITION) PER TREATED ACRE
C      SALACRES: ACRES SALVAGED
C      TACRES:   STOCKABLE ACRES
C
C==============================================================================
C
C     CYCLE OUTPUT FILE 
C     IF REQUESTED, THIS FILE IS WRITTEN FOR ALL STOCKABLE STANDS IN ALL 
C        CYCLE-BOUNDARY YEARS.  
C     VALUES REPORTED ARE EITHER CYCLE-BEGINNING VALUES (FOR VARIABLE NAMES 
C        BEGINNING w/ "CB") OR ELSE CYCLE TOTAL VALUES (FOR VARIABLE NAMES 
C        BEGINNING w/ "CT" OR "CY")
C
C     CB_BKP(I)   BKP (POST REPRODN, POST DISPERSAL)
C     CB_RV(I)    RV
C     CB_BATOT(I) TOTAL STAND BASAL AREA
C     CB_BAH(I)   BASAL AREA OF HOST
C     CB_TPA(I)   TOTAL TREES PER ACRE
C     CB_TPAH(I)  TPA HOST
C     CB_VOL(I)   TOTAL VOLUME (WWPBM-ESTIMATED)
C     CB_VOLH(I)  VOLUME HOST (WWPBM-ESTIMATED)
C     CBIPSLSH(I) IPS SLASH (TONS PER ACRE)(RECENT FUEL OF QUALIFYING SIZE)
C     CT_BAK(I)   BASAL AREA BEETLE-KILLED DURING THE CYCLE
C     CT_TPAK(I)  TPA BEETLE-KILLED DURING THE CYCLE
C     CT_VOLK(I)  VOLUME BEETLE-KILLED DURING THE CYCLE
C     CT_BASAN(I) BA SANITIZED DURING THE CYCLE (CUMULATIVE)
C     CT_TRSAN(I) TPA SANITIZED DURING THE CYCLE (CUMULATIVE)
C     CYVOLSAN(I) VOLUME SANITIZED DURING THE CYCLE (CUMULATIVE)
C     CYVOLSAL(I) VOLUME SALVAGED DURING HE CYCLE (CUMULATIVE)
C
C==============================================================================
C
C     MAIN OUTPUT FILE--THIS REPORTING IS NOW A STAND-LEVEL ACTIVITY
C
C     KEYWORDS MUST BE ATTACHED TO EACH STAND FOR WHICH OUTPUT IS DESIRED.
C     USER MAY REQUEST BEGINNING YEAR, ENDING YEAR, AND FREQUENCY INTERVAL TO 
C        WRITE THIS OUTPUT, AS WELL AS THE STANDS.  
C     DIFFERNT INTERVALS WITH DIFFERENT FREQUENCIES MAY BE SPECIFIED
C     (i.e. MULTIPLE INSTANCES OF THE KEYWORD IS ALLOWED. 
C     VARIABLES ARE STATE VARIABLES REPRESENTING THE STAND CONDITIONS AT THE 
C       BEGINNING OF THE REPORTED YEAR, OR (IN THE CASE OF MORTALITY & REMOVALS)
C       * DURING * THE REPORTED YEAR
C     THOSE VARIABLES INDEXED "(I)" ARE ALREADY AVAILABLE (IN COMMON)

C     OLDBKP(I),    BKP PER ACRE AFTER REPRODUCTION BUT BEFORE DISPERSAL
C     BKPA(I),      BKP PER ACRE AFER DISPERSAL
C     GRFSTD(I),    RATING VALUE
C     BASTD(I),     TOTAL BASAL AREA (SQ FT PER ACRE)
C     BAH(I,NSCL+1) BASAL AREA OF HOST (SQ FT / ACRE)
C     BAK_YR,       BASAL AREA BEETLE-KILLED (SQ FT PER ACRE)
C     TPA_YR,       TOTAL TPA IN THE STAND
C     TREE(I,NSCL+1,1), TPA HOST 
C     TPAK_YR,     TPA BEETLE-KILLED THIS YEAR
C     VOL_YR,      STAND VOLUME BEGINNING OF YEAR (CU FT / ACRE) WWPBM-ESTIMATED
C     VOLH_YR,     VOLUME OF HOST CU FT/ACRE; WWPBM-ESTIMATED
C     VOLK_YR,     VOLUME BEETLE-KILLED THIS YEAR
C     BA_SP,       BASAL AREA OF "SPECIAL" TREES AT BEGINNING OF YEAR 
C                   =AFTER THIS YR's LIGHTNING, ATTRACT PHER, FIRE SCORCH ETC.
C                   & INCLUDING LAST YR's (BUT NOT THIS YR's) PITCHOUTS/STRPKILS
C     SPCL_TPA,    TPA SPECIAL TREES 
C     IPS_SLSH,    IPS SLASH (RECENT DEAD FUEL OF QUALIFYING SIZE) TONS PER ACRE
C     SANBAREM,    BASAL AREA SANITIZED THIS YEAR (LIVE-TREE SANITIATIONS ONLY)
C     SANITREM,    TPA SANITIZED (LIVE-TREE SANITATIONS ONLY)
C     SREMOV(I),   TPA SANITIZED --LIVE PLUS DEAD TREE SANITATIONS
C     VOLREM(I,1), VOLUME REMOVED SANITATION (ALL TREES, LIVE + DEAD)
C     VOLREM(I,2)  VOLUME REMOVED SALVAGE
C
C==============================================================================
C
C     DETAILED OUTPUT FILE--"TREEOUT". ITS REPORTING IS NOW A STAND-LEVEL ACTIVITY
C     CONTAINS OUTPUT VARIABLES BY TREE SIZE-CLASS (ISIZ).
C     TOP 4 ARE LOCAL 1-D ARRAYS SIZE 10 (ISIZ = 1,NSCL).  
C 
C     TPA_SC(ISIZ)  TOTAL TREES PER ACRE BY SC (BEGINNING OF YEAR)
C     TPAH_SC(ISIZ) TPA HOST, BY SC  (BEGINNING OF YEAR)
C     TPAKLL(ISIZ)  TPH BEETLE-KILLED BY SC (DURING THE YEAR)
C     SPCL_TRE(ISIZ)TPA OF SPECIAL TREES (BEGINNING OF YEAR)
C     AAREMS(I,ISIZ)LIVE TPA REMOVED VIA SANITATION BY SC (DURING THE YEAR--FROM BMSANI)
C
C==============================================================================
C
C     DETAILED OUTPUT FILE--"BKPOUT". ITS REPORTING IS NOW A STAND-LEVEL ACTIVITY
C     CONTAINS INFORMATION ABOUT BKP DYNAMICS AND RATING VALUES.
C     VARIABLES REFLECT STATUS AT THE BEGINNING OF, OR DURING, THE YEAR REPORTED
C     MOST ALL OF THESE IN COMMON
C
C     OLDBKP(I),    BKP PER ACRE AFTER REPRODUCTION BUT BEFORE DISPERSAL
C     BKPA(I),      BKP PER ACRE AFER DISPERSAL AND BKP MORTALITY
C     SELFBKP(I),   BKP/ACRE ALLOCATED TO SELF (NOT EXPORTED TO LS OR OW) BEFORE BKP MORT
C     TO_LS,        BKP ALLOCATED TO OTHER STANDS IN LS--BEFORE BKP MORT
C     FRM_LS,       BKP IMMIGRATING FROM OTHER STANDS IN THE LS--BEFORE BKP MORT
C     BKPIN(I),     BKP IMMIGRATING FROM THE OW--BEFORE BKP MORT
C     BKPOUT(I),    BKP ALLOCATED TO THE OW--BEFORE BKP MORT
C     BKPS(I),      PERCENT SURVIVAL OF BKP
C     FINAL(I,1),   BKP "USED" IN STAND'S FINAL ATTACK (THE STRIP-KILL/PITCHOUT TREE)
C     FINAL(I,2),   SIZE CLASS OF TREE OF FINAL(I,1)
C     GRFSTD(I),    STAND RV
C     DVRV(I,1-9)   RATING VALUES BY DRIVING VARIABLE
C     FASTK(I,1),   TPA KILLED BY FAST DVs (FIRE, WIND, QMORT)
C     FASTK(I,3),   BA KILLED BY FAST DVs
C     FASTK(I,2)    VOL KILLED BY FAST DVs
C
C==============================================================================
C     COMMONS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'PPEPRM.F77' 
      INCLUDE 'PPCNTL.F77'
      
      INCLUDE 'BMPRM.F77'
      INCLUDE 'BMCOM.F77'
      INCLUDE 'BMPCOM.F77'

	INCLUDE 'METRIC.F77'
C
C     DECLARATIONS 
C
      REAL TO_LS,FRM_LS
C
C==============================================================================
C     FYI:
C     MIY(MICYC)     = first year of next cycle 
C     MIY(MICYC) - 1 = last year of current cycle.
C     MIY(MICYC - 1) = first year of current cycle
C
C     INITIALIZE VARIABLES

C     ZERO OUT ANNUAL ACCUMULATORS
C 
      DO 10 ISIZ= 1,NSCL 
         BAK_SC(ISIZ)   = 0.0
         TPA_SC(ISIZ)   = 0.0
         TPAH_SC(ISIZ)  = 0.0
         TPAKLL(ISIZ)   = 0.0
         TVOL_SC(ISIZ)  = 0.0
         HVOL_SC(ISIZ)  = 0.0
         VOLK_SC(ISIZ)  = 0.0
         SPCL_TRE(ISIZ) = 0.0
   10 CONTINUE 
      BAK_YR  = 0.0
      TPA_YR  = 0.0
      TPAK_YR = 0.0
      VOL_YR  = 0.0
      VOLH_YR = 0.0
      VOLK_YR = 0.0
      BA_SP   = 0.0
      SPCL_TPA = 0.0
      SANBAREM = 0.0
      SANITREM = 0.0
      PROPHKLD = 0.0
      IPS_SLSH = 0.0
C
C IF LANDSCAPE OR CYCLE OUTPUT IS REQUESTED, PROCEED, (PROCESS ALL STANDS)
C REGARDLESS OF THE STATUS OF STAND-LEVEL (MAIN,TREE,BKP,VOL) REQUESTS FOR THIS STAND       
C
      IF(LBMLPY .OR. LBMCYC)GO TO 15
C
C IF WE'RE HERE, LANDSCAPE OR CYCLE OUTPUT NOT REQUESTED, BUT MAYBE STAND-LEVEL IS.
C IF ANY OF THE THREE--MAIN, TREE, OR VOL--IS DUE THIS YEAR, PROCEED
C
      IF (IYEAR .LT. IEND(1,I)) THEN          !IF TRUE, THEN PARAMETERS HAVE BEEN SET
         IF((IYEAR .EQ. IBEG(1,I)).OR.
     >   (MOD(IYEAR-IBEG(1,I),ISTP(1,I)).EQ.0))GO TO 15                      
      ENDIF
C
      IF (IYEAR .LT. IEND(2,I)) THEN          !IF TRUE, THEN PARAMETERS HAVE BEEN SET
         IF((IYEAR .EQ. IBEG(2,I)).OR.
     >   (MOD(IYEAR-IBEG(2,I),ISTP(2,I)).EQ.0))GO TO 15                      
      ENDIF
C
      IF (IYEAR .LT. IEND(4,I)) THEN          !IF TRUE, THEN PARAMETERS HAVE BEEN SET
         IF((IYEAR .EQ. IBEG(4,I)).OR.
     >   (MOD(IYEAR-IBEG(4,I),ISTP(4,I)).EQ.0))GO TO 15                      
      ENDIF
C
C OTHERWISE, GO TO DETAILED BKP SECTION
C
      GO TO 800
C
   15 CONTINUE
C
C     BEGIN CALCULATING STAND AND SIZE-CLASS LEVEL VARIABLES.
C     FETCH ALL OF THESE REGARDLESS OF WHICH OUTPUTS ARE REQUESTED
C     (we might derive some we don't need, but it's simpler this way)
C
      DO 20 ISIZ= 1,NSCL
        TPAKLL(ISIZ) = PBKILL(I,ISIZ) + ALLKLL(I,ISIZ) ! 6) TPA BTL KLD FOR SC 
        IF (TREE(I,ISIZ,1) .GT. 1E-6) THEN
           PROPHKLD = TPAKLL(ISIZ) / TREE(I,ISIZ,1)    ! PROPORTION OF HOST TREES BTL KLD [we need this for BAK by SC,
        ELSE                                           ! which we need to get *total* BA Kld
           PROPHKLD = 0.0
        ENDIF
        BAK_SC(ISIZ) = BAH(I,ISIZ) * PROPHKLD          ! 3) BAK by SC
        TPA_SC(ISIZ) = TREE(I,ISIZ,1) + TREE(I,ISIZ,2) ! 4) TOTAL TPA by SC 
        TPAH_SC(ISIZ)= TREE(I,ISIZ,1)                  ! 5) TPAH by SC. Assigned to new 1-D array for passing to DB
        TVOL_SC(ISIZ) = (TVOL(I,ISIZ,1)*TREE(I,ISIZ,1)
     >       + TVOL(I,ISIZ,2)*TREE(I,ISIZ,2))          ! 7) TOT VOL by SC (index 1 = host, index 2 = non-host)
        HVOL_SC(ISIZ) = TVOL(I,ISIZ,1)*TREE(I,ISIZ,1)  ! 8) VOL HOST by SC
        VOLK_SC(ISIZ) = TPAKLL(ISIZ) * TVOL(I,ISIZ,1)  ! 9) VOL KLD BY SC (TVOL in common holds vol/tree by sc)
        SPCL_TRE(ISIZ)= SPCLT(I,ISIZ,1)*TREE(I,ISIZ,1) ! 22 TPA special by size class 
                                                       !(Note:3rd argument on SPCLT is "ipass": 1= MAIN BTL, 2 = IPS (if secondary)
C
C                             STAND LEVEL VARS
C Some we have in common, some we need to accumulate within this loop
C
                                            ! 10) total stand BA is in BASTD() (in BMCGRF)
                                            ! 11) BAH for stand we have in BAH()
        BAK_YR  = BAK_YR  + BAK_SC(ISIZ)    ! 12) BA beetle killed
        TPA_YR  = TPA_YR  + TPA_SC(ISIZ)    ! 13) TPA for stand ALTERNATIVELY: [TREE(I,NSCL+1,1) + TREE(I,NSCL+1,2)]
                                            ! 14) TPAH we have in TREE(I,NSCL+1,1)
        TPAK_YR = TPAK_YR + TPAKLL(ISIZ)    ! 15) TPA killed 
        VOL_YR  = VOL_YR  + TVOL_SC(ISIZ)   ! 16) Stand Volume
        VOLH_YR = VOLH_YR + HVOL_SC(ISIZ)   ! 17) Volume Host
        VOLK_YR = VOLK_YR + VOLK_SC(ISIZ)   ! 18) Volume host beetle-killed
C                                           ! 19) BKP: Use var. OLDBKP() to get PREDISPERSAL (Note: this is POST REPRODN!!) 
        ! Note that we don't yet have a var to hole TRUE beginning of year BKP (LAST YEAR'S MINUS PITCHOUTS)
        ! AND NOTE: var BKPA() [from BMATCT] holds POST DISPERSAL (and POST-INFLIGHT MORTALITY) BKP / Acre
        ! THE ACTUAL BKP() ARRAY HAS BEEN DECREMENTED DOWN TO 0 BY TREE CONSUMPTION OF BKP IN BMISTD
C
                                            ! 20) RV -->IN COMMON : GRFSTD()
        ! NOTE: FOR COMPONENT RVs, WE HAVE (in common) TWO kinds:
        ! DVRV(STND,1-9) [= DV RVs, by stand & by DV--but NOT by SC], AND
        ! GRF(STAND,SIZECLASS) for RVs by Size Class (CUMULATIVE FOR ALL DVs)
C
        BA_SP=BA_SP+TREE(I,ISIZ,1)*MSBA(ISIZ)*SPCLT(I,ISIZ,1) ! 21) BA special
        SPCL_TPA = SPCL_TPA + SPCL_TRE(ISIZ)                  ! 22b) TPA special. )
        SANBAREM=SANBAREM+AAREMS(I,ISIZ)*MSBA(ISIZ)           ! 23) BA Sanit removal (LIVE only!). AAREMS IS NEW.  
C                                                  ! KEEPING ORIGINAL AREMS ARRAY (ZEROED CYCLICALLY) AS-IS, FOR USE IN BMKILL
        SANITREM=SANITREM+AAREMS(I,ISIZ)     ! 24) TPA Sanit removal (LOW RV LIVE TREE REMOVAL ONLY)
                                            ! 24b) TPA Sanit removal ALL stems (recent dead plus live low-RV removals) 
                                            !      available in common SREMOV(I)
                                            ! 25) VOL SAN in common VOLREM(I,1) (RECENT KILLS PLUS LOW RV LIVE TREES)
                                            ! 26) VOL SALV in common VOLREM(I,2)
                                            ! 27) BKP REMVD SANIT (NEW VAR IN COMMON, IN BMSANI: [REMBKP(I)]
                                            ! 28) TWO OUTPUT VARS CALCULATED IN BKPOUT SECTION
   20 CONTINUE
C
C FETCHES IPS SLASH (ONLY) --(BEGINNING OF YR)
      DO 300 J=1,MXDWHC
         DO 320 K=1,MXDWHZ
            IPS_SLSH =IPS_SLSH + DWPHOS(I,J,K)   ! IPS SLASH
  320    CONTINUE
  300 CONTINUE
C
C     IF CYCLE OUTPUT NOT REQUESTED, BYPASS
C
      IF (.NOT. LBMCYC) GO TO 400  
C
C     HOLD SOME CYCLE-BEGINNING VALUES IF WE'RE IN FIRST YEAR OF A CYCLE
C     AND INITIALIZE THE CYCLE-ACCUMULATOR VARIABLES TO ZERO
C
      IF (IYEAR .EQ. MIY(MICYC-1)) THEN
         CB_BKP(I)   = BKPA(I)
         CB_RV(I)    = GRFSTD(I)
         CB_BATOT(I) = BASTD(I)
         CB_BAH(I)   = BAH(I,NSCL+1)
         CB_TPA(I)   = TREE(I,NSCL+1,1) + TREE(I,NSCL+1,2)
         CB_TPAH(I)  = TREE(I,NSCL+1,1)
         CB_VOL(I)   = VOL_YR
         CB_VOLH(I)  = VOLH_YR
         CBIPSLSH(I) = IPS_SLSH
         CT_BAK(I)   = 0.0
         CT_TPAK(I)  = 0.0
         CT_VOLK(I)  = 0.0
         CT_BASAN(I) = 0.0
         CT_TRSAN(I) = 0.0
         CYVOLSAN(I) = 0.0
         CYVOLSAL(I) = 0.0
      ENDIF
C
C     FOR OTHERS, ACCUMULATE OVER THE CYCLE (CYCLE TOTALS)
C
      CT_BAK(I)   = CT_BAK(I)   + BAK_YR      ! BASAL AREA BEETLE KILLED
      CT_TPAK(I)  = CT_TPAK(I)  + TPAK_YR     ! TPA BEETLE KILLED
      CT_VOLK(I)  = CT_VOLK(I)  + VOLK_YR     ! VOLUME KILLED
      CT_BASAN(I) = CT_BASAN(I) + SANBAREM    ! BA SANITIZED. *LIVE* TREE (LOW RV, UNATTACKED) SANITs ONLY!
      CT_TRSAN(I) = CT_TRSAN(I) + SREMOV(I)   ! TPA SANITIZED FROM BMSANI! (all: live + dead removals)
      CYVOLSAN(I) = CYVOLSAN(I) + VOLREM(I,1) ! VOL SANITIZED FROM BMSANI! (all; live + dead removals)
      CYVOLSAL(I) = CYVOLSAL(I) + VOLREM(I,2) ! VOL SALVAGED FROM BMSALV
C
  400 CONTINUE
C
C     IF LANDSCAPE AVERAGE OUTPUT NOT REQUESTED, BYPASS
C
      IF (.NOT. LBMLPY) GOTO 500  
C
C     -------------------LANDSCAPE OUTPUT FILE PROCESSING (*.bml)---------------
C
C     LANDSCAPE OUTPUT FILE CONTENTS: 
C     "LS AVG" = LANDSCAPE AVERAGE
C     ALL AVERAGES ARE (STOCKABLE) STAND AREA WEIGHTED
C
C      LS_BKP:  LS AVG BKP (POST REPRODN, POST-DISPERSAL)
C      LS_RV:   LS AVG RATING VALUE
C      LS_BA:   LS AVG STAND TOTAL BASAL AREA (SQ FT PER ACRE)
C      LS_BAH:  LS AVG BA HOST (SQ FT/ACRE)
C      LS_BAK:  LS AVG BA BEETLE KILLED THIS YEAR, SQ FT/ACRE
C      LS_TPA:  LS AVG TREES PER ACRE (TPA) TOTAL
C      LS_TPAH: LS AVG TPA HOST
C      LS_TPAK: LS AVG TPA BEETLE KILLED
C      LS_VOL:  LS AVG WWPBM-ESTIMATED STAND VOLUME
C      LS_VOLH: LS AVG WWPBM-ESTIMATED VOLUME OF HOST
C      LS_VOLK: LS AVG WWPBM-ESTIMATED VOLUME BEETLE KILLED THIS YEAR
C      LS_BASP: LS AVG BASAL AREA OF SPECIAL TREES (SQ FT / ACRE)
C      LS_SPCLT: LS AVG TPA SPECIAL TREES
C      LS_IPSLS: LS AVG IPS SLASH (TONS/ACRE)
C      LS_BASAN: LS AVG BASAL AREA OF *LIVE* TREES SANITIZED (SQ FT / ACRE TREATED)
C      LSTPASAN: LS AVG TPA SANITIZED ( * ! LIVE + DEAD ! * ) PER TREATED ACRE
C      LSVOLSAN: LS AVG VOLUME SANITIZED (LIVE PLUS DEAD) PER TREATED ACRE
C      SANACRES: ACRES SANITIZED
C      LSVOLSAL: LS AVG VOLUME SALVAGED (DEAD, BY DEFINITION) PER TREATED ACRE
C      SALACRES: ACRES SALVAGED
C      TACRES:   STOCKABLE ACRES
C
C WEIGHT SOME FOR LANDSCAPE AVERAGES
C USE OF COUNTER "ICNT" ALONG W/ "BMEND METHOD" ADAPTED FROM ORIG CODE.
C BMEND = # STOCKED STANDS.  THIS ROUTINE IS ENTERED ONLY IF STAND IS STOCKED
C WHEN COUNTER HITS BMEND, WE'VE PROCESSED ALL STOCKED STANDS, 
C AND THUS CAN CALCULATE A LANDSCAPE MEAN.
C
C     IF IT IS NOT THE VERY FIRST TIME THROUGH, RE-SET ICNT TO 0 WHEN WE'VE
C     FINISH A LOOP THROUGH ALL STOCKED STANDS (WHEN ICNT = BMEND, WE'RE AT 
C     THE BEGINNING OF THE NEXT YEAR.
C
      IF (JCNT .GE. BMEND) JCNT = 0
C
C     IF ICNT IS ZERO, WE'RE AT FIRST STAND THROUGH FOR THIS YEAR, SO 
C     INITIALIZE VARIABLES
C
      IF(JCNT .EQ.0) THEN
         WTD_BKP = 0.0
         WTD_RV  = 0.0
         WTD_BA  = 0.0
         WTD_BAH = 0.0
         WTD_BAK = 0.0
         WTD_TPA = 0.0
         WTD_TPAH= 0.0
         WTD_TPAK= 0.0
         WTD_VOL = 0.0
         WTD_VOLH= 0.0
         WTD_VOLK= 0.0
         WTD_BASP= 0.0
         w_SPCL  = 0.0
         w_IPSLSH= 0.0
         SANACRES= 0.0
         w_BASAN = 0.0
         w_TPASAN= 0.0
         w_VOLSAN= 0.0
         SALACRES= 0.0
         w_VOLSAL= 0.0
         LS_BKP  = 0.0
         LS_RV   = 0.0
         LS_BA   = 0.0
         LS_BAH  = 0.0
         LS_BAK  = 0.0
         LS_TPA  = 0.0
         LS_TPAH = 0.0
         LS_TPAK = 0.0
         LS_VOL =  0.0
         LS_VOLH = 0.0
         LS_VOLK = 0.0
         LS_BASP = 0.0
         LS_SPCLT =0.0
         LS_IPSLS =0.0
         LS_BASAN =0.0
         LSTPASAN =0.0
         LSVOLSAN =0.0
         LSVOLSAL =0.0
      ENDIF
C
C     INCREMENT ICNT (Its initialized at zero in BMINIT)
      JCNT = JCNT + 1
C
C     FETCH THE STAND'S ACREAGE
C
      CALL SPLAAR (I, ACRES, IRC)
      IF (ACRES .LE. 0.) ACRES = 1.0
C
      WTD_BKP  = WTD_BKP  + OLDBKP(I) * ACRES
      WTD_RV   = WTD_RV   + GRFSTD(I) * ACRES
      WTD_BA   = WTD_BA   + BASTD(I)  * ACRES
      WTD_BAH  = WTD_BAH  + BAH(I,NSCL+1) * ACRES
      WTD_BAK  = WTD_BAK  + BAK_YR     * ACRES
      WTD_TPA  = WTD_TPA  + TPA_YR    * ACRES
      WTD_TPAH = WTD_TPAH + TREE(I,NSCL+1,1) * ACRES
      WTD_TPAK = WTD_TPAK + TPAK_YR  * ACRES
      WTD_VOL =  WTD_VOL +  VOL_YR   * ACRES
      WTD_VOLH = WTD_VOLH + VOLH_YR  * ACRES
      WTD_VOLK = WTD_VOLK + VOLK_YR  * ACRES
      WTD_BASP = WTD_BASP + BA_SP    * ACRES
      w_SPCLT  = w_SPCLT  + SPCL_TPA * ACRES
      w_IPSLSH = w_IPSLSH + IPS_SLSH * ACRES
C
C     ACCUMULATE SANITATION INFO
C
! SREMOV IS IN BMCOM.F77, FROM BMSANI; ITS THE TPA (live plus recent dead) REMOVED VIA SANIT
      IF (SREMOV(I) .GT. 0) THEN 
         SANACRES = SANACRES + ACRES 
         w_BASAN  = w_BASAN  + SANBAREM    * ACRES
         w_TPASAN = w_TPASAN + SREMOV(I)   * ACRES
         w_VOLSAN = w_VOLSAN + VOLREM(I,1) * ACRES
      ENDIF
C
C     ACCUMULATE SALVAGES
C
      IF (VOLREM(I,2) .GT.0) THEN
         SALACRES = SALACRES + ACRES
         w_VOLSAL = w_VOLSAL + VOLREM(I,2) * ACRES
      ENDIF
C
C WHEN LAST STAND PROCESSED FOR YEAR, CALCULATE LANDSCAPE AVERAGES
C NOTE: "TACRES" IS IN COMMON, SET IN BMSETP.  
C IT IS THE TOTAL AREA OF THE STOCKABLE PORTION OF LS, IN ACRES.
C NOTE: SANITATIONS AND SALVAGES ARE NOW REPORTED ON THEIR OWN AREA BASES!
C
      IF (JCNT .GE. BMEND) THEN
C
         LS_BKP  = WTD_BKP / TACRES
         LS_RV   = WTD_RV  / TACRES
         LS_BA   = WTD_BA  / TACRES
         LS_BAH  = WTD_BAH / TACRES
         LS_BAK  = WTD_BAK / TACRES
         LS_TPA  = WTD_TPA / TACRES
         LS_TPAH = WTD_TPAH/ TACRES
         LS_TPAK = WTD_TPAK/ TACRES
         LS_VOL =  WTD_VOL / TACRES
         LS_VOLH = WTD_VOLH/ TACRES
         LS_VOLK = WTD_VOLK/ TACRES
         LS_BASP = WTD_BASP/ TACRES
         LS_SPCLT = w_SPCLT / TACRES 
         LS_IPSLS = w_IPSLSH / TACRES
C
         IF (SANACRES .GT. 0) THEN
            LS_BASAN = w_BASAN  / SANACRES
            LSTPASAN = w_TPASAN / SANACRES
            LSVOLSAN = w_VOLSAN / SANACRES
         ENDIF
C
         IF (SALACRES .GT. 0) THEN
            LSVOLSAL = w_VOLSAL / SALACRES
         ENDIF
C
C     IF THE HEADER AIN'T DONE, DO IT
C
         IF (.NOT. LPRHDBML)THEN
            WRITE(JBMLPY,410)
C                      2345678901234567890123456789012345678901234567890
  410       FORMAT(1X,'YEAR     BKP   RV    BA   BAH   BAK    TPH   '
     >                ' TPHH  TPHK  TOTVOL    VOLH  VOLKLD BASPCL '
     >                ' #SPCL IPSSLSH BASAN TPHSAN  VOLSAN SANHA   '
     >                ' VOLSAL SALHA   TOTHA  ')
C
            LPRHDBML = .TRUE.
         ENDIF
C
         WRITE (JBMLPY,420)
     >     IYEAR,
     >     LS_BKP*FT2pACRtoM2pHA,
     >     LS_RV,
     >     LS_BA*FT2pACRtoM2pHA,
     >     LS_BAH*FT2pACRtoM2pHA,
     >     LS_BAK*FT2pACRtoM2pHA,        ! BA INFO
     >     LS_TPA/ACRtoHA,
     >     LS_TPAH/ACRtoHA,
     >     LS_TPAK/ACRtoHA,              ! TPA INFO
     >     LS_VOL*FT3pACRtoM3pHA,
     >     LS_VOLH*FT3pACRtoM3pHA,
     >     LS_VOLK*FT3pACRtoM3pHA,       ! VOL INFO
     >     LS_BASP*FT2pACRtoM2pHA,
     >     LS_SPCLT/ACRtoHA,
     >     LS_IPSLS*TItoTM/ACRtoHA,      ! SPECIALTREES
     >     LS_BASAN*FT2pACRtoM2pHA,
     >     LSTPASAN/ACRtoHA,
     >     LSVOLSAN*FT3pACRtoM3pHA,
     >     SANACRES*ACRtoHA,             ! SANITATION
     >     LSVOLSAL*FT3pACRtoM3pHA,
     >     SALACRES*ACRtoHA,
     >     TACRES*ACRtoHA                ! SALVAGE
C
  420    FORMAT(1X,I4,1X,F7.3,1X,F4.2,3(1X,F5.1),3(1X,F6.1),    !TOP9
     >          3(1X,F7.1),2(1X,F6.2),1X,F7.2,                  !VOL&SPCL
     >          1X,F5.1,1X,F6.2,1X,F7.2,1X,F7.1,                !SANITS
     >          1X,F7.2,2(1X,F7.1))
C
      ENDIF
C
C     --------END OF LANDSCAPE AVERAGE OUTPUT PROCESSING----------------
C
C=======================================================================
C
  500 CONTINUE
C
C     ------------   -CYCLE BOUNDARY OUTPUT-----------------------------
C
C     IF REQUESTED, THIS FILE IS WRITTEN FOR ALL STOCKABLE STANDS IN 
C        ALL CYCLE-BOUNDARY YEARS.(* see footnote *)
C     VALUES REPORTED ARE EITHER CYCLE-BEGINNING ("CB_") VALUES 
C        OR CYCLE TOTAL ("CT_") VALUES 
C
C     CB_BKP(I)   BKP (POST REPRODN, POST DISPERSAL
C     CB_RV(I)    RV
C     CB_BATOT(I) TOTAL STAND BASAL AREA
C     CB_BAH(I)   BASAL AREA OF HOST
C     CB_TPA(I)   TOTAL TREES PER ACRE
C     CB_TPAH(I)  TPA HOST
C     CB_VOL(I)   TOTAL VOLUME (WWPBM-ESTIMATED)
C     CB_VOLH(I)  VOLUME HOST (WWPBM-ESTIMATED)
C     CBIPSLSH(I) IPS SLASH (TONS PER ACRE)
C     CT_BAK(I)   BASAL AREA BEETLE-KILLED DURING THE CYCLE
C     CT_TPAK(I)  TPA BEETLE-KILLED DURING THE CYCLE
C     CT_VOLK(I)  VOLUME BEETLE-KILLED DURING THE CYCLE
C     CT_BASAN(I) BA SANITIZED DURING THE CYCLE (CUMULATIVE)
C     CT_TRSAN(I) TPA SANITIZED DURING THE CYCLE (CUMULATIVE)
C     CYVOLSAN(I) VOLUME SANITIZED DURING THE CYCLE (CUMULATIVE)
C     CYVOLSAL(I) VOLUME SALVAGED DURING HE CYCLE (CUMULATIVE)
C
C (*) FOOTNOTE: We could ammend this.  Via the global option processor,
C      we could allow users to (1) specify a range of years to output, 
C      AND (2) optionally provide supplemental list of stands to output.
C=======================================================================
C
C IF ITs CYCLE-END, AND WE'VE REQUESTED CYCLE (LANDSCAPE) OUTPUT FILE...
C
      IF (IYEAR .EQ. (MIY(MICYC) - 1) .AND. LBMCYC) THEN
C
         CALL SPLAAR (I, ACRES, IRC)
         IF (ACRES .LE. 0.) ACRES = 1.0
C
C     IF THE HEADER AIN'T DONE, DO IT
C
         IF (.NOT. LPRHDBMC)THEN
            WRITE(JBMCYC,510)
C                      2345678901234567890123456789012345678901234567890
  510       FORMAT(1X,'YEAR STAND ID                     BKP  RV   ',
     >                ' BA   BAH   BAK    TPH   TPHH   TPHK  TOTVOL ',
     >                '   VOLH  VOLKLD IPSSLSH BASAN TPHSAN  VOLSAN ',
     >                ' VOLSAL TOTHA  ')
C
            LPRHDBMC = .TRUE.
         ENDIF
C
         WRITE(JBMCYC,520)
     >    IYEAR,
     >    BMSTDS(I),
     >    CB_BKP(I)*FT2pACRtoM2pHA,
     >    CB_RV(I),
     >    CB_BATOT(I)*FT2pACRtoM2pHA,
     >    CB_BAH(I)*FT2pACRtoM2pHA,
     >    CT_BAK(I)*FT2pACRtoM2pHA,
     >    CB_TPA(I)/ACRtoHA,
     >    CB_TPAH(I)/ACRtoHA,
     >    CT_TPAK(I)/ACRtoHA,
     >    CB_VOL(I)*FT3pACRtoM3pHA,
     >    CB_VOLH(I)*FT3pACRtoM3pHA,
     >    CT_VOLK(I)*FT3pACRtoM3pHA,
     >    CBIPSLSH(I)*TItoTM/ACRtoHA,
     >    CT_BASAN(I)*FT2pACRtoM2pHA,
     >    CT_TRSAN(I)/ACRtoHA,
     >    CYVOLSAN(I)*FT3pACRtoM3pHA,
     >    CYVOLSAL(I)*FT3pACRtoM3pHA,
     >    ACRES*ACRtoHA
C
  520    FORMAT(1X,I4,1X,A26,F6.2,1X,F3.1,3(1X,F5.1),    !THRU BA
     >          3(1X,F6.1),3(1X,F7.1),1X,F7.2,           !TPA,VOL,IPSSLASH
     >          1X,F5.1,1X,F6.2,1X,F7.2,1X,F7.2,1X,F6.1) !SAN,SAL,ACRES
C
      ENDIF
C
C     --------END OF CYCLE BOUNDARY OUTPUT PROCESSING-------------------
C
C=======================================================================
C
C     --------      BEGIN "MAINOUT" PROCESSING--------------------------
C
C     OLDBKP(I),    BKP PER ACRE AFTER REPRODUCTION BUT BEFORE DISPERSAL
C     BKPA(I),      BKP PER ACRE AFER DISPERSAL
C     GRFSTD(I),    RATING VALUE
C     BASTD(I),     TOTAL BASAL AREA (SQ FT PER ACRE)
C     BAH(I,NSCL+1) BASAL AREA OF HOST (SQ FT / ACRE)
C     BAK_YR,       BASAL AREA BEETLE-KILLED (SQ FT PER ACRE)
C     TPA_YR,       TOTAL TPA IN THE STAND
C     TREE(I,NSCL+1,1), TPA HOST 
C     TPAK_YR,     TPA BEETLE-KILLED THIS YEAR
C     VOL_YR,      STAND VOLUME BEGINNING OF YEAR (CU FT / ACRE) WWPBM-ESTIMATED
C     VOLH_YR,     VOLUME OF HOST CU FT/ACRE; WWPBM-ESTIMATED
C     VOLK_YR,     VOLUME BEETLE-KILLED THIS YEAR
C     BA_SP,       BASAL AREA OF "SPECIAL" TREES AT BEGINNING OF YEAR 
C                   =AFTER THIS YR's LIGHTNING, ATTRACT PHER, FIRE SCORCH ETC.
C                   & INCLUDING LAST YR's (BUT NOT THIS YR's) PITCHOUTS/STRPKILS
C     SPCL_TPA,    TPA SPECIAL TREES 
C     IPS_SLSH,    IPS SLASH (RECENT DEAD FUEL OF QUALIFYING SIZE) TONS PER ACRE
C     SANBAREM,    BASAL AREA SANITIZED THIS YEAR (LIVE-TREE SANITIATIONS ONLY)
C     SANITREM,    TPA SANITIZED (LIVE-TREE SANITATIONS ONLY)
C     SREMOV(I),   TPA SANITIZED --LIVE PLUS DEAD TREE SANITATIONS
C     VOLREM(I,1), VOLUME REMOVED SANITATION (ALL TREES, LIVE + DEAD)
C     VOLREM(I,2)  VOLUME REMOVED SALVAGE
C     REMBKP(I)    BKP REMOVED (PER ACRE) VIA SANITATION CUTS
C
C     ******************************************************************
      IF (LBMDEB) WRITE(JBMBPR,540) IBEG(1,I),IEND(1,I),ISTP(1,I),
     >                             JBMAIN,I
  540 FORMAT(' IN BMOUT--MAINOUT: IBEG=',I5,' IEND=',I5,' ISTP=',I5,
     >       'JBMAIN UNIT # =',I3,'FOR BM STAND INDEX=',I5)
C
C IF OUTPUT IS NOT REQUESTED FOR THIS STAND, THIS YEAR, THEN BYPASS
C
      IF ((IYEAR .GT.IEND(1,I)).OR.
     >(IYEAR .NE. IBEG(1,I) .AND. MOD(IYEAR-IBEG(1,I),ISTP(1,I)).NE. 0))
     > GOTO 600 
C
C     IS DB OUTPUT IS REQUESTED? IF SO, SEND IT
C
      IF(JBMDB(1,I) .GT. 0) CALL DBSBMMAIN(
     >   BMSTDS(I),IYEAR,
     >   OLDBKP(I)*FT2pACRtoM2pHA,
     >   BKPA(I)*FT2pACRtoM2pHA,
     >   GRFSTD(I),
     >   BASTD(I)*FT2pACRtoM2pHA,
     >   BAH(I,NSCL+1)*FT2pACRtoM2pHA,
     >   BAK_YR*FT2pACRtoM2pHA,
     >   TPA_YR/ACRtoHA,
     >   TREE(I,NSCL+1,1)/ACRtoHA,
     >   TPAK_YR/ACRtoHA,
     >   VOL_YR*FT3pACRtoM3pHA,
     >   VOLH_YR*FT3pACRtoM3pHA,
     >   VOLK_YR*FT3pACRtoM3pHA,
     >   BA_SP*FT2pACRtoM2pHA,
     >   SPCL_TPA/ACRtoHA,
     >   IPS_SLSH*TItoTM/ACRtoHA,
     >   SANBAREM*FT2pACRtoM2pHA,
     >   SANITREM/ACRtoHA,
     >   SREMOV(I)/ACRtoHA,
     >   VOLREM(I,1)*FT3pACRtoM3pHA,
     >   VOLREM(I,2)*FT3pACRtoM3pHA,
     >   REMBKP(I)*FT2pACRtoM2pHA,
     >   BMCASEID(I))
C
C     IF WERE WRITING *ONLY* TO DB, THEN BYPASS WRITING OF *.BMN FILE
C
      IF (JBMDB(1,I) .EQ. 2) GO TO 600
C
C     WRITE THE STANDARD (NON-DB) MAINOUT FILE
C
C     IF THE HEADER AIN'T DONE, DO IT
C
      IF (.NOT. LPRHD1)THEN
         WRITE(JBMAIN,560)
C                   2345678901234567890123456789012345678901234567890
  560    FORMAT(1X,'STAND ID                   YEAR   BKP1   BKP2 ',
     >             ' RV     BA   BAH   BAK    TPH   TPHH   TPHK ',
     >             ' TOTVOL    VOLH  VOLKLD SP_BA  #SPCL  IPSLSH BASAN',
     >             ' TRSAN1 TRSAN2  VOLSAN  VOLSAL REMBKP  HA   ')
         LPRHD1 = .TRUE.
      ENDIF
C
C     WRITE THE "MAINOUT" OUTPUT FILE TO UNIT JBMAIN (*.bmn)
C
      WRITE(JBMAIN,580)BMSTDS(I),IYEAR,
     >  OLDBKP(I)*FT2pACRtoM2pHA,
     >  BKPA(I)*FT2pACRtoM2pHA,
     >  GRFSTD(I),
     >  BASTD(I)*FT2pACRtoM2pHA,
     >  BAH(I,NSCL+1)*FT2pACRtoM2pHA,
     >  BAK_YR*FT2pACRtoM2pHA,
     >  TPA_YR/ACRtoHA,
     >  TREE(I,NSCL+1,1)/ACRtoHA,
     >  TPAK_YR/ACRtoHA,
     >  VOL_YR*FT3pACRtoM3pHA,
     >  VOLH_YR*FT3pACRtoM3pHA,
     >  VOLK_YR*FT3pACRtoM3pHA,
     >  BA_SP*FT2pACRtoM2pHA,
     >  SPCL_TPA/ACRtoHA,
     >  IPS_SLSH*TItoTM/ACRtoHA,
     >  SANBAREM*FT2pACRtoM2pHA,
     >  SANITREM/ACRtoHA,
     >  SREMOV(I)/ACRtoHA,
     >  VOLREM(I,1)*FT3pACRtoM3pHA,
     >  VOLREM(I,2)*FT3pACRtoM3pHA,
     >  REMBKP(I)*FT2pACRtoM2pHA,
     >  ACRES*ACRtoHA
C
  580 FORMAT(1X,A26,1X,I4,2(1X,F6.2),1X,F3.1,1X,3(1X,F5.1), !THRU BA
     >       3(1X,F6.1),3(1X,F7.1),1X,F5.1,1X,F6.1,1X,F7.2, !TPA,VOL,SPCL,IPSLSH
     >       1X,F5.1,2(1X,F6.2),2(1X,F7.2),1X,F6.2,1X,F6.1) !SANIT,SALV,ACRES
C
C     ------------ END OF MAIN OUTPUT PROCESSING------------------------
C
  600 CONTINUE
C
C=======================================================================
C     -----BEGIN THREE DETAILED OUTPUT FILEs PROCESSING-----------------
C=======================================================================
C
C                          TREEOUT ==> MYACT(2)
C
C     OUTPUT VARs BY SIZE CLASS (SC).  # OF SC's (NSCL) =10, INDEXED BY "ISIZ"
C
C     TPA_SC(ISIZ)  TOTAL TREES PER ACRE BY SC (BEGINNING OF YEAR)
C     TPAH_SC(ISIZ) TPA HOST, BY SC  (BEGINNING OF YEAR)
C     TPAKLL(ISIZ)  TPA BEETLE-KILLED BY SC (DURING THE YEAR)
C     SPCL_TRE(ISIZ)TPA OF SPECIAL TREES BY SC (BEGINNING OF YEAR)
C     AAREMS(I,ISIZ) LIVE TPA REMOVED VIA SANITATION BY SC (DURING THE YEAR)

C     ******************************************************************
      IF (LBMDEB) WRITE(JBMBPR,640) IBEG(2,I),IEND(2,I),ISTP(2,I),
     >                             JBMTRE,I
  640 FORMAT(' IN BMOUT--TREEOUT: IBEG=',I5,' IEND=',I5,' ISTP=',I5,
     >       ' JBMTRE UNIT # =',I3,' BM STAND INDEX=',I5)
C
C IF OUTPUT IS NOT REQUESTED FOR THIS STAND, THIS YEAR, THEN BYPASS
C
      IF ((IYEAR .GT.IEND(2,I)).OR.
     >(IYEAR .NE. IBEG(2,I) .AND. MOD(IYEAR-IBEG(2,I),ISTP(2,I)).NE. 0)) 
     > GOTO 700 
C
C     IF DB OUTPUT IS REQUESTED, SEND IT
C
C     NOTE: TPA_SC,TPAH_SC,TPAKLL,SPCL_TRE ARE 1-DIMENSIONAL ARRAYS,
C           OF SIZE 10, REPRESENTING SIZE CLASSES 1-10
C
      IF(JBMDB(2,I).GT.0) CALL DBSBMTREE(
     >  NSCL,
     >  BMSTDS(I),
     >  IYEAR,
     >  TPA_SC/ACRtoHA,  ! ahh - the magic of implicit array multiplication
     >  TPAH_SC/ACRtoHA,
     >  TPAKLL/ACRtoHA,
     >  SPCL_TRE/ACRtoHA,
     >  AAREMS(I,1)/ACRtoHA,
     >  AAREMS(I,2)/ACRtoHA,
     >  AAREMS(I,3)/ACRtoHA,
     >  AAREMS(I,4)/ACRtoHA,
     >  AAREMS(I,5)/ACRtoHA,
     >  AAREMS(I,6)/ACRtoHA,
     >  AAREMS(I,7)/ACRtoHA,
     >  AAREMS(I,8)/ACRtoHA,
     >  AAREMS(I,9)/ACRtoHA,
     >  AAREMS(I,10)/ACRtoHA,
     >  BMCASEID(I))
C
C   IF WE'RE WRITING *ONLY* TO DB, THEN BYPASS WRITING OF *.BMT FILE
C
      IF (JBMDB(2,I) .EQ.2) GO TO 700
C
C     IF THE HEADER AIN'T DONE, DO IT
C
      IF (.NOT. LPRHD2)THEN
         WRITE(JBMTRE,660)
C                   2345678901234567890123456789012345678901234567890
  660    FORMAT(1X,'STAND ID                   YEAR   TPH_1   TPH_2 ',
     >  ' TPH_3  TPH_4  TPH_5  TPH_6  TPH_7  TPH_8  TPH_9 TPH_10 ',
     >  '  TPHH1   TPHH2  TPHH3  TPHH4  TPHH5  TPHH6  TPHH7  TPHH8 ',
     >  ' TPHH9 TPHH10   TPHK1   TPHK2  TPHK3  TPHK4  TPHK5  TPHK6 ',
     >  ' TPHK7  TPHK8  TPHK9 TPHK10   SPCL1   SPCL2  SPCL2  SPCL4 ',
     >  ' SPCL5  SPCL6  SPCL7  SPCL8  SPCL9 SPCL10    SAN1    SAN2 ',
     >  '  SAN3   SAN4   SAN5   SAN6   SAN7   SAN8   SAN9  SAN10')
         LPRHD2 = .TRUE.
      ENDIF
C
C     WRITE THE "TREEOUT" OUTPUT FILE TO UNIT JBMTRE (*.bmt)
C
      WRITE(JBMTRE,680)
     >  BMSTDS(I),
     >  IYEAR,
     >  TPA_SC/ACRtoHA,
     >  TPAH_SC/ACRtoHA,
     >  TPAKLL/ACRtoHA,
     >  SPCL_TRE/ACRtoHA,
     >  (AAREMS(I,J)/ACRtoHA,J=1,NSCL)
C
  680 FORMAT(1X,A26,1X,I4,5(2(1X,F7.2),8(1X,F6.2)))
C
C     ------- END OF "TREEOUT" OUTPUT PROCESSING------------------------
C=======================================================================
  700 CONTINUE
C
C                          VOLOUT ==> MYACT(4)
C
C     OUTPUT VARs BY ARRAYED SIZE CLASS (SC).  
C
C     TVOL_SC: TOTAL STAND VOLUME PER ACRE BY SC (BEGINNING OF YEAR)
C     HVOL_SC: VOLUME HOST PER ACRE, BY SC  (BEGINNING OF YEAR)
C     VOLK_SC: VOLUME PER ACRE BEETLE-KILLED BY SC (DURING THE YEAR)
C     ******************************************************************
C
      IF (LBMDEB)WRITE(JBMBPR,740)IBEG(4,I),IEND(4,I),ISTP(4,I),JBMVOL,I
  740 FORMAT(' IN BMOUT--VOLOUT: IBEG=',I5,' IEND=',I5,' ISTP=',I5,
     >       ' JBMVOL UNIT #=',I3,'BM STAND INDEX=',I5)
C
C IF OUTPUT IS NOT REQUESTED FOR THIS STAND, THIS YEAR, THEN BYPASS
C
      IF ((IYEAR .GT. IEND(4,I)) .OR. 
     >(IYEAR .NE. IBEG(4,I) .AND. MOD(IYEAR-IBEG(4,I),ISTP(4,I)).NE. 0))
     > GOTO 800 
C
C     IS DB OUTPUT IS REQUESTED? IF SO, SEND IT
C
      IF(JBMDB(4,I).GT.0) CALL DBSBMVOL(
     >  BMSTDS(I),
     >  IYEAR,
     >  TVOL_SC*FT3pACRtoM3pHA,
     >  HVOL_SC*FT3pACRtoM3pHA,
     >  VOLK_SC*FT3pACRtoM3pHA,
     >  NSCL,
     >  BMCASEID(I))
C
C     IF WERE WRITING *ONLY* TO DB, THEN BYPASS WRITING OF *.BMN FILE
C
      IF (JBMDB(4,I) .EQ. 2) GO TO 800
C
C     IF THE HEADER AIN'T DONE, DO IT
C
      IF (.NOT. LPRHD4)THEN
         WRITE(JBMVOL,760)
C                   2345678901234567890123456789012345678901234567890
  760    FORMAT(1X,'STAND ID                   YEAR   TV_SC1   TV_SC2',
     >'   TV_SC3   TV_SC4   TV_SC5   TV_SC6   TV_SC7   TV_SC8   TV_SC9',
     >'    TV_10   HV_SC1   HV_SC2   HV_SC3   HV_SC4   HV_SC5   HV_SC6',
     >'   HV_SC7   HV_SC8   HV_SC9    HV_10   VK_SC1   VK_SC2   VK_SC3',
     >'   VK_SC4   VK_SC5   VK_SC6   VK_SC7   VK_SC8   VK_SC9    VK_10')
C
         LPRHD4 = .TRUE.
      ENDIF
C
C     WRITE THE "VOLOUT" OUTPUT FILE TO UNIT JBMTRE (*.bmt)
C
      WRITE(JBMVOL,780)
     >  BMSTDS(I),
     >  IYEAR,
     >  TVOL_SC*FT3pACRtoM3pHA,
     >  HVOL_SC*FT3pACRtoM3pHA,
     >  VOLK_SC*FT3pACRtoM3pHA
C
  780 FORMAT(1X,A26,1X,I4,30(1X,F8.2))
C
C     ------- END OF "VOLOUT" OUTPUT PROCESSING------------------------
C======================================================================
  800 CONTINUE
C
C                   BKPOUT ==> MYACT(3)---------------------------------
C
C     OLDBKP(I),    BKP PER ACRE AFTER REPRODUCTION BUT BEFORE DISPERSAL
C     BKPA(I),      BKP PER ACRE AFER DISPERSAL (AND AFTER BKP MORTALITY)
C     SELFBKP(I),   BKP/ACRE ALLOCATED TO SELF (NOT EXPORTED TO LS OR OW) BEFORE BKP MORT
C     TO_LS,        BKP ALLOCATED TO OTHER STANDS IN LS--BEFORE BKP MORT
C     FRM_LS,       BKP IMMIGRATING FROM OTHER STANDS IN THE LS--BEFORE BKP MORT
C     BKPIN(I),     BKP IMMIGRATING FROM THE OW--BEFORE BKP MORT
C     BKPOUT(I),    BKP ALLOCATED TO THE OW--BEFORE BKP MORT
C     BKPS(I),      PERCENT SURVIVAL OF BKP
C     FINAL(I,1),   BKP "USED" IN STAND'S FINAL ATTACK (THE STRIP-KILL/PITCHOUT TREE)
C     FINAL(I,2),   SIZE CLASS OF TREE OF FINAL(I,1)
C     REMBKP(I)     BKP REMOVED VIA SANITATION CUTS THIS YEAR
C     GRFSTD(I),    STAND RV
C     DVRV(I,1-9)   RATING VALUES BY DRIVING VARIABLE
C     FASTK(I,1),   TPA KILLED BY FAST DVs (FIRE, WIND, QMORT)
C     FASTK(I,3),   BA KILLED BY FAST DVs
C     FASTK(I,2)    VOL KILLED BY FAST DVs
C
C     ******************************************************************     
C
      IF (LBMDEB)WRITE(JBMBPR,840)IBEG(3,I),IEND(3,I),ISTP(3,I),JBMBKP,I
  840 FORMAT(' IN BMOUT--BKPOUT: IBEG=',I5,' IEND=',I5,' ISTP=',I5,
     >       ' JBMBKP UNIT # =',I3,' BM STAND INDEX=',I5)
C
C IF OUTPUT IS NOT REQUESTED FOR THIS STAND, THIS YEAR, THEN BYPASS
C
      IF ((IYEAR .GT.IEND(3,I)).OR.
     >(IYEAR .NE. IBEG(3,I) .AND. MOD(IYEAR-IBEG(3,I),ISTP(3,1)).NE. 0))
     > GOTO 900 
C
C     CURRENTLY, FOR BKP BOOKKEEPING, WE HAVE PREDISPERSAL AND POST DISPERSAL
C     BKP VLAUES, AND THE FLUXES TO & FROM OW, AND SELF.  
C     BY DIFFERENCE, WE CAN GET FLUX TO & FROM REST OF LS.   E.G. GIVEN:
C
C     PRE-DISPERSAL BKP = To_OW + To_SELF + {To_RESTofLS}
C     ...and...
C     POST-DISPERSAL BKP = From_OW + From_SELF + {FROM_RESTofLS}
C
C     WE KNOW EVERYTHING EXCEPT WHAT'S IN BRAKETS, WHICH IS WHAT WE WANT. SOLVE.
C
C     NOTE! ALL VARS--EXCEPT FOR BKPA (THE POST DISPERSAL VALUE)--ARE *BEFORE*
C     IN-FLIGHT BKP MORTALITY. THUS, FOR ONE CALCULATI0N BELOW, WE NEED TO EMPLOY
C     THE VARIABLE REPRESENTING PERCENT SURVIVAL OF BKP--BKPS().
C     ALL REPORTED VALUES WILL REFLECT PRE- IN-FLIGHT MORTALITY AMOUNTS, EXCEPT
C     FOR THE "BKPA" VARIABLE, WHICH REPRESENTS THE POST-DIPERSAL (AND POST-
C     MORTALITY) BKP LEVELS AND IS DERIVED AS: THE PRE-DISPERSAL AMOUNT, 
C     MINUS ALL EXPORTS, PLUS ALL IMPORTS, TIMES THE SURVIVAL RATE.
C
      TO_LS =OLDBKP(I)-BKPOUT(1,I)-SELFBKP(1,I)
      FRM_LS=(BKPA(I)/BKPS(I))-BKPIN(1,I)-SELFBKP(1,I)
C
C     IS DB OUTPUT IS REQUESTED? IF SO, SEND IT
C

cc     >  SREMOV(I)/ACRtoHA,
cc    >  VOLREM(I,1)*FT3pACRtoM3pHA,
cc     >  REMBKP(I)*FT2pACRtoM2pHA,

      IF(JBMDB(3,I).GT.0) CALL DBSBMBKP(
     >  BMSTDS(I),
     >  IYEAR,
     >  OLDBKP(I)*FT2pACRtoM2pHA,
     >  BKPA(I)*FT2pACRtoM2pHA,
     >  SELFBKP(1,I)*FT2pACRtoM2pHA,
     >  TO_LS*FT2pACRtoM2pHA,
     >  FRM_LS*FT2pACRtoM2pHA,
     >  BKPIN(1,I)*FT2pACRtoM2pHA,
     >  BKPOUT(1,I)*FT2pACRtoM2pHA,
     >  BKPS(I),
     >  FINAL(I,1)*FT2pACRtoM2pHA,
     >  FINAL(I,2),
     >  REMBKP(I)*FT2pACRtoM2pHA,
     >  GRFSTD(I),
     >  DVRV(I,1),
     >  DVRV(I,2),
     >  DVRV(I,3),
     >  DVRV(I,4),
     >  DVRV(I,5),
     >  DVRV(I,6),
     >  DVRV(I,7),
     >  DVRV(I,8),
     >  DVRV(I,9),
     >  FASTK(I,1)/ACRtoHA,
     >  FASTK(I,2)*FT2pACRtoM2pHA,
     >  FASTK(I,3)*FT3pACRtoM3pHA,
     >  BMCASEID(I))
C
C     IF WERE WRITING *ONLY* TO DB, THEN BYPASS WRITING OF *.BMN FILE
C
      IF (JBMDB(3,I) .EQ. 2) GO TO 900
C
C     IF THE HEADER AIN'T DONE, DO IT
C
      IF (.NOT. LPRHD3)THEN
         WRITE(JBMBKP,860)
C                   2345678901234567890123456789012345678901234567890
  860    FORMAT(1X,'STAND ID                   YEAR  BKP1  BKP2',
     >   ' BSTAY TO_LS FRMLS TO_OW FRMOW %SRV BSTRP SC BREMV   RV',
     >   '  RV1  RV2  RV3  RV4  RV5  RV6  RV7  RV8  RV9',
     >   ' TKlFst BAKFs VolKFs')
C
         LPRHD3 = .TRUE.
      ENDIF
C
C     WRITE THE "BKPOUT" OUTPUT FILE TO UNIT JBMBKP (*.bmb)
C
      WRITE(JBMBKP,880)
     >  BMSTDS(I),
     >  IYEAR,
     >  OLDBKP(I)*FT2pACRtoM2pHA,
     >  BKPA(I)*FT2pACRtoM2pHA,
     >  SELFBKP(1,I)*FT2pACRtoM2pHA,
     >  TO_LS*FT2pACRtoM2pHA,
     >  FRM_LS*FT2pACRtoM2pHA,
     >  BKPIN(1,I)*FT2pACRtoM2pHA,
     >  BKPOUT(1,I)*FT2pACRtoM2pHA,
     >  BKPS(I),
     >  FINAL(I,1)*FT2pACRtoM2pHA,
     >  INT(FINAL(I,2)),
     >  REMBKP(I)*FT2pACRtoM2pHA,
     >  GRFSTD(I),
     >  DVRV(I,1),
     >  DVRV(I,2),
     >  DVRV(I,3),
     >  DVRV(I,4),
     >  DVRV(I,5),
     >  DVRV(I,6),
     >  DVRV(I,7),
     >  DVRV(I,8),
     >  DVRV(I,9),
     >  FASTK(I,1)/ACRtoHA,
     >  FASTK(I,2)*FT2pACRtoM2pHA,
     >  FASTK(I,3)*FT3pACRtoM3pHA
C
  880 FORMAT(1X,A26,1X,I4,7(1X,F5.2),1x,F4.1,1X,F5.1,1X,I2,1X,!THRU FINAL2 (SC)
     >      F5.2,1X,F4.2,9(1X,F4.2),1X,F6.2,1X,F5.1,1X,F6.1)
C
C     -------- END OF "BKPOUT" OUTPUT PROCESSING------------------------
C
  900 CONTINUE
C
 1000 CONTINUE 
C
      RETURN
C
      END