      SUBROUTINE AMGT1C (Q,NSTNS2,C1SBAR,C2SBAR)        
C        
C     SUPERSONIC CASCADE CODE FOR SWEPT TURBOPROPS.        
C        
      INTEGER         SLN        
      REAL            M2SBAR        
      COMPLEX         SBKDE1,SBKDE2,F4,F4S,AM4,F5S,F6S,AM4TST,SUM3,SUM4,
     1                AM5TT,AM6,SUMSV1,SUMSV2,SVKL1,SVKL2,F5,F5T,AM5,   
     2                AM5T,AI,A,B,BSYCON,ALP,F1,AM1,ALN,BLKAPM,BKDEL3,  
     3                F1S,C1,C2P,C2N,C2,AMTEST,FT2,BLAM1,FT3,AM2,SUM1,  
     4                SUM2,F2,BLAM2,FT2T,C1T,FT3T,F2P,AM2P,SUM1T,SUM2T, 
     5                C1P,C1N,BKDEL1,BKDEL2,BLKAP1,ARG,ARG2,FT3TST,BC,  
     6                BC2,BC3,BC4,BC5,CA1,CA2,CA3,CA4,CLIFT,CMOMT,      
     7                PRES1,PRES2,PRES3,PRES4,QRES4,FQA,FQB,FQ7,PRESU,  
     8                PRESL,Q,GUSAMP        
      DIMENSION       GYE(29,29),GEE(29,80),PRESU(29),PRESL(29),XUP(29),
     1                XTEMP(29),GEETMP(29,40),XLOW(29),AYE(10,29),      
     2                INDEX(29,3),Q(NSTNS2,NSTNS2),PRES1(21),PRES2(21), 
     3                PRES3(21),PRES4(21),QRES4(21),SBKDE1(201),        
     4                SBKDE2(201),SUMSV1(201),SUMSV2(201),SVKL1(201),   
     5                SVKL2(201),XLSV1(21),XLSV2(21),XLSV3(21),XLSV4(21)
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ SYSBUF,IBBOUT        
      COMMON /TAMG1L/ IREF,MINMAC,MAXMAC,NLINES,NSTNS,REFSTG,REFCRD,    
     1                REFMAC,REFDEN,REFVEL,REFSWP,SLN,NSTNSX,STG,       
     2                CHORD,DCBDZB,BSPACE,MACH,DEN,VEL,SWEEP,AMACHD,    
     3                REDFD,BLSPC,AMACHR,TSONIC        
      COMMON /AMGMN / MCB(7),NROW,DUM(2),REFC,SIGM,RFREQ        
      COMMON /BLK1  / SCRK,SPS,SNS,DSTR,AI,PI,DEL,SIGMA,BETA,RES        
      COMMON /BLK2  / BSYCON        
      COMMON /BLK3  / SBKDE1,SBKDE2,F4,F4S,AM4,F5S,F6S,AM4TST,SUM3,SUM4,
     1                AM5TT,AM6,SUMSV1,SUMSV2,SVKL1,SVKL2,F5,F5T,AM5,   
     2                AM5T,A,B,ALP,F1,AM1,ALN,BLKAPM,BKDEL3,F1S,C1,C2P, 
     3                C2N,C2,AMTEST,FT2,BLAM1,FT3,AM2,SUM1,SUM2,F2,     
     4                BLAM2,FT2T,C1T,FT3T,F2P,AM2P,SUM1T,SUM2T,C1P,C1N, 
     5                BKDEL1,BKDEL2,BLKAP1,ARG,ARG2,FT3TST,BC,BC2,BC3,  
     6                BC4,BC5,CA1,CA2,CA3,CA4,CLIFT,CMOMT,PRES1,PRES2,  
     7                PRES3,PRES4,QRES4,FQA,FQB,FQ7        
      COMMON /BLK4  / I,R,Y,A1,B1,C4,C5,GL,I6,I7,JL,NL,RI,RT,R5,SN,SP,  
     1                XL,Y1,AMU,GAM,IDX,INX,NL2,RL1,RL2,RQ1,RQ2,XL1,    
     2                ALP1,ALP2,GAMN,GAMP,INER,IOUT,REDF,STAG,STEP,     
     3                AMACH,BETNN,BETNP,BKAP1,XLSV1,XLSV2,XLSV3,XLSV4,  
     4                ALPAMP,AMOAXS,GUSAMP,DISAMP,PITAXS,PITCOR        
