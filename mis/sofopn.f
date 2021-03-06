      SUBROUTINE SOFOPN (B1,B2,B3)        
C        
C     READS THE SOF AND SYS COMMON BLOCKS FROM THE DIRECT ACCESS STORAGE
C     DEVICE, AND INITIALIZES THE POINTERS TO THE THREE BUFFERS NEEDED  
C     BY THE SOF UTILITY SUBROUTINES        
C        
      LOGICAL         FIRST,OPNSOF        
      INTEGER         B1(1),B2(1),B3(1),BUF,DIT,A,B,CORWDS,GINOBL       
      DIMENSION       NAME(2),IPTR(3)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /MACHIN/ MACH        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / A(37)        
      COMMON /SYS   / B(6)        
      COMMON /SOFCOM/ NFILES,FILNAM(10),FILSIZ(10),STATUS,PSSWRD(2),    
     1                FIRST,OPNSOF        
      COMMON /ITEMDT/ NITEM,ITEM(7,1)        
      COMMON /SYSTEM/ NBUFF,NOUT        
      COMMON /GINOX / C(161),GINOBL        
      DATA    NAME  / 4HSOFO,4HPN  /        
      DATA    IRD   / 1 /        
C        
      IF (OPNSOF) GO TO 1000        
C        
C     CHECK IF THE OPEN CORE BUFFERS ARE LARGE ENOUGH AND DO NOT OVERLAP
C        
      IPTR(1) = CORWDS(BUF,B1) + 2        
      IPTR(2) = CORWDS(BUF,B2) + 2        
      IPTR(3) = CORWDS(BUF,B3) + 2        
      ISIZ    = KORSZ(BUF)        
      DO 2 I = 1,3        
      IF (ISIZ-IPTR(I) .LT. NBUFF-3) CALL MESAGE (-8,0,NAME)        
    2 CONTINUE        
      DO 4 I = 1,2        
      K = I + 1        
      DO 3 J = K,3        
      ISIZ = IPTR(I) - IPTR(J)        
      IF (ISIZ .LT.     0) ISIZ = -ISIZ        
      IF (ISIZ .LT. NBUFF) CALL MESAGE (-8,0,NAME)        
    3 CONTINUE        
    4 CONTINUE        
      A( 1) = IPTR(1)        
      A( 7) = IPTR(2)        
      A(15) = IPTR(3)        
      A(19) = IPTR(1)        
C        
C     SET SOF BUFFER SIZE FROM /GINOX/        
C     ON IBM USE /SYSTEM/ BECAUSE /GINOX/ IS IN SUPER LINK        
C        
      B(1) = GINOBL        
      IF (MACH.EQ.2 .OR. MACH.GE.5) B(1) = NBUFF - 4        
      IF (FIRST) CALL SOFINT (IPTR(1),IPTR(2),NUMB,IBL1)        
C        
C     READ AND INITIALIZE THE COMMON BLOCKS SYS AND SOF        
C        
      DIT = IPTR(1)        
      CALL SOFIO (IRD,1,BUF(DIT-2))        
      DO 20 I = 1,4        
      B(I) = BUF(DIT+24+I)        
   20 CONTINUE        
      B(5) = BUF(DIT+46)        
      B(6) = BUF(DIT+47)        
      A(1) = IPTR(1)        
      A(2) = 0        
      A(3) = 0        
      A(4) = BUF(DIT+29)        
      A(5) = BUF(DIT+30)        
      A(6) = BUF(DIT+31)        
      A(7) = IPTR(2)        
      DO 30 I = 8,14        
      A(I) = 0        
   30 CONTINUE        
      A(15) = IPTR(3)        
      A(16) = 0        
      A(17) = 0        
      A(18) = BUF(DIT+32)        
      A(19) = IPTR(1)        
      A(20) = 0        
      A(21) = 0        
      A(22) = BUF(DIT+33)        
      DO 35 I = 1,NFILES        
      A(22+I) = BUF(DIT+33+I)        
   35 CONTINUE        
      A(33) = BUF(DIT+44)        
      A(34) = 0        
      A(35) = 0        
      A(36) = 0        
      A(37) = BUF(DIT+45)        
C        
C     INITILIZE COMMON BLOCK ITEMDT        
C        
      NITEM = BUF(DIT+100)        
      K = 100        
      DO 38 I = 1,NITEM        
      DO 37 J = 1,7        
   37 ITEM(J,I) = BUF(DIT+K+J)        
   38 K = K + 7        
      OPNSOF = .TRUE.        
      IF (.NOT. FIRST) RETURN        
      FIRST  = .FALSE.        
      IF (NUMB .EQ. 0) RETURN        
C        
C     ADD THE NUMBER NUMB OF BLOCKS TO THE SUPERBLOCK WHOSE SIZE        
C     NEEDED TO BE INCREASED        
C        
      DO 40 I = 1,NUMB        
      CALL RETBLK (IBL1+I-1)        
   40 CONTINUE        
      B(4) = B(4) - NUMB        
      RETURN        
C        
C     ERROR MESSAGE        
C        
 1000 WRITE  (NOUT,1001) UFM        
 1001 FORMAT (A23,' 6222 - ATTEMPT TO CALL SOFOPN MORE THAN ONCE ',     
     1       'WITHOUT CALLING SOFCLS.')        
      CALL SOFCLS        
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        
