      SUBROUTINE XPARAM        
C        
C     THE PURPOSE OF XPARAM IS TO GENERATE THE PARAMETER SECTION OF AN  
C     OSCAR ENTRY,AND TO GENERATE THE VPS TABLE.        
C        
C          ... DESCRIPTION OF PROGRAM VARIABLES ...        
C     ITMP   = TEMPORARY STORAGE FOR PARAMETER NAME AND VALUE.        
C     IPVAL  = HIGHEST PRIORITY NOMINAL VALUE IN ITMP.        
C     IPRVOP = PREVIOUS OPERATOR OR OPERAND RECEIVED FROM DMAP.        
C     INDEX  = TABLE CONTAINING ROW INDEXES FOR ISYNTX TABLE.        
C     ISYNTX = SYNTAX TABLE USED TO PROCESS DMAP PARAMETER LIST.        
C     NVSTBL = NOMINAL VALUE SOURCE TABLE.        
C     NOSPNT = POINTER TO PARAMETER COUNT IN PARAMETER SECTION OF OSCAR.
C     IOSPNT = POINTER TO NEXT AVAILABLE WORD IN OSCAR.        
C     ENDCRD = END OF CARD FLAG        
C     MPLLN  = LENGTH(IN WORDS) OF MPL PARAMETER VALUE        
C     ITYPE  = TABLE FOR TRANSLATING NUMBER TYPE CODES TO WORD LENGTH.  
C     ENDCRD = FLAG INDICATING END OF CARD SENSED.        
C        
C     RETURN CODES FROM XSCNDM        
C        
C        1  DELIMITOR        
C        2  BCD        
C        3  VALUE        
C        4  END OF CARD        
C        5  ERROR ENCOUNTERED        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF        
      DIMENSION       ITMP(7),INDEX(2,2),ISYNTX(4,5),NVSTBL(4,4),       
     1                ITYPE(6),OSCAR(1),OS(5)        
      COMMON /SYSTEM/ BUFSZ,OPTAPE,NOGO        
      COMMON /XGPIC / ICOLD,ISLSH,IEQUL,NBLANK,NXEQUI,        
     1                NDIAG,NSOL,NDMAP,NESTM1,NESTM2,NEXIT,        
     2                NBEGIN,NEND,NJUMP,NCOND,NREPT,NTIME,NSAVE,NOUTPT, 
     3                NCHKPT,NPURGE,NEQUIV,        
     4                NCPW,NBPC,NWPC,        
     5                MASKHI,MASKLO,ISGNON,NOSGN,IALLON,MASKS(1)        
      COMMON /XGPID / XXGPID(8),MODFLG        
CZZ   COMMON /ZZXGPI/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /XGPI2 / LMPL,MPLPNT,MPL(1)        
      COMMON /XGPI3 / PVT(2)        
      COMMON /XGPI4 / IRTURN,INSERT,ISEQN,DMPCNT,        
     1                IDMPNT,DMPPNT,BCDCNT,LENGTH,ICRDTP,ICHAR,NEWCRD,  
     2                MODIDX,LDMAP,ISAVDW,DMAP(1)        
      COMMON /XVPS  / VPS(2)        
      COMMON /AUTOSM/ NWORDS,SAVNAM(100)        
      EQUIVALENCE     (CORE(1),OS(1),LOSCAR),(OS(2),OSPRC),        
     1                (OS(3),OSBOT),(OS(4),OSPNT),(OS(5),OSCAR(1))      
C        
      DATA   INDEX  / 1,3,2,4/,        
     1       ISYNTX / 3*1,8,3*2,7,3*3,5,4*4,4*6/,        
     2       NVSTBL / 1,1,3,3,1,1,4,4,1,1,4,4,1,2,4,2/,        
     3       ITYPE  / 1,1,2,2,2,4/,        
     4       IC  /4HC   /,  IV/4HV   /,  IY   /4HY   /,  IN/4HN   /,    
     5       NVPS/4HVPS /,  IS/4HS   /,  IASTK/4H*   /,        
     6       NAME/1 /, IVAL/2/, NONE/1/, IMPL/2/, IDMAP/3/, IPVT/4/     
