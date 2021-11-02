      SUBROUTINE MISACT (LACTV)
***********************************************************************
C MISTOE $Id: misact.f 2451 2018-07-11 18:10:16Z gedixon $
*----------------------------------------------------------------------
*  Purpose:
*     Returns TRUE when called to signal that the "real" mistletoe
*  submodel is linked to the program.  There is an entry in EXMIST
*  that always returns FALSE.
*
***********************************************************************
      IMPLICIT NONE

      LOGICAL LACTV
      LACTV=.TRUE.

      RETURN
      END