C        
C        
C     THEORY DEPENDENT RESTRICTION OF NO MORE THAN 10 COMPUTING        
C     STATIONS PER STREAMLINE IS REFLECTED IN CODING.        
C        
      IF (NSTNS .GT. 10) GO TO 9993        
C        
      REDF  = REDFD        
      AMACH = AMACHD        
      AI    = CMPLX(0.0,1.0)        
      PI    = 3.1415927        
      PITCOR= BLSPC        
      STAG  = 90.0 - STG        
      SIGMA = -SIGM*PI/180.0        
      BETA  = SQRT(AMACH**2-1.0)        
      SCRK  = REDF*AMACH/(BETA**2)        
      DEL   = SCRK*AMACH        
      AMU   = REDF/(BETA**2)        
      SP    = PITCOR*COS(STAG*PI/180.0)*2.0        
      SN    = PITCOR*SIN(STAG*PI/180.0)*2.0        
      SPS   = SP        
      SNS   = SN*BETA        
      DSTR  = SQRT(SPS**2-SNS**2)        
      SPS1  = ABS(SPS-SNS)        
      IF (SPS1 .LT. .00001)  GO TO 9991        
C        
C     PARAMETERS RELATED TO SWEEP CHANGES        
C        
      CSBAR  = .25*(DEN*VEL**2*CHORD**2)/(REFDEN*REFVEL**2)        
      CSBAR1 = 2.0/CHORD        
      M2SBAR = -DCBDZB/CHORD        
      C2SSCH = CSBAR1*C2SBAR        
      CSBLSB = CSBAR*CSBAR1        
      CSBM2S = CSBAR*M2SBAR        
      TANLAM = TAN(SWEEP*PI/180.)        
      DLSDZB = DCBDZB/2.0        
      TD     = TANLAM*DLSDZB        
C        
C     ZERO OUT GEE        
C        
      NSTNS4 = 4*NSTNS        
      NSTNS8 = 8 * NSTNS        
      DO 50 I = 1,29        
      DO 50 J = 1,NSTNS8        
   50 GEE(I,J) = 0.0        
      PITAXS   = 0.0        
      AMOAXS   = 0.        
      CALL ASYCON        
      CALL AKP2        
      RL1 = 9        
      S1  = SPS - SNS        
      AA  = S1/RL1        
      XLSV1(1) = 0.0        
      DO 4541 JL = 1,9        
4541  XLSV1(JL+1) = JL*AA        
      AA  = SPS - SNS        
      RL2 = 19        
      S1  = 2.0 + SNS - SPS        
      TEMP= S1/RL2        
      XL  = AA        
      DO 4571 JL = 1,20        
      XLSV2(JL) = XL        
      XLSV3(JL) = XL + SNS - SPS        
4571  XL = XL + TEMP        
      XL = SNS + 2.0 - SPS        
      TEMP = (SPS-SNS)/RL1        
      DO 458 JL = 1,10        
      XLSV4(JL) = XL        
458   XL = XL + TEMP        
C        
C     ACCUMULATE PRESSURE VECTORS INTO G-MATRIX        
C        
      DO 100 NM = 1,NSTNS        
      NTIMES = 1        
      IF (NM .GT. 2) NTIMES = 2        
      DO 100 NMM = 1,NTIMES        
C        
      JNDX = 0        
 5000 IF (JNDX .EQ. 0) GO TO 5010        
C        
      IF (NM .GT. 2) GO TO 5020        
C        
      GL = 0.0        
      IF (NM .EQ. 1) A = TANLAM/CSBAR1        
      IF (NM .EQ. 1) B = 0.0        
      IF (NM .EQ. 2) A = 0.0        
      IF (NM .EQ. 2) B = TANLAM/CSBAR1        
C        
      GO TO 2047        
C        
 5020 IF (NMM .EQ. 1) GUSAMP =-AI*TANLAM/CSBAR1/2.0        
      IF (NMM .EQ. 1) GL = (NM-2)*PI/2.0        
      IF (NMM .EQ. 2) GUSAMP = AI*TANLAM/CSBAR1/2.0        
      IF (NMM .EQ. 2) GL =-(NM-2)*PI/2.0        
C        
      A = GUSAMP        
      B = 0.0        
C        
      GO TO 2047        