C        
C     INITIALIZE        
C        
      OR (I,J) = ORF(I,J)        
      AND(I,J) = ANDF(I,J)        
      ENDCRD = 0        
      IPRVOP = ISLSH        
      NOSPNT = OSCAR(OSPNT) + OSPNT        
      IOSPNT = NOSPNT + 1        
      OSCAR(NOSPNT) = 0        
      MPLBOT = MPL(MPLPNT-7) + MPLPNT - 7        
C        
C     GET FIRST/NEXT TYPE AND MODIFY CODES FROM DMAP,CHECK FOR $        
C        
   10 NEWTYP = 0        
      ISAVE  = 0        
   15 CALL XSCNDM        
      GO TO (600,20,601,410,570), IRTURN        
   20 IF (DMAP(DMPPNT) .EQ. NBLANK) GO TO 15        
      OSCAR(NOSPNT) = 1 + OSCAR(NOSPNT)        
      J = DMAP(DMPPNT)        
      IF (J.NE.IC .AND. J.NE.IV .AND. J.NE.IS) GO TO 602        
      IF (J .EQ. IS) ISAVE = 1        
      I = 1        
      IF (J .EQ.IC) I = 2        
      CALL XSCNDM        
      GO TO (470,30,470,470,570), IRTURN        
   30 K = DMAP(DMPPNT)        
      IF (K.NE.IY .AND. K.NE.IN) GO TO 470        
      J = 1        
      IF (K.EQ.IN .OR. K.EQ.IS) J = 2        
C        
C     USE I AND J TO OBTAIN ROW INDEX FOR SYNTAX TABLE.        
C        
   75 I = INDEX(I,J)        
C        
C     INITIALIZE IPVAL,AND ITMP WITH MPL DATA        
C        
      IF (MPLPNT .GE. MPLBOT) GO TO 580        
      DO 40 K = 1,7        
   40 ITMP(K) = 0        
      ITMP(3) = IABS(MPL(MPLPNT))        
C        
C     CONVERT PARAMETER TYPE CODE TO WORD LENGTH        
C        
      K = ITMP(3)        
      MPLLN = ITYPE(K)        
      IPVAL = NONE        
      IF (MPL(MPLPNT) .LT. 0) GO TO 60        
      DO 50 K = 1,MPLLN        
      MPLPNT = MPLPNT + 1        
   50 ITMP(K+3) = MPL(MPLPNT)        
      IPVAL  = IMPL        
   60 MPLPNT = MPLPNT + 1        
      IF (NEWTYP .EQ. 1) GO TO (620,100,110,120,570), IRTURN        
C        
C     SCAN DMAP FOR PARAMETER NAME AND VALUE IF ANY, AND CODE DMAP ENTRY
C     FOR USE AS COLUMN INDEX IN SYNTAX TABLE.        
C        
   70 CALL XSCNDM        
      GO TO (90,100,110,120,570), IRTURN        
   90 IF (DMAP(DMPPNT+1).NE.IEQUL .AND. DMAP(DMPPNT+1).NE.ISLSH .AND.   
     1    DMAP(DMPPNT+1).NE.IASTK) GO TO 470        
      IF (DMAP(DMPPNT+1) .EQ. IASTK) GO TO 70        
      J = 2        
      IF (DMAP(DMPPNT+1).EQ.ISLSH) J = 4        
      GO TO 130        
  100 J = 1        
C        
C     CHECK FOR BLANK        
C        
      IF (DMAP(DMPPNT) .EQ. NBLANK) GO TO 70        
      GO TO 130        
  110 J = 3        
      GO TO 130        
  120 J = 5        
