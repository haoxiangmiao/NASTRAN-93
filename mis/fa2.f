      SUBROUTINE FA2        
C        
C     THIS IS THE DMAP MODULE FA2        
C        
C     DMAP CALLING SEQUENCE        
C        
C     FA2  PHIH,CLAMA,FSAVE/PHIHL,CLAMAL,CASEYY,OVG/V,N,TSTART/C,Y,VREF/
C    1     C,Y,PRINT=YES $        
C        
C     ALL OUTPUTS ARE APPEND        
C        
C     THE PURPOSE OF THIS MODULE IS TO COPY PARTS OF PHIH, CLAMA, AND   
C    1    FSAVE ONTO PHIHL, CLAMAL, CASEYY, AND OVG RESPECTIVELY        
C        
      EXTERNAL        LSHIFT        
      INTEGER         SYSBUF,PHIH,CLAMA,FSAVE,PHIHL,CLAMAL,CASEYY,OVG,  
     1                TSTART,PRINT(2),MCB(7),FILE,NAME(2),FMETH,FLOOP,  
     2                MCBPHL(7),MCBCL(7),MCBCC(7),MCBOVG(7),BUF(146),   
     3                EJECT,IARY(22),IALPH(2),ME(3),YES,YESB        
      REAL            XMACH,KFREQ,LBUF(6),IML,Z(1)        
      COMMON /SYSTEM/ SYSBUF,NOUT,SKP(6),NLPP,MTEMP,NPAG,NLINES        
CZZ   COMMON /ZZFA2X/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      COMMON /UNPAKX/ ITC,II,JJ,INCR        
      COMMON /BLANK / TSTART,VREF,PRINT        
      EQUIVALENCE     (Z(1),IZ(1))        
      DATA    PHIH  , CLAMA,FSAVE,PHIHL,CLAMAL,CASEYY,OVG /        
     1        101   , 102  ,  103,  201,   202,   203,204 /        
      DATA    NAME  , NO,MCBCL,MCBCC,MCBOVG,IBLNK         /        
     1        4HFA2 , 1H , 2HNO, 21*0,4H                  /        
      DATA    BUF   / 146*1H                              /        
      DATA    IARY  / 4H POI,4HNT =,1H ,1H ,4H MAC,4HH = ,1H ,1H ,      
     1        4H KFR, 4HEQ= ,1H ,1H ,4H RHO,4H =  ,1H ,1H ,6*1H /       
      DATA    TWOPHI/ 6.28318531          /        
      DATA    ME    / 1HK,  2HKE,  2HPK   /        
      DATA    YES   , YESB/ 3HYES, 4HYESB /        
C        
C     INITIALIZE        
C        
      NZ    = KORSZ(Z)        
      IBUF1 = NZ - SYSBUF + 1        
      IBUF2 = IBUF1 - SYSBUF        
      IBUF3 = IBUF2 - SYSBUF        
      IBUF4 = IBUF3 - SYSBUF        
      NZ    = IBUF4 - 1        
      ITC   = 3        
      INCR  = 1        
      MCBCL(1) = CLAMAL        
      MCBCC(1) = CASEYY        
      MCBOVG(1)= OVG        
      IF (VREF .EQ. 0.0) VREF = 1.0        
C        
C     FIND PROPER METHOD        
C        
      FILE  = FSAVE        
      CALL OPEN (*900,FSAVE,IZ(IBUF1),0)        
      CALL READ (*910,*920,FSAVE,IZ(1),8,1,IFLAG)        
      J     = 3        
      FMETH = IZ(J)        
      METH  = ME(FMETH)        
      ONEOK = 1.E+25        
      MCB(1)= FSAVE        
      CALL RDTRL (MCB)        
      FLOOP = MCB(2)        
      NLOOP = MCB(3)        
      NVALUE= MCB(7)        
      J     = 6        
      BREF  = Z(J)        
      PHIB  = TWOPHI*BREF        
      GO TO (1000,2000,3000), FMETH        
C        
C     K  METHOD        
C        
 1000 CONTINUE        
C        
C     PICK UP CONSTANTS        
C        
      NVALUE = 8        
      NVALUE = IZ(NVALUE)        
C        
C     COPY ONTO PHIHL        
C        
      IF (FLOOP .NE. 1) GO TO 1010        
