      SUBROUTINE MPBCUP
      IMPLICIT NONE
C----------
C LPMPB $Id: mpbcup.f 2450 2018-07-11 17:28:41Z gedixon $
C----------
C
C     INTERFACING PROGRAM TO CALL EITHER MPBDRV OR COLDRV.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'MPBCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
C Revision History
C   02/08/88 Last noted revision date.
C   07/02/10 Lance R. David (FMSC)
C     Added IMPLICIT NONE.
C----------
C
COMMONS
C
C************************* EXECUTION BEGINS ***************************
C
      IF (LPOPDY) THEN
         CALL MPBDRV
      ELSE
         CALL COLDRV
      ENDIF
      RETURN
      END
