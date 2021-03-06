      SUBROUTINE EXLVL (NOS,MD,NAME,Z,NWDS)        
C        
C     EXLVL ADDS A SUBSTRUCTURE TO THE RESIDENT SOF FOR THE SOFIN       
C     OPERATION.  IT USES THE DIT AND MDI DATA WRITTEN ON THE EXTERNAL  
C     FILE BY SOFOUT TO RESTORE THE HL, CS, AND LL POINTERS IN THE MDI. 
C        
      EXTERNAL LSHIFT   ,RSHIFT   ,ANDF     ,ORF        
      LOGICAL  MDIUP        
      INTEGER  MD(4,1)  ,NAME(2)  ,BUF      ,ANDF     ,RSHIFT    ,      
     1         PS       ,CS       ,HL       ,TP       ,Z(2)      ,      
     2         SUBR(2)  ,ORF        
CZZ   COMMON  /SOFPTR/   BUF(1)        
      COMMON  /ZZZZZZ/   BUF(1)        
      COMMON  /SYSTEM/   SYSBUF   ,NOUT     ,X1(6)    ,NLPP      ,      
     1                   X2(2)    ,LINE        
      COMMON  /SOF   /   X3(34)   ,MDIUP        
      DATA     SUBR  /   4HEXLV   ,4HL      /        
C        
C        
C     ADD THE NEW SUBSTRUCTURE TO THE RESIDENT DIT.        
C        
      CALL FDSUB (NAME,I)        
      IF (I .NE. -1) GO TO 6104        
      CALL CRSUB (NAME,I)        
      IF (NOS .LE. 0) GO TO 200        
      Z(1) = NAME(1)        
      Z(2) = NAME(2)        
      NSS  = 1        
      ISS  = 1        
C        
C     DECODE THE OLD MDI ENTRY        
C        
    5 DO 10 I = 1,NOS        
      IF (MD(1,I).NE.Z(2*ISS-1) .OR. MD(2,I).NE.Z(2*ISS)) GO TO 10      
      PS = ANDF(MD(3,I),1023)        
      TP = ANDF(RSHIFT(MD(3,I),20),1023)        
      LL = RSHIFT(MD(4,I),20)        
      CS = ANDF(RSHIFT(MD(4,I),10),1023)        
      HL = ANDF(MD(4,I),1023)        
      IOLD = I        
      GO TO 15        
   10 CONTINUE        
C        
C     SET NEW MDI POINTERS FOR HL, CS, AND LL IF THE SUBSTRUCTURES OF   
C     THE ORIGINATING SOF WHICH ARE INDICATED THEREBY EXIST.        
C        
C        
C     HIGHER LEVEL (HL)        
C        
   15 M = 0        
      IF (HL .EQ. 0) GO TO 30        
      CALL FDSUB (MD(1,HL),I)        
      IF (I .GT. 0) GO TO 20        
      CALL CRSUB (MD(1,HL),I)        
      NSS = NSS + 1        
      IF (2*NSS .GT. NWDS) GO TO 9008        
      Z(2*NSS-1) = MD(1,HL)        
      Z(2*NSS  ) = MD(2,HL)        
   20 M  = I        
      HL = I        
C        
C     COMBINED SUBSTRUCTURE (CS)        
C        
   30 IF (CS .EQ. 0) GO TO 60        
      CALL FDSUB (MD(1,CS),J)        
      IF (J .GT. 0) GO TO 50        
      CALL CRSUB (MD(1,CS),J)        
      NSS = NSS + 1        
      IF (2*NSS .GT. NWDS) GO TO 9008        
      Z(2*NSS-1) = MD(1,CS)        
      Z(2*NSS  ) = MD(2,CS)        
   50 M  = ORF(M,LSHIFT(J,10))        
      CS = J        
C        
C     LOWER LEVEL (LL)        
C        
   60 IF (LL .EQ. 0) GO TO 90        
      CALL FDSUB (MD(1,LL),J)        
      IF (J .GT. 0) GO TO 80        
      CALL CRSUB (MD(1,LL),J)        
      NSS = NSS + 1        
      IF (2*NSS .GT. NWDS) GO TO 9008        
      Z(2*NSS-1) = MD(1,LL)        
      Z(2*NSS  ) = MD(2,LL)        
   80 M  = ORF(M,LSHIFT(J,20))        
      LL = J        
C        
C     UPDATE THE MDI        
C        
   90 CALL FDSUB (Z(2*ISS-1),J)        
      CALL FMDI (J,I)        
      BUF(I+1) = LSHIFT(TP,20)        
      BUF(I+2) = M        
      MDIUP    =.TRUE.        
C        
C     WRITE USER MESSAGES        
C        
      NL = 2        
      IF (LL .NE. 0) NL = NL + 1        
      IF (CS .NE. 0) NL = NL + 1        
      IF (HL .NE. 0) NL = NL + 1        
      IF (PS .NE. 0) NL = NL + 3        
      IF (LINE+NL .GT. NLPP) CALL PAGE        
      LINE = LINE + NL        
      WRITE (NOUT,63470) Z(2*ISS-1),Z(2*ISS)        
      IF (HL .EQ. 0) GO TO 100        
      CALL FDIT (HL,I)        
      WRITE (NOUT,63471) BUF(I),BUF(I+1)        
  100 IF (CS .EQ. 0) GO TO 130        
      CALL FDIT (CS,I)        
      WRITE (NOUT,63472) BUF(I),BUF(I+1)        
  130 IF (LL .EQ. 0) GO TO 160        
      CALL FDIT (LL,I)        
      WRITE (NOUT,63473) BUF(I),BUF(I+1)        
  160 IF (PS .EQ. 0) GO TO 170        
      WRITE (NOUT,63590) Z(2*ISS-1),Z(2*ISS)        
  170 ISS = ISS + 1        
      IF (ISS-NSS) 5,5,210        
C        
C     SUBSTRUCTURE ADDED TO SOF SUCCESSFULLY        
C        
  200 WRITE (NOUT,63470) NAME        
  210 RETURN        
C        
C     SUBSTRUCTURE NAME WAS DUPLICATED        
C        
 6104 CALL SMSG (4,0,NAME)        
      RETURN        
C        
C     INSUFFICIENT CORE        
C        
 9008 CALL MESAGE (-8,0,SUBR)        
      RETURN        
C        
C     MESSAGE TEXT        
C        
63470 FORMAT (49H0*** USER INFORMATION MESSAGE 6347, SUBSTRUCTURE ,     
     1        2A4,18H ADDED TO THE SOF.)        
63471 FORMAT (5X, 25HHIGHER LEVEL SUBSTRUCTURE,2X,2A4)        
63472 FORMAT (5X, 25HCOMBINED SUBSTRUCTURE    ,6(2X,2A4))        
63473 FORMAT (5X, 25HLOWER LEVEL SUBSTRUCTURE ,7(2X,2A4))        
63590 FORMAT (49H0*** USER INFORMATION MESSAGE 6359, SUBSTRUCTURE ,     
     1        2A4,41H WAS ORIGINALLY A SECONDARY SUBSTRUCTURE./36X,     
     2        42HON THIS SOF, IT IS A PRIMARY SUBSTRUCTURE.)        
      END        
