      SUBROUTINE FORMCL(ISPC,IFOR,D,FC)
      IMPLICIT NONE
C----------
C NC $Id: formcl.f 3758 2021-08-25 22:42:32Z lancedavid $
C----------
C
C THIS PROGRAM CALCULATES FORM FACTORS FOR CALCULATING CUBIC AND
C BOARD FOOT VOLUMES.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
COMMONS
C
C----------
      REAL SISKFC(MAXSP,5),BLM712(MAXSP),FC,D
      INTEGER IFOR,ISPC,IFCDBH
C----------
C  FOREST ORDER: (IFOR)
C  1=KLAMATH(505)       2=SIX RIVERS(510)     3=TRINITY(514)
C  4=SISKIYOU(611)      5=HOOPA(705)          6=SIMPSON(800)
C  7=BLM COOS BAY(712)
C
C  SPECIES ORDER: (ISPC)
C  1=OC  2=SP  3=DF  4=WF  5=M   6=IC  7=BO  8=TO  9=RF 10=PP 11=OH, 12=RW
C----------
C  SISKIYOU  FORM CLASS VALUES
C----------
      DATA SISKFC/
     & 91., 96., 90., 98., 98., 89., 98., 91., 92., 93., 95., 82.,
     & 84., 91., 86., 90., 88., 89., 98., 91., 83., 89., 86., 82.,
     & 79., 85., 81., 86., 84., 77., 98., 82., 80., 83., 78., 79.,
     & 78., 83., 80., 85., 81., 73., 98., 80., 80., 81., 76., 78.,
     & 78., 82., 80., 85., 80., 72., 98., 79., 79., 80., 75., 78./

      DATA BLM712/
     & 74., 76., 76., 78., 72., 66., 72., 74., 78., 80., 70., 75./
C----------
C  FOR REGION 6 FORESTS, LOAD THE FORM CLASS USING TABLE VALUES.
C  IF A FORM CLASS HAS BEEN ENTERED VIA KEYWORD, USE IT INSTEAD.
C
C  REGION 5 VOLUME ROUTINES DON'T USE FORM CLASS.
C----------
      IF(IFOR.EQ.4 .AND. FRMCLS(ISPC).LE.0.) THEN
        IFCDBH = INT((D - 1.0) / 10.0 + 1.0)
        IF(IFCDBH .LT. 1) IFCDBH=1
        IF(D.GT.40.9) IFCDBH=5
        FC = SISKFC(ISPC,IFCDBH)
      ELSEIF(IFOR.EQ.7 .AND. FRMCLS(ISPC).LE.0.) THEN
        FC = BLM712(ISPC)
      ELSE
        FC=FRMCLS(ISPC)
        IF(FC .LE. 0.) FC=80.
      ENDIF
C
      RETURN
      END
