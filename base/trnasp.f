      SUBROUTINE TRNASP
      IMPLICIT NONE
C----------
C BASE $Id: trnasp.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C  TRNASP DECODES THE INPUT AZIMUTH VALUE GIVEN IN DEGREES AND CONVERTS
C  THE VALUE TO RADIANS. THE VALUE IS THEN ASSIGNED TO THE VARIABLE
C  ASPECT.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C
C----------
C   CONVERT ASPECT TO RADIANS.
C----------
      ASPECT=ASPECT*0.0174533
      RETURN
      END
