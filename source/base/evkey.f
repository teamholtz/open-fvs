      SUBROUTINE EVKEY (CTOK,NUM,IRC)
      IMPLICIT NONE
C----------
C BASE $Id: evkey.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
C     CALLED FROM ALGCMP
C
C     FINDS CTOK IN THE ARRAY OF USER-DEFINED VARIABLES.
C
C     N.L.CROOKSTON - APR 87 - FORESTRY SCIENCES LAB - MOSCOW, ID
C
C     CTOK  = C*8 TOKEN FOUND IN AN EXPRESSION.
C     NUM   = THE LOAD OP-CODE FOR THE TOKEN, IF IT IS DEFINED.
C     IRC   = RETURN CODE, 0=CTOK WAS FOUND, NUM IS DEFINED.
C             1=CTOK WAS NOT FOUND, NUM IS UNDEFINED.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
COMMONS
C
      INTEGER IRC,NUM,I
      CHARACTER*8 CTOK
C
C     IF THERE ARE NO USER DEFINED VARIABLES, THEN BRANCH TO EXIT
C
      IF (ITST5.LE.0) GOTO 110
C
C     SEARCH THROUGH LIST OF USER DEFINED VARILABLES.
C
      DO 10 I=1,ITST5
      NUM=I
      IF (CTOK.EQ.CTSTV5(I)) GOTO 20
   10 CONTINUE
      NUM=0
      GOTO 110
   20 CONTINUE
      NUM=500+NUM
      IRC=0
      RETURN
  110 CONTINUE
      IRC=1
      RETURN
      END
