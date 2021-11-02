      BLOCK DATA DBSBLKD
C
C DBSQLITE $Id: dbsblkd.f 2445 2018-07-09 21:23:04Z gedixon $
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
      DATA DSNOUT/"FVSOut.db"/
      DATA DSNIN /"FVS_Data.db"/
      DATA IoutDBref/-1/
      DATA IinDBref /-1/

      END
