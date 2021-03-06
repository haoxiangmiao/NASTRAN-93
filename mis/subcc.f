      SUBROUTINE SUBCC        
C        
C     THIS ROUTINE WAS ORIGINALLY CALLED SUBD        
C        
      COMPLEX         GUSAMP,SBKDE1,SBKDE2,        
     1                F4,F4S,AM4,F5S,F6S,AM4TST,SUM3,SUM4,AM5TT,AM6,    
     2                SUMSV1,SUMSV2,SVKL1,SVKL2,F5,F5T,AM5,AM5T,        
     3                AI,A,B,BSYCON,ALP,F1,AM1,ALN,BLKAPM,BKDEL3,F1S,C1,
     4                C2P,C2N,        
     5                C2,AMTEST,FT2,BLAM1,FT3,AM2,SUM1,SUM2,F2,BLAM2,   
     6                FT2T,C1T,FT3T,F2P,AM2P,SUM1T,SUM2T,        
     7                C1P,C1N,BKDEL1,BKDEL2,BLKAP1,ARG,ARG2,FT3TST,     
     8                BC,BC2,BC3,BC4,BC5,CA1,CA2,CA3,CA4,        
     9                CLIFT,CMOMT,PRES1,PRES2,PRES3,PRES4,QRES4,FQ7,    
     O                FQA,FQB,SS,T1,T2,T3,T4,CONST,CONST2,CONST3,CONST4,
     1                CONST5,CONST6,C1A,C2A,CEXP1,CEXP2,CEXP1A,CEXP2A   
      DIMENSION       PRES1(21),PRES2(21),PRES3(21),PRES4(21),QRES4(21),
     1                SBKDE1(201),SBKDE2(201),        
     2                SUMSV1(201),SUMSV2(201),SVKL1(201),SVKL2(201),    
     3                XLSV1(21),XLSV2(21),XLSV3(21),XLSV4(21)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ SYSBUF,IBBOUT        
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
      AM6 = 0.0        
      F5  = 0.0        
      AM5 = 0.0        
      S1  = SPS + SNS        
      S2  = SIGMA - SPS*DEL        
      S3  = SPS/(DSTR**2)        
      S4  = SNS/DSTR        
      S5  = DEL*SNS + SIGMA        
      SS  = CEXP(-AI*SIGMA)        
      DO 150 IOUT = 1,200        
      IF (IOUT .GT. I7) GO TO 240        
      R5  = IOUT - 1        
      RQ1 = SQRT((R5*PI/SNS)**2+SCRK**2)        
      RQ2 =-RQ1        
      C4  = (RQ1*S1+S2)/(2.0*PI)        
      C5  = (RQ2*S1+S2)/(2.0*PI)        
      BC2 = BC/(2.0*SVKL1(IOUT))*CEXP(-AI*(-S2)*(SPS+3.0*SNS)/        
     1      (2.0*S1))/(2.0*PI*AI)        
      BC3 = BC2*SVKL1(IOUT)/SVKL2(IOUT)        
      BC4 = BC/(2.0*SVKL1(IOUT))*CEXP(AI*(-S2)*(SNS-SPS)/        
     1      (2.0*S1))/(2.0*PI*AI)        
      BC5 = BC4*SVKL1(IOUT)/SVKL2(IOUT)        
      F5T = 0.0        
      AM5T= 0.0        
      AM5TT = 0.0        
      DO 10 JL = 1,NL        
      QRES4(JL) = 0.0        
   10 CONTINUE        
      DO 100 INER = 1,200        
      R    = INER - 1        
      GAMP = 2.0*PI*R - S2        
      GAMN =-2.0*PI*R - S2        
      C1P  = (GAMP/DSTR) - SCRK        
      C2P  = (GAMP/DSTR) + SCRK        
      ALP  = GAMP*S3 - S4*CSQRT(C1P)*CSQRT(C2P)        
      BKDEL3 = SBKDE1(INER)        
      IF (INER .LE. I6) GO TO 20        
      CALL AKAPM (ALP,BKDEL3)        
      SBKDE1(INER) = BKDEL3        
   20 CONTINUE        
      T1   = ALP*SPS-GAMP        
      T2   = ALP*DSTR**2-GAMP*SPS        
      SUM1 = SUMSV1(IOUT)*CEXP(AI*T1)*BKDEL3*T1/        
     1       (T2*SVKL1(IOUT)*(ALP-RQ1))        
      SUM3 = SUMSV2(IOUT)*CEXP(AI*T1)*BKDEL3*T1/        
     1       (T2*SVKL2(IOUT)*(ALP-RQ2))        
      IF (INER .EQ. 1) GO TO 40        
      C1N  = (GAMN/DSTR) - SCRK        
      C2N  = (GAMN/DSTR) + SCRK        
      ALN  = GAMN*S3 - S4*CSQRT(C1N)*CSQRT(C2N)        
      BKDEL3 = SBKDE2(INER)        
      IF (INER .LE. I6) GO TO 30        
      CALL AKAPM (ALN,BKDEL3)        
      SBKDE2(INER) = BKDEL3        
   30 CONTINUE        
      T1   = ALN*SPS - GAMN        
      T2   = ALN*DSTR**2 - GAMN*SPS        
      SUM2 = SUMSV1(IOUT)*CEXP(AI*T1)*BKDEL3*T1/        
     1       (T2*SVKL1(IOUT)*(ALN-RQ1))        
      SUM4 = SUMSV2(IOUT)*CEXP(AI*T1)*BKDEL3*T1/        
     1       (T2*SVKL2(IOUT)*(ALN-RQ2))        
   40 CONTINUE        
      IF (INER .EQ. 1) SUM2 = 0.0        
      IF (INER .EQ. 1) SUM4 = 0.0        
      C1P = CEXP(-AI*(ALP-DEL)*SPS)        
      C2P = CEXP(-AI*(ALP-DEL)*SNS)        
      C1N = CEXP(-AI*(ALN-DEL)*SPS)        
      C2N = CEXP(-AI*(ALN-DEL)*SNS)        
      F5T = F5T + (SUM1+SUM3)*AI*SS/(ALP-DEL)*(C1P-C2P) +        
     1      (SUM2+SUM4)*SS*AI/(ALN-DEL)*(C1N-C2N)        
      AM5T= AM5T + (SUM1+SUM3)*SS*(AI*SPS*C1P/(ALP-DEL) - AI*SNS*C2P/   
     1      (ALP-DEL) + 1.0/((ALP-DEL)**2)*(C1P-C2P) + AI*(2.0-SPS)/    
     2      (ALP-DEL)*(C1P-C2P)) + (SUM2+SUM4)*SS*(AI*SPS*C1N/(ALN-DEL) 
     3    - AI*SNS*C2N/(ALN-DEL) + 1.0/((ALN-DEL)**2)*(C1N-C2N) +       
     4      AI*(2.0-SPS)/(ALN-DEL)*(C1N-C2N))        
      TEMP  = (SPS-SNS)/RL1        
      CONST = (SUM1+SUM3)*SS        
      CONST2= (SUM2+SUM4)*SS        
      C1A   =-AI*(ALP-DEL)        
      C2A   =-AI*(ALN-DEL)        
      CEXP1 = CEXP(C1A*SNS)        
      CEXP2 = CEXP(C2A*SNS)        
      CEXP1A= CEXP(C1A*TEMP)        
      CEXP2A= CEXP(C2A*TEMP)        
      DO 50 JL = 1,NL        
      QRES4(JL) = QRES4(JL) - (CONST*CEXP1+CONST2*CEXP2)        
      CEXP1 = CEXP1*CEXP1A        
      CEXP2 = CEXP2*CEXP2A        
   50 CONTINUE        
      BETNP = ( 2.0*R*PI-S5)/S1        
      BETNN = (-2.0*R*PI-S5)/S1        
      C1P   = CEXP(-2.0*PI*R*AI*SNS/S1)        
      C2P   = CEXP(-2.0*PI*R*AI*SPS/S1)        
      C1N   = CEXP(2.0*PI*R*AI*SNS/S1)        
      C2N   = CEXP(2.0*PI*R*AI*SPS/S1)        
      T1    = CEXP(-AI*BETNP*SPS)        
      T2    = CEXP(-AI*BETNP*SNS)        
      T3    = CEXP(-AI*BETNN*SPS)        
      T4    = CEXP(-AI*BETNN*SNS)        
      CA1   = AI*SS/BETNP*(T1-T2)        
      CA2   = AI*SS/BETNN*(T3-T4)        
      CA3   = SS*(AI*SPS/BETNP*T1 - AI*SNS*T2/BETNP+(T1-T2)/        
     1        BETNP**2 + (2.0-SPS)*AI/BETNP*(T1-T2))        
      CA4   = SS*(AI*SPS*T3/BETNN - AI*SNS*T4/BETNN+(T3-T4)/        
     1        BETNN**2 + (2.0-SPS)*AI/BETNN*(T3-T4))        
      IF (INER .GT. 1) GO TO 70        
      F5T   = F5T - SUMSV1(IOUT)*(BC2*C1P-BC4*C2P)/(R-C4)*CA1 -        
     1        SUMSV2(IOUT)*(BC3*C1P-BC5*C2P)/(R-C5)*CA1        
      AM5T  = AM5T - SUMSV1(IOUT)*(BC2*C1P-BC4*C2P)/(R-C4)*CA3 -        
     1        SUMSV2(IOUT)*(BC3*C1P-BC5*C2P)/(R-C5)*CA3        
      TEMP  = (SPS-SNS)/RL1        
      CONST = SS*SUMSV1(IOUT)*(BC2*C1P-BC4*C2P)/(R-C4)        
      CONST2= SS*SUMSV2(IOUT)*(BC3*C1P-BC5*C2P)/(R-C5)        
      C1A   =-AI*BETNP        
      CEXP1 = CEXP(C1A*SNS)        
      CEXP1A= CEXP(C1A*TEMP)        
      DO 60 JL = 1,NL        
      QRES4(JL) = QRES4(JL)+CONST*CEXP1+CONST2*CEXP1        
      CEXP1 = CEXP1*CEXP1A        
   60 CONTINUE        
      GO TO 90        
   70 CONTINUE        
      F5T = F5T - SUMSV1(IOUT)*((BC2*C1P-BC4*C2P)/(R-C4)*CA1 -        
     1      (BC2*C1N-BC4*C2N)/(R+C4)*CA2) - SUMSV2(IOUT)*        
     2      ((BC3*C1P-BC5*C2P)/(R-C5)*CA1-(BC3*C1N-BC5*C2N)/(R+C5)*CA2) 
      AM5T= AM5T - SUMSV1(IOUT)*((BC2*C1P-BC4*C2P)/(R-C4)*CA3-(BC2*C1N- 
     1      BC4*C2N)/(R+C4)*CA4)-SUMSV2(IOUT)*((BC3*C1P-BC5*C2P)/       
     2      (R-C5)*CA3-(BC3*C1N-BC5*C2N)/(R+C5)*CA4)        
      TEMP   = (SPS-SNS)/RL1        
      CONST  = (BC2*C1P-BC4*C2P)/(R-C4)        
      CONST2 = (BC2*C1N-BC4*C2N)/(R+C4)        
      CONST3 = (BC3*C1P-BC5*C2P)/(R-C5)        
      CONST4 = (BC3*C1N-BC5*C2N)/(R+C5)        
      CONST5 = SS*SUMSV1(IOUT)        
      CONST6 = SS*SUMSV2(IOUT)        
      C1A    =-AI*BETNP        
      C2A    =-AI*BETNN        
      CEXP1  = CEXP(C1A*SNS)        
      CEXP2  = CEXP(C2A*SNS)        
      CEXP1A = CEXP(C1A*TEMP)        
      CEXP2A = CEXP(C2A*TEMP)        
      DO 80 JL = 1,NL        
      QRES4(JL) = QRES4(JL) + CONST5*(CONST*CEXP1-CONST2*CEXP2) +       
     1            CONST6*(CONST3*CEXP1-CONST4*CEXP2)        
      CEXP1  = CEXP1*CEXP1A        
      CEXP2  = CEXP2*CEXP2A        
   80 CONTINUE        
   90 CONTINUE        
      IF (CABS((AM5TT-AM5T)/AM5T) .LT. 0.001) GO TO 110        
      AM5TT  = AM5T        
  100 CONTINUE        
      GO TO 200        
  110 CONTINUE        
      IF (INER  .LE.  I6) GO TO 120        
      I6 = INER        
  120 CONTINUE        
      F5  = F5  + F5T        
      AM5 = AM5 + AM5T        
      DO 130 JL = 1,NL        
      PRES4(JL) = PRES4(JL) + QRES4(JL)        
  130 CONTINUE        
      ALP1 = (2.0*PI*C4-DEL*SNS-SIGMA)/S1        
      ALP2 = (2.0*PI*C5-DEL*SNS-SIGMA)/S1        
      T1   = 1.0 - CEXP(-2.0*PI*AI*C4)        
      T2   = 1.0 - CEXP(-2.0*PI*AI*C5)        
      C1P  = CEXP(-2.0*PI*AI*C4*SNS/S1)/(T1)        
      C2P  = CEXP( 2.0*PI*AI*C4*SNS/S1)/(T1)        
      C1N  = CEXP(-2.0*PI*AI*C5*SNS/S1)/(T2)        
      C2N  = CEXP( 2.0*PI*AI*C5*SNS/S1)/(T2)        
      T1   = CEXP(-AI*SPS*ALP1)        
      T2   = CEXP(-AI*SNS*ALP1)        
      T3   = CEXP(-AI*SPS*ALP2)        
      T4   = CEXP(-AI*SNS*ALP2)        
      CA1  = AI*SS/ALP1*(T1-T2)        
      CA2  = AI*SS/ALP2*(T3-T4)        
      CA3  = SS*(AI*SPS*T1/ALP1 - AI*SNS*T2/ALP1 + (T1-T2)/        
     1       ALP1**2 + (2.0-SPS)*AI/ALP1*(T1-T2))        
      CA4  = SS*(AI*SPS*T3/ALP2 - AI*SNS*T4/ALP2 + (T3-T4)/        
     1       ALP2**2 + (2.0-SPS)*AI/ALP2*(T3-T4))        
      F5   = F5 - 2.0*PI*AI*SUMSV1(IOUT)*(BC2*C1P-BC4*C2P)*CA1 - 2.0*PI*
     1       AI*SUMSV2(IOUT)*(BC3*C1N-BC5*C2N)*CA2        
      AM5  = AM5 - 2.0*PI*AI*SUMSV1(IOUT)*(BC2*C1P-BC4*C2P)*CA3 - 2.0*  
     1       PI*AI*SUMSV2(IOUT)*(BC3*C1N-BC5*C2N)*CA4        
      TEMP = (SPS-SNS)/RL1        
      CONST  = SS*2.0*PI*AI        
      CONST2 = CONST*SUMSV1(IOUT)*(BC2*C1P-BC4*C2P)        
      CONST3 = CONST*SUMSV2(IOUT)*(BC3*C1N-BC5*C2N)        
      C1A    =-AI*ALP1        
      C2A    =-AI*ALP2        
      CEXP1  = CEXP(C1A*SNS)        
      CEXP2  = CEXP(C2A*SNS)        
      CEXP1A = CEXP(C1A*TEMP)        
      CEXP2A = CEXP(C2A*TEMP)        
      DO 140 JL = 1,NL        
      PRES4(JL) = PRES4(JL)+CONST2*CEXP1+CONST3*CEXP2        
      CEXP1  = CEXP1*CEXP1A        
      CEXP2  = CEXP2*CEXP2A        
  140 CONTINUE        
      IF (CABS((AM5-AM6)/AM5) .LT. 0.0009) GO TO 160        
      AM6 = AM5        
  150 CONTINUE        
      GO TO 220        
  160 CONTINUE        
      CLIFT = F1 + F2 - F2P + F4 + F5        
      CMOMT = AM1 + AM2 - AM2P + AM4 + AM5 - AMOAXS*CLIFT        
      GO TO 270        
C        
  200 WRITE  (IBBOUT,210) UFM        
  210 FORMAT (A23,' - AMG MODULE -SUBROUTINE SUBCC.  AM5T LOOP DID NOT',
     1       ' CONVERGE.')        
      GO TO 260        
  220 WRITE  (IBBOUT,230) UFM        
  230 FORMAT (A23,' - AMG MODULE -SUBROUTINE SUBCC.  AM5 LOOP DID NOT', 
     1       ' CONVERGE.')        
      GO TO 260        
  240 WRITE  (IBBOUT,250) UFM,I7        
  250 FORMAT (A23,' - AMG MODULE -SUBROUTINE SUBCC.  OUTER LOOP OF AM5',
     1       ' EXCEEDED I7 (',I6,1H))        
  260 CALL MESAGE (-61,0,0)        
  270 CONTINUE        
      RETURN        
      END        
