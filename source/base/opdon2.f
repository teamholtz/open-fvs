      SUBROUTINE OPDON2(IACTK,IDT,IYR1,IYR2,ISQNUM,KODE)
      IMPLICIT NONE
C----------
C BASE $Id: opdon2.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
C     OPDON2 IS USED TO SET THE STATUS OF AN OPTION FOUND AS
C     DESCRIBED UNDER OPGET2 AS 'DONE', OR THE VALUE OF IDT.
C     THE ARGUMENTS:
C
C     IACTK, IYR1, IYR2, ISQNUM, AND KODE ARE SAME AS ABOVE.
C     IDT   = THE YEAR THE ACTIVITY WAS ACCOMPLISHED.
C
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
C
      INTEGER KODE,ISQNUM,IYR1,IYR2,IDT,IACTK,IFIND,NTIMES,I2,II,I,ID
C
C     PREFORM THE SEARCH FOR THE ACTIVITY IN ASSENDING DATE ORDER.
C
      KODE=0
      IFIND=0
      NTIMES=0
      I2=IMGL-1
      DO 40 II=1,I2
      I=IOPSRT(II)
      ID=IDATE(I)
      IF (ID.LT.IYR1 .OR. ID.GT.IYR2 .OR. IACTK.NE.IACT(I,1)) GOTO 40
      IF (IACT(I,4).NE.0) GOTO 40
      NTIMES=NTIMES+1
      IF (ISQNUM.GT.0) GOTO 30
      IFIND=I
      GOTO 40
   30 CONTINUE
      IF (ISQNUM.NE.NTIMES) GOTO 40
      IFIND=I
      GOTO 50
   40 CONTINUE
   50 CONTINUE
      IF (IFIND.GT.0) GOTO 60
      KODE=1
      RETURN
C
C     THE SEARCH IS COMPLETE - PROCEED WITH THE OPERATION.
C
   60 CONTINUE
      ISEQDN=ISEQDN+1
      ISEQ(IFIND)=ISEQDN
      IACT(IFIND,4)=IDT
      RETURN
      END