C        
C     BRANCH ON SYNTAX TABLE VALUE        
C        
  130 K = ISYNTX(I,J)        
      GO TO (140,180,210,280,200,290,470,190), K        
C        
C     NAME FOUND. NAME TO TEMP,UPDATE PREVOP AND SEARCH PVT FOR VALUE.  
C        
  140 IF (IPRVOP .EQ. IEQUL) GO TO 190        
      IF (IPRVOP .NE. ISLSH) GO TO 470        
      ITMP(1) = DMAP(DMPPNT  )        
      ITMP(2) = DMAP(DMPPNT+1)        
      IPRVOP  = NAME        
C        
C     SCAN PVT        
      K = 3        
  150 L = ANDF(PVT(K+2),NOSGN)        
      L = ITYPE(L)        
      IF (DMAP(DMPPNT).EQ.PVT(K) .AND. DMAP(DMPPNT+1).EQ.PVT(K+1))      
     1    GO TO 160        
      K = K + 3 + L        
      IF (K-PVT(2)) 150,70,70        
C        
C     CHECK LENGTH OF PVT VALUE        
C        
  160 IPVAL = IPVT        
      PVT(K+2) = ORF(PVT(K+2),ISGNON)        
      IF (ANDF(PVT(K+2),NOSGN) .NE. ITMP(3)) GO TO 490        
C        
C     TRANSFER VALUE TO ITMP        
C        
      DO 170 M = 1,L        
      J = K + M + 2        
  170 ITMP(M+3) = PVT(J)        
      GO TO 70        
C        
C     DMAP ENTRY IS = OPERATOR        
C        
  180 IF (IPRVOP .NE. NAME) GO TO 470        
      IPRVOP = IEQUL        
      GO TO 70        
C        
C     BCD PARAMETER VALUE FOUND        
C        
  190 IF (ITMP(3) .NE. 3) GO TO 500        
      LENGTH = 2        
      DMPPNT = DMPPNT - 1        
      DMAP(DMPPNT) = ITMP(3)        
      GO TO 220        
C        
C     DMAP ENTRY IS BINARY VALUE        
C        
  200 IF (IPRVOP .EQ. ISLSH) GO TO 220        
  210 IF (IPRVOP .NE. IEQUL) GO TO 470        
  220 IPRVOP = IVAL        
      IF (IPVAL .EQ. IPVT) GO TO 70        
C        
C     DMAP VALUE IS HIGHEST PRIORITY        
C        
      IPVAL = IDMAP        
      IF (ANDF(DMAP(DMPPNT),NOSGN) .NE. ITMP(3)) GO TO 500        
C        
C TRANSFER DMAP VALUE TO ITMP        
C        
      DO 270 M = 1,LENGTH        
      J = DMPPNT + M        
  270 ITMP(M+3) = DMAP(J)        
      GO TO 70        
C        
C     DMAP ENTRY IS / OPERATOR        
C        
  280 IF (IPRVOP .EQ. IEQUL) GO TO 470        
      IPRVOP = ISLSH        
      GO TO 300        
C        
C     END OF DMAP INSTRUCTION        
C        
  290 IF (IPRVOP .EQ. IEQUL) GO TO 470        
C        
C     PARAMETER SCANNED,CHECK CORRECTNESS OF NAME AND VALUE AND        
C     PROCESS ITMP ACCORDING TO NVSTBL        
C        
  300 IF (I.LT.4 .AND. ITMP(1).EQ.0) GO TO 510        
      K = NVSTBL(I,IPVAL)        
C        
      GO TO (310,520,530,390), K        
C        
C     VARIABLE PARAMETER,VALUE TO VPS,POINTER TO OSCAR        
C        
  310 K = 3        
  320 IF (ITMP(1).EQ.VPS(K) .AND. ITMP(2).EQ.VPS(K+1)) GO TO 330        
      K = K + AND(VPS(K+2),MASKHI) + 3        
      IF (K-VPS(2)) 320,350,350        
