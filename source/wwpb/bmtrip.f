      SUBROUTINE BMTRIP(ITFN,I,WEIGHT)
C----------
C WWPB $Id: bmtrip.f 2460 2018-07-24 14:41:48Z gedixon $
C----------
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'PPEPRM.F77'
      INCLUDE 'BMPRM.F77'
      INCLUDE 'BMCOM.F77'
C..the following line commented out 7/1/99 (AJM)
C      GRFDEN(ITFN)=  GRFDEN(I)
      LBMDAM(ITFN) = LBMDAM(I) 
      
c... samples from triple.
c
c      PROB(ITFN)=PROB(I)*WEIGHT
c      WK1(ITFN)=WK1(I)
      
      RETURN
      END