C        
C     DEFINE -----------------------------        
C              ALPAMP - PITCHING AMP        
C              DISAMP - PLUNGING AMP        
C              GUSAMP - GUST AMP        
C              GL -GUST WAVE NUMBER        
 5010 ALPAMP = 0.0        
      IF (NM .EQ. 2) ALPAMP = 1.0        
      DISAMP = 0.0        
      IF (NM .EQ. 1) DISAMP = 1.0        
      GUSAMP = 0.0        
      GL     = 0.0        
      IF (NM.GT.2 .AND. NMM.EQ.1) GUSAMP =-(REDF+AI*TD)/2.+(NM-2)*PI/4. 
      IF (NM.GT.2 .AND. NMM.EQ.1) GL = (NM-2)*PI/2.0        
      IF (NM.GT.2 .AND. NMM.EQ.2) GUSAMP = (REDF+AI*TD)/2.+(NM-2)*PI/4. 
      IF (NM.GT.2 .AND. NMM.EQ.2) GL =-(NM-2)*PI/2.0        
C        
      A = (1.0+AI*REDF*PITAXS)*ALPAMP - (AI*REDF-TD)*DISAMP        
      B =-(AI*REDF-TD)*ALPAMP        
      IF (GL .EQ. 0.0) GO TO 2047        
      A = GUSAMP        
      B = 0.0        
 2047 CONTINUE        
C        
      CALL SUBA        
C        
C     FIND  DELTA P(LOWER-UPPER)        
C        
      DO 60 NX = 1,10        
      PRESU(NX) = PRES1(NX)        
      XUP(NX)   = XLSV1(NX)        
      IF (NX .EQ. 10) GO TO 55        
      NXX = NX + 20        
      PRESL(NXX) = PRES4(NX+1)        
      XLOW( NXX) = XLSV4(NX+1)        
      GO TO 610        
   55 PRESU(NX) = (PRES1(10) + PRES2(1))/2.0        
      XUP(10)   = (XLSV1(10) + XLSV2(1))/2.0        
 610  CONTINUE        
   60 CONTINUE        
      DO 70 NX = 1,20        
      NXX = NX + 10        
      IF (NX .EQ. 20) GO TO 65        
      PRESU(NXX) = PRES2(NX+1)        
      XUP  (NXX) = XLSV2(NX+1)        
      PRESL(NX)  = PRES3(NX  )        
      XLOW( NX)  = XLSV3(NX  )        
      GO TO 710        
   65 PRESL(20) = (PRES3(20) + PRES4(1))/2.0        
      XLOW(20)  = (XLSV3(20) + XLSV4(1))/2.0        
  710 CONTINUE        
   70 CONTINUE        
C        
      JX   = JNDX*4*NSTNS        
      NMZ  = NM + JX        
      NM2Z = NM + NSTNS   + JX        
      NM3Z = NM + 2*NSTNS + JX        
      NM4Z = NM + 3*NSTNS + JX        
C        
      DO 101 NMMM = 1,29        
      GEE(NMMM,NMZ ) = GEE(NMMM,NMZ ) + REAL(PRESL(NMMM))        
      GEE(NMMM,NM2Z) = GEE(NMMM,NM2Z) + AIMAG(PRESL(NMMM))        
      GEE(NMMM,NM3Z) = GEE(NMMM,NM3Z) + REAL(PRESU(NMMM))        
      GEE(NMMM,NM4Z) = GEE(NMMM,NM4Z) + AIMAG(PRESU(NMMM))        
C        
  101 CONTINUE        
C        
      IF (JNDX .NE. 0) GO TO 100        
      JNDX = 1        
      GO TO 5000        
C        
  100 CONTINUE        
C        
C     NOW DEFINE  I-MATRIX (NSTNS X 29)        
C        
      AYE(1,1) = C1SBAR*2.0 + C2SSCH*2.0        
      AYE(1,2) = C1SBAR*8.0/3.0 + C2SSCH*2.0        
      AYE(2,1) = C1SBAR*8.0/3.0 + C2SSCH*2.0        
      AYE(2,2) = C1SBAR*4.0 + C2SSCH*8.0/3.0        
C        
      CONZ1 = 1.0        
C        
      DO 280 I = 3,NSTNS        
      CONZ4 = (1.+CONZ1 )*2./(PI*(J-2))        
      CONZ5 = CONZ1*4./ (PI*(J-2))        
      CONZ6 = CONZ1*8./(PI*(J-2)) - (1.+CONZ1)*16./(PI*(J-2))**3        