C        
C     FIRST TIME        
C        
      CALL GOPEN (PHIHL,IZ(IBUF2),1)        
      CALL CLOSE (PHIHL,1)        
      MCBPHL(1) = PHIH        
      CALL RDTRL (MCBPHL)        
      MCBPHL(2) = 0        
      MCBPHL(6) = 0        
      MCBPHL(7) = 0        
      MCBPHL(1) = PHIHL        
      CALL WRTTRL (MCBPHL)        
      CALL GOPEN  (CLAMAL,IZ(IBUF2),1)        
      CALL GOPEN  (CLAMA,IZ(IBUF3),0)        
      CALL FREAD  (CLAMA,BUF,146,1)        
      CALL CLOSE  (CLAMA,1)        
      CALL WRITE  (CLAMAL,BUF,146,1)        
      CALL WRITE  (CLAMAL,0,0,1)        
      CALL CLOSE  (CLAMAL,1)        
      CALL GOPEN  (CASEYY,IZ(IBUF2),1)        
      CALL CLOSE  (CASEYY,1)        
      CALL GOPEN  (OVG,IZ(IBUF2),1)        
      CALL CLOSE  (OVG,1)        
C        
C     COPY NVALUE VECTORS TO PHIHL        
C        
 1010 CONTINUE        
      MCB(1) = PHIH        
      CALL RDTRL (MCB)        
      NCOPY = MIN0(NVALUE,MCB(2))        
      CALL GOPEN  (PHIH,IZ(IBUF2),0)        
      CALL GOPEN  (PHIHL,IZ(IBUF3),0)        
      CALL SKPFIL (PHIHL, 1)        
      CALL SKPFIL (PHIHL,-1)        
      CALL CLOSE  (PHIHL, 2)        
      CALL GOPEN  (PHIHL,IZ(IBUF3),3)        
      MCBPHL(1) = PHIHL        
      CALL RDTRL  (MCBPHL)        
      MCBPHL(7) = (2*MCBPHL(7)*MCBPHL(2)*MCBPHL(3))/10000        
      CALL CYCT2B (PHIH,PHIHL,NCOPY,IZ,MCBPHL)        
      CALL CLOSE  (PHIH,1)        
      CALL CLOSE  (PHIHL,1)        
      CALL WRTTRL (MCBPHL)        
C        
C     PICK UP M,K,RHO FOR THIS LOOP        
C        
      CALL FREAD (FSAVE,IZ,-3*(FLOOP-1),0)        
      CALL FREAD (FSAVE,Z,3,1)        
      J     = 0        
      XMACH = Z(  1)        
      KFREQ = Z(J+2)        
      RHO   = Z(J+3)        
      CALL FREAD (FSAVE,Z,1,1)        
C        
C     PUT CASEYY INTO CORE        
C        
      CALL READ (*910,*1020,FSAVE,IZ,NZ,0,IFLAG)        
      CALL MESAGE (-8,0,NAME)        
 1020 CONTINUE        
      CALL CLOSE (FSAVE,1)        
      K = 39        
      DO 1021 I = 51,146        
      BUF(I) = IZ(K)        
      K = K + 1        
 1021 CONTINUE        
C        
C     READY CLAMA        
C        
      CALL GOPEN  (CLAMA,IZ(IBUF1),0)        
      CALL FWDREC (*910,CLAMA)        
C        
C     READY CLAMAL        
C        
      CALL GOPEN  (CLAMAL,IZ(IBUF2),0)        
      CALL SKPFIL (CLAMAL, 1)        
      CALL SKPFIL (CLAMAL,-1)        
      CALL BCKREC (CLAMAL)        
      CALL READ   (*910,*1022,CLAMAL,IZ(IFLAG+1),NZ,0,I)        
      CALL MESAGE (-8,0,NAME)        
 1022 CONTINUE        
      CALL BCKREC (CLAMAL)        
      CALL CLOSE  (CLAMAL,2)        
      CALL GOPEN  (CLAMAL,IZ(IBUF2),3)        
      CALL WRITE  (CLAMAL,IZ(IFLAG+1),I,0)        
      CALL RDTRL  (MCBCL)        
C        
C     READY CASEYY        
C        
      CALL GOPEN  (CASEYY,IZ(IBUF3),0)        
      CALL SKPFIL (CASEYY, 1)        
      CALL SKPFIL (CASEYY,-1)        
      CALL CLOSE  (CASEYY, 2)        
      CALL GOPEN  (CASEYY,IZ(IBUF3),3)        
      CALL RDTRL  (MCBCC)        
