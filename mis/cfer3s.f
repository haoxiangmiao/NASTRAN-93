      SUBROUTINE CFER3S (V1,V1L,V2,V2L,V3,V3L,V4,V4L,V5,V5L,ZB,ZC)      
C        
C     CFER3S IS A SINGLE PRECISION ROUTINE (CALLED BY CFEER3) WHICH     
C     PERFORMS THE TRIDIAGONAL REDUCTION FOR THE COMPLEX FEER METHOD    
C        
      LOGICAL           SUCESS   ,NO B     ,SKIP     ,AGAIN      ,      
     1                  QPR      ,SYMMET        
      INTEGER           CSP      ,NAME(2)        
      REAL              LAMBDA   ,TEMP1(2)        
      DOUBLE PRECISION  TEMP2        
      DIMENSION         ZB(1)    ,ZC(1)    ,S(8)     ,A(2)       ,      
     1                  V1(1)    ,V1L(1)   ,V2(1)    ,V2L(1)     ,      
     2                  V3(1)    ,V3L(1)   ,V4(1)    ,V4L(1)     ,      
     3                  V5(1)    ,V5L(1)   ,DSAVE(2) ,D(4)        
      CHARACTER         UFM*23   ,UWM*25        
      COMMON  /XMSSG /  UFM      ,UWM        
      COMMON  /FEERAA/  IKMB(7,3),ILAM(7)  ,IPHI(7)  ,DUDXX      ,      
     1                  ISCR(11) ,DUMAA(84),MCBVEC(7)        
      COMMON  /FEERXC/  LAMBDA(4),SYMMET   ,MREDUC   ,NORD       ,      
     1                  IDIAG    ,EPSDUM(2),NORTHO   ,NORD2      ,      
     2                  NORD4    ,NORDP1   ,NSWP(2)  ,NO B       ,      
     3                  IT       ,TEN2MT   ,TENMHT   ,NSTART     ,      
     4                  QPR      ,REGDUM(2),NZERO    ,XCDUM(3)   ,      
     5                  NUMRAN        
      COMMON  /SYSTEM/  KSYSTM(65)        
      COMMON  /UNPAKX/  IPRC     ,II       ,NN       ,INCR        
      COMMON  /PACKX /  ITP1     ,ITP2     ,IIP      ,NNP        ,      
     1                  INCRP        
      COMMON  /NAMES /  RD       ,RDREW    ,WRT      ,WRTREW     ,      
     1                  REW      ,NOREW    ,EOFNRW   ,RSP        ,      
     2                  RDP      ,CSP      ,CDP      ,SQR        
      EQUIVALENCE       (A(1),D(3))        ,(KSYSTM(2),NOUT )    ,      
     1                  (D(1),S(1))        ,(TEMP1(1) ,TEMP2)        
      DATA     ZERO  /  0.           /        
      DATA     NAME  /  4HCFER,4H3S  /        
C        
C     DEFINITION OF INPUT AND OUTPUT PARAMETERS        
C        
C     V1,V2,V3,V4,V5  = AREAS OF OPEN CORE DESIGNATED BY SUBROUTINE     
C                       CFEER3 AND USED INTERNALLY AS WORKING VECTORS,  
C                       USUALLY RIGHT-HANDED        
C     V1L,.......,V5L = SAME AS V1 THRU V5 BUT USUALLY LEFT-HANDED      
C     RESTRICTION ..... LEFT-HANDED VECTOR MUST IMMEDIATELY FOLLOW      
C                       CORRESPONDING RIGHT-HANDED VECTOR IN CORE       
C                       ALSO, V2 SHOULD FOLLOW V1L FOR READ TO WORK     
C     ZB,ZC           = REQUIRED GINO BUFFERS        
C        
C     DEFINITION OF INTERNAL PARAMETERS        
C        
C     A        = DIAGONAL ELEMENTS OF REDUCED TRIDIAGONAL MATRIX        
C     D        = OFF-DIAG ELEMENTS OF REDUCED TRIDIAGONAL MATRIX        
C     AGAIN    = LOGICAL INDICATOR FOR CYCLING THRU LOGIC AGAIN WHEN    
C                NULL VECTOR TEST (D-BAR) FAILS        
C     SKIP     = LOGICAL INDICATOR FOR AVOIDING REDUNDANT OPERATIONS    
C     NORTHO   = TOTAL CURRENT NUMBER OF VECTOR PAIRS ON ORTHOGONAL     
C                VECTOR FILE        
C     NZERO    = NUMBER OF EIGENVECTOR PAIRS ON EIGENVECTOR FILE        
C                (RESTART AND PRIOR NEIGHBORHOODS)        
C     LANCOS   = LANCZOS ALGORITHM COUNTER        
C     NSTART   = NUMBER OF INITIAL REORTHOGONALIZATION ATTEMPTS        
C        
      IF (QPR) WRITE (NOUT,8887)        
 8887 FORMAT (1H1,50X,6HCFER3S,/1H0)        