C        
      AYE(I,1) = C1SBAR*CONZ5 + C2SSCH*CONZ4        
      AYE(I,2) = C1SBAR*CONZ6 + C2SSCH*CONZ5        
  280 CONZ1    = -CONZ1        
C        
      CONZ1 = 1.0        
C        
      DO 282 J = 3,29        
      CONZ4 = (1.+CONZ1)*2./(PI*(J-2))        
      CONZ5 = CONZ1*4./(PI*(J-2))        
      CONZ6 = CONZ1*8./(PI*(J-2)) - (1.+CONZ1)*16./(PI*(J-2))**3        
C        
      AYE(1,J) = C1SBAR*CONZ5 + C2SSCH*CONZ4        
      AYE(2,J) = C1SBAR*CONZ6 + C2SSCH*CONZ5        
  282 CONZ1    = -CONZ1        
C        
      DO 284 I = 3, NSTNS        
C        
      DO 284 J = 3,29        
      CONZ1 = 0.0        
      IF (J .EQ. I) GO TO 286        
      IF ((I+J)/2*2 .EQ. (I+J)) GO TO 285        
      CONZ1 = -16.*(I-2)*(J-2)/(PI*PI*(I-J)*(I-J)*(I+J-4)**2)        
  285 CONZ2 = 0.0        
      GO TO 284        
  286 CONZ1 = 1.0        
      CONZ2 = 1.0        
  284 AYE(I,J) = C1SBAR*CONZ1 + C2SSCH*CONZ2        
C        
C        
C     Q DUE TO PRESL ONLY        
C        
C     NOW DEFINE LARGE G MATRIX        
C        
      DO 110 I = 1,29        
      GYE(1,I) = 0.0        
  110 GYE(I,1) = 1.0        
C        
C     PUT XLOW IN XTEMP        
C        
      DO 120 I = 1,29        
  120 XTEMP(I) = XLOW(I)        
      DO 160 J = 3,29        
      CONST = (J-2)*PI/2.0        
      DO 160 I = 2,29        
      GYE(I,J) = SIN(CONST*XTEMP(I))        
  160 CONTINUE        
      DO 165 I = 2,29        
  165 GYE(I,2) = XTEMP(I)        
C        
C     PUT PRESL PARTS OF GEE IN GEETMP (UNPRIMED AND PRIMED TERMS)      
C        
      DO 1655 I = 1,29        
      DO 1655 J = 1,NSTNS2        
      GEETMP(I,J) = GEE(I,J)        
 1655 GEETMP(I,J+NSTNS2) = GEE(I,J+NSTNS4)        
C        
C     SOLVE FOR G-INVERSE G IN GEE MATRIV        
C     ISING = 1  NON-SINGULAR (GYE)        
C     ISING = 2  SIGULAR      (GYE)        
C     INDEX IS WORK STORAGE FOR ROUTINE INVERS        
C        
      ISING = -1        
      CALL INVERS (29,GYE,29,GEETMP,NSTNS4,DETERM,ISING,INDEX)        
      IF (ISING .EQ. 2) GO TO 9992        