C        
C     PARAMETER IS ALREADY IN VPS - MAKE SURE TYPES AGREE.        
C        
  330 L = ANDF(RSHIFT(VPS(K+2),16),15)        
      IF (L .EQ. 0) GO TO 335        
      IF (L .NE. ANDF(ITMP(3),15)) GO TO 555        
C        
C     CHECK VALUE MODIFIED FLAG        
C        
  335 IF (ANDF(MODFLG,VPS(K+2)) .EQ. 0) GO TO 340        
C        
C     VALUE HAS BEEN MODIFIED FOR RESTART - DO NOT CHANGE.        
C        
      GO TO 380        
C        
C     CHECK IF PREVIOUSLY DEFINED        
C        
  340 IF (VPS(K+2) .LT. 0) GO TO 540        
      GO TO 360        
C        
C     NAME NOT IN VPS,MAKE NEW ENTRY        
C        
  350 K = VPS(2) + 1        
      VPS(2) = K + 2 + MPLLN        
      IF (VPS(2)-VPS(1)) 360,360,560        
C        
C     ITMP NAME,LENGTH,FLAG,VALUE TO VPS        
C        
  360 L = MPLLN + 3        
      DO 370 M = 1,L        
      J = K + M - 1        
  370 VPS(J  ) = ITMP(M)        
      VPS(K+2) = OR(MPLLN,LSHIFT(ITMP(3),16))        
      IF (IPVAL .EQ. IDMAP) VPS(K+2) = OR(VPS(K+2),ISGNON)        
C        
C     LOCATION OF VALUE IN VPS TO OSCAR        
C        
  380 OSCAR(IOSPNT) = K + 3        
      IF (ISAVE .NE. 1) GO TO 385        
      NWORDS = NWORDS + 1        
      SAVNAM(NWORDS) = K+3        
  385 CONTINUE        
      OSCAR(IOSPNT) = OR(OSCAR(IOSPNT),ISGNON)        
      IOSPNT = IOSPNT + 1        
      GO TO 10        
C        
C     CONSTANT PARAMETER,VALUE TO OSCAR        
C        
  390 OSCAR(IOSPNT) = MPLLN        
      DO 400 M = 1,MPLLN        
      J = IOSPNT + M        
  400 OSCAR(J) = ITMP(M+3)        
      IOSPNT = IOSPNT + MPLLN + 1        
      GO TO 10        
C        
C     PROCESS ANY INTEGER, REAL, OR COMPLEX CONSTANTS        
C        
  601 I = 2        
      J = 2        
      NEWTYP = 1        
      OSCAR(NOSPNT) = OSCAR(NOSPNT) + 1        
      GO TO 75        
C        
C     PROCESS POSSIBLE DELIMITERS - SLASH AND ASTERISK        
C        
  600 IF (DMAP(DMPPNT+1) .NE. IASTK) GO TO 610        
      CALL XSCNDM        
      GO TO (470,605,470,410,570), IRTURN        
  605 I = 2        
      J = 2        
      NEWTYP = 1        
      OSCAR(NOSPNT) = OSCAR(NOSPNT) + 1        
      GO TO 75        
C        
C     PROCESS MPL DEFAULTS IF // IS ENCOUNTERED        
C        
  610 IF (DMAP(DMPPNT+1) .NE. ISLSH) GO TO 470        
      I = 2        
      J = 2        
      NEWTYP = 1        
      OSCAR(NOSPNT) = OSCAR(NOSPNT) + 1        
      GO TO 75        
C        
C     USE DEFAULT MPL VALUE FOR PARAMETER        
C        
  620 IF (IPVAL .EQ. NONE) GO TO 470        
      OSCAR(IOSPNT) = MPLLN        
      DO 625 M = 1,MPLLN        
      J = IOSPNT + M        
  625 OSCAR(J) = ITMP(M+3)        
      IOSPNT = IOSPNT + MPLLN + 1        
      GO TO 10        
