      SUBROUTINE GKAM        
C        
C     ROUTINE TO ASSEMBLE MODAL MATRICES        
C        
C     INPUTS = 9        
C        
C     USETD,PHIA,MI,LAMA,SDT,M2DD,B2DD,K2DD,CASECC        
C        
C     OUTPUTS = 4        
C        
C     MHH,BHH,KHH,PHIDH        
C        
C     SCRATCHES = 4        
C        
      INTEGER         USETD,B2DD,SDT,PHIA,PHIDH,BHH,SCR1,SCR2,SCR3,     
     1                PHIDH1,SYSBUF,CASECC,NAME(2)        
      REAL            LFREQ        
      DIMENSION       MCB(7),ICORE(2),BLOCK(11),IBLOCK(11)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /BLANK / NOUE,NLMODE,LFREQ,HFREQ,NOM2DD,NOB2DD,NOK2DD,     
     1                NONCUP,NMODE,KDAMP        
      COMMON /PACKX / IT1,IT2,II,JJ,INCR        
      COMMON /UNPAKX/ IT3,II1,JJ1,INCR1        
      COMMON /CONDAS/ PI,TWOPHI,RADEG,DEGRA,S4PISQ        
CZZ   COMMON /ZZGKAM/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /SYSTEM/ SYSBUF,NOUT        
C        
      EQUIVALENCE     (CORE(1),ICORE(1)),(IBLOCK(1),BLOCK(1))        
C        
      DATA    NAME  / 4HGKAM,4H    /        
      DATA    IBLOCK(1),IBLOCK(7),BLOCK(2),BLOCK(8)   / 1,1,1.0,1.0 /   
      DATA    USETD , PHIA,MI, LAMA,SDT,M2DD,B2DD,K2DD/        
     1        101   , 102, 103,104, 105,106, 107, 108 /        
      DATA    MHH   , BHH,KHH,PHIDH/        
     1        201   , 202,203,204  /        
      DATA    SCR1  , SCR2,SCR3,PHIDH1,CASECC /        
     1        301   , 302 ,303 ,304   ,109    /        
C        
C        
C     PICK UP AND STORE SELECTED MODES, SAVING EIGENVECTORS        
C        
      LC1  = KORSZ(CORE)        
      NZ   = LC1 - SYSBUF        
      ICRQ = 2*SYSBUF - NZ        
      IF (ICRQ .GT. 0) GO TO 220        
C        
C     FIND SELECTED SDT INTO CASECC        
C        
      CALL GOPEN (CASECC,CORE(NZ+1),0)        
      CALL FREAD (CASECC,ICORE,166,1)        
      CALL CLOSE (CASECC,1)        
      I149  = 149        
      NOSDT = ICORE(I149)        
C        
C     OPEN  LAMA, PHIA, AND PHI0H        
C        
      CALL GOPEN (LAMA,CORE(NZ+1),0)        
      CALL SKPREC (LAMA,1)        
      NZ = NZ - SYSBUF        
      CALL GOPEN (PHIA,CORE(NZ+1),0)        
      ICORE(1) = PHIA        
      CALL RDTRL (ICORE)        
      NVECT = ICORE(2)        
      NZ = NZ - SYSBUF        
      IF (NOUE .LT. 0) PHIDH1 = PHIDH        
      CALL GOPEN (PHIDH1,CORE(NZ+1),1)        
      MCB(1) = PHIA        
      CALL RDTRL (MCB)        
      MCB(1)= PHIDH1        
      IT1   = MCB(5)        
      IT2   = IT1        
      IT3   = IT1        
      INCR  = 1        
      INCR1 = 1        
      II    = 1        
      II1   = 1        
      JJ    = MCB(3)        
      JJ1   = JJ        
      MCB(2)= 0        
      MCB(6)= 0        
      MCB(7)= 0        
      ISW   = 1        
      MODES = 1        
      DO 10 I = 1,NVECT        
      CALL READ (*190,*40,LAMA,CORE(NZ-6),7,0,IFLAG)        
C        
C     PICK UP FREQUENCY        
C        
      F = CORE(NZ-2)        
      IF (NLMODE .EQ. 0) GO TO 50        
