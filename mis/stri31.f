      SUBROUTINE STRI31        
C        
C     ROUTINE TO RECOVER CTRIA3 ELEMENT FORCES, STRAINS, AND STRESSES.  
C     PHASE 1.        
C        
C     WAS NAMED T3ST1D/S IN UAI CODE        
C        
C                 EST  LISTING        
C        
C        WORD     TYP       DESCRIPTION        
C     ----------------------------------------------------------------  
C     ECT:        
C         1        I   ELEMENT ID, EID        
C         2-4      I   SIL LIST, GRIDS 1,2,3        
C         5-7      R   MEMBRANE THICKNESSES T, AT GRIDS 1,2,3        
C         8        R   MATERIAL PROPERTY ORIENTAION ANGLE, THETA        
C               OR I   COORD. SYSTEM ID (SEE TM ON CTRIA3 CARD)        
C         9        I   TYPE FLAG FOR WORD 8        
C        10        R   GRID OFFSET, ZOFF        
C    EPT:        
C        11        I   MATERIAL ID FOR MEMBRANE, MID1        
C        12        R   ELEMENT THICKNESS,T (MEMBRANE, UNIFORMED)        
C        13        I   MATERIAL ID FOR BENDING, MID2        
C        14        R   MOMENT OF INERTIA FACTOR, I (BENDING)        
C        15        I   MATERIAL ID FOR TRANSVERSE SHEAR, MID3        
C        16        R   TRANSV. SHEAR CORRECTION FACTOR, TS/T        
C        17        R   NON-STRUCTURAL MASS, NSM        
C        18-19     R   STRESS FIBER DISTANCES, Z1,Z2        
C        20        I   MATERIAL ID FOR MEMBRANE-BENDING COUPLING, MID4  
C        21        R   MATERIAL ANGLE OF ROTATION, THETA        
C               OR I   COORD. SYSTEM ID (SEE MCSID ON PSHELL CARD)      
C                      (DEFAULT FOR WORD 8)        
C        22        I   TYPE FLAG FOR WORD 21 (DEFAULT FOR WORD 9)       
C        23        I   INTEGRATION ORDER FLAG        
C        24        R   STRESS ANGLE OF RATATION, THETA        
C               OR I   COORD. SYSTEM ID (SEE SCSID ON PSHELL CARD)      
C        25        I   TYPE FLAG FOR WORD 24        
C        26        R   OFFSET, ZOFF1 (DEFAULT FOR WORD 10)        
C    BGPDT:        
C        27-38   I/R   CID,X,Y,Z  FOR GRIDS 1,2,3        
C    ETT:        
C        39        I   ELEMENT TEMPERATURE        
C        
C        
C     ****************        RESIDES IN COMMON BLOCK SDR2X5 (AFTER EST)
C     PH1OUT DATA BLOCK       TOTAL NO. OF WORDS = 713        
C     ****************        
C        
C     PH1OUT( 1)    = ELID, ELEMENT ID        
C     PH1OUT( 2- 4) = SIL NUMBERS        
C     PH1OUT( 5- 7) = ARRAY IORDER        
C     PH1OUT( 8)    = TSUB0, REFERENCE TEMP.        
C     PH1OUT( 9-10) = Z1 & Z2, FIBER DISTANCES        
C     PH1OUT(11)    = ID OF THE ORIGINAL PCOMPI PROPERTY ENTRY        
C     PH1OUT(12)    = DUMMY WORD (FOR ALLIGNMENT)        
C        
C     PH1RST( 1)    = AVGTHK, AVERAGE THICKNESS        
C     PH1RST( 2)    = MOMINR, MOMENT OF INER. FACTOR        
C     PH1RST( 3-38) = 6X6 MATERIAL PROPERTY MATRIX (NO SHEAR)        
C     PH1RST(39-41) = THERMAL EXPANSION COEFFICIENTS FOR MEMBRANE       
C     PH1RST(42-44) = THERMAL EXPANSION COEFFICIENTS FOR BENDING        
C     PH1RST(45-47) = CORNER NODE THICKNESSES        
C     PH1RST(48)    = OFFSET OF ELEMENT FROM GP PLANE        
C     PH1RST(49-57) = 3X3 USER-TO-MATERIAL COORD. TRNASF. MATRIX UEM    
C     PH1RST(58-66) = 3X3 ELEM-TO-STRESS/STRAIN TRANSF. TENSOR TES      
C     PH1RST(67-93) = THREE 3X3 GLOBAL-TO-ELEM COORD. TRANSFORMATION    
C                     NODAL MATRICES TEG, ONE FOR EACH NODE        
C        
C     THE FOLLOWING IS REPEATED FOR EACH EVALUATION POINT (4 TIMES, AT  
C     THE CENTER OF THE ELEMENT AND AT 3 STANDARD TRIANGULAR POINTS).   
C     THE CHOICE OF THE FINAL STRESS/FORCE OUTPUT POINTS IS MADE AT THE 
C     SUBCASE LEVEL (PHASE 2).        
C        
C              1             ELEMENT THICKNESS AT THIS POINT        
C            2 - 5           OUT-OF-PLANE-SHEAR-FORCE/STRAIN MATRIX     
C            6 - 8           ELEMENT SHAPE FUNCTION VALUES        
C          8+1 - 8+8*NDOF    STRAIN RECOVERY MATRIX        
C        
C        
C     *****************      RESIDES IN COMMON BLOCK SDR2X6        
C     IELOUT DATA BLOCK      CONTAINS DATA FOR GPSRN        
C     *****************      (TOTAL NO OF WORDS =  77)        
C        
C              1             ELEMENT ID        
C              2             AVERAGE THICKNESS        
C        
C     THE FOLLOWING IS REPEATED FOR EACH NODE.        
C        
C         WORD  1            SIL NUMBER        
C         WORD  2-10         [TSB] FOR Z1        
C         WORD 11-19         [TSB] FOR Z2        
C         WORD 20-22         NORMAL VECTOR IN BASIC COORD. SYSTEM       
C         WORD 23-25         GRID COORDS   IN BASIC COORD. SYSTEM       
C        
C        
      LOGICAL         MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH,        
     1                SHEART,NOALFA,USERST        
      INTEGER         NPHI(100),NEST(39),SIL(3),SILO,IGPDT(4,3),ELID,   
     1                NECPT(4),MID(4),PIDO,SCSID,FLAGS,HUNMEG,ITHERM,   
     2                NAME(2),INDEX(2,3),SYSBUF,NOUT,NOGO,PREC        
      REAL            RELOUT(300),GPTH(3),BGPDT(4,3),ECPT(4),        
     1                KHEAT,HTCP,TSUB0,GSUBE,ELTEMP,Z1O,Z2O        
      REAL            PH1RST,DGPTH(3),TH,AVGTHK,GPNORM(4,3),        
     1                EPNORM(4,3),EGPDT(4,3),CENTE(3),OFFSET,ALPHA(6),  
     2                GI(36),RHO,JOG,JOK,K11,K22,ZZ(4),AIC(18),        
     3                EGNOR(4),TSS,LX,LY,EDGLEN(3),MOMINR,TS,REALI,TSI, 
     4                TEU(9),TES(9),TEB(9),TBG(9),TUS(9),TEM(9),TSB(9), 
     5                TSM(9),TUB(9),TUM(9),THETAM,THETAS,UEM(9),VEM(4), 
     6                DETERM,BDUM(3),SHPT(3),BTERMS(6),BMAT1(486),      
     7                BMATRX(162),BMTRX(36),DRKCE(33)        
      COMMON /SYSTEM/ SYSBUF,NOUT,NOGO,IDUM(51),PREC,ITHERM        
      COMMON /SDR2X5/ EST(100),        
     1                ELID,SILO(3),IORDER(3),TSUB0,Z1O,Z2O,PIDO,IDUMAL, 
     1                PH1RST(701)        
      COMMON /SDR2X6/ IELOUT(300)        
      COMMON /MATIN / MATID,INFLAG,ELTEMP,DUMMY,SINMAT,COSMAT        
      COMMON /HMTOUT/ KHEAT(7),TYPE        
      COMMON /TERMS / MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
      EQUIVALENCE     (EST( 1),NEST(1) ), (EST( 2),SIL(1)),        
     1                (EST( 5),GPTH(1) ), (EST(10),ZOFF  ),        
     2                (EST(12),ELTH    ), (EST(23),INT   ),        
     3                (EST(26),ZOFF1   ), (EST(39),TEMPEL),        
     4                (EST(27),BGPDT(1,1), IGPDT(1,1))        
      EQUIVALENCE     (NPHI( 1),ELID   ), (NPHI (27),DRKCE(1) ),        
     1                (NECPT(1),ECPT(1)), (IELOUT(1),RELOUT(1)),        
     2                (HTCP,KHEAT(4))        
      DATA    HUNMEG, ISTART / 100000000, 93 /,  EPS / 1.0E-17 /        
      DATA    NAME  / 4HTRIA , 4H3           /        
