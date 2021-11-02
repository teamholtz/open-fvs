      SUBROUTINE OLDSEC(ISPC,VN,D,H)
      IMPLICIT NONE
C----------
C AK $Id: oldsec.f 3758 2021-08-25 22:42:32Z lancedavid $
C----------
C  VARIABLE DECLARATIONS:
C----------
C
      INTEGER ISPC
C
      REAL D,H,VN
C
C----------
C ENTRY SECGRO COMPUTES VOLUMES FOR SECOND GROWTH TREES
C (D GE 4 AND H GE 18) UP TO (D LE 9 AND H LT 40)
C----------
      VN=-5.577 + 1.9067 * ALOG(D) + 0.9416 * ALOG(H)
      IF (VN .LE. 0.0) GO TO 120
      VN = EXP(VN)
      GO TO 130
  120 CONTINUE
      VN=0.0
  130 CONTINUE
      RETURN
      END
