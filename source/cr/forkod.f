      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C CR $Id: forkod.f 2790 2019-09-24 20:26:58Z lancedavid $
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
C
C----------
C  NATIONAL FORESTS:
C  201 = ARAPAHO (MAPPED TO ARAPAHO-ROOSEVELT)
C  202 = BIGHORN
C  203 = BLACK HILLS
C  204 = GRAND MESA, UNCOMPAHGRE, GUNNISON
C  205 = GUNNISON (MAPPED TO GMUG)
C  206 = MEDICINE BOW-ROUTT
C  207 = NEBRASKA
C  208 = PIKE (MAPPED TO PIKE-SAN ISABEL)
C  209 = RIO GRANDE
C  210 = ARAPAHO-ROOSEVELT
C  211 = ROUTT (MAPPED TO MEDICINE BOW-ROUTT)
C  212 = PIKE-SAN ISABEL
C  213 = SAN JUAN
C  214 = SHOSHONE
C  215 = WHITE RIVER
C  224 = GRAND MESA (MAPPED TO GMUG)
C  301 = APACHE-SITGREAVES
C  302 = CARSON
C  303 = CIBOLA
C  304 = COCONINO
C  305 = CORONADO
C  306 = GILA
C  307 = KAIBAB
C  308 = LINCOLN
C  309 = PRESCOTT
C  310 = SANTE FE
C  311 = SITGREAVES (MAPPED TO APACHE-SITGREAVES)
C  312 = TONTO