C        
C     INITIALIZE        
C        
      NNODE  = 3        
      MOMINR = 0.0        
      TS     = 0.0        
      ELTEMP = TEMPEL        
      ELID   = NEST(1)        
      Z1O    = EST(18)        
      Z2O    = EST(19)        
      PIDO   = NEST(11) - HUNMEG        
      MCSID  = NEST(21)        
      SCSID  = NEST(24)        
      FLAGS  = NEST(25)        
      USERST = SCSID.LT.0 .AND. FLAGS.EQ.1        
      NOALFA = .FALSE.        
      SHEART = .TRUE.        
      OFFSET = ZOFF        
      IF (ZOFF .EQ. 0.0) OFFSET = ZOFF1        
C        
C     START FILLING IN THE DATA BLOCKS        
C        
      IELOUT(1) = ELID        
      DO 20 I = 1,3        
      IELOUT(3+(I-1)*25) = SIL(I)        
      DO 10 J = 1,3        
      RELOUT(25*I+J-1) = BGPDT(J+1,I)        
   10 CONTINUE        
   20 CONTINUE        
C        
C     SET UP THE ELEMENT FORMULATION        
C        
      CALL T3SETS (IERR,SIL,IGPDT,ELTH,GPTH,DGPTH,EGPDT,GPNORM,EPNORM,  
     1             IORDER,TEB,TUB,CENTE,AVGTHK,LX,LY,EDGLEN,ELID)       
      IF (IERR .NE. 0) GO TO 600        
      CALL GMMATS (TEB,3,3,0, TUB,3,3,1, TEU)        
      DO 30 I = 1,3        
      SILO(I) = SIL(I)        
   30 CONTINUE        
