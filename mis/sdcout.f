      SUBROUTINE SDCOUT (BLOCK,IRW,AC,N,VECS,VECD)        
C        
C     SDCOUT WRITES A ROW OF A MATRIX IN STRING FORMAT USING        
C     PUTSTR/ENDPUT.        
C        
C     BLOCK = A 15-WORD ARRAY IN WHICH BLOCK(1),(2),(3) HAVE ALREADY    
C             BEEN COMPLETED WITH GINO NAME, TYPE AND FORMAT        
C     IRW   = ZERO -- ROW NBR OF VECTOR = AC(1)        
C           = N.Z. -- ROW NBR OF VECTOR IS IRW        
C     AC    = A VECTOR OF N COLUMN POSITIONS (COL NBRS MAY BE .LT. 0)   
C     N     = NUMBER OF WORDS IN AC AND NUMBER OF TERMS IN VECS        
C     VECS  = A VECTOR OF N TERMS. THE POS OF EACH TERM IS DEFINED      
C             BY THE NUMBER STORED IN THE CORRESPONDING POSITION IN AC  
C     VECD  = SAME VECTOR AS VECS        
C        
      INTEGER          AC(1)    ,PRC      ,WORDS    ,RLCMPX   ,TYPE   , 
     1                 RC       ,PREC     ,BLOCK(15)        
      REAL             VECS(1)  ,XNS(1)        
      DOUBLE PRECISION XND(1)   ,VECD(1)        
      COMMON /TYPE  /  PRC(2)   ,WORDS(4) ,RLCMPX(4)        
CZZ   COMMON /XNSTRN/  XND        
      COMMON /ZZZZZZ/  XND        
      EQUIVALENCE      (XND(1),XNS(1))        
C        
      BLOCK(8)  = -1        
      BLOCK(12) = IRW        
      IF (IRW .EQ. 0) BLOCK(12) = IABS(AC(1))        
      II   = 0        
      TYPE = BLOCK(2)        
      RC   = RLCMPX(TYPE)        
      PREC = PRC(TYPE)        
      I    = 1        
C        
C     DETERMINE LENGTH OF A STRING BY SCANNING AC        
C        
   10 BLOCK(4) = IABS(AC(I))        
      J = BLOCK(4) - I        
      K = I + 1        
   12 IF (K .GT. N) GO TO 14        
      IF (IABS(AC(K)) .NE. J+K) GO TO 14        
      K = K + 1        
      GO TO 12        
   14 NBRSTR = K - I        
C        
C     WRITE STRING WITH PUTSTR/ENDPUT        
C        
   15 CALL PUTSTR (BLOCK)        
      BLOCK(7) = MIN0(BLOCK(6),NBRSTR)        
      JSTR = BLOCK(5)        
      NSTR = JSTR + RC*BLOCK(7) - 1        
      IF (PREC .EQ. 2) GO TO 18        
C        
      DO 16 JJ = JSTR,NSTR        
      II = II + 1        
      XNS(JJ) = VECS(II)        
   16 CONTINUE        
      GO TO 22        
C        
   18 DO 20 JJ = JSTR,NSTR        
      II = II + 1        
      XND(JJ) = VECD(II)        
   20 CONTINUE        
C        
C     TEST FOR COMPLETION        
C        
   22 I = I + BLOCK(7)        
      IF (I .GT. N) GO TO 30        
      CALL ENDPUT (BLOCK)        
      IF (NBRSTR .EQ. BLOCK(7)) GO TO 10        
      NBRSTR   = NBRSTR - BLOCK(7)        
      BLOCK(4) = IABS( AC(I) )        
      GO TO 15        
C        
C     END LAST STRING        
C        
   30 BLOCK(8) = 1        
      CALL ENDPUT (BLOCK)        
      RETURN        
      END        