      SUBROUTINE UPCASE (C)
      IMPLICIT NONE
C----------
C  $Id: upcase.f 2355 2018-05-18 17:21:33Z lancedavid $
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