C        
C     SET THE NUMBER OF DOF'S        
C        
      NNOD2 = NNODE*NNODE        
      NDOF  = NNODE*6        
      NPART = NDOF*NDOF        
      ND2   = NDOF*2        
      ND6   = NDOF*6        
      ND7   = NDOF*7        
      ND8   = NDOF*8        
      ND9   = NDOF*9        
C        
C     PASS THE LOCATION OF THE ELEMENT CENTER FOR TRANSFORMATIONS.      
C        
      DO 40 IEC = 2,4        
      ECPT(IEC) = CENTE(IEC-1)        
   40 CONTINUE        
C        
C     STRESS TRANSFORMATIONS        
C        
      IF (.NOT.USERST) GO TO 50        
      EST (24) = 0.0        
      NEST(25) = 0        
   50 CALL SHCSGS (*620,NEST(25),NEST(24),EST(24),NEST(25),NEST(24),    
     1             EST(24),NECPT,TUB,SCSID,THETAS,TUS)        
      CALL GMMATS (TEU,3,3,0, TUS,3,3,0, TES)        
C        
C     OBTAIN MATERIAL INFORMATION        
C        
C     SET MATERIAL FLAGS        
C     0.83333333 = 5.0/6.0        
C        
      IF (NEST(13) .NE.   0) MOMINR = EST(14)        
      IF (NEST(13) .NE.   0) TS = EST(16)        
      IF ( EST(16) .EQ. 0.0) TS = 0.83333333        
      IF (NEST(13).EQ.0 .AND. NEST(11).GT.HUNMEG) TS = 0.83333333       
