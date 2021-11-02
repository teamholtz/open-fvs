      BLOCK DATA DBSBLKD
C
C $Id: dbsblkd.f 2067 2018-01-12 00:55:53Z nickcrookston $
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
