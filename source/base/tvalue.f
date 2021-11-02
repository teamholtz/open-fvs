      SUBROUTINE TVALUE(N,P,T,IERR)
      IMPLICIT NONE
C----------
C BASE $Id: tvalue.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
C  THIS SUBROUTINE APPROXIMATES THE VALUE OF STUDENT'S T ASSOCIATED
C  WITH 'N' DEGREES OF FREEDOM FOR THE 'P' LEVEL OF PROBABILITY.
C  WHEN THERE ARE NO DEGREES OF FREEDOM, OR WHEN P IS LESS THAN OR
C  EQUAL TO 0.0 OR GREATER THAN OR EQUAL TO 1.0, 'T' IS ASSIGNED
C  A VALUE OF ZERO AND AN ERROR FLAG (IERR) IS SET.
C  THE ALGORITHM USED IS FROM:
C
C       HILL, G. W. 1970.  ALGORITHM 396: STUDENT'S T QUANTILES.
C          COMMUNICATIONS OF THE ACM 13(10) 619-620.
C
C  UNDER CERTAIN CONDITIONS, THIS ALGORITHM REQUIRES AN
C  APPROXIMATION OF THE X-DEVIATE ASSOCIATED WITH A GIVEN INTEGRAL
C  VALUE FROM THE NEGATIVE TAIL OF THE NORMAL PROBABILITY DENSITY
C  FUNCTION.  AN ALGORITHM FROM THE HEWLETT-PACKARD HP-67/HP-97
C  STAT PAC 1 IS USED TO APPROXIMATE X-DEVIATES.
C
C
      INTEGER IERR,N
      REAL T,P,HALFPI,XN,A,B,C,D,X,Y,Q,QT
C
C----------
      DATA HALFPI/1.5707963268/
      T=0.0
      IERR=0
      IF(N.GE.1 .AND. P.GT.0.0 .AND. P.LT.1.0) GO TO 10
C----------
C  INVALID ARGUEMENTS: SET ERROR CODES AND RETURN.
C----------
      IERR=1
      RETURN
   10 CONTINUE
      IF(N.GT.1) GO TO 15
C----------
C  ONE DEGREE OF FREEDOM.
C----------
      T=COS(P*HALFPI)/SIN(P*HALFPI)
      RETURN
   15 CONTINUE
      IF(N.GT.2) GO TO 20
C----------
C  TWO DEGREES OF FREEDOM.
C----------
      T=SQRT(2.0/(P*(2.0-P))-2.0)
      RETURN
C----------
C  THREE OR MORE DEGREES OF FREEDOM.
C----------
   20 CONTINUE
      XN=FLOAT(N)
      A=1.0/(XN-0.5)
      B=48.0/(A*A)
      C=((20700.0*A/B-98.0)*A-16.0)*A+96.36
      D=((94.5/(B+C)-3.0)/B+1.0)*SQRT(A*HALFPI)*XN
      X=D*P
      Y=X**(2.0/XN)
      IF(Y.LE.A+0.05) GO TO 25
C----------
C  Y > A+0.05:  USE ASYMPTOTIC INVERSE EXPANSION ABOUT NORMAL.
C----------
      Q=P*0.5
C----------
C  APPROXIMATE X-DEVIATE ASSOCIATED WITH THE INTEGRAL VALUE Q FROM
C  THE NEGATIVE TAIL OF THE NORMAL PROBABILITY DENSITY FUNCTION.
C----------
      QT=SQRT(ALOG(1.0/(Q*Q)))
      X=-QT+(((0.802853+QT*0.010328)*QT+2.515517)/
     &      (((0.189269+QT*0.001308)*QT+1.432788)*QT+1))
      Y=X*X
      IF(N.LT.5) C=C+0.3*(XN-4.5)*(X+0.6)
      C=(((0.05*D*X-5.0)*X-7.0)*X-2.0)*X+B+C
      Y=(((((0.4*Y+6.3)*Y+36.0)*Y+94.5)/C-Y-3.0)/B+1.0)*X
      Y=A*Y*Y
      IF(Y.GT.0.002) GO TO 22
      Y=0.5*Y*Y+Y
      GO TO 30
   22 CONTINUE
      Y=EXP(Y)-1.0
      GO TO 30
   25 CONTINUE
      Y=((1.0/(((XN+6.0)/(XN*Y)-0.089*D-0.822)*(XN+2.0)*3.0)+
     &    0.5/(XN+4.0))*Y-1.0)*(XN+1.0)/(XN+2.0)+1.0/Y
   30 CONTINUE
      T=SQRT(XN*Y)
      RETURN
      END