C        
      MID(1) = NEST(11)        
      MID(2) = NEST(13)        
      MID(3) = NEST(15)        
      MID(4) = NEST(20)        
C        
      MEMBRN = MID(1).GT.0        
      BENDNG = MID(2).GT.0 .AND. MOMINR.GT.0.0        
      SHRFLX = MID(3).GT.0        
      MBCOUP = MID(4).GT.0        
      NORPTH = .FALSE.        
C        
C     SET UP TRANSFORMATION MATRIX FROM MATERIAL TO ELEMENT COORD. SYSTM
C        
      CALL SHCSGS (*610,NEST(9),NEST(8),NEST(8),NEST(21),NEST(20),      
     1             NEST(20),NECPT,TUB,MCSID,THETAM,TUM)        
C        
C     BRANCH ON FORMULATION TYPE, HEAT        
C        
      IF (ITHERM .NE. 0) GO TO 500        
C        
C     FETCH MATERIAL PROPERTIES        
C        
      CALL GMMATS (TEU,3,3,0, TUM,3,3,0, TEM)        
      CALL GMMATS (TES,3,3,1, TEM,3,3,0, TSM)        
      CALL SHGMGS (*630,ELID,TSM,MID,TS,NOALFA,GI,RHO,GSUBE,TSUB0,      
     1             EGNOR,ALPHA)        
C        
C     TURN OFF THE COUPLING FLAG WHEN MID4 IS PRESENT WITH ALL        
C     CALCULATED ZERO TERMS.        
C        
      IF (.NOT.MBCOUP) GO TO 70        
      DO 60 I = 28,36        
      IF (ABS(GI(I)) .GT. EPS) GO TO 70        
   60 CONTINUE        
      MBCOUP = .FALSE.        
   70 CONTINUE        
C        
C     CONTINUE FILLING IN THE DATA BLOCKS        
C        
      PH1RST( 1) = AVGTHK        
      PH1RST( 2) = MOMINR        
      PH1RST(48) = OFFSET        
      RELOUT( 2) = AVGTHK        
C        
C     PUT NORMALS IN IELOUT, GRID THICKNESS IN PH1OUT        
C        
      DO 80 I = 1,NNODE        
      IO  = IORDER(I)        
      IOP = (IO-1)*25 + 21        
      RELOUT(IOP+1) = GPNORM(2,I)        
      RELOUT(IOP+2) = GPNORM(3,I)        
      RELOUT(IOP+3) = GPNORM(4,I)        
      PH1RST(44+IO) = DGPTH(I)        
   80 CONTINUE        
C        
C     CALCULATE [TSB] AND STORE IT IN IELOUT.        
C        
      CALL GMMATS (TES,3,3,1, TEB,3,3,0, TSB)        
      ND25 = NNODE*25        
      DO 100 IP2 = 3,ND25,25        
      DO 90 IX = 1,9        
      RELOUT(IP2+IX  ) = TSB(IX)        
      RELOUT(IP2+IX+9) = TSB(IX)        
   90 CONTINUE        
  100 CONTINUE        
C        
C     STORE ALPHA IN PH1RST(39-44)        
C        
      DO 110 IALF = 1,6        
      PH1RST(38+IALF) = ALPHA(IALF)        
  110 CONTINUE        
C        
C     STORE UEM IN PH1RST(49-57)        
C     STORE TES IN PH1RST(58-66)        
C        
      CALL SHSTTS (TEM,UEM,VEM)        
      DO 120 LL = 1,9        
      PH1RST(48+LL) = UEM(LL)        
      PH1RST(57+LL) = TES(LL)        
  120 CONTINUE        
C        
C     STORE THE 6X6 [G] IN PH1RST        
C        
      DO 130 IG = 3,38        
      PH1RST(IG) = 0.0        
  130 CONTINUE        
C        
      IF (.NOT.MEMBRN) GO TO 160        
      DO 150 IG = 1,3        
      IG1 = (IG-1)*6 + 2        
      IG2 = (IG-1)*3        
      DO 140 JG = 1,3        
      PH1RST(IG1+JG) = GI(IG2+JG)        
  140 CONTINUE        
  150 CONTINUE        