C        
C     READY OVG        
C        
      CALL GOPEN  (OVG,IZ(IBUF4),0)        
      CALL SKPFIL (OVG, 1)        
      CALL SKPFIL (OVG,-1)        
      CALL CLOSE  (OVG,2)        
      CALL GOPEN  (OVG,IZ(IBUF4),3)        
      CALL RDTRL  (MCBOVG)        
      MCBOVG(2)= MCBOVG(2) + 1        
      MCBCC(4) = IFLAG        
      CALL WRTTRL (MCBOVG)        
      MCBCC(2) = MCBCC(2) + NCOPY        
      CALL WRTTRL (MCBCC)        
      MCBCL(2) = MCBCL(2) + NCOPY        
      CALL WRTTRL (MCBCL)        
      GO TO 1042        
C        
C     K-E METHOD        
C        
 2000 CONTINUE        
C        
C     P - K METHOD        
C        
 3000 CONTINUE        
C        
C     READY OVG        
C        
      CALL GOPEN (OVG,IZ(IBUF2),1)        
      MCBOVG(2) = 1        
      CALL WRTTRL (MCBOVG)        
C        
C     PUT RECORD 2 OF FSAVE INTO CORE        
C        
      CALL READ (*910,*3010,FSAVE,IZ(1),NZ,1,IFLAG)        
      CALL MESAGE (-8,0,NAME)        
 3010 CONTINUE        
      CALL SKPREC (FSAVE,1)        
      CALL FREAD  (FSAVE,0,-51,0)        
      CALL FREAD  (FSAVE,BUF,96,1)        
      IMR   = 1        
      FLOOP = 1        
C        
C     COUNT RHO S        
C        
      NRHO = 1        
      IF (FMETH .EQ. 3) GO TO 3012        
      IRHO = 1        
      RHO  = Z(IMR+2)        
      IMR1 = IMR + 3        
 3013 CONTINUE        
      IF (IMR1 .GT.     IFLAG) GO TO 3012        
      IF (RHO  .EQ. Z(IMR1+2)) GO TO 3012        
      NRHO = NRHO + 1        
      IMR1 = IMR1 + 3        
      GO TO 3013        
 3012 CONTINUE        
 3011 CONTINUE        
      NV = 1        
C        
C     DETERMINE THE NUMBER OF M-RHO PAIRS FOR THIS GO        
C        
      XMACH = Z(IMR  )        
      RHO   = Z(IMR+2)        
      NCOPY = 1        
      IMR1  = IMR + 3*NRHO        
 3020 CONTINUE        
      IF (IMR1 .GT. IFLAG) GO TO 1042        
      IF (XMACH.NE.Z(IMR1) .OR. RHO.NE.Z(IMR1+2)) GO TO 1042        
      NCOPY = NCOPY + 1        
      IMR1  = IMR1 + 3*NRHO        
      GO TO 3020        
 1042 CONTINUE        
C        
      IF (PRINT(1) .EQ. NO) GO TO 1041        
C     SET UP PAGE FORMATS        
C        
      CALL PAGE1        
      NLINES = NLINES + 7        
      IF (PRINT(1) .EQ. YESB) WRITE (NOUT,1039) FLOOP,XMACH,RHO,METH    
      IF (PRINT(1) .EQ. YES ) WRITE (NOUT,1040) FLOOP,XMACH,RHO,METH    
 1039 FORMAT (1H0,55X,16HFLUTTER  SUMMARY, //7X,        
     1        9HPOINT =  ,I3,5X,14HSIGMA VALUE = ,F8.3,4X,        
     2        16HDENSITY RATIO = ,1P,E11.4,5X,9HMETHOD = ,A4, ///7X,    
     3        5HKFREQ,12X, 8H1./KFREQ, 9X,8HVELOCITY, 12X,7HDAMPING,    
     4        9X,9HFREQUENCY,12X,20HCOMPLEX   EIGENVALUE)        
 1040 FORMAT (1H0,55X,16HFLUTTER  SUMMARY, //7X,        
     1        9HPOINT =  ,I3, 5X,14HMACH NUMBER = ,F7.4,5X,        
     2        16HDENSITY RATIO = ,1P,E11.4, 5X,9HMETHOD = ,A4, ///7X,   
     3        5HKFREQ, 12X,8H1./KFREQ, 9X,8HVELOCITY, 12X,7HDAMPING,    
     4        9X,9HFREQUENCY, 12X,20HCOMPLEX   EIGENVALUE)        
 1041 CONTINUE        
