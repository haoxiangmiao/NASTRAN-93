      SUBROUTINE PKROD        
C        
C     THIS ROUTINE COMPUTES THE TWO 6 X 6 MATRICES  K(NPVT,NPVT) AND    
C     K(NPVT,J) FOR A ROD HAVING END POINTS NUMBERED NPVT AND J.        
C        
C     ECPT FOR THE ROD        
C     ================                                              CARD
C                                                      TYPE  TABLE  TYPE
C     ECPT( 1)ELEMENT ID.                                I    ECT   CROD
C     ECPT( 2)SCALAR INDEX NUMBER FOR GRID POINT A       I    ECT   CROD
C     ECPT( 3)SCALAR INDEX NUMBER FOR GRID POINT B       I    ECT   CROD
C     ECPT( 4)MATERIAL ID.                               I    EPT   PROD
C     ECPT( 5)AREA  (A)                                  R    EPT   PROD
C     ECPT( 6)POLAR MOMENT OF INERTIA (J)                R    EPT   PROD
C     ECPT( 7) TORSIONAL STRESS COEFF (C)                R    EPT   PROD
C     ECPT( 8) NON-STRUCTRAL MASS (MU)                   R    EPT   PROD
C     ECPT( 9) COOR. SYS. ID. NO. FOR GRID POINT A       I   BGPDT  GRID
C     ECPT(10) X-COORDINATE OF GRID PT. A (IN BASIC COOR)R   BGPDT      
C     ECPT(11) Y-COORDINATE OF GRID PT. A (IN BASIC COOR)R   BGPDT      
C     ECPT(12) Z-COORDINATE OF GRID PT. A (IN BASIC COOR)R   BGPDT      
C     ECPT(13) COOR. SYS. ID. NO. FOR GRID POINT B       I   BGPDT      
C     ECPT(14) X-COORDINATE OF GRID PT. B (IN BASIC COOR)R   BGPDT      
C     ECPT(15) Y-COORDINATE OF GRID PT. B (IN BASIC COOR)R   BGPDT      
C     ECPT(16) Z-COORDINATE OF GRID PT. B (IN BASIC COOR)R   BGPDT      
C     ECPT(17) ELEMENT TEMPERATURE        
C     ECPT(18) PREVIOUS STRAIN VALUE, ONCE REMOVED (EPSIN1)        
C     ECPT(19) PREVIOUS STRAIN VALUE (EPSIN2)        
C     ECPT(20) PREVIOUSLY COMPUTED VALUE OF MODULUS OF ELASTICITY, ESTAR
C     ECPT(21) DISPLACEMENT COORDINATES FOR GRID POINT A        
C     ECPT(22)                   . . .        
C     ECPT(23)                   . . .        
C     ECPT(24) DISPLACEMENT COORDINATES FOR GRID POINT B        
C     ECPT(25)                   . . .        
C     ECPT(26)                   . . .        
C        
      DOUBLE PRECISION D(18),X,Y,Z,XL,XN(3),UA(6),UB(6),TA(9),TB(9),E,G,
     1                 DIFF(3),DPTERM,EPSIN1,EPSIN2,DEPS1,DEPS2,EPS1,   
     2                 EPS2,GAMMA,GAMMAS,SIGMA1,SIGMA2,DSCL,DSCR,KE(36) 
      DIMENSION        IECPT(200)        
C        
C     PLA42 PARAMETERS COMMUNICATION BLOCK        
      COMMON /PLA42C/  NPVT,G NEW,G OLD,DUMCL(146),NOGO        
     1        
C        
C     ECPT COMMON BLOCK        
      COMMON /PLA42E/  ECPT(100)        
C        
C     PLA42 LOCAL VARIABLE (SCRATCH) BLOCK        
      COMMON /PLA42D/  D,X,Y,Z,XL,XN,UA,UB,TA,TB,DIFF,DPTERM,EPSIN1,    
     1                 EPSIN2,DEPS1,DEPS2,EPS1,EPS2,GAMMA,GAMMAS,       
     2                 SIGMA1,SIGMA2,DSCL,DSCR,E,G,KE        
C        
C     INPUT AND OUTPUT BLOCKS FOR SUBROUTINE MAT        
      COMMON /MATIN /  MATIDC,MATFLG,TEMDUM,PLAARG,MATDUM(2)        
      COMMON /MATOUT/  E SUB 0,G SUB 0,DUMMAT(18)        
      EQUIVALENCE      (IECPT(1),ECPT(1)) ,(PLAANS,ESUB0)        
C        
C     BEGIN EXECUTION        
C        
      IND = 0        
      IF (IECPT(2) .EQ. NPVT) GO TO 10        
      IF (IECPT(3) .NE. NPVT) CALL MESAGE (-30,34,IECPT(1))        
      IND = 1        
      ITEMP = IECPT(2)        
      IECPT(2) = IECPT(3)        
      IECPT(3) = ITEMP        
      KA  = 13        
      KB  =  9        
      IDISPA = 23        
      IDISPB = 20        
      GO TO 20        
   10 KA  =  9        
      KB  = 13        
      IDISPA = 20        
      IDISPB = 23        