C        
C     SET PACK AND UNPACK CONSTANTS        
C        
      IPRC = CSP        
      INCR = 1        
      ITP1 = IPRC        
      ITP2 = ITP1        
      INCRP= INCR        
      II   = 1        
      IIP  = 1        
C        
C     NN AND NNP ARE SET LOCALLY        
C        
      CALL GOPEN (ISCR(7),ZB(1),WRTREW)        
      CALL CLOSE (ISCR(7),NOREW)        
      IF (NORTHO .EQ. 0) GO TO 20        
C        
C     LOAD AND RE-NORMALIZE ALL EXISTING VECTORS ON THE NASTRAN        
C     EIGENVECTOR FILE (INCLUDES ANY RESTART VECTORS AND ALL VECTORS    
C     OBTAINED IN PRIOR NEIGHBORHOODS). PACK THESE VECTORS ON        
C     THE ORTHOGONAL VECTOR SCRATCH FILE.        
C        
      CALL OPEN (*170,IPHI(1),ZC(1),0)        
C        
C     LEFT-HAND VECTOR IS STORED IMMEDIATELY AFTER RIGHT-HAND VECTOR    
C        
      NNP   = NORD2        
      NORD8 = 2*NORD4        
      DO 15 I = 1,NORTHO        
            IF (QPR) WRITE (NOUT,8802) I        
 8802       FORMAT(1H ,13(10H----------),/,18H ORTHOGONAL VECTOR,I3)    
C        
C     THIS LOADS VALUES INTO V1, V1L, V2, AND V2L        
C        
      CALL READ (*190,*5,IPHI(1),V1(1),NORD8+10,0,N3)        
      GO TO 210        
C        
C     COMPRESS PHYSICAL EIGENVECTORS TO SINGLE PRECISION        
C        
    5 DO 6 J = 1,NORD4        
C   6 V1(J) = V1(2*J-1)        
      J2 = J*2        
      TEMP1(1) = V1(J2-1)        
      TEMP1(2) = V1(J2  )        
    6 V1(J) = TEMP2        
      IF (IDIAG .EQ. 0) GO TO 13        
      DO 8 J = 1,NORD4        
      IF (V1(J) .NE. ZERO) GO TO 13        
    8 CONTINUE        
      WRITE (NOUT,590) I        
   13 CONTINUE        
            IF (QPR) WRITE (NOUT,8803) (V1 (J),J=1,NORD2)        
            IF (QPR) WRITE (NOUT,8803) (V1L(J),J=1,NORD2)        
 8803       FORMAT (1H ,(1H ,4E25.16))        
      CALL CFNOR1 (V1(1),V1L(1),NORD2,0,D(1))        
      IF (IDIAG.NE.0 .AND. NORD2.LE.70) WRITE (NOUT,570) I,        
     1               (V1(J),V1(J+1),V1L(J),V1L(J+1),J=1,NORD2,2)        
      CALL GOPEN (ISCR(7),ZB(1),WRT)        
      CALL PACK  (V1(1),ISCR(7),MCBVEC(1))        
      CALL CLOSE (ISCR(7),NOREW)        
   15 CONTINUE        
      CALL CLOSE (IPHI(1),NOREW)        
      IF (IDIAG .NE. 0) WRITE (NOUT,580) NORTHO,MCBVEC        
