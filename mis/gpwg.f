      SUBROUTINE GPWG        
C        
C     GRID POINT WEIGHT GENERATOR        
C        
C     INPUTS  - BGPDT,CSTM,EQEXIN,MGG        
C        
C     OUTPUTS - OGPWG        
C        
C     PARAMETERS -- POINT,WTMASS        
C        
      INTEGER        BGPDT,CSTM,EQEXIN,OGPWG,SCR1,SCR2,SCR3,SCR4,POINT  
      COMMON /BLANK/ POINT,WTMASS        
      DATA    BGPDT, CSTM,EQEXIN,MGG, OGPWG, SCR1,SCR2,SCR3,SCR4 /      
     1        101  , 102 ,103   ,104, 201  , 301 ,302 ,303 ,304  /      
C        
C     FORM D MATRIX (TRANSPOSED)        
C        
      IP = POINT        
C        
      CALL GPWG1A (POINT,BGPDT,CSTM,EQEXIN,SCR3,NOGO)        
C        
C     CHECK FOR AN ALL SCALAR PROBLEM AND A STUPID USER        
C        
      IF (NOGO .EQ. 0) GO TO 10        
C        
C     COMPUTE MZERO = DT*MGG*D        
C        
      CALL TRANP1 (SCR3,SCR1,2,SCR2,SCR4,0,0,0,0,0,0)        
      CALL SSG2B  (MGG ,SCR1,0,SCR2,0,1,1,SCR3)        
      CALL SSG2B  (SCR1,SCR2,0,SCR4,1,1,1,SCR3)        
C        
C     M-ZERO IS ON SCR4        
C        
C     FORM OUTPUT  STUFF        
C        
      IF (POINT .EQ. 0) IP = 0        
      CALL GPWG1B (SCR4,OGPWG,WTMASS,IP)        
   10 RETURN        
      END        
