      FUNCTION CMRANG (LEN,INDX,ARR)
      IMPLICIT NONE
C----------
C BASE $Id: cmrang.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
C     FINDS THE MAX RANGE, CMRANG, OF THE VECTOR ARR.  ONLY THE
C     ELEMENTS OF ARR INDEXED BY INDX ARE CONSIDERED.
C
C     PART OF THE COMPRESSION ROUTINE COMPRS, WHICH IS PART OF THE
C     PROGNOSIS MODEL FOR STAND DEVELOPMENT.
C     N.L. CROOKSTON - FORESTRY SCIENCES LAB, MOSCOW, ID - JUNE 1982.
C
      INTEGER INDX(*),LEN,I,J
      REAL ARR(*),CMRANG,X1,X2
C
      X1=1E30
      X2=-1E30
      DO 10 J=1,LEN
      I=INDX(J)
      IF (ARR(I).LT.X1) X1=ARR(I)
      IF (ARR(I).GT.X2) X2=ARR(I)
   10 CONTINUE
      CMRANG=X2-X1
      RETURN
      END