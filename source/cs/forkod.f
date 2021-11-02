      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C CS $Id: forkod.f 2790 2019-09-24 20:26:58Z lancedavid $
C----------
C
C     TRANSLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
C     KODFOR IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
COMMONS
C  ------------------------
C  NATIONAL FORESTS:
C  905 = MARK TWAIN
C  908 = SHAWNEE
C  912 = HOOSIER
C  911 = OLD WAYNE-HOOSIER COMBINED CODE (MAP TO HOOSIER)
C  ------------------------
C  RESERVATION PSUEDO CODES:

C  7110 = OMAHA RESERVATION                 (MAPPED TO  905 MARK TWAIN)
C  7111 = SANTEE RESERVATION                (MAPPED TO  905 MARK TWAIN)
C  7112 = WINNEBAGO RESERVATION             (MAPPED TO  905 MARK TWAIN)
C  7202 = IOWA (KS-NE) RESERVATION          (MAPPED TO  905 MARK TWAIN)
C  7203 = KICKAPOO (KS) RESERVATION         (MAPPED TO  905 MARK TWAIN)
C  7204 = PRAIRIE BAND OF POTAWATOMI        (MAPPED TO  905 MARK TWAIN)
C  7205 = SAC AND FOX NATION RESERVATION    (MAPPED TO  905 MARK TWAIN)
C  7210 = KAW OTSA                          (MAPPED TO  905 MARK TWAIN)
C  7509 = SAC AND FOX/MESKWAKI SETTLEMENT   (MAPPED TO  908 SHAWNEE)
C  7602 = QUAPAW OTSA                       (MAPPED TO  905 MARK TWAIN)
C  7606 = MIAMI OTSA                        (MAPPED TO  905 MARK TWAIN)
C  7608 = MODOC OTSA                        (MAPPED TO  905 MARK TWAIN)
C  7609 = OSAGE RESERVATION                 (MAPPED TO  905 MARK TWAIN)
C  7611 = CHEROKEE OTSA                     (MAPPED TO  905 MARK TWAIN)
C  ------------------------

      INTEGER JFOR(4),KFOR(4),NUMFOR,I
      LOGICAL USEIGL, FORFOUND
      DATA JFOR/905,908,912,911/
      DATA NUMFOR/4/
      DATA KFOR/1,1,1,1/

      USEIGL = .TRUE.
      FORFOUND = .FALSE.


      SELECT CASE (KODFOR)