C        
C     NOW  MULTIPLY  I*G-INVERSE*G(DELTA P'S)        
C        
      DO  360  J = 1,NSTNS        
      DO  360  K = 1,NSTNS        
C        
      SUMR1 = 0.0        
      SUMI1 = 0.0        
      SUMR2 = 0.0        
      SUMI2 = 0.0        
C        
      DO 350 I = 1,29        
      SUMR1 = SUMR1 + AYE(J,I)*GEETMP(I,K)        
      SUMI1 = SUMI1 + AYE(J,I)*GEETMP(I,K+NSTNS)        
      SUMR2 = SUMR2 + AYE(J,I)*GEETMP(I,K+NSTNS4)        
  350 SUMI2 = SUMI2 + AYE(J,I)*GEETMP(I,K+NSTNS+NSTNS4)        
C        
      CONZ1 = CSBLSB*SUMR1 + CSBM2S*SUMR2        
      CONZ2 = CSBLSB*SUMI1 + CSBM2S*SUMI2        
      CONZ3 = CSBAR*SUMR2        
      CONZ4 = CSBAR*SUMI2        
C        
      Q(J,K      ) = 2.0*CMPLX(CONZ1,-CONZ2)        
      Q(J,K+NSTNS) = 2.0*CMPLX(CONZ3,-CONZ4)        
      Q(J+NSTNS,K) = (0.0,0.0)        
  360 Q(J+NSTNS,K+NSTNS) = (0.0,0.0)        
C        
C     FINALLY, Q DUE TO (PRESL-PRESU) IS COMPUTED BY SUBTRACTING Q DUE  
C     TO PRESU FROM Q DUE TO PRESL ABOVE        
C        
C     LARGE G MATRIX        
C        
      DO 1101 I = 1,29        
      GYE(1,I) = 0.0        
 1101 GYE(I,1) = 1.0        
C        
C     PUT XUP IN XTEMP        
C        
      DO 1201 I = 1,29        
 1201 XTEMP(I) = XUP(I)        
      DO 1601 J = 3,29        
      CONST = (J-2)*PI/2.0        
      DO 1601 I = 2,29        
      GYE(I,J) = SIN(CONST*XTEMP(I))        
 1601 CONTINUE        
      DO 1651 I = 2,29        
 1651 GYE(I,2) = XTEMP(I)        
C        
C     PUT PRESU PARTS OF GEE IN GEETMP (UNPRIMED AND PRIMED TERMS)      
C        
      DO 2655 I = 1,29        
      DO 2655 J = 1,NSTNS2        
C        
      NSNS2 = NSTNS2 + J        
      GEETMP(I,J) = GEE(I,NSNS2)        
 2655 GEETMP(I,NSNS2) = GEE(I,NSNS2+NSTNS4)        
C        
C     SOLVE FOR G-INVERSE G IN GEETMP MATRIX        
C     ISING = 1  NON-SINGULAR (GYE)        
C     ISING = 2  SINGULAR GYE        
C     INDEX IS WORK STORAGE FOR ROUTINE INVERS        
C        
      ISING = -1        
      CALL INVERS (29,GYE,29,GEETMP,NSTNS4,DETERM,ISING,INDEX)        
C        
      IF (ISING .EQ. 2) GO TO 9992        
C        
C    MULTIPLY I*G-INVERS*G        
C        
      DO 3601 J = 1,NSTNS        
      DO 3601 K = 1,NSTNS        
C        
      SUMR1 = 0.0        
      SUMI1 = 0.0        
      SUMR2 = 0.0        
      SUMI2 = 0.0        
C        
      DO 3501 I = 1, 29        
      SUMR1 = SUMR1 + AYE(J,I)*GEETMP(I,K)        
      SUMI1 = SUMI1 + AYE(J,I)*GEETMP(I,K+NSTNS)        
      SUMR2 = SUMR2 + AYE(J,I)*GEETMP(I,K+NSTNS4)        
 3501 SUMI2 = SUMI2 + AYE(J,I)*GEETMP(I,K+NSTNS+NSTNS4)        
C        
      CONZ1 = CSBLSB*SUMR1 + CSBM2S*SUMR2        
      CONZ2 = CSBLSB*SUMI1 + CSBM2S*SUMI2        
      CONZ3 = CSBAR*SUMR2        
      CONZ4 = CSBAR*SUMI2        
C        
      Q(J,K      ) = Q(J,K) - 2.0*CMPLX(CONZ1,-CONZ2)        
 3601 Q(J,K+NSTNS) = Q(J,K+NSTNS) - 2.0*CMPLX(CONZ3,-CONZ4)        
      RETURN        
C        
 9991 WRITE (IBBOUT,3000) UFM        
      GO TO 9999        
 9992 WRITE (IBBOUT,3001) UFM        
      GO TO 9999        
 9993 WRITE (IBBOUT,3002) UFM,SLN,NSTNS        
 9999 CALL MESAGE (-61,0,0)        
      RETURN        
C        
 3000 FORMAT (A23,' - AMG MODULE -SUBROUTINE AMGT1C', /39X,        
     1       'AXIAL MACH NUMB. IS EQUAL TO OR GREATER THAN ONE.')       
 3001 FORMAT (A23,' - AMG MODULE - LARGE G-MATRIX IS SINGULAR IN ',     
     1        'ROUTINE AMGT1C.')        
 3002 FORMAT (A23,' - AMG MODULE - NUMBER OF COMPUTING STATIONS ON ',   
     1       'STREAMLINE',I8,4H IS ,I3,1H. ,/39X,'SUPERSONIC CASCADE ', 
     2       'ROUTINE AMGT1C ALLOWS ONLY A MAXIMUM OF 10.')        
      END        