C        
C     SET UP FOR OVG        
C        
      BUF(1) = 60        
      BUF(2) = 2002        
      BUF(4) = 1        
      BUF(5) = 10*FLOOP        
      BUF(9) = 1        
      BUF(10)= 4        
      CALL WRITE (OVG,BUF,146,1)        
      IF (FMETH .NE. 1) GO TO 1101        
      DO  1090 I = 115,146        
      BUF(I) = IBLNK        
 1090 CONTINUE        
      CALL INT2A8 (*1092,FLOOP,IALPH)        
 1092 IARY(3) = IALPH(1)        
      IARY(4) = IALPH(2)        
      CALL RE2AL (XMACH,IALPH)        
      IARY(7) = IALPH(1)        
      IARY(8) = IALPH(2)        
      CALL RE2AL (KFREQ,IALPH)        
      IARY(11) = IALPH(1)        
      IARY(12) = IALPH(2)        
      CALL RE2AL (RHO,IALPH)        
      IARY(15) = IALPH(1)        
      IARY(16) = IALPH(2)        
      K = 115        
      DO 1095 I = 1,16        
      BUF(K) = IARY(I)        
      K = K + 1        
 1095 CONTINUE        
      K = 103        
      DO 1100 I = 115,146        
      IZ(K) = BUF(I)        
      K = K + 1        
 1100 CONTINUE        
 1101 CONTINUE        
      DO  1030 I = 1,NCOPY        
      GO TO (1102,1150,3200), FMETH        
C        
C     KE METHOD        
C        
 1150 CONTINUE        
      IF (I.NE.1 .OR. NV.NE.1) GO TO 1152        
      IR = IFLAG + 1        
      J  = NVALUE*2        
      DO 1153 M = 1,NCOPY        
C        
C     READ A RECORD OF COMPLEX EIGENVALUES INTO CORE        
C        
      CALL FREAD  (FSAVE,IZ(IR),J,1)        
      CALL SKPREC (FSAVE,NRHO-1)        
C        
C     REARRANGE THE COMPLEX EIGENVALUES IN THE RECORD IN ASCENDING      
C     ORDER OF THE ABSOLUTE VALUES OF THE IMAGINARY PARTS        
C        
      NVALU1 = NVALUE - 1        
      DO 1170 L = 1,NVALU1        
      LR = IR + 2*(L-1)        
      LI = LR + 1        
      VALUER = Z(LR)        
      VALUEI = Z(LI)        
      VALUE  = ABS(VALUEI)        
      INDEX  = L        
      L1     = L + 1        
      DO 1160 K = L1,NVALUE        
      KR = IR + 2*(K-1)        
      KI = KR + 1        
      VALUE1 = ABS(Z(KI))        
      IF (VALUE1 .GE. VALUE) GO TO 1160        
      VALUER = Z(KR)        
      VALUEI = Z(KI)        
      VALUE  = VALUE1        
      INDEX  = K        
 1160 CONTINUE        
      IF (INDEX .EQ. L) GO TO 1170        
      IRR = IR  + 2*(INDEX-1)        
      IRI = IRR + 1        
      Z(IRR) = Z(LR)        
      Z(IRI) = Z(LI)        
      Z(LR)  = VALUER        
      Z(LI)  = VALUEI        
 1170 CONTINUE        
      IR = IR + J        
 1153 CONTINUE        
C        
C     SELECT EACH FOR OUTPUT        
C        
 1152 CONTINUE        
      J    = IFLAG + 1 + (I-1)*NVALUE*2 + (NV-1)*2        
      REL  = Z(J)        
      IML  = Z(J+1)        
      VOUT = ABS(IML)/VREF        
      G    = 0.0        
      IF (IML .NE. 0.0) G = 2.*REL/IML        
      KFREQ= Z(IMR+3*I-2)        
      F    = KFREQ*IML/PHIB        
      GO TO 1103        
C        
C     PK METHOD        
C        
 3200 CONTINUE        
      CALL FREAD (FSAVE,LBUF,-(NV-1)*5,0)        
      CALL FREAD (FSAVE,LBUF,5,1)        
      REL = LBUF(1)        
      IML = LBUF(2)        
      KFREQ = LBUF(3)        
      F = LBUF(4)        
      G = LBUF(5)        
      VOUT = ABS(Z(IMR+3*I-2))/VREF        
      GO TO 1103        