C       CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE
        CASE (7110)
          WRITE(JOSTND,60)
   60     FORMAT(/,'********',T12,'OMAHA RESERVATION (7110) BEING ',
     &    'MAPPED TO MARK TWAIN NF (905) FOR FURTHER PROCESSING.')
           IFOR = 1
        CASE (7111)
          WRITE(JOSTND,61)
   61     FORMAT(/,'********',T12,'SANTEE RESERVATION (7111) BEING ',
     &    'MAPPED TO MARK TWAIN NF (905) FOR FURTHER PROCESSING.')
          IFOR = 1
        CASE (7112)
          WRITE(JOSTND,62)
   62     FORMAT(/,'********',T12,'WINNEBAGO RESERVATION (7112) ',
     &    'BEING MAPPED TO MARK TWAIN NF (905) FOR FURTHER PROCESSING.')
          IFOR = 1
        CASE (7202)
          WRITE(JOSTND,63)
   63     FORMAT(/,'********',T12,'IOWA (KS-NE) RESERVATION (7202) ',
     &    'BEING MAPPED TO MARK TWAIN NF (905) FOR FURTHER PROCESSING.')
          IFOR = 1
        CASE (7203)
          WRITE(JOSTND,64)
   64     FORMAT(/,'********',T12,'KICKAPOO (KS) RESERVATION (7203)',
     &    ' BEING MAPPED TO MARK TWAIN NF (905) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 1
        CASE (7204)
          WRITE(JOSTND,65)
   65     FORMAT(/,'********',T12,'PRAIRIE BAND OF POTAWATOMI ',
     &    '(7204) BEING MAPPED TO MARK TWAIN NF (905) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 1
        CASE (7205)
          WRITE(JOSTND,66)
   66     FORMAT(/,'********',T12,'SAC AND FOX NATION RESERVATION ',
     &    '(7205) BEING MAPPED TO MARK TWAIN NF (905) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 1
        CASE (7210)
          WRITE(JOSTND,67)
   67     FORMAT(/,'********',T12,'KAW OTSA (7210) BEING MAPPED',
     &    'TO MARK TWAIN NF (905) FOR FURTHER PROCESSING.')
          IFOR = 1
        CASE (7509)
          WRITE(JOSTND,68)
   68     FORMAT(/,'********',T12,'SAC AND FOX/MESKWAKI SETTLEMENT ',
     &    '(7509) BEING MAPPED TO SHAWNEE NF (908) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 2
        CASE (7602)
          WRITE(JOSTND,69)
   69     FORMAT(/,'********',T12,'QUAPAW OTSA (7602) BEING MAPPED ',
     &    'TO MARK TWAIN NF (905) FOR FURTHER PROCESSING.')
          IFOR = 1
        CASE (7606)
          WRITE(JOSTND,70)
   70     FORMAT(/,'********',T12,'MIAMI OTSA (7606) BEING MAPPED ',
     &    'TO MARK TWAIN NF (905) FOR FURTHER PROCESSING.')
          IFOR = 1
        CASE (7608)
          WRITE(JOSTND,71)
   71     FORMAT(/,'********',T12,'MODOC OTSA (7608) BEING MAPPED ',
     &    'TO MARK TWAIN NF (905) FOR FURTHER PROCESSING.')
          IFOR = 1
        CASE (7609)
          WRITE(JOSTND,72)
   72     FORMAT(/,'********',T12,'OSAGE RESERVATION (7609) BEING ',
     &    'MAPPED TO MARK TWAIN NF (905) FOR FURTHER PROCESSING.')
          IFOR = 1
        CASE (7611)
          WRITE(JOSTND,73)
   73     FORMAT(/,'********',T12,'CHEROKEE OTSA (7611) BEING',
     &    ' MAPPED TO MARK TWAIN NF (905) FOR FURTHER PROCESSING.')
          IFOR = 1
C       END CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE

        CASE DEFAULT
        
C         CONFIRMS THAT KODFOR IS AN ACCEPTED FVS LOCATION CODE
C         FOR THIS VARIANT FOUND IN DATA ARRAY JFOR
          DO 10 I=1,NUMFOR
            IF (KODFOR .EQ. JFOR(I)) THEN
              IFOR = I
              FORFOUND = .TRUE.
              EXIT
            ENDIF
   10     CONTINUE        
          
C         LOCATION CODE ERROR TRAP       
          IF (.NOT. FORFOUND) THEN
            CALL ERRGRO (.TRUE.,3)
            WRITE(JOSTND,11) JFOR(IFOR)
   11       FORMAT(/,'********',T12,'FOREST CODE USED IN THIS ',
     &      'PROJECTION IS',I4)
            USEIGL = .FALSE.
          ENDIF

      END SELECT


C     FOREST MAPPING CORRECTION
      SELECT CASE (IFOR)
        CASE (4)
          WRITE(JOSTND,21)
   21     FORMAT(/,'********',T12,'WAYNE-HOOSIER NF (911) BEING ',
     &    'MAPPED TO HOOSIER (912) FOR FURTHER PROCESSING.')
          IFOR = 3
      END SELECT

C  ------------------------
C  SET DEFAULT TLAT, TLONG, AND ELEVATION VALUES, BY FOREST
C  ------------------------
      SELECT CASE(IFOR)
        CASE(1)
          IF(TLAT.EQ.0) TLAT=37.95
          IF(TLONG.EQ.0)TLONG=91.77
          IF(ELEV.EQ.0) ELEV=10.
        CASE(2)
          IF(TLAT.EQ.0) TLAT=37.74
          IF(TLONG.EQ.0)TLONG=88.54
          IF(ELEV.EQ.0) ELEV=4.
        CASE(3,4)
          IF(TLAT.EQ.0) TLAT=38.86
          IF(TLONG.EQ.0)TLONG=86.49
          IF(ELEV.EQ.0) ELEV=6.
      END SELECT

C     SET THE IGL VARIABLE ONLY IF DEFAULT FOREST IS USED
C     GEOGRAPHIC LOCATION CODE: 1=NORTH, 2=CENTRAL, 3=SOUTH
C     USED TO SET SOME EQUATIONS IN REGENERATION AND PERHAPS
C     HEIGHT-DIAMETER IN DIFFERENT VARIANTS.
      IF (USEIGL) IGL = KFOR(IFOR)

      KODFOR=JFOR(IFOR)
      RETURN
      END


