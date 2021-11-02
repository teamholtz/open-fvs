      SUBROUTINE BWEUCA (C)
      IMPLICIT NONE
C----------
C WSBWE $Id: bweuca.f 2460 2018-07-24 14:41:48Z gedixon $
C----------
      CHARACTER C
      CHARACTER*26 UPPER,LOWER
      INTEGER IP
      
      DATA UPPER /'ABCDEFGHIJKLMNOPQRSTUVWXYZ'/
      DATA LOWER /'abcdefghijklmnopqrstuvwxyz'/

      IP=INDEX(LOWER,C)
      IF (IP.GT.0) C=UPPER(IP:IP)
      RETURN
      END
