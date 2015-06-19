      SUBROUTINE INVFBS (DX,DY,IOBUF)        
C        
C     DOUBLE PRECISION VERSION        
C        
C     INVFBS IS A SPECIAL FORWARD-BACKWARD SUBSTITUTION ROUTINE FOR     
C     INVPWR. IT OPERATES ON CONJUNCTION WITH SDCOMP.        
C     THE ARITHMETIC PRECISION IS THAT OF THE INPUT FILE        
C        
C     FILEL    =  MATRIX CONTROL BLOCK FOR THE LOWER TRIANGLE L        
C     FILEU    =  MATRIX CONTROL BLOCK FOR THE UPPER TRIANGLE U        
C     DX       =  THE LOAD VECTOR B        
C     DY       =  THE SOLUTION VECTOR X        
C     IOBUF    =  THE INPUT BUFFER        
C        
C     COMMENT FROM G.CHAN/UNISYS, 6/89        
C     IF LOAD IS SUDDENLY INCREADED TO A LARGE VALUE, THE VAX MACHINE   
C     MAY BLOW ITS TOP (ARITHMETIC FAULT, FLOATING OVERFLOW) BECAUSE    
C     VAX DOUBLE PRECISION REAL NUMBERS ARE LIMITED TO 10**38, SAME     
C     LIMIT AS THE SINGLE PRECISION REAL NUMBERS. OTHER MACHINES ALLOW  
C     MUCH LARGER LIMITS FOR DOUBLE PRECISION NUMBERS.        
C        
      INTEGER            FILEL     ,FILEU    ,TYPEAR   ,RDP      ,      
     1                   PARM(4)   ,EOL      ,IJJ(2)        
      DOUBLE PRECISION   DX(1)     ,DY(1)    ,DA       ,DTEMP    ,      
     1                   DJJ       ,DYJ      ,EPSI        
      DIMENSION          IOBUF(1)        
      CHARACTER          UFM*23    ,UWM*25   ,UIM*29   ,SFM*25        
      COMMON   /XMSSG /  UFM       ,UWM      ,UIM      ,SFM        
      COMMON   /MACHIN/  MACH        
      COMMON   /SYSTEM/  IBUF      ,NOUT        
C     COMMON   /DESCRP/  LENGTH    ,MAJOR        
      COMMON   /NAMES /  RD        ,RDREW    ,WRT      ,WRTREW   ,      
     1                   REW       ,NOREW    ,EOFNRW   ,RSP      ,      
     2                   RDP       ,CSP      ,CDP      ,SQR      ,      
     3                   RECT      ,DIAG     ,LOWTRI   ,UPRTRI   ,      
     4                   SYM       ,ROW      ,IDENTY        
      COMMON   /TYPE  /  RC(2)     ,NWDS(4)        
      COMMON   /ZNTPKX/  A(4)      ,II       ,EOL        
      COMMON   /INFBSX/  FILEL(7)  ,FILEU(7)        
      COMMON   /TRDXX /  IDUMMY(27),IOPEN        
      EQUIVALENCE        (A(1),DA) ,(FILEL(3),NROW)    ,(DJJ,IJJ(1))    
      DATA      EPSI  /  1.0D-24   /        
      DATA      PARM(3), PARM(4)   /4HINVF,4HBS  /        
C        
C        
C     TRANSFER THE LOAD VECTOR TO THE SOLUTION VECTOR        
C        
      DO 10 I = 1,NROW        
   10 DY(I)  = DX(I)        
      TYPEAR = RDP        
C        
C     OPEN FILE FOR THE LOWER TRIANGLE        
C     IOPEN WAS SET TO -20 BY STEP2        
C        
      PARM(2) = FILEL(1)        
      IF (IOPEN .EQ.  -20) CALL FWDREC (*360,FILEL(1))        
      IF (FILEL(7) .LT. 0) GO TO 300        
C        
C     NASTRAN ORIGINAL CODE        
C        
C     BEGIN FORWARD PASS        
C        
      J = 1        
   20 CALL INTPK (*100,FILEL(1),0,TYPEAR,0)        
   30 IF (EOL) 220,40,220        
   40 CALL ZNTPKI        
      IF (J-II) 80,50,30        
C        
C     PERFORM THE REQUIRED ROW INTERCHANGE        
C        
   50 IN1   = J+IFIX(SNGL(DA))        
      DTEMP = DY(J)        
      DY(J) = DY(IN1)        
      DY(IN1) = DTEMP        
   60 IF (EOL) 100,70,100        
   70 CALL ZNTPKI        
   80 IF (MACH.NE.5 .OR.        
     1   (DABS(DA).LT.1.D+19 .AND. DABS(DY(J)).LT.1.D+19)) GO TO 90     
      X1 = ALOG10(ABS(SNGL(DA)))        
      X2 = ALOG10(ABS(SNGL(DY(J))))        
      IF (X1+X2 .GT. 38.) GO TO 200        
   90 DY(II) = DY(II) - DY(J)*DA        
      GO TO 60        
  100 J = J + 1        
      IF (J .LT. NROW) GO TO 20        
      CALL REWIND (FILEL(1))        
      IF (IOPEN .EQ. -20) GO TO 110        
      CALL SKPREC (FILEL,1)        
