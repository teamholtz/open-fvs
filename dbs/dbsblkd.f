      BLOCK DATA DBSBLKD
C
C DBS $Id: dbsblkd.f 2445 2018-07-09 21:23:04Z gedixon $
C
C     INITIALIZE DATABASE VARIABLES
C
COMMONS
C
C
      INCLUDE 'DBSCOM.F77'
C
C
COMMONS
C
      DATA DSNOUT/'FVSOut.mdb'/
      DATA ConnHndlOut/-1/
      DATA EnvHndlOut/-1/
      DATA DSNIN/'FVSIn.mdb'/
      DATA ConnHndlIn/-1/
      DATA EnvHndlIn/-1/

      END