C        
C     GENERATE INITIAL PSEUDO-RANDOM VECTORS        
C        
   20 N3 = 3*NORD        
      IJ = 0        
      SS = 1.        
      NZERO  = NORTHO        
      NSTART = 0        
      LANCOS = 0        
      AGAIN  = .FALSE.        
      D(1)   = ZERO        
      D(2)   = ZERO        
   25 NUMRAN = NUMRAN + 1        
      DO 30 I = 1,NORD4        
      IJ = IJ + 1        
      SS =-SS        
      IF (I .GT. NORD2) GO TO 28        
      IF (I .GT. NORD ) GO TO 27        
      JJ = 2*I - 1        
      GO TO 30        
   27 JJ = 2*(I-NORD)        
      GO TO 30        
   28 IF (I .GT. N3) GO TO 29        
      JJ = 2*I - 1 - NORD2        
      GO TO 30        
   29 JJ = 2*(I-N3) + NORD2        
C        
C     THIS LOADS VALUES INTO V1 AND V1L        
C        
   30 V1(JJ) = SS*(MOD(IJ,3)+1)/        
     1         (3.*(MOD(IJ,13)+1)*(1+5*FLOAT(I)/NORD))        
      IF (QPR) WRITE (NOUT,8844) (V1(I),I=1,NORD4)        
 8844 FORMAT (1H0,13(10H----------),/,(1H ,4E25.16))        
      IF (QPR) WRITE (NOUT,8845)        
 8845 FORMAT (1H ,13(10H----------))        
C        
C     NORMALIZE RIGHT AND LEFT START VECTORS        
C        
      CALL CFNOR1 (V1(1),V1L(1),NORD2,0,D(1))        
C        
C     REORTHOGONALIZE START VECTORS W.R.T. RESTART AND        
C     PRIOR-NEIGHBORHOOD VECTORS        
C        
      CALL CF1ORT (SUCESS,10,TEN2MT,NZERO,LANCOS,        
     2             V1(1),V1L(1),V5(1),V5L(1),V3(1),V3L(1),ZB(1))        
      IF (SUCESS) GO TO 40        
      IF (AGAIN ) GO TO 160        
   35 NSTART = NSTART + 1        
      IF (NSTART .LE. 2) GO TO 25        
      WRITE (NOUT,600) UWM,LAMBDA(1),LAMBDA(3)        
      GO TO 450        
   40 IF (AGAIN) GO TO 90        
C        
C     SWEEP START VECTORS CLEAN OF ZERO-ROOT EIGENVECTORS        
C        
      CALL CFE1AO (.FALSE.,V1 (1),V2 (1),V3 (1),ZB(1))        
      CALL CFE1AO (.TRUE .,V1L(1),V2L(1),V3L(1),ZB(1))        
C        
C     NORMALIZE THE PURIFIED VECTOR AND OBTAIN D(1)        
C        
      CALL CFNOR1 (V2(1),V2L(1),NORD2,0,D(1))        
      IF (NZERO.EQ.0 .OR. NORTHO.GT.NZERO) GO TO 50        
C        
C     IF RESTART OR BEGINNING OF NEXT NEIGHBORHOOD, PERFORM        
C     REORTHOGONALIZATION AND RENORMALIZATION        
C        
      CALL CF1ORT (SUCESS,10,TEN2MT,NZERO,LANCOS,        
     1             V2(1),V2L(1),V5(1),V5L(1),V3(1),V3L(1),ZB(1))        
      IF (.NOT.SUCESS) GO TO 35        
      CALL CFNOR1 (V2(1),V2L(1),NORD2,0,D(1))        
