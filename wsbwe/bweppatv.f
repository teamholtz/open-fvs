      SUBROUTINE BWEPPATV (L)
      IMPLICIT NONE
C----------
C WSBWE $Id: bweppatv.f 2460 2018-07-24 14:41:48Z gedixon $
C----------
C
C  RETURNS L=TRUE, TO INDICATE THAT GENDEFOL/BUDWORM MODEL IS AVAILABLE
C  TO PARALLEL PROCESSOR.
C
C  CALLED BY :
C     GETSTD  [PARALLEL PROCESSOR]
C     PUTSTD  [PARALLEL PROCESSOR]
C
C  CALLS     :
C     NONE
C
C  PARAMETERS :
C     L     - FLAG THAT IS SET TO TRUE WHEN THE BUDWORM MODEL IS
C             ATTACHED WITH PPE.
C
      LOGICAL L

      L = .TRUE.

      RETURN
      END