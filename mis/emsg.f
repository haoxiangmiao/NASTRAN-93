      SUBROUTINE EMSG(NCHAR,NO,ISYS,IWF,ITEXT)
      INTEGER IMSG(2,4), ITEXT(1)
      COMMON /SYSTEM/SYSBUF(41)
C     ISYS = 1   USER           IWF  =     1   WARNING
C          = 2   SYSTEM             =     2   FATAL
C
      EQUIVALENCE (NCPW,SYSBUF(41)),(NOUT,SYSBUF(2)),(IMACH,SYSBUF(22))
      DATA IMSG /4HUSER,1H ,4HSYST,4HEM  ,4HWARN,4HING ,4HFATA,1HL  /   
      NWORD = (NCHAR + NCPW-1)/NCPW
      NLINE = (NCHAR + 9 + 131)/ 132   +2
      CALL PAGE2(-NLINE)
      NO1=IABS(NO)
      K = IWF +2
      WRITE(NOUT,10)(IMSG(I,ISYS),I=1,2),(IMSG(M,K),M=1,2),NO1
   10 FORMAT(1H0,4H*** ,4A4, I4,1H,)                                    
      IF(NCHAR .EQ. 0) RETURN
      GO TO (20,30,20,50,30), IMACH
C
C     7094
C
   20 WRITE (NOUT,25)(ITEXT(I),I=1,NWORD)
   25 FORMAT(10X, 20A6,A2)                                              
      GO TO 60
C
C     360/370
C
   30 WRITE(NOUT,35) (ITEXT(I),I=1,NWORD)
   35 FORMAT(10X, 30A4,A2)                                              
      GO TO 60
C
C     CDC
C
   50 WRITE(NOUT,55) (ITEXT(I),I=1,NWORD)
   55 FORMAT(10X,12A10,A2)                                              
   60 IF (NO .LT. 0) CALL MESAGE(-61,0,0)
      RETURN
      END