C  ------------------------
C  RESERVATION PSUEDO CODES:
C  7101 = CHEYENNE RIVER RES.              (MAPPED TO 203 BLACK HILLS)
C  7104 = PINE RIDGE RES.                  (MAPPED TO 203 BLACK HILLS)
C  7105 = ROSEBUD INDIAN RES.              (MAPPED TO 203 BLACK HILLS)
C  7106 = YANKTON RES.                     (MAPPED TO 203 BLACK HILLS)
C  7108 = STANDING ROCK RES.               (MAPPED TO 203 BLACK HILLS)
C  7111 = SANTEE RES.                      (MAPPED TO 207 NEBRASKA)
C  7113 = CROW CREEK RES.                  (MAPPED TO 203 BLACK HILLS)
C  7114 = LOWER BRULE RES.                 (MAPPED TO 203 BLACK HILLS)
C  7206 = CHEYENNE-ARAPAHO OTSA            (MAPPED TO 310 SANTA FE)
C  7207 = KIOWA-COMANCHE-APACHE-           (MAPPED TO 310 SANTA FE)
C         FORT SILL APACHE OTSA
C  7208 = KIOWA-COMANCHE-APACHE-FT SILL-   (MAPPED TO 310 SANTA FE)
C         APACHE/CADDO-WICHITA-DELAWARE
C          JOINT-USE OTSA
C  7209 = CADDO-WICHITA-DELAWARE OTSA      (MAPPED TO 310 SANTA FE)
C  7210 = KAW OTSA                         (MAPPED TO 310 SANTA FE)
C  7211 = OTOE-MISSOURIA OTSA              (MAPPED TO 310 SANTA FE)
C  7213 = PONCA OTSA                       (MAPPED TO 310 SANTA FE)
C  7214 = TONKAWA OTSA                     (MAPPED TO 310 SANTA FE)
C  7217 = KICKAPOO (TX) RES.               (MAPPED TO 308 LINCOLN)
C  7302 = CROW RES.                        (MAPPED TO 202 BIGHORN)
C  7305 = NORTHERN CHEYENNE OFF-RES.       (MAPPED TO 203 BLACK HILLS)
C         TRUST LAND
C  7306 = WIND RIVER RES.                  (MAPPED TO 214 SHOSHONE)
C  7601 = CHICKASAW OTSA                   (MAPPED TO 310 SANTA FE)
C  7609 = OSAGE RES.                       (MAPPED TO 310 SANTA FE)
C  7701 = COLORADO RIVER INDIAN RES.       (MAPPED TO 312 TONTO)
C  7702 = FORT MOJAVE RES.                 (MAPPED TO 312 TONTO)
C  7703 = CHEMEHUEVI RES.                  (MAPPED TO 312 TONTO)
C  7704 = FORT APACHE RES.                 (MAPPED TO 311 SITGREAVES)
C  7705 = TOHONO O'ODHAM NATION RES.       (MAPPED TO 312 TONTO)
C  7706 = FORT MCDOWELL YAVAPAI NATION RES.(MAPPED TO 312 TONTO)
C  7707 = SALT RIVER RES.                  (MAPPED TO 312 TONTO)
C  7708 = MARICOPA (AK CHIN) INDIAN RES.   (MAPPED TO 312 TONTO)
C  7709 = GILA RIVER INDIAN RES.           (MAPPED TO 312 TONTO)
C  7710 = SAN CARLOS RES.                  (MAPPED TO 305 CORONADO)
C  7718 = UINTAH AND OURAY RES.            (MAPPED TO 215 WHITE RIVER)
C  7719 = COCOPAH RES.                     (MAPPED TO 312 TONTO)
C  7720 = FORT YUMA INDIAN RES.            (MAPPED TO 312 TONTO)
C  7724 = HOPI RES.                        (MAPPED TO 311 SITGREAVES)
C  7725 = HAVASUPAI RES.                   (MAPPED TO 307 KAIBAB)
C  7726 = HUALAPAI INDIAN RES.             (MAPPED TO 307 KAIBAB)
C  7727 = YAVAPAI-PRESCOTT RES.            (MAPPED TO 309 PRESCOTT)
C  7728 = KAIBAB INDIAN RES.               (MAPPED TO 307 KAIBAB)
C  7835 = TIMBI-SHA SHOSHONE RES.          (MAPPED TO 312 TONTO)
C  7847 = AGUA CALIENTE INDIAN RES.        (MAPPED TO 312 TONTO)
C  7848 = AUGUSTINE RES.                   (MAPPED TO 312 TONTO)
C  7859 = MORONGO RES.                     (MAPPED TO 312 TONTO)
C  7901 = ACOMA PUEBLO                     (MAPPED TO 303 CIBOLA)
C  7902 = PUEBLO DE COCHITI                (MAPPED TO 310 SANTA FE)
C  7903 = ISLETA PUEBLO                    (MAPPED TO 303 CIBOLA)
C  7904 = JEMEZ PUEBLO                     (MAPPED TO 310 SANTA FE)
C  7905 = SANDIA PUEBLO                    (MAPPED TO 303 CIBOLA)
C  7906 = SAN FELIPE PUEBLO                (MAPPED TO 310 SANTA FE)
C  7907 = SANTA ANA PUEBLO                 (MAPPED TO 310 SANTA FE)
C  7908 = SANTO DOMINGO PUEBLO             (MAPPED TO 310 SANTA FE)
C  7909 = ZIA PUEBLO                       (MAPPED TO 310 SANTA FE)
C  7910 = LAGUNA PUEBLO                    (MAPPED TO 303 CIBOLA)
C  7911 = NAMBE PUEBLO                     (MAPPED TO 310 SANTA FE)
C  7912 = PICURIS PUEBLO                   (MAPPED TO 302 CARSON)
C  7913 = PUEBLO OF POJOAQUE               (MAPPED TO 310 SANTA FE)
C  7914 = SAN ILDEFONSO PUEBLO             (MAPPED TO 310 SANTA FE)
C  7915 = OHKAY OWINGEH                    (MAPPED TO 302 CARSON)
C  7916 = SANTA CLARA PUEBLO               (MAPPED TO 310 SANTA FE)
C  7917 = TAOS PUEBLO                      (MAPPED TO 302 CARSON)
C  7918 = TESUQUE PUEBLO                   (MAPPED TO 310 SANTA FE)
C  7919 = SOUTHERN UTE RES.                (MAPPED TO 213 SAN JUAN)
C  7920 = UTE MOUNTAIN RES.                (MAPPED TO 213 SAN JUAN)
C  7921 = JICARILLA APACHE NATION RES.     (MAPPED TO 302 CARSON)
C  7922 = MESCALERO RES.                   (MAPPED TO 308 LINCOLN)
C  7923 = FORT SILL APACHE INDIAN RES.     (MAPPED TO 306 GILA)
C  7924 = ZUNI RES.                        (MAPPED TO 303 CIBOLA)
C  7925 = RAMAH-NAVAJO                     (MAPPED TO 303 CIBOLA)
C  8001 = NAVAJO NATION RES.               (MAPPED TO 311 SITGREAVES)
C----------
      INTEGER JFOR(28),NUMFOR,I
      LOGICAL FORFOUND
      DATA JFOR/ 202, 203, 204, 206, 207, 209, 210, 211, 212, 213,
     & 214, 215, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 312,
     & 201, 205, 208, 224, 311/
      DATA NUMFOR/28/

      FORFOUND = .FALSE.


      SELECT CASE (KODFOR)
