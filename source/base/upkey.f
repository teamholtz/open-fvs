      SUBROUTINE UPKEY (KEYWRD)
      IMPLICIT NONE
C----------
C BASE $Id: upkey.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C  THESE ROUTINES CONVERT KEYWORDS THAT ARE INPUT IN LOWER CASE LETTERS
C  TO UPPER CASE LETTERS.
C----------
      INTEGER I
      CHARACTER*8 KEYWRD
      DO 40 I=1,8
      CALL UPCASE(KEYWRD(I:I))
   40 CONTINUE
      RETURN
      END
