      SUBROUTINE CH2NUM (C2,ICYC)
      IMPLICIT NONE
C----------
C BASE $Id: ch2num.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
      INTEGER ICYC
      CHARACTER*2 C2
C
C     WRITES A TWO DIGIT INTEGER INTO A CHARACTER*2 STRING.
C
      WRITE (C2,20) ICYC
   20 FORMAT (I2)
      RETURN
      END
