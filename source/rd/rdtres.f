      SUBROUTINE RDTRES (IRNTRE,IRTP1)
      IMPLICIT NONE
C----------
C RD $Id: rdtres.f 2454 2018-07-18 23:01:17Z gedixon $
C----------
C
C  ROUTINE THAT RETURNS THE NUMBER OF TREE RECORDS THAT WILL
C  BE PERMITTED FOR THE ROOT DISEASE MODEL.  THIS VALUE FOR
C  NUMBER OF TREES IS THE NUMBER THAT IS CONTAINED IN THE ROUTINE
C  ANPARM AS A PARAMETER VALUE.  THIS ROUTINE IS CALLED FROM INTREE
C  TO ESTABLISH THE MAXIMUM NUMBER OF TREE RECORDS TO BE READ.
C
C  CALLED BY :
C     INTREE  [PROGNOSIS]
C
C  CALLS     :
C     NONE
C
C  PARAMETERS :
C     IRNTRE -
C     IRTP1  -
C
C  Revision History:
C   11/20/89 - Last revision date.
C   09/04/14 Lance R. David (FMSC)
C     Added implicit none and declared variables.
C
C----------------------------------------------------------------------
C
COMMONS
C
      INCLUDE 'RDPARM.F77'
C
COMMONS
C
      INTEGER IRNTRE, IRTP1

      IRNTRE = IRRTRE
      IRTP1  = IRRTP1

      RETURN
      END
