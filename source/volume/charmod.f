C----------
C VOLUME $Id: charmod.f 2458 2018-07-22 19:09:30Z gedixon $
C----------
      MODULE CHARMOD

!     Module to store utility type definitions

!     Created TEH 02/24/09
!     Revised TDH 02/27/09 .

!     Class for receiving strings in calls from C++
      TYPE CHAR256
      SEQUENCE
        INTEGER        LENGTH
        CHARACTER(256) STR        
      END TYPE CHAR256
   

      END MODULE CHARMOD
