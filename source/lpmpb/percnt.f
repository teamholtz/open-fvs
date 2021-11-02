      FUNCTION PERCNT(VALUE, BASE)
      IMPLICIT NONE
C----------
C LPMPB $Id: percnt.f 2450 2018-07-11 17:28:41Z gedixon $
C----------
C
C     PART OF THE MOUNTAIN PINE BEETLE EXTENSION OF PROGNOSIS SYSTEM.
C
C
C Revision History
C   02/08/88 Last noted revision date.
C   07/02/10 Lance R. David (FMSC)
C     Added IMPLICIT NONE.
C----------
      REAL BASE, PERCNT, VALUE
      
      PERCNT = 0.
      IF(ABS(BASE) .GE. 1E-30) PERCNT = 100.*VALUE/BASE
      RETURN
      END
