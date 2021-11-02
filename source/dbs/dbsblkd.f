      BLOCK DATA DBSBLKD
C
C $Id: dbsblkd.f 2357 2018-05-18 17:26:03Z lancedavid $
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