C        
  160 IF (.NOT.BENDNG) GO TO 210        
      DO 180 IG = 1,3        
      IG1 = (IG-1)*6 + 23        
      IG2 = (IG-1)*3 +  9        
      DO 170 JG = 1,3        
      PH1RST(IG1+JG) = GI(IG2+JG)*MOMINR        
  170 CONTINUE        
  180 CONTINUE        
C        
      IF (.NOT.MBCOUP) GO TO 210        
      DO 200 IG = 1,3        
      IG3 = (IG-1)*3        
      IG1 =  IG3 +  5        
      IG2 =  IG3 + 27        
      IG3 =  IG3 + 20        
      DO 190 JG = 1,3        
      PH1RST(IG1+JG) = GI(IG2+JG)        
      PH1RST(IG3+JG) = GI(IG2+JG)        
  190 CONTINUE        
  200 CONTINUE        
  210 CONTINUE        
C        
C     CALCULATE [TEG] FOR EACH NODE AND STORE IT IN PH1RST        
C        
      DO 220 I = 1,NNODE        
      IP = 67 + (I-1)*9        
      CALL TRANSS (IGPDT(1,I),TBG)        
      CALL GMMATS (TEB,3,3,0, TBG,3,3,0, PH1RST(IP))        
  220 CONTINUE        
C        
C     GET THE GEOMETRY CORRECTION TERMS        
C        
      IF (.NOT.BENDNG) GO TO 230        
      CALL T3GEMS (IERR,EGPDT,IORDER,GI(10),GI(19),LX,LY,EDGLEN,SHRFLX, 
     1             AIC,JOG,JOK,K11,K22)        
      IF (IERR .NE. 0) GO TO 600        
C        
C     REDUCED INTEGRATION        
C        
  230 IF (INT .NE. 0) GO TO 260        
C        
C     DETERMINE THE AVERAGE [B] FOR OUT-OF-PLANE SHEAR        
C        
      DO 240 IPT = 1,3        
      KPT = (IPT-1)*ND9 + 1        
      CALL T3BMGS (IERR,SHEART,IPT,IORDER,EGPDT,DGPTH,AIC,TH,DETJAC,    
     1             SHPT,BTERMS,BMAT1(KPT))        
      IF (IERR .NE. 0) GO TO 600        
  240 CONTINUE        
C        
      DO 250 I = 1,NDOF        
      BMTRX(I     ) = BMAT1(I+ND6) +BMAT1(I+ND6+ND9) +BMAT1(I+ND6+2*ND9)
      BMTRX(I+NDOF) = BMAT1(I+ND7) +BMAT1(I+ND7+ND9) +BMAT1(I+ND7+2*ND9)
  250 CONTINUE        
C        
C     STRAIN/STRESS EVALUATION LOOP        
C        
C     PRESET THE PH1RST COUNTER TO THE START OF THE REPEATED SECTION    
C     WHICH WILL NOW BE FILLED.        
C        
  260 ICOUNT =  ISTART        
C        
      DO 400 IPT = 4,7        
C        
      CALL T3BMGS (IERR,SHEART,IPT,IORDER,EGPDT,DGPTH,AIC,TH,DETJAC,    
     1             SHPT,BTERMS,BMATRX)        
      IF (IERR .NE. 0) GO TO 600        
C        
      IF (INT .NE. 0) GO TO 310        
      DO 300 IX = 1,NDOF        
      BMATRX(IX+ND6) = BMTRX(IX     )        
      BMATRX(IX+ND7) = BMTRX(IX+NDOF)        
  300 CONTINUE        
C        
C     FINISH FILLING IN THE DATA BLOCKS        
C        
C     STORE THICKNESS        
C        
  310 PH1RST(ICOUNT+1) = TH        
C        
C     STORE [G3]        
C        
      IF (.NOT.BENDNG) GO TO 330        
      REALI = MOMINR*TH*TH*TH/12.0        
      TSI   = TS*TH        
      TSS   = 1.0/(2.0*12.0*REALI)        