C        
C     LOAD FIRST VECTORS TO ORTHOGONAL VECTOR FILE        
C        
   50 CALL GOPEN (ISCR(7),ZB(1),WRT)        
      NNP = NORD2        
      CALL PACK  (V2(1),ISCR(7),MCBVEC(1))        
      CALL CLOSE (ISCR(7),NOREW)        
      NORTHO = NORTHO + 1        
C        
C     COMMENCE LANCZOS ALGORITHM        
C        
C     INITIALIZE BY CREATING NULL VECTOR        
C        
      DO 60  I = 1,NORD2        
      V1 (I) = ZERO        
   60 V1L(I) = ZERO        
      SKIP = .FALSE.        
C        
C     ENTER LANCZOS LOOP        
C        
   70 LANCOS = LANCOS + 1        
C        
C     GENERATE DIAGONAL ELEMENT OF REDUCED TRIDIAGONAL MATRIX        
C        
      IF (.NOT.SKIP) CALL CFE1AO (.FALSE.,V2(1),V3(1),V5(1),ZB(1))      
      SKIP = .FALSE.        
      CALL CFNOR1 (V3(1),V2L(1),NORD2,1,A(1))        
C        
C     COMPUTE D-BAR        
C        
      CALL CFE1AO (.TRUE.,V2L(1),V3L(1),V5(1),ZB(1))        
      DO 80 I = 1,NORD2,2        
      J = I + 1        
      V4(I) = V3(I) - A(1)*V2(I) + A(2)*V2(J) - D(1)*V1(I) + D(2)*V1(J) 
      V4(J) = V3(J) - A(1)*V2(J) - A(2)*V2(I) - D(1)*V1(J) - D(2)*V1(I) 
      V4L(I) = V3L(I) - A(1)*V2L(I) + A(2)*V2L(J)        
     1                - D(1)*V1L(I) + D(2)*V1L(J)        
   80 V4L(J) = V3L(J) - A(1)*V2L(J) - A(2)*V2L(I)        
     1                - D(1)*V1L(J) - D(2)*V1L(I)        
      CALL CFNOR1 (V4(1),V4L(1),NORD2,2,D(1))        
      DSAVE(1) = D(1)        
      DSAVE(2) = D(2)        
C        
C     TEST IF LANCZOS ALGORITHM FINISHED        
C        
      IF (LANCOS .EQ. MREDUC) GO TO 150        
      IF (.NOT.QPR) GO TO 85        
      WRITE  (NOUT,8845)        
      WRITE  (NOUT,8886) D        
 8886 FORMAT (8H D-BAR =,2E16.8,9X,3HA =,2E16.8)        
      WRITE  (NOUT,8844) (V4 (I),I=1,NORD2)        
      WRITE  (NOUT,8844) (V4L(I),I=1,NORD2)        
      WRITE  (NOUT,8845)        
   85 CONTINUE        
C        
C     NULL VECTOR TEST        
C        
      IF (SQRT(D(1)**2+D(2)**2) .GT. SQRT(A(1)**2+A(2)**2)*TENMHT)      
     1    GO TO 100        
      IF (IDIAG .NE. 0) WRITE (NOUT,610) D        
      AGAIN = .TRUE.        
      GO TO 25        
   90 CALL CFE1AO (.FALSE.,V1 (1),V4 (1),V3 (1),ZB(1))        
      CALL CFE1AO (.TRUE .,V1L(1),V4L(1),V3L(1),ZB(1))        
C        
C     PERFORM REORTHOGONALIZATION        
C        
  100 CALL CFNOR1 (V4(1),V4L(1),NORD2,0,D(1))        
      CALL CF1ORT (SUCESS,10,TEN2MT,NZERO,LANCOS,        
     1             V4(1),V4L(1),V3(1),V3L(1),V5(1),V5L(1),ZB(1))        
      IF (.NOT.SUCESS) GO TO 160        
C        
C     NORMALIZE THE REORTHOGONALIZED VECTORS        
C        
      CALL CFNOR1 (V4(1),V4L(1),NORD2,0,D(1))        
