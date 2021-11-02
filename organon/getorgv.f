      SUBROUTINE GETORGV(I,VALU)
      IMPLICIT NONE
C----------
C ORGANON $Id: getorgv.f 2453 2018-07-12 22:20:53Z gedixon $
C----------
C
C  SUBROUTINE TO RETURN EVENT MONITOR VARIABLES
C----------
COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ORGANON.F77'
C
COMMONS
C----------
      INTEGER I
      REAL    VALU
C
      SELECT CASE (I)
      CASE(1)
        VALU = OCC
      CASE(2)
        VALU = OAHT
      END SELECT
C
      RETURN
      END
