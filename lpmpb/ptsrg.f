      FUNCTION PTSRG(X,BASNO)
      IMPLICIT NONE
C----------
C LPMPB $Id: ptsrg.f 2450 2018-07-11 17:28:41Z gedixon $
C----------
C
C
C Revision History
C   02/08/88 Last noted revision date.
C   07/02/10 Lance R. David (FMSC)
C     Added IMPLICIT NONE.
C----------
      INTEGER J
      REAL BASNO, C, PTSRG, X

      DO 1 J=4,12,4
      C=J
      PTSRG=C*BASNO
      IF(PTSRG .GE. X) RETURN
    1 CONTINUE
      RETURN
      END
