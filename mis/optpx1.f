      SUBROUTINE OPTPX1 (*,STOR,NOGO,NEN,LOC1)        
C        
C     PROCESS PID DATA ON PLIMIT CARD        
C        
      INTEGER         STOR(15),SYSBUF,OUTTAP,YCOR,THRU,NAM(2),X(7),IY(1)
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / SKP1(5),YCOR        
CZZ   COMMON /ZZOPT1/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /SYSTEM/ SYSBUF,OUTTAP        
      EQUIVALENCE     (CORE(1),X(1)),(X(7),IY(1))        
      DATA    THRU  / 4HTHRU  /        
C        
      NAM(1) = STOR(1)        
      NAM(2) = STOR(2)        
      IF (STOR(6) .EQ. THRU) GO TO 100        
C        
C     USER SPECIFIED BY EXPLICIT ID-S        
C        
      CALL SORT (0,0,1,1,STOR(5),5)        
C        
C     CREATE PSEUDO THRU RANGE        
C     LOCATE FIRST NONZERO        
C        
      DO 10 L = 5,9        
      IF (STOR(L) .NE. 0) GO TO 30        
   10 CONTINUE        
      CALL PAGE2 (-2)        
      WRITE  (OUTTAP,20) UFM,NAM        
   20 FORMAT (A23,' 2293, NO PID ENTRIES ON PLIMIT CARD (',2A4,2H).)    
      NOGO = NOGO + 1        
      GO TO 110        
C        
C     LOOP ON ENTRIES        
C        
   30 CONTINUE        
      I1 = STOR(L)        
      I3 = 1        
   35 I2 = STOR(L+1)        
      IF (L-9) 40,60,130        
   40 IF (I2-I1-I3) 80,50,60        
C        
C     THRU CAN BE EXPANDED        
C        
   50 L  = L  + 1        
      I3 = I3 + 1        
      GO TO 35        
C        
C     PUT OUT I1,I2        
C        
   60 STOR(1) = I1        
      STOR(2) = STOR(L)        
      IF (LOC1+3+NEN .GT. YCOR) GO TO 120        
      CALL BISHEL (*80,STOR,NEN,4,IY(LOC1))        
   70 L = L + 1        
      IF (L-9) 30,30,110        
C        
C     DUPLICATE ENTRIES FOUND        
C        
   80 CALL PAGE2 (-2)        
      WRITE  (OUTTAP,90) UFM,I1,I2,NAM        
   90 FORMAT (A23,' 2294, DUPLICATE',I8,' THRU',I8,' RANGE FOR ELEMENT',
     1        1X,2A4,' REJECTED PLIMIT. SCAN CONTINUED.')        
      NOGO = NOGO + 1        
      GO TO 70        
C        
C     USER SPECIFIED BY USING THRU        
C        
  100 L = 8        
      STOR(9) = STOR(8)        
      STOR(8) = STOR(5)        
      GO TO 30        
C        
C     THIS PLIMIT FINISHED        
C        
  110 CONTINUE        
      RETURN        
C        
C     INSUFFICIENT CORE        
C        
  120 CONTINUE        
      STOR(1) = NAM(1)        
      STOR(2) = NAM(2)        
      RETURN 1        
C        
  130 CALL MESAGE (-7,0,NAM)        
      GO TO 120        
      END        