C        
C     AT THIS POINT KA POINTS TO THE COOR. SYS. ID. OF THE PIVOT GRID   
C     POINT. SIMILARLY FOR KB AND THE NON-PIVOT GRID POINT.        
C     NOW COMPUTE THE LENGTH OF THE ROD.        
C        
C     WE STORE THE COORDINATES IN THE D ARRAY SO THAT ALL ARITHMETIC    
C     WILL BE DOUBLE PRECISION        
C        
   20 D(1) = ECPT(KA+1)        
      D(2) = ECPT(KA+2)        
      D(3) = ECPT(KA+3)        
      D(4) = ECPT(KB+1)        
      D(5) = ECPT(KB+2)        
      D(6) = ECPT(KB+3)        
      X    = D(1) - D(4)        
      Y    = D(2) - D(5)        
      Z    = D(3) - D(6)        
      XL = DSQRT(X**2 + Y**2 + Z**2)        
      IF (XL .NE. 0.0D0) GO TO 25        
      CALL MESAGE (30,26,IECPT(1))        
C        
C     SET FLAG FOR FATAL ERROR WHILE ALLOWING ERROR MESSAGES TO        
C     ACCUMULATE        
C        
      NOGO = 1        
      RETURN        
C        
C     CALCULATE A NORMALIZED DIRECTION VECTOR IN BASIC COORDINATES.     
C        
   25 XN(1) = X/XL        
      XN(2) = Y/XL        
      XN(3) = Z/XL        
C        
C     STORE DISPLACEMENT VECTORS IN DOUBLE PRECISION LOCATIONS        
C        
      UA(1) = ECPT(IDISPA+1)        
      UA(2) = ECPT(IDISPA+2)        
      UA(3) = ECPT(IDISPA+3)        
      UB(1) = ECPT(IDISPB+1)        
      UB(2) = ECPT(IDISPB+2)        
      UB(3) = ECPT(IDISPB+3)        
C        
C        
C     COMPUTE THE DIFFERENCE VECTOR DIFF =  T  * U   -  T  * U        
C                                            A    A      B    B        
C        
      IBASEA = 0        
      IF (IECPT(KA) .EQ. 0) GO TO 30        
      CALL TRANSD (ECPT(KA),TA)        
      IBASEA = 3        
      CALL GMMATD (TA,3,3,0, UA(1),3,1,0, UA(4))        
   30 IBASEB = 0        
      IF (IECPT(KB) .EQ. 0) GO TO 40        
      CALL TRANSD (ECPT(KB),TB)        
      IBASEB = 3        
      CALL GMMATD (TB,3,3,0, UB(1),3,1,0, UB(4))        
   40 DIFF(1) = UA(IBASEA+1) - UB(IBASEB+1)        
      DIFF(2) = UA(IBASEA+2) - UB(IBASEB+2)        
      DIFF(3) = UA(IBASEA+3) - UB(IBASEB+3)        
C        
C     COMPUTE DOT PRODUCT XN . DIFF        
C        
      CALL GMMATD (XN,3,1,1, DIFF,3,1,0, DPTERM)        
C        
C     COMPUTE INCREMENT OF STRAIN        
C        
      DEPS1  = DPTERM/XL        
      EPSIN1 = ECPT(18)        
      EPSIN2 = ECPT(19)        
      DEPS2  = EPSIN2 - EPSIN1        
C        
C     COMPUTE CURRENT STRAIN AND ESTIMATED NEXT STRAIN        
C        
      EPS1   = EPSIN2 + DEPS1        
      GAMMA  = G NEW        
      GAMMAS = G OLD        
      EPS2   = EPS1 + GAMMA*DEPS1        
C        
C     CALL MAT ROUTINE TWICE TO GET SIGMA1 AND SIGMA2 AS A FUNCTION OF  
C     EPS1 AND EPS2        
C        
      MATIDC = IECPT(4)        
      MATFLG = 6        
      PLAARG = EPS1        
      CALL MAT (IECPT(1))        
      SIGMA1 = PLAANS        
      PLAARG = EPS2        
      CALL MAT (IECPT(1))        
      SIGMA2 = PLAANS        
C        
C     ON THE FIRST PASS, I.E. WHEN ECPT(19) = 0.0, SIGMA1 = E  * EPS1   
C                                                            0        
C        
      IF (ECPT(19) .NE. 0.0) GO TO 41        
      MATFLG = 1        
      CALL MAT (IECPT(1))        
      D(2)   = E SUB 0        
      SIGMA1 = D(2)*EPS1        
C        
C     FOR STIFFNESS MATRIX GENERATION, COMPUTE THE NEW MATERIAL        
C     PROPERTIES        
C        
   41 IF (EPS1 .EQ. EPS2) GO TO 42        
      E = (SIGMA2-SIGMA1)/(EPS2-EPS1)        
      GO TO 44        
   42 E = ECPT(20)        