C        
C     ACCEPT LAMA        
C        
   20 CORE(MODES) = F*TWOPHI        
      MODES = MODES + 1        
      CALL UNPACK (*210,PHIA,CORE(MODES))        
      GO TO 30        
C        
C     FREQUENCY RANGE SPECIFICATION        
C        
   50 IF (F .GT. HFREQ) GO TO 40        
      IF (F .GE. LFREQ) GO TO 20        
      CALL SKPREC (PHIA,1)        
      ISW = ISW + 1        
      GO TO 10        
   30 CALL PACK (CORE(MODES),PHIDH1,MCB)        
      IF (NLMODE .EQ. 0) GO TO 10        
      IF (MODES .GT. NLMODE) GO TO 40        
   10 CONTINUE        
C        
C     DONE        
C        
   40 CALL CLOSE (LAMA,1)        
      CALL CLOSE (PHIA,1)        
      CALL CLOSE (PHIDH1,1)        
      CALL WRTTRL (MCB)        
      GO TO 60        
C        
C     BUILD PHIDH        
C        
   60 LHSET = MODES - 1        
      NMODE = ISW        
      IF (LHSET .LE. 0) GO TO 230        
      IF (NOUE  .LT. 0) GO TO 70        
      CALL GKAM1B (USETD,SCR1,SCR2,PHIDH,PHIDH1,MODES,CORE,LHSET,NOUE,  
     1             SCR3)        
C        
C     FORM H MATRICES        
C        
   70 MODES = MODES - 1        
C        
C     SAVE MODES ON SCRATCH3 IN CASE DMI WIPES THEM OUT        
C        
      NZ = LC1 - SYSBUF        
      CALL OPEN  (*250,SCR3,CORE(NZ+1),1)        
      CALL WRITE (SCR3,CORE(1),MODES,1)        
      CALL CLOSE (SCR3,1)        
      NONCUP = 1        
C        
C     FORM  MHH        
C        
      CALL  GKAM1A (MI,PHIDH,SDT,SCR1,SCR2,1,MHH,NO M2DD,CORE(1),MODES, 
     1              NOSDT,LHSET,M2DD,ISW,SCR3)        
      IF (NOM2DD .LT. 0) GO TO 80        
      CALL SSG2C (SCR1,SCR2,MHH,1,IBLOCK(1))        
   80 CONTINUE        
C        
C     FORM  BHH        
C        
      IF (NOSDT.EQ.0 .AND. NOB2DD.LT.0) GO TO 90        
      CALL GKAM1A (MI,PHIDH,SDT,SCR1,SCR2,2,BHH,NOB2DD,CORE(1),MODES,   
     1             NOSDT,LHSET,B2DD,ISW,SCR3)        
      IF (NOB2DD .LT. 0) GO TO 90        
      CALL SSG2C (SCR1,SCR2,BHH,1,IBLOCK(1))        
   90 CONTINUE        
C        
C     FORM  KHH        
C        
      CALL GKAM1A (MI,PHIDH,SDT,SCR1,SCR2,3,KHH,NOK2DD,CORE(1),MODES,   
     1             NOSDT,LHSET,K2DD,ISW,SCR3)        
      IF (NOK2DD .LT. 0) GO TO 100        
      CALL SSG2C (SCR1,SCR2,KHH,1,IBLOCK(1))        
  100 CONTINUE        
      IF (NOB2DD.LT.0 .AND. NOM2DD.LT.0 .AND. NOK2DD.LT.0) NONCUP = -1  
      RETURN        
C        
C     ERROR MESAGES        
C        
  120 IP1 = -1        
  130 CALL MESAGE (IP1,IP2,NAME)        
  190 IP2 = LAMA        
      IP1 = -3        
      GO TO 130        
  210 WRITE  (NOUT,215) SFM        
  215 FORMAT (A25,' 2204, UNPACK FOUND NULL COLUMN IN PHIA FILE IN ',   
     1       'GKAM MODULE.')        
      IP1 = -37        
      GO TO 130        
  220 IP1 = -8        
      FILE = ICRQ        
      GO TO 130        
C        
C     NO MODES SELECTED        
C        
  230 IP1 = -47        
      GO TO 130        
  250 IP2 = SCR3        
      GO TO 120        
      END        