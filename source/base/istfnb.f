      FUNCTION ISTFNB (STRING)
      IMPLICIT NONE
C----------
C BASE $Id: istfnb.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
C     FIND THE LOCATION OF THE FIRST NON-BLANK CHAR IN A STRING.
C     RETURN A ZERO IF THE ENTIRE STRING IS BLANK.
C
      INTEGER ISTFNB,I
      CHARACTER*(*) STRING
      IF (STRING.EQ.' ') THEN
         ISTFNB=0
      ELSE
         DO 10 I=1,LEN(STRING)
         IF (STRING(I:I).NE.' ') THEN
            ISTFNB=I
            RETURN
         ENDIF
   10    CONTINUE
      ENDIF
      RETURN
      END
