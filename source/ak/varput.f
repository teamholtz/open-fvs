      SUBROUTINE VARPUT (WK3,IPNT,ILIMIT,REALS,LOGICS,INTS)
      IMPLICIT NONE
C----------
C AK $Id: varput.f 3617 2021-05-28 17:02:44Z lancedavid $
C----------
C
C     WRITE THE VARIANT SPECIFIC VARIABLES.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION TO PROGNOSIS.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'ESPARM.F77'

      INCLUDE 'ESCOMN.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'VARCOM.F77'
C
C
COMMONS
C
C     NOTE: THE ACTUAL STORAGE LIMIT FOR INTS, LOGICS, AND REALS
C     IS MAXTRE (SEE PRGPRM).
C
      INTEGER ILIMIT,IPNT,MXL,MXI,MXR
      PARAMETER (MXL=1,MXI=2,MXR=5)
      LOGICAL LOGICS(*)
      REAL WK3(MAXTRE)
      INTEGER INTS(*)
      REAL REALS(*)
      LOGICAL LDANUW
      REAL RDANUW
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      LDANUW = LOGICS(1)
      RDANUW = REALS(1)
      RDANUW = WK3(1)
C----------
C
C     STORE THE INTEGER SCALARS IN THE ARRAY INTS
C
      INTS ( 1) = IIFORTP             ! from PLOT.F77
      INTS ( 2) = IFT0                ! from ESCOMN.F77 
      CALL IFWRIT (WK3, IPNT, ILIMIT, INTS, MXI, 2)
C
C     WRITE THE INTEGER ARRAYS
C
C     STORE THE LOGICAL SCALARS.
C
C**   CALL LFWRIT (WK3, IPNT, ILIMIT, LOGICS, MXL, 2)
C
C     STORE THE REAL SCALARS IN THE ARRAY REALS.
C
C**   REALS( 1) =  
C**   CALL BFWRIT (WK3, IPNT, ILIMIT, REALS, MXR, 2)
C
C     WRITE THE REAL ARRAYS
C
      CALL BFWRIT (WK3, IPNT, ILIMIT, OCURFT,    MAXSP*14, 2) ! from ESCOMN.F77
      CALL BFWRIT (WK3, IPNT, ILIMIT, HTT11,     MAXSP,    2) ! from ESCOMN.F77
      CALL BFWRIT (WK3, IPNT, ILIMIT, HTT12,     MAXSP,    2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, HTT13,     MAXSP,    2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, XMAXPT,    MAXPLT,   2)

      RETURN
      END

      SUBROUTINE VARCHPUT (CBUFF, IPNT, LNCBUF)
      IMPLICIT NONE
C----------
C     Put variant-specific character data
C----------

      INCLUDE 'PRGPRM.F77'

      INTEGER LNCBUF
      CHARACTER CBUFF(LNCBUF)
      INTEGER IPNT
      INTEGER IDANUW
      CHARACTER CDANUW
      ! Stub for variants which need to get/put character data
      ! See /bc/varget.f and /bc/varput.f for examples of VARCHGET and VARCHPUT
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = IPNT
      CDANUW = CBUFF(1)

      RETURN
      END