C        
C     GENERATE OFF-DIAGONAL ELEMENT OF REDUCED TRIDIAGONAL MATRIX       
C        
      CALL CFE1AO (.FALSE.,V4(1),V3(1),V5(1),ZB(1))        
      SKIP = .TRUE.        
      CALL CFNOR1 (V3(1),V2L(1),NORD2,1,D(1))        
      IF (AGAIN) GO TO 105        
C        
C     NULL VECTOR TEST        
C        
      IF (SQRT(D(1)**2+D(2)**2) .LE. SQRT(A(1)**2+A(2)**2)*TENMHT)      
     1    GO TO 160        
      GO TO 110        
  105 AGAIN = .FALSE.        
      D(1)  = ZERO        
      D(2)  = ZERO        
C        
C     TRANSFER TWO ELEMENTS TO REDUCED TRIDIAGONAL MATRIX FILE        
C        
  110 CALL WRITE (ISCR(5),S(1),4,1)        
      IF (IDIAG .NE. 0) WRITE (NOUT,560) LANCOS,D        
C        
C     LOAD CURRENT VECTORS TO ORTHOGONAL VECTOR FILE        
C        
      CALL GOPEN (ISCR(7),ZB(1),WRT)        
      NNP = NORD2        
      CALL PACK  (V4(1),ISCR(7),MCBVEC(1))        
      CALL CLOSE (ISCR(7),NOREW)        
      NORTHO = NORTHO + 1        
C        
C     TRANSFER (I+1)-VECTORS TO (I)-VECTORS AND CONTINUE LANCZOS LOOP   
C        
      DO 130 I = 1,NORD2        
      V1 (I) = V2 (I)        
      V1L(I) = V2L(I)        
      V2 (I) = V4 (I)        
  130 V2L(I) = V4L(I)        
      GO TO 70        
C        
C     TRANSFER TWO ELEMENTS TO REDUCED TRIDIAGONAL MATRIX FILE        
C        
  150 IF (D(1).NE.ZERO .OR. D(2).NE.ZERO) GO TO 155        
      D(1) = DSAVE(1)        
      D(2) = DSAVE(2)        
  155 CALL WRITE (ISCR(5),S(1),4,1)        
      IF (IDIAG .NE. 0) WRITE (NOUT,560) LANCOS,D        
      GO TO 450        
  160 MREDUC = LANCOS        
      WRITE (NOUT,500) UWM,MREDUC,LAMBDA(1),LAMBDA(3)        
      IF (.NOT.AGAIN) GO TO 150        
      D(1) = ZERO        
      D(2) = ZERO        
      GO TO 150        
C        
  170 I = -1        
  180 CALL MESAGE (I,IPHI(1),NAME)        
  190 I = -2        
      GO TO 180        
  210 I = -8        
      GO TO 180        
C        
  450 RETURN        
C        
  500 FORMAT (A25,' 3157', //5X,'FEER PROCESS MAY HAVE CALCULATED ',    
     1       'FEWER ACCURATE MODES',I5,        
     2       ' THAN REQUESTED IN THE NEIGHBORHOOD OF ',2E14.6,//)       
  560 FORMAT (36H REDUCED TRIDIAGONAL MATRIX ELEMENTS,5X,3HROW,I4, /10X,
     1        14HOFF-DIAGONAL =,2E24.16, /14X,10HDIAGONAL =,2E24.16)    
  570 FORMAT (1H0,17HORTHOGONAL VECTOR,I4, /1H0,23X,5HRIGHT,56X,4HLEFT, 
     1        //,(1H ,2E25.16,10X,2E25.16))        
  580 FORMAT (1H0,I10,32H ORTHOGONAL VECTOR PAIRS ON FILE,I5,12X,6I8,/) 
  590 FORMAT (18H ORTHOGONAL VECTOR,I4,8H IS NULL)        
  600 FORMAT (A25,' 3158', //5X,'NO ADDITIONAL MODES CAN BE FOUND BY ', 
     1       'FEER IN THE NEIGHBORHOOD OF ',2E14.6,//)        
  610 FORMAT (14H D-BAR IS NULL,10X,4E20.12)        
      END        