C       CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE
        CASE (7101)
          WRITE(JOSTND,60)
   60     FORMAT(/,'********',T12, 'CHEYENNE RIVER RES. (7101) ',
     &    'BEING MAPPED TO BLACK HILLS NF (203) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 2

        CASE (7104)
          WRITE(JOSTND,61)
   61     FORMAT(/,'********',T12, 'PINE RIDGE RES. (7104) BEING ',
     &    'MAPPED TO BLACK HILLS NF (203) FOR FURTHER PROCESSING.')
          I =2

        CASE (7105)
          WRITE(JOSTND,62)
   62     FORMAT(/,'********',T12, 'ROSEBUD INDIAN RES. (7105) ',
     &    'BEING MAPPED TO BLACK HILLS NF (203) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 2

        CASE (7106)
          WRITE(JOSTND,63)
   63     FORMAT(/,'********',T12, 'YANKTON RES. (7106) BEING ',
     &    'MAPPED TO BLACK HILLS NF (203) FOR FURTHER PROCESSING.')
          IFOR = 2

        CASE (7108)
          WRITE(JOSTND,64)
   64     FORMAT(/,'********',T12, 'STANDING ROCK RES. (7108) ',
     &    'BEING MAPPED TO BLACK HILLS NF (203) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 2

        CASE (7111)
          WRITE(JOSTND,65)
   65     FORMAT(/,'********',T12, 'SANTEE RES. (7111) BEING ',
     &    'MAPPED TO NEBRASKA NF (207) FOR FURTHER PROCESSING.')
          IFOR = 5

        CASE (7113)
          WRITE(JOSTND,66)
   66     FORMAT(/,'********',T12, 'CROW CREEK RES. (7113) BEING ',
     &    ' MAPPED TO BLACK HILLS NF (203) FOR FURTHER PROCESSING.')
          IFOR = 2

        CASE (7114)
          WRITE(JOSTND,67)
   67     FORMAT(/,'********',T12, 'LOWER BRULE RES. (7114) BEING',
     &    ' MAPPED TO BLACK HILLS NF (203) FOR FURTHER PROCESSING.')
          IFOR = 2

        CASE (7206)
          WRITE(JOSTND,68)
   68     FORMAT(/,'********',T12, 'CHEYENNE-ARAPAHO OTSA (7206) ',
     &    'BEING MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7207)
          WRITE(JOSTND,69)
   69     FORMAT(/,'********',T12, 'KIOWA-COMANCHE-APACHE-FORT ',
     &    'SILL APACHE OTSA (7207) BEING MAPPED TO SANTA FE NF ',
     &    '(310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7208)
          WRITE(JOSTND,70)
   70     FORMAT(/,'********',T12, 'KIOWA-COMANCHE-APACHE-FT SILL-',
     &    'APACHE CADDO-WICHITA-DELAWARE JOINT-USE OTSA (7208) BEING ',
     &    'MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7209)
          WRITE(JOSTND,71)
   71     FORMAT(/,'********',T12, 'CADDO-WICHITA-DELAWARE OTSA ',
     &    '(7209) BEING MAPPED TO SANTA FE NF (310) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 22

        CASE (7210)
          WRITE(JOSTND,72)
   72     FORMAT(/,'********',T12, 'KAW OTSA (7210) BEING MAPPED ',
     &    'TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7211)
          WRITE(JOSTND,73)
   73     FORMAT(/,'********',T12, 'OTOE-MISSOURIA OTSA (7211) ',
     &    'BEING MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7213)
          WRITE(JOSTND,74)
   74     FORMAT(/,'********',T12, 'PONCA OTSA (7213) BEING ',
     &    'MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7214)
          WRITE(JOSTND,75)
   75     FORMAT(/,'********',T12, 'TONKAWA OTSA (7214) BEING ',
     &    'MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7217)
          WRITE(JOSTND,76)
   76     FORMAT(/,'********',T12, 'KICKAPOO (TX) RES. (7217) ',
     &    'BEING MAPPED TO LINCOLN NF (308) FOR FURTHER PROCESSING.')
          IFOR = 20

        CASE (7302)
          WRITE(JOSTND,77)
   77     FORMAT(/,'********',T12, 'CROW RES. (7302) BEING MAPPED',
     &    ' TO BIGHORN NF (202) FOR FURTHER PROCESSING.')
          IFOR = 1

        CASE (7305)
          WRITE(JOSTND,78)
   78     FORMAT(/,'********',T12, 'NORTHERN CHEYENNE OFF-RES. ',
     &    'TRUST LAND (7305) BEING MAPPED TO BLACK HILLS NF (203) ',
     &    'FOR FURTHER PROCESSING.')
          IFOR = 2

        CASE (7306)
          WRITE(JOSTND,79)
   79     FORMAT(/,'********',T12, 'WIND RIVER RES. (7306) BEING ',
     &    'MAPPED TO SHOSHONE NF (214) FOR FURTHER PROCESSING.')
          IFOR = 11

        CASE (7601)
          WRITE(JOSTND,80)
   80     FORMAT(/,'********',T12, 'CHICKASAW OTSA (7601) BEING ',
     &    'MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7609)
          WRITE(JOSTND,81)
   81     FORMAT(/,'********',T12, 'OSAGE RES. (7609) BEING MAPPED',
     &    ' TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7701)
          WRITE(JOSTND,82)
   82     FORMAT(/,'********',T12, 'COLORADO RIVER INDIAN RES. ',
     &    '(7701) BEING MAPPED TO TONTO NF (312) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 23

        CASE (7702)
          WRITE(JOSTND,83)
   83     FORMAT(/,'********',T12, 'FORT MOJAVE RES. (7702) BEING ',
     &    'MAPPED TO TONTO NF (312) FOR FURTHER PROCESSING.')
          IFOR = 23

        CASE (7703)
          WRITE(JOSTND,84)
   84     FORMAT(/,'********',T12, 'CHEMEHUEVI RES. (7703) BEING ',
     &    'MAPPED TO TONTO NF (312) FOR FURTHER PROCESSING.')
          IFOR = 23

        CASE (7704)
          WRITE(JOSTND,85)
   85     FORMAT(/,'********',T12, 'FORT APACHE RES. (7704) BEING ',
     &    'MAPPED TO SITGREAVES NF (311) FOR FURTHER PROCESSING.')
          IFOR = 28

        CASE (7705)
          WRITE(JOSTND,86)
   86     FORMAT(/,'********',T12, 'TOHONO O''ODHAM NATION RES. ',
     &    '(7705) BEING MAPPED TO TONTO NF (312) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 23

        CASE (7706)
          WRITE(JOSTND,87)
   87     FORMAT(/,'********',T12, 'FORT MCDOWELL YAVAPAI NATION ',
     &    'RES. (7706) BEING MAPPED TO TONTO NF (312) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 23

        CASE (7707)
          WRITE(JOSTND,88)
   88     FORMAT(/,'********',T12, 'SALT RIVER RES. (7707) BEING ',
     &    'MAPPED TO TONTO NF (312) FOR FURTHER PROCESSING.')
          IFOR = 23

        CASE (7708)
          WRITE(JOSTND,89)
   89     FORMAT(/,'********',T12, 'MARICOPA (AK CHIN) INDIAN ',
     &    'RES. (7708) BEING MAPPED TO TONTO NF (312) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 23

        CASE (7709)
          WRITE(JOSTND,90)
   90     FORMAT(/,'********',T12, 'GILA RIVER INDIAN RES. (7709) ',
     &    'BEING MAPPED TO TONTO NF (312) FOR FURTHER PROCESSING.')
          IFOR = 23

        CASE (7710)
          WRITE(JOSTND,91)
   91     FORMAT(/,'********',T12, 'SAN CARLOS RES. (7710) BEING ',
     &    'MAPPED TO CORONADO NF (305) FOR FURTHER PROCESSING.')
          IFOR = 17

        CASE (7718)
          WRITE(JOSTND,92)
   92     FORMAT(/,'********',T12, 'UINTAH AND OURAY RES. (7718) ',
     &    'BEING MAPPED TO WHITE RIVER NF (215) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 12

        CASE (7719)
          WRITE(JOSTND,93)
   93     FORMAT(/,'********',T12, 'COCOPAH RES. (7719) BEING ',
     &    'MAPPED TO TONTO NF (312) FOR FURTHER PROCESSING.')
          IFOR = 23

        CASE (7720)
          WRITE(JOSTND,94)
   94     FORMAT(/,'********',T12, 'FORT YUMA INDIAN RES. (7720) ',
     &    'BEING MAPPED TO TONTO NF (312) FOR FURTHER PROCESSING.')
          IFOR = 23

        CASE (7724)
          WRITE(JOSTND,95)
   95     FORMAT(/,'********',T12, 'HOPI RES. (7724) BEING MAPPED ',
     &    'TO SITGREAVES NF (311) FOR FURTHER PROCESSING.')
          IFOR = 28

        CASE (7725)
          WRITE(JOSTND,96)
   96     FORMAT(/,'********',T12, 'HAVASUPAI RES. (7725) BEING ',
     &    'MAPPED TO KAIBAB NF (307) FOR FURTHER PROCESSING.')
          IFOR = 19

        CASE (7726)
          WRITE(JOSTND,97)
   97     FORMAT(/,'********',T12, 'HUALAPAI INDIAN RES. (7726) ',
     &    'BEING MAPPED TO KAIBAB NF (307) FOR FURTHER PROCESSING.')
          IFOR = 19

        CASE (7727)
          WRITE(JOSTND,98)
   98     FORMAT(/,'********',T12, 'YAVAPAI-PRESCOTT RES. (7727) ',
     &    'BEING MAPPED TO PRESCOTT NF (309) FOR FURTHER PROCESSING.')
          IFOR = 21

        CASE (7728)
          WRITE(JOSTND,99)
   99     FORMAT(/,'********',T12, 'KAIBAB INDIAN RES. (7728) ',
     &    'BEING MAPPED TO KAIBAB NF (307) FOR FURTHER PROCESSING.')
          IFOR = 19

        CASE (7835)
          WRITE(JOSTND,100)
  100     FORMAT(/,'********',T12, 'TIMBI-SHA SHOSHONE RES. (7835)',
     &    ' BEING MAPPED TO TONTO NF (312) FOR FURTHER PROCESSING.')
          IFOR = 23

        CASE (7847)
          WRITE(JOSTND,101)
  101     FORMAT(/,'********',T12, 'AGUA CALIENTE INDIAN RES. ',
     &    '(7847) BEING MAPPED TO TONTO NF (312) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 23

        CASE (7848)
          WRITE(JOSTND,102)
  102     FORMAT(/,'********',T12, 'AUGUSTINE RES. (7848) BEING ',
     &    'MAPPED TO TONTO NF (312) FOR FURTHER PROCESSING.')
          IFOR = 23

        CASE (7859)
          WRITE(JOSTND,103)
  103     FORMAT(/,'********',T12, 'MORONGO RES. (7859) BEING ',
     &    'MAPPED TO TONTO NF (312) FOR FURTHER PROCESSING.')
          IFOR = 23

        CASE (7901)
          WRITE(JOSTND,104)
  104     FORMAT(/,'********',T12, 'ACOMA PUEBLO (7901) BEING ',
     &    'MAPPED TO CIBOLA NF (303) FOR FURTHER PROCESSING.')
          IFOR = 15

        CASE (7902)
          WRITE(JOSTND,105)
  105     FORMAT(/,'********',T12, 'PUEBLO DE COCHITI (7902) BEING',
     &    ' MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7903)
          WRITE(JOSTND,106)
  106     FORMAT(/,'********',T12, 'ISLETA PUEBLO (7903) BEING ',
     &    'MAPPED TO CIBOLA NF (303) FOR FURTHER PROCESSING.')
          IFOR = 15

        CASE (7904)
          WRITE(JOSTND,107)
  107     FORMAT(/,'********',T12, 'JEMEZ PUEBLO (7904) BEING ',
     &    'MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7905)
          WRITE(JOSTND,108)
  108     FORMAT(/,'********',T12, 'SANDIA PUEBLO (7905) BEING ',
     &    'MAPPED TO CIBOLA NF (303) FOR FURTHER PROCESSING.')
          IFOR = 15

        CASE (7906)
          WRITE(JOSTND,109)
  109     FORMAT(/,'********',T12, 'SAN FELIPE PUEBLO (7906) ',
     &    'BEING MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7907)
          WRITE(JOSTND,110)
  110     FORMAT(/,'********',T12, 'SANTA ANA PUEBLO (7907) BEING ',
     &    'MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7908)
          WRITE(JOSTND,111)
  111     FORMAT(/,'********',T12, 'SANTO DOMINGO PUEBLO (7908) ',
     &    'BEING MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7909)
          WRITE(JOSTND,112)
  112     FORMAT(/,'********',T12, 'ZIA PUEBLO (7909) BEING MAPPED',
     &    ' TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7910)
          WRITE(JOSTND,113)
  113     FORMAT(/,'********',T12, 'LAGUNA PUEBLO (7910) BEING ',
     &    'MAPPED TO CIBOLA NF (303) FOR FURTHER PROCESSING.')
          IFOR = 15

        CASE (7911)
          WRITE(JOSTND,114)
  114     FORMAT(/,'********',T12, 'NAMBE PUEBLO (7911) BEING ',
     &    'MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7912)
          WRITE(JOSTND,115)
  115     FORMAT(/,'********',T12, 'PICURIS PUEBLO (7912) BEING ',
     &    'MAPPED TO CARSON NF (302) FOR FURTHER PROCESSING.')
          IFOR = 14

        CASE (7913)
          WRITE(JOSTND,116)
  116     FORMAT(/,'********',T12, 'PUEBLO OF POJOAQUE (7913) ',
     &    'BEING MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7914)
          WRITE(JOSTND,117)
  117     FORMAT(/,'********',T12, 'SAN ILDEFONSO PUEBLO (7914) ',
     &    'BEING MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7915)
          WRITE(JOSTND,118)
  118     FORMAT(/,'********',T12, 'OHKAY OWINGEH (7915) BEING ',
     &    'MAPPED TO CARSON NF (302) FOR FURTHER PROCESSING.')
          IFOR = 14

        CASE (7916)
          WRITE(JOSTND,119)
  119     FORMAT(/,'********',T12, 'SANTA CLARA PUEBLO (7916) ',
     &    'BEING MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7917)
          WRITE(JOSTND,120)
  120     FORMAT(/,'********',T12, 'TAOS PUEBLO (7917) BEING ',
     &    'MAPPED TO CARSON NF (302) FOR FURTHER PROCESSING.')
          IFOR = 14

        CASE (7918)
          WRITE(JOSTND,121)
  121     FORMAT(/,'********',T12, 'TESUQUE PUEBLO (7918) BEING ',
     &    'MAPPED TO SANTA FE NF (310) FOR FURTHER PROCESSING.')
          IFOR = 22

        CASE (7919)
          WRITE(JOSTND,122)
  122     FORMAT(/,'********',T12, 'SOUTHERN UTE RES. (7919) BEING ',
     &    'MAPPED TO SAN JUAN NF (213) FOR FURTHER PROCESSING.')
          IFOR = 10

        CASE (7920)
          WRITE(JOSTND,123)
  123     FORMAT(/,'********',T12, 'UTE MOUNTAIN RES. (7920) BEING ',
     &    'MAPPED TO SAN JUAN NF (213) FOR FURTHER PROCESSING.')
          IFOR = 10

        CASE (7921)
          WRITE(JOSTND,124)
  124     FORMAT(/,'********',T12, 'JICARILLA APACHE NATION RES. ',
     &    '(7921) BEING MAPPED TO CARSON NF (302) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 14

        CASE (7922)
          WRITE(JOSTND,125)
  125     FORMAT(/,'********',T12, 'MESCALERO RES. (7922) BEING ',
     &    'MAPPED TO LINCOLN NF (308) FOR FURTHER PROCESSING.')
          IFOR = 20

        CASE (7923)
          WRITE(JOSTND,126)
  126     FORMAT(/,'********',T12, 'FORT SILL APACHE INDIAN RES. ',
     &    '(7923) BEING MAPPED TO GILA NF (306) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 18

        CASE (7924)
          WRITE(JOSTND,127)
  127     FORMAT(/,'********',T12, 'ZUNI RES. (7924) BEING MAPPED ',
     &    'TO CIBOLA NF (303) FOR FURTHER PROCESSING.')
          IFOR = 15

        CASE (7925)
          WRITE(JOSTND,128)
  128     FORMAT(/,'********',T12, 'RAMAH-NAVAJO (7925) BEING ',
     &    'MAPPED TO CIBOLA NF (303) FOR FURTHER PROCESSING.')
          IFOR = 15

        CASE (8001)
          WRITE(JOSTND,129)
  129     FORMAT(/,'********',T12, 'NAVAJO NATION RES. (8001) ',
     &    'BEING MAPPED TO SITGREAVES NF (311) FOR FURTHER PROCESSING.')
          IFOR = 28
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

C           ERROR TRAPPING FOR MISSING LOCATIONS BASED UPON
C           CENTRAL ROCKIES VARIANT - 5 SUBMODELS IMODTY
C             SOUTHWEST MIXED CONIFER    : 1
C             SOUTHWEST PONDEROSA PINE   : 2
C             BLACK HILLS PONDEROSA PINE : 3
C             SPRUCE-FIR                 : 4
C             LODGEPOLE PINE             : 5

            CALL ERRGRO (.TRUE.,3)
            SELECT CASE (IMODTY)
              CASE ( :2)
                IF(IFOR.EQ.0) THEN
C                 CIBOLA
                  IFOR = 15
                ENDIF
                IF(KODFOR.GT.0 .AND. KODFOR.LT.300) THEN
C                 SAN JUAN
                  IFOR = 10
                ENDIF
              CASE (3)
                IF(IFOR.EQ.0) THEN
C                 BIGHORN
                  IFOR = 2
                ENDIF
              CASE DEFAULT
                IF(IFOR.EQ.0) THEN
C                 GMUG
                  IFOR = 4
                ENDIF
            END SELECT

            IF(KODFOR.GT.0) THEN
              WRITE(JOSTND,149) JFOR(IFOR)
  149         FORMAT(/,'********',T12,'FOREST CODE USED IN THIS ',
     &        'PROJECTION IS ',I4)
            ENDIF

          ENDIF

      END SELECT


C     FOREST MAPPING CORRECTION
      SELECT CASE (IFOR)
        CASE (24)
          WRITE(JOSTND,201)
  201     FORMAT(/,'********',T12,'ARAPAHO NF (201) BEING MAPPED TO ',
     &    'ARAPAHO-ROOSEVELT (210) FOR FURTHER PROCESSING.')
          IFOR = 7
        CASE (25)
          WRITE(JOSTND,202)
  202     FORMAT(/,'********',T12,'GUNNISON NF (205) BEING MAPPED TO ',
     &    'GRAND MESA-UNCOMPAHGRE-GUNNISON (204) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 3
        CASE (26)
          WRITE(JOSTND,203)
  203     FORMAT(/,'********',T12,'PIKE NF (208) BEING MAPPED TO ',
     &    'PIKE-SAN ISABEL (212) FOR FURTHER PROCESSING.')
          IFOR = 9
        CASE (27)
          WRITE(JOSTND,204)
  204     FORMAT(/,'********',T12,'GRAND MESA NF (224) BEING MAPPED ',
     &    'TO GRAND MESA-UNCOMPAHGRE-GUNNISON (204) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 3
        CASE (28)
          WRITE(JOSTND,205)
  205     FORMAT(/,'********',T12,'SITGREAVES NF (311) BEING MAPPED ',
     &    'TO APACHE-SITGREAVES (301) FOR FURTHER PROCESSING.')
          IFOR = 13
        CASE (8)
          WRITE(JOSTND,206)
  206     FORMAT(/,'********',T12,'ROUTT NF (211) BEING MAPPED TO ',
     &    'MEDICINE BOW-ROUTT (206) FOR FURTHER PROCESSING.')
          IFOR = 4
      END SELECT

      KODFOR=JFOR(IFOR)
      RETURN
      END
