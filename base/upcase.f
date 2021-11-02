      SUBROUTINE UPCASE (C)
      IMPLICIT NONE
C----------
C BASE $Id: upcase.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
      INTEGER IP
      CHARACTER C
      CHARACTER*26 UPPER,LOWER
      DATA UPPER /'ABCDEFGHIJKLMNOPQRSTUVWXYZ'/
      DATA LOWER /'abcdefghijklmnopqrstuvwxyz'/
      IP=INDEX(LOWER,C)
      IF (IP.GT.0) C=UPPER(IP:IP)
      RETURN
      END