C        
C     BEGIN BACKWARD PASS        
C        
  110 IOFF    = FILEU(7) - 1        
      PARM(2) = FILEU(1)        
      IF (IOPEN .EQ. -20) CALL FWDREC (*360,FILEU(1))        
      J = NROW        
  120 CALL INTPK (*220,FILEU(1),0,TYPEAR,0)        
      IF (EOL .NE. 0) GO TO 220        
  130 CALL ZNTPKI        
      I = NROW - II + 1        
      IF (I .NE. J) GO TO 150        
C        
C     DIVIDE BY THE DIAGONAL        
C        
      DY(I) = DY(I)/DA        
C        
C     SUBTRACT OFF REMAINING TERMS        
C        
  140 IF (I   .GT. J) GO TO 130        
      IF (EOL .NE. 0) GO TO 180        
      CALL ZNTPKI        
      I   = NROW - II + 1        
  150 IN1 = I        
      IN2 = J        
      IF (I .LT. J) GO TO 160        
      K   = IN1        
      IN1 = IN2 - IOFF        
      IN2 = K        
  160 IF (MACH.NE.5 .OR.        
     1   (DABS(DA).LT.1.D+19 .AND. DABS(DY(IN2)).LT.1.D+19)) GO TO 170  
      X1 = ALOG10(ABS(SNGL(DA)))        
      X2 = ALOG10(ABS(SNGL(DY(IN2))))        
      IF (X1+X2 .GT. 38.) GO TO 200        
  170 DY(IN1) = DY(IN1) - DY(IN2)*DA        
      GO TO 140        
  180 J = J - 1        
      IF (J .GT. 0) GO TO 120        
      CALL REWIND (FILEU)        
      IF (IOPEN .EQ. -20) RETURN        
      CALL SKPREC (FILEU,1)        
      GO TO 450        
C        
  200 WRITE  (NOUT,210) SFM,PARM(1),PARM(2)        
  210 FORMAT (A25,' FROM ',2A4,'- SOLUTION VECTOR VALUE OVERFLOWS,',/5X,
     1       'POSSIBLY DUE TO SUDDEN INCREASE OF LARGE LOAD VECTOR OR ',
     2       'OTHER INPUT CONDITION')        
      GO TO 420        
  220 PARM(1) = -5        
      GO TO 440        
C        
C        
C     NEW METHOD        
C     FILEL HAS BEEN RE-WRITTEN FORWARD FIRST THAN BACKWARD BY UNPSCR   
C     IN INVP3)        
C        
C     THE LOAD VECTOR DX WILL BE DESTROYED IN THIS NEW METHOD        
C        
C     FORWARD SWEEP DIRECTLY ON SOLUTION VECTOR DY        
C        
  300 IFILE  =-FILEL(7)        
      PARM(2)= IFILE        
      NWD    = NWDS(FILEL(5))        
      IF (FILEL(4) .NE. 2) GO TO 400        
      IFW = +1        
      CALL REWIND (IFILE)        
      CALL SKPREC (IFILE,1)        
      CALL READ (*360,*370,IFILE,DX,2,0,I)        
      NTMS = 0        
      DO 320 J = 1,NROW        
      DJJ = DX(NTMS+1)        
      II  = IJJ(1)        
      JJ  = IJJ(2)        
      IF (II .NE. J) GO TO 380        
      NTMS = JJ - II + 1        
      JI = NTMS*NWD + 2        
      CALL READ (*360,*370,IFILE,DX,JI,0,I)        
      IF (NTMS .LE. 1) GO TO 320        
      DYJ = DY(J)        
      IF (DABS(DYJ) .LT. EPSI) GO TO 320        
      DO 310 I = 2,NTMS        
      II = II + 1        
      DY(II) = DY(II) + DX(I)*DYJ        
  310 CONTINUE        
  320 DY(J) = DY(J)/DX(1)        
C        
C     BACKWARD SUBSTITUTION OMIT DIAGONAL        
C        
      IFW = -1        
      IF (NROW .EQ. 1) GO TO 450        
      J  = NROW        
      DO 340 JX = 1,NROW        
      DJJ = DX(NTMS+1)        
      II  = IJJ(1)        
      JJ  = IJJ(2)        
      IF (II .NE. J) GO TO 380        
      NTMS = JJ - II + 1        
      JI = NTMS*NWD + 2        
      CALL READ (*360,*370,IFILE,DX,JI,0,I)        
      IF (NTMS .LE. 1) GO TO 340        
      DO 330 I = 2,NTMS        
      II = II + 1        
      DY(J) = DY(J) + DX(I)*DY(II)        
  330 CONTINUE        
  340 J = J - 1        
      GO TO 450        
C        
C     ERROR        
C        
  360 PARM(1) = -2        
      GO TO 440        
  370 PARM(1) = -3        
      GO TO 440        
  380 WRITE  (NOUT,390) IFW,II,J        
  390 FORMAT ('   ERROR IN INVFBS.   IFW),II,J =',I3,1H),2I6)        
      GO TO 420        
  400 WRITE  (NOUT,410) FILEL(4)        
  410 FORMAT ('0*** FILEL MATRIX IN WRONG FORMAT. UNPSCR FLAG =',I3)    
  420 PARM(1) = -37        
  440 CALL MESAGE (PARM(1),PARM(2),PARM(3))        
C        
  450 RETURN        
      END        