C        
C     PROCESS V,N,NAME PARAMETER TYPES AS /NAME/        
C        
  602 I = 1        
      J = 2        
      NEWTYP = 1        
      GO TO 75        
C        
C     ALL PARAMETERS ON DMAP CARD PROCESSED,PROCESS ANY REMAINING ON    
C     MPL        
C        
  410 IF (MPLPNT .GE. MPLBOT) GO TO 450        
      ENDCRD = 1        
      LENGTH = IABS(MPL(MPLPNT))        
      LENGTH = ITYPE(LENGTH)        
      OSCAR(NOSPNT) = 1 + OSCAR(NOSPNT)        
      IF (MPL(MPLPNT)) 530,480,420        
  420 OSCAR(IOSPNT) = LENGTH        
      DO 430 M = 1,LENGTH        
      J = IOSPNT + M        
      MPLPNT = MPLPNT + 1        
  430 OSCAR(J) = MPL(MPLPNT)        
  440 MPLPNT = MPLPNT + 1        
      IOSPNT = IOSPNT + LENGTH + 1        
      GO TO 410        
C        
C     RETURN TO XOSGEN        
C        
  450 OSCAR(OSPNT) = IOSPNT - OSPNT        
      IRTURN = 1        
  460 RETURN        
C        
C     ERROR MESSAGES -        
C        
C     DMAP CARD FORMAT ERROR        
C        
  470 CALL XGPIDG (3,OSPNT,OSCAR(NOSPNT),0)        
      GO TO 450        
C        
C     MPL PARAMETER ERROR        
C        
  480 CALL XGPIDG (4,OSPNT,OSCAR(NOSPNT),0)        
      GO TO 450        
C        
C     PARA CARD ERROR        
C        
  490 CALL XGPIDG (5,0,ITMP(1),ITMP(2))        
      GO TO 70        
C        
C     ILLEGAL DMAP PARAMETER VALUE        
C        
  500 CALL XGPIDG (6,OSPNT,OSCAR(NOSPNT),0)        
      GO TO 70        
C        
C     DMAP PARAMETER NAME MISSING        
C        
  510 CALL XGPIDG (7,OSPNT,OSCAR(NOSPNT),0)        
      GO TO 390        
C        
C     ILLEGAL PARA CARD        
C        
  520 CALL XGPIDG (8,0,ITMP(1),ITMP(2))        
      IF (I-2) 310,310,390        
C        
C     CONSTANT PARAMETER NOT DEFINED        
C        
  530 CALL XGPIDG (9,OSPNT,OSCAR(NOSPNT),0)        
      IF (ENDCRD .EQ. 1) GO TO 440        
      GO TO 390        
C        
C     WARNING - PARAMETER ALREADY HAD VALUE ASSIGNED PREVIOUSLY        
C        
  540 IF (IPVAL .NE. IDMAP) GO TO 550        
      CALL XGPIDG (-42,OSPNT,ITMP(1),ITMP(2))        
  550 IF (AND(RSHIFT(VPS(K+2),16),15) .EQ. AND(ITMP(3),15)) GO TO 380   
C        
C     INCONSISTENT LENGTH USED FOR VARIABLE PARAMETER.        
C        
  555 CALL XGPIDG (15,OSPNT,ITMP(1),ITMP(2))        
      GO TO 380        
C        
C     VPS TABLE OVERFLOW        
C        
  560 CALL XGPIDG (14,NVPS,NBLANK,DMPCNT)        
  570 NOGO   = 2        
      IRTURN = 2        
      GO TO 460        
C        
C     TOO MANY PARAMETERS IN DMAP PARAMETER LIST.        
C        
  580 CALL XGPIDG (18,OSPNT,0,0)        
      GO TO 450        
      END        