C        
C     CALL MAT ROUTINE TO GET ELASTIC MODULI.  STORE IN D.P. LOCATIONS. 
C        
   44 MATFLG = 1        
      CALL MAT (IECPT(1))        
      D(2) = E SUB 0        
      D(4) = GSUB0        
C        
C     SET UP STIFFNESS MATRIX CONSTANTS IN DSCL AND DSCR        
C        
      G    = E*D(4)/D(2)        
      D(1) = ECPT(5)        
      D(3) = ECPT(6)        
      DSCL = D(1)*E/XL        
      DSCR = D(3)*G/XL        
C        
C     SET UP THE -N- MATRIX AND STORE AT D(1)        
C        
      D(1) = XN(1)*XN(1)        
      D(2) = XN(1)*XN(2)        
      D(3) = XN(1)*XN(3)        
      D(4) = D(2)        
      D(5) = XN(2)*XN(2)        
      D(6) = XN(2)*XN(3)        
      D(7) = D(3)        
      D(8) = D(6)        
      D(9) = XN(3)*XN(3)        
C        
C     ZERO OUT THE 6X6 WHICH WILL BE USED FOR STORAGE OF        
C     KGG(NPVT,NONPVT), NONPVT = NPVT,J        
C        
      DO 50 I = 1,36        
   50 KE(I) = 0.0D0        
      NONPVT = 2        
      K2 = 1        
C        
C     IF PIVOT GRID POINT IS IN BASIC COORDINATES, GO TO 70        
C        
      IF (IECPT(KA) .EQ. 0) GO TO 70        
      CALL GMMATD (TA(1),3,3,1, D(1),3,3,0, D(10))        
      CALL GMMATD (D(10),3,3,0, TA(1),3,3,0, D(1))        
C        
C     AT THIS POINT D(1) CONTAINS THE MATRIX PRODUCT TAT*N*TA        
C     AND D(10) CONTAINS THE MATRIX PRODUCT TAT*N.        
C        
      ASSIGN 100 TO IRETRN        
      GO TO  80        
   70 ASSIGN 90 TO IRETRN        
C        
C     FILL THE KE MATRIX        
C        
   80 KE( 1) = DSCL*D(K2  )        
      KE( 2) = DSCL*D(K2+1)        
      KE( 3) = DSCL*D(K2+2)        
      KE( 7) = DSCL*D(K2+3)        
      KE( 8) = DSCL*D(K2+4)        
      KE( 9) = DSCL*D(K2+5)        
      KE(13) = DSCL*D(K2+6)        
      KE(14) = DSCL*D(K2+7)        
      KE(15) = DSCL*D(K2+8)        
      KE(22) = DSCR*D(K2  )        
      KE(23) = DSCR*D(K2+1)        
      KE(24) = DSCR*D(K2+2)        
      KE(28) = DSCR*D(K2+3)        
      KE(29) = DSCR*D(K2+4)        
      KE(30) = DSCR*D(K2+5)        
      KE(34) = DSCR*D(K2+6)        
      KE(35) = DSCR*D(K2+7)        
      KE(36) = DSCR*D(K2+8)        
      CALL PLA4B (KE,IECPT(NONPVT))        
C        
C     RETURN FROM FILL CODE W/ IRETRN =  90 IMPLIES G.P. A WAS IN BASIC 
C       .     .    .     .      .     = 100 IMPLIES G.P. A WAS NOT BASIC
C       .     .    .     .      .     = 140 IMPLIES THE K(NPVT,NONPVT)  
C                                       HAS BEEN COMPUTED AND INSERTED  
C                                       AND HENCE WE ARE FINISHED.      
C        
      GO TO IRETRN, (90,100,140)        
   90 K1 = 1        
      K2 = 10        
      GO TO 110        
  100 K1 = 10        
      K2 = 1        
  110 NONPVT = 3        
C        
C     IF NON-PIVOT GRID POINT IS IN BASIC COORDINATES, GO TO 120        
C        
      IF (IECPT(KB) .EQ. 0) GO TO 120        
C        
C     RECALL THAT D(K1) CONTAINS TAT*N.        
C        
      CALL GMMATD (D(K1),3,3,0, TB(1),3,3,0, D(K2))        
C        
C     AT THIS POINT D(K2) CONTAINS TAT*N*TB.        
C        
      GO TO 130        
  120 K2 = K1        
  130 ASSIGN 140 TO IRETRN        
C        
C     SET CONSTANTS NEGATIVE TO PROPERLY COMPUTE K(NPVT,NONPVT)        
C        
      DSCR = -DSCR        
      DSCL = -DSCL        
      GO TO 80        
C        
C     A TRANSFER TO STATEMENT NO. 140 IMPLIES KGGNL CALCULATIONS HAVE   
C     BEEN COMPLETED.  UPDATE ECPT ARRAY.        
C        
  140 IF (IND .EQ. 0) GO TO 150        
      ITEMP    = IECPT(2)        
      IECPT(2) = IECPT(3)        
      IECPT(3) = ITEMP        
  150 ECPT(18) = ECPT(19)        
      ECPT(19) = EPS1        
      ECPT(20) = E        
      RETURN        
      END        