C        
C     K METHOD        
C        
 1102 CONTINUE        
      CALL FREAD (CLAMA ,LBUF,6,0)        
      CALL WRITE (CLAMAL,LBUF,6,0)        
      REL = LBUF(3)        
      IML = LBUF(4)        
      VOUT= ABS(IML)/VREF        
      G   = 0.0        
      IF (IML .NE. 0.0) G = 2.0*REL/IML        
      F =  KFREQ*IML/(PHIB)        
C        
C     PUT OUT CASEYY        
C        
      CALL WRITE (CASEYY,IZ,IFLAG,1)        
 1103 CONTINUE        
      IF (PRINT(1) .EQ. NO) GO TO 1050        
C        
C     PRINT OUTPUT        
C        
      K = EJECT(1)        
      IF (K .EQ. 0) GO TO 1060        
      IF (PRINT(1) .EQ. YESB) WRITE (NOUT,1039) FLOOP,XMACH,RHO,METH    
      IF (PRINT(1) .EQ. YES ) WRITE (NOUT,1040) FLOOP,XMACH,RHO,METH    
      NLINES = NLINES + 7        
 1060 CONTINUE        
      IF (KFREQ .NE. 0.0) ONEOK = 1.0/KFREQ        
      WRITE  (NOUT,1070) KFREQ,ONEOK,VOUT,G,F,REL,IML        
 1070 FORMAT (1H ,5X,F8.4,5X,6(1X,1P,E14.7,3X))        
 1050 CONTINUE        
C        
C     PUT OUT OVG PARTS        
C        
      LBUF(1) = VOUT        
      LBUF(2) = 0.0        
      LBUF(3) = G        
      LBUF(4) = F        
      CALL WRITE (OVG,LBUF,4,0)        
 1030 CONTINUE        
      FLOOP = FLOOP+1        
      CALL WRITE (OVG,0,0,1)        
      GO TO (1031,2031,3331), FMETH        
C        
C     FINISH UP FOR KE METHOD        
C        
 2031 CONTINUE        
      NV = NV + 1        
      IF (NV .LE. NVALUE) GO TO 1042        
C        
C     ALL MODES DONE        
C        
      IF (IRHO .GE. NRHO) GO TO 2090        
C        
C     DO ANOTHER RHO        
C        
      IRHO= IRHO + 1        
      IMR = IMR  + 3        
      RHO = Z(IMR+2)        
      CALL SKPREC (FSAVE,NCOPY*(NRHO-1))        
      GO TO 1042        
 2090 CONTINUE        
      IF (IMR1 .GT. IFLAG) GO TO 4000        
      IMR = IMR1        
      GO TO 3011        
C        
C     P-K AT POINT END        
C        
 3331 CONTINUE        
      NV = NV + 1        
      IF (NV .GT. NVALUE) GO TO 3390        
      CALL SKPREC (FSAVE,-NCOPY)        
      GO TO 1042        
C        
C     ALL MODES DONE--CONSIDER MORE M-RHO VALUES        
C        
 3390 IF (IMR1 .GT. IFLAG) GO TO 4000        
      IMR = IMR1        
      GO TO 3011        
C        
C     DONE        
C        
 4000 CALL CLOSE (OVG,1)        
      CALL CLOSE (FSAVE,1)        
      RETURN        
C        
C     FINISH UP        
C        
 1031 CALL WRITE (CLAMAL,0,0,1)        
      CALL CLOSE (OVG,1)        
      CALL CLOSE (CLAMAL,1)        
      CALL CLOSE (CLAMA,1)        
      CALL CLOSE (CASEYY,1)        
C        
C     CHECK TIMES        
C        
      CALL KLOCK  (NOW)        
      CALL TMTOGO (ITLFT)        
      IF (NOW-TSTART.GE.ITLFT .AND. FLOOP.NE.NLOOP) GO TO 1110        
      RETURN        
C        
C     INSUFFICIENT TIME        
C        
 1110 CALL MESAGE (45,NLOOP - FLOOP,NAME)        
      TSTART = -1        
      RETURN        
C        
C     ERROR MESSAGES        
C        
  900 IP1 = -1        
      GO TO 901        
  910 IP1 = -2        
      GO TO 901        
  920 IP1 = -3        
  901 CALL MESAGE (IP1,FILE,NAME)        
      RETURN        
      END        