C        
      ZZ(1) = (JOG/TSI)* GI(22) + TSS*JOK*K22        
      ZZ(2) =-(JOG/TSI)*(GI(20) + GI(21))/2.0        
      ZZ(3) = ZZ(2)        
      ZZ(4) = (JOG/TSI)* GI(19) + TSS*JOK*K11        
C        
      CALL INVERS (2,ZZ,2,BDUM,0,DETERM,ISING,INDEX)        
      IF (ISING .NE. 1) GO TO 600        
C        
      DO 320 IG = 1,4        
      PH1RST(ICOUNT+1+IG) = ZZ(IG)        
  320 CONTINUE        
      GO TO 350        
C        
  330 DO 340 IG = 1,4        
      PH1RST(ICOUNT+1+IG) = 0.0        
  340 CONTINUE        
C        
C     STORE SHAPE FUNCTION VALUES        
C        
  350 DO 360 I = 1,NNODE        
      PH1RST(ICOUNT+5+I) = SHPT(I)        
  360 CONTINUE        
C        
C     STORE THE STRAIN RECOVERY MATRIX        
C        
      DO 370 IPH = 1,ND8        
      PH1RST(ICOUNT+8+IPH) = BMATRX(IPH)        
  370 CONTINUE        
C        
C     END OF THE EVALUATION LOOP        
C        
C     INCREMENT THE PH1RST COUNTER        
C        
      ICOUNT = ICOUNT + 8 + 8*NDOF        
C        
  400 CONTINUE        
      GO TO 700        
C        
C        
C     BEGINNING OF HEAT FORCE RECOVERY        
C        
  500 CONTINUE        
C        
C     SET UP FOR THE UNIVERSAL PHASE 2 HEAT RECOVERY        
C        
      NPHI(22) = 2        
      NPHI(23) = NNODE        
      NPHI(24) = NAME(1)        
      NPHI(25) = NAME(2)        
C        
      SHEART = .FALSE.        
      IPT = 4        
      CALL T3BMGS (IERR,SHEART,IPT,IORDER,EGPDT,DGPTH,AIC,TH,DETJAC,    
     1             SHPT,BTERMS,BMATRX)        
      IF (IERR .NE. 0) GO TO 600        
C        
      MATID  = NEST(11)        
      INFLAG = 2        
      THETAS = THETAS - THETAM        
      SINMAT = SIN(THETAS)        
      COSMAT = COS(THETAS)        
      CALL HMAT (ELID)        
C        
      DRKCE(1) = KHEAT(1)        
      DRKCE(2) = KHEAT(2)        
      DRKCE(3) = KHEAT(2)        
      DRKCE(4) = KHEAT(3)        
C        
      TES(3) = TES(4)        
      TES(4) = TES(5)        
      CALL GMMATS (TES,2,2,1, BTERMS,2,NNODE,0, DRKCE(10))        
C        
      GO TO 700        
C        
C        
C     FATAL ERRORS        
C        
C     CTRIA3 ELEMENT HAS ILLEGAL GEOMETRY OR CONNECTIONS        
C        
  600 J = 224        
      GO TO 640        
C        
C     THE X-AXIS OF THE MATERIAL COORDINATE SYSTEM HAS NO PROJECTION    
C     ON THE PLANE OF THE CTRIA3 ELEMENT        
C        
  610 J = 225        
      NEST(2) = MCSID        
      GO TO 640        
C        
C     THE X-AXIS OF THE STRESS COORDINATE SYSTEM ID HAS NO PROJECTION   
C     ON THE PLANE OF THE CTRIA3 ELEMENT        
C        
  620 J = 227        
      NEST(2) = SCSID        
      GO TO 640        
C        
C     ILLEGAL DATA DETECTED ON MATERIAL ID REFERENCED BY CTRIA3 ELEMENT 
C     FOR MID3 APPLICATION        
C        
  630 J = 226        
      NEST(2) = MID(3)        
C        
  640 CALL MESAGE (30,J,NEST(1))        
      NOGO = 1        
C        
  700 CONTINUE        
      RETURN        
      END        
