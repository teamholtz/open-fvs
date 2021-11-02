      SUBROUTINE FMSVSYNC
      IMPLICIT NONE
C----------
C FIRE-BASE $Id: fmsvsync.f 2462 2018-07-26 14:39:59Z gedixon $
C----------
C
C     STAND VISUALIZATION GENERATION
C     A.H.DALLMANN -- RMRS MOSCOW -- MAY 2000
C
C     SYNCHRONIZES THE SV OUTPUT SNAGS WITH THE SNAGS THAT THE FIRE 
C     MODEL IS KEEPING TRACK OF.
C
C     *****  UNDER DEVELOPMENT ******
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'FMPARM.F77'
C
C
      INCLUDE 'CONTRL.F77'
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'FMCOM.F77'
      INCLUDE 'FMFCOM.F77'
C
C
      INCLUDE 'SVDATA.F77'
      INCLUDE 'SVDEAD.F77'
C
C
COMMONS
C
      REAL FMTOTAL
      INTEGER D,S
      INTEGER SVTOTAL
      INTEGER DBHCL
      LOGICAL DEBUG

      REAL CURFMSN(19,MAXSP)
      INTEGER CURSVSN(19,MAXSP)
      INTEGER I

      CALL DBCHK (DEBUG,'FMSVSYNC',8,ICYC)

      IF (DEBUG) WRITE (JOSTND,'('' IN FMSVSYNC, JSVOUT='',I4)') JSVOUT

C     NO NEED TO SYNC THE DATA IF VISUALIZATION IS NOT BEING DONE!

      IF (JSVOUT.EQ.0) RETURN

C     CLEAR OUT OUT TEMP LIST

      DO D=1,19
         DO S=1,MAXSP
            CURFMSN(D,S) = 0.
            CURSVSN(D,S) = 0
         ENDDO
      ENDDO

      FMTOTAL = 0.
      SVTOTAL = 0
    
C     ADD UP ALL OF THE DIFFERENT DENSITIES FROM THE FIRE SNAGS.
    
      DO I=1,NSNAG
         DBHCL = INT(DBHS(I)/2.0+1)
         IF (DBHCL .GT. 19) DBHCL = 19

         CURFMSN(DBHCL,SPS(I))=CURFMSN(DBHCL,SPS(I))+DENIS(I)+DENIH(I)
         IF (DBHCL .GE. 2) FMTOTAL = FMTOTAL + DENIS(I) + DENIH(I)
      ENDDO

C     ADD UP ALL OF THE STANDING SV SNAGS IN EACH CATEGORY OF THE FIRE SNAGS.

      DO I=1,NSVOBJ

        IF (IOBJTP(I).NE.2) CYCLE
        IF (FALLDIR(IS2F(I)).EQ.-1) THEN

C           THIS IS A STANDING SNAG, GET THE DIAMETER CLASS AND SPECIES
     
            DBHCL = INT(ODIA(IS2F(I)) / 2.0 + 1.0)
            IF (DBHCL .GT. 19) DBHCL = 19

C           NOW THAT WE HAVE THE CORRECT DIAMETER CLASS, WE NEED TO
C           ADD ONE TO THE MATCHING SPECIES-DIAMETER COUNT
     
            CURSVSN(DBHCL,ISNSP(IS2F(I)))=CURSVSN(DBHCL,ISNSP(IS2F(I)))
     >           + 1

C           ADD ONE TO THE SVTOTAL AS WELL.
C    
            IF (DBHCL .GE. 2) SVTOTAL = SVTOTAL + 1
         ENDIF

      ENDDO
     
C     DISPLAY THE DIFFERENCE BETWEEN THE PROB AND THE OBJECTS.

      IF (DEBUG) THEN
         
         DO S=1,MAXSP
            DO D=2,19
               IF (CURFMSN(D,S)+CURSVSN(D,S).GT.0.) THEN
                  WRITE (JOSTND,10) S,D,CURFMSN(D,S),CURSVSN(D,S)
 10               FORMAT (' Species=',A,' DBHClass=',I3,' CURFM=',
     >                     F8.3,' CURSVSN=',I4)
               ENDIF
            ENDDO
         ENDDO
         WRITE (JOSTND,'('' TOTAL DIFF='',F10.3)') SVTOTAL-FMTOTAL
      ENDIF

      RETURN
      END
      








