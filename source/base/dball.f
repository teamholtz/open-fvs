      SUBROUTINE DBALL (ICYC)
      IMPLICIT NONE
C----------
C BASE $Id: dball.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'DBSTK.F77'
C
C
COMMONS
C
      INTEGER ICYC,IRC
C
      IF ((ICYC.LT.1).OR.(ICYC.GT.MAXCYC)) THEN
        CALL DBINIT
        CALL DBADD (ALLSUB,6,0,IRC)
      ELSE
        CALL DBADD (ALLSUB,6,ICYC,IRC)
      ENDIF
      RETURN
      END
