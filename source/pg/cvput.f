      SUBROUTINE CVPUT (WK3, IPNT, ILIMIT, ICYC, ITRN)
      IMPLICIT NONE
C----------
C PG $Id: cvput.f 2876 2019-12-05 23:03:10Z nickcrookston $
C----------
C
C     STORE THE COVER DATA FOR A GIVEN STAND.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION TO PROGNOSIS.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CVCOM.F77'
C
C
COMMONS
C
C
      INTEGER MXL,MXI,MXR
      PARAMETER (MXL=12,MXI=17,MXR=7)
C
      INTEGER ITRN,ICYC,ILIMIT,IPNT,IP1,ISUB,JSUB
      LOGICAL LOGICS(MXL)
      REAL WK3 (MAXTRE)
      INTEGER INTS (MXI)
      REAL REALS (MXR)
C
C     SET THE VALUE OF IP1, WHICH WILL CONTROL HOW MANY WORDS
C     GET WRITTEN DEPENDING ON WHAT CYCLE WE ARE IN.
C
      IP1=ICYC+1
C
C     PUT THE INTEGER SCALARS.
C
      INTS ( 1) = COVOPT
      INTS ( 2) = ICVBGN
      INTS ( 3) = IDIST
      INTS ( 4) = IHTYPE
      INTS ( 5) = INF
      INTS ( 6) = IOV
      INTS ( 7) = IP1
      INTS ( 8) = IPHYS
      INTS ( 9) = ITRN
      INTS (10) = ITUN
      INTS (11) = IUN
      INTS (12) = JOSHRB
      INTS (13) = NKLASS
      INTS (14) = NSHOW
      INTS (15) = JCVNOH
      INTS (16) = ICEHAB
      INTS (17) = IGFHAB
      CALL IFWRIT (WK3, IPNT, ILIMIT, INTS, MXI, 2)
C
C     PUT THE LOGICAL SCALARS.
C
      LOGICS ( 1) = LBROW
      LOGICS ( 2) = LCALIB
      LOGICS ( 3) = LCAL1
      LOGICS ( 4) = LCAL2
      LOGICS ( 5) = LCNOP
      LOGICS ( 6) = LCOV
      LOGICS ( 7) = LCOVER
      LOGICS ( 8) = LCVSUM
      LOGICS ( 9) = LSHOW
      LOGICS (10) = LSHRUB
      LOGICS (11) = LCVNOH
      LOGICS (12) = LSAGE 
      CALL LFWRIT (WK3, IPNT, ILIMIT, LOGICS, MXL, 2)
C
C     PUT THE REAL SCALARS.
C
      REALS (1) = CRAREA
      REALS (2) = HTMAX
      REALS (3) = HTMIN
      REALS (4) = SAGE
      REALS (5) = SUMCVR
      REALS (6) = TALLSH
      REALS (7) = TCOV
      CALL BFWRIT (WK3, IPNT, ILIMIT, REALS, MXR, 2)
C
C     PUT THE ONE DIMENSIONAL ARRAYS.
C
      CALL IFWRIT (WK3,IPNT,ILIMIT, ISHOW, 6, 2)
      CALL IFWRIT (WK3,IPNT,ILIMIT, ILAYR, 31, 2)
      CALL IFWRIT (WK3,IPNT,ILIMIT, ICVAGE, IP1, 2)
      CALL IFWRIT (WK3,IPNT,ILIMIT, ISHAPE, ITRN, 2)
C
      CALL LFWRIT (WK3,IPNT,ILIMIT, LTHIND, IP1, 2)
C
      CALL BFWRIT (WK3, IPNT, ILIMIT, AVGBHT, 3, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, AVGBPC, 3, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, CVAVG, 3, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, CVFRAC, 3, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, HTAVG, 3, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, HTFRAC, 3, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, CRXHT, 16, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, SD2XHT, 16, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, BHTCF, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, BPCCF, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, PB, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, PBCV, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, PCON, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, SH, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, SHRBHT, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, SHRBPC, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, XCV, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, XPB, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, XSH, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TRECW, ITRN, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TRFBMS, ITRN, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TCON, 2,  2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, CCON, 31, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, HCON, 31, 2)
C
C     PUT THE MAXCY1*2 ARRAYS.
C
      DO 1000 ISUB=1,2
      CALL IFWRIT (WK3,IPNT,ILIMIT, ISTAGE (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, ASHT (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, CLOW (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, CMED (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, CTALL (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, PGT0 (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, SBMASS (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, SDIAM (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, STDHT (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TCVOL (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TIMESD (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TOTBMS (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TOTLCV (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TPCTCV (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TPROAR (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TRETOT (1,ISUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TWIGS (1,ISUB), IP1, 2)
C
C     PUT THE MAXCY1*2*6 ARRAYS.
C
      DO 300 JSUB=1,6
      CALL IFWRIT (WK3,IPNT,ILIMIT, INDSP (1,ISUB,JSUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, CIND (1,ISUB,JSUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, PIND (1,ISUB,JSUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, HIND (1,ISUB,JSUB), IP1, 2)
  300 CONTINUE
C
C     PUT THE MAXCY1*2*11 ARRAYS.
C
      DO 400 JSUB=1,11
      CALL BFWRIT (WK3, IPNT, ILIMIT, SCOV (1,ISUB,JSUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TRSH (1,ISUB,JSUB), IP1, 2)
  400 CONTINUE
C
C     PUT THE MAXCY1*2*12 ARRAYS.
C
      DO 500 JSUB=1,12
      CALL IFWRIT (WK3,IPNT,ILIMIT, ISSP (1,ISUB,JSUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, SCV (1,ISUB,JSUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, SHT (1,ISUB,JSUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, SPB (1,ISUB,JSUB), IP1, 2)
  500 CONTINUE
C
C     PUT THE MAXCY1*2*16 ARRAYS.
C
      DO 600 JSUB=1,16
      CALL BFWRIT (WK3, IPNT, ILIMIT, CFBXHT (1,ISUB,JSUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, PCXHT (1,ISUB,JSUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, PROXHT (1,ISUB,JSUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, TXHT (1,ISUB,JSUB), IP1, 2)
      CALL BFWRIT (WK3, IPNT, ILIMIT, VOLXHT (1,ISUB,JSUB), IP1, 2)
  600 CONTINUE
 1000 CONTINUE
      RETURN
      END
