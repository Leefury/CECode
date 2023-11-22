/* ***********************
Points calc by Element
*********************** */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_ELACT/ZCLA_BUF2'
,      :ELEMENT
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
Reset Modifiers */
UPDATE PROJACTS
SET ZCLA_INITPOINTS = 0
,   ZCLA_TRAVEL = 0
,   ZCLA_MILEAGE = 0
,   ZCLA_PARTSUM = 0
,   ZCLA_SUNDRY = 0
WHERE 0=0
AND ZCLA_PLOT = :ELEMENT ;
/*
*/
:ZCLA_TIMETOSITE = 0 ;
:ZCLA_MILESTOSITE =  :SAFETYMARGIN = 
:DEFEXTRA = :MILEAGE = :FULLPOINTS = :TRAVELCOST = 0.0 ;
/*
*/
SELECT ZCLA_MILESTOSITE , ZCLA_TIMETOSITE
INTO :ZCLA_MILESTOSITE , :ZCLA_TIMETOSITE
FROM DOCUMENTS
WHERE 0=0
AND DOCUMENTS.DOC = :DOC ;
/*
Get Travel Constants */
#INCLUDE ZCLA_TRAVELCONST/ZCLA_BUF1
SELECT :SAFETYMARGIN , :ZCLA_MILESTOSITE , :ZCLA_TIMETOSITE
, :MILEAGE , :TRAVELCOST , :FULLPOINTS
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
Build the BoM */
#INCLUDE PARTARC/ZCLA_ELEMREPLACE
/*
Get the default value for extra points */
SELECT VALUE INTO :DEFEXTRA
FROM ZCLA_CONST
WHERE 0=0
AND   NAME = 'EXTRAPOINTS'
AND   TYPE = 'FIN' ;
/*
*/
DECLARE @INIT CURSOR FOR
SELECT ZCLA_PARTPOINTSPF.FIXID
,   SUM ( 
( ZCLA_PARTPOINTSPF.VALUE * REALQUANT( ZCLA_PLOTCOMPONENT.TQUANT ) ) 
+ (ZCLA_FIXES.FIX = '3' ? ZCLA_ACCYCOL.POINTS * REALQUANT( ZCLA_PLOTCOMPONENT.TQUANT ) : 0) 
+ ( ZCLA_PLOTCOMPONENT.EXTRA <> 'Y' ? 0 : ( ZCLA_PARTPOINTSPF.EVALUE > 0 ? 
ZCLA_PARTPOINTSPF.EVALUE * REALQUANT( ZCLA_PLOTCOMPONENT.TQUANT ) : :DEFEXTRA )
) ) AS POINTS 
,   MAX(ZCLA_FIXES.CASHVALUE / 100)
FROM  ZCLA_FIXES , PROJACTS , ZCLA_PARTPOINTSPF , ZCLA_ACCYCOL
,     ZCLA_PLOTROOMS  ,  ZCLA_PLOTCOMPONENT
WHERE 0 = 0
AND   ZCLA_PLOTROOMS.ROOM = ZCLA_PLOTCOMPONENT.ROOM
AND   ZCLA_PLOTROOMS.PROJACT = ZCLA_PLOTCOMPONENT.PROJACT
AND   PROJACTS.ZCLA_FIX = ZCLA_FIXES.FIXID
AND   ZCLA_PLOTROOMS.PROJACT = PROJACTS.ZCLA_PLOT
AND   ZCLA_ACCYCOL.COL = ZCLA_PLOTCOMPONENT.COL
AND   ZCLA_PARTPOINTSPF.PART = ZCLA_PLOTCOMPONENT.PART
AND   ZCLA_PARTPOINTSPF.FIXID = ZCLA_FIXES.FIXID
AND   PROJACTS.ZCLA_PLOT = :ELEMENT
AND   ZCLA_PLOTCOMPONENT.ISDELETED <> 'Y'
GROUP BY 1
;
OPEN @INIT ;
GOTO 999 WHERE :RETVAL = 0 ;
LABEL 500;
:FIXID =  0 ;
:SUNDRYSUM = :PARTSUM = :CASHVALUE = :POINTS = 0.0 ; 
FETCH @INIT INTO :FIXID , :POINTS, :CASHVALUE ;
GOTO 600 WHERE :RETVAL = 0;
/*
Add subcontract points */
SELECT :POINTS + SUM(POINT) INTO :POINTS
FROM  ZCLA_ROOMQUOTE , ZCLA_ROOMS , ZCLA_ROOMFIXES
,     PROJACTS
WHERE 0=0
AND   ZCLA_ROOMQUOTE.ROOM = ZCLA_ROOMS.ROOM
AND   ZCLA_ROOMFIXES.ROOM = ZCLA_ROOMS.ROOM
AND   ZCLA_ROOMS.HOUSETYPEID = PROJACTS.ZCLA_HOUSETYPEID
AND   PROJACT = :ELEMENT
AND   FIX = :FIXID
;
/*
Get cost price */
SELECT SUM ( ZCLA_PARTARC.SONQUANT * PARTPRICE.PRICE )
INTO :PARTSUM
FROM   ZCLA_PARTARC
,      PRICELIST  
,      PARTPRICE 
WHERE 0 = 0 
AND   PRICELIST.PLIST = PARTPRICE.PLIST 
AND   PRICELIST.CURRENCY = PARTPRICE.CURRENCY
AND   PARTPRICE.PART = ZCLA_PARTARC.SON
AND   PRICELIST.PLIST = - 1 
AND   PARTPRICE.CURRENCY = - 1 
AND   PARTPRICE.QUANT = 1000 
AND   ZCLA_PARTARC.ZCLA_FIXID = :FIXID 
AND   ZCLA_PARTARC.USER = SQL.USER 
;
/* 
Get price from pricelist 
for parts not included in a package 
TODO: Link the site pricelist */
:NOPACK = 0.0 ;
SELECT SUM 
(   ZCLA_PARTARC.SONQUANT * PARTPRICE.PRICE )
INTO :NOPACK
FROM   ZCLA_PARTARC
,      PRICELIST  
,      PARTPRICE 
WHERE 0 = 0 
AND   PRICELIST.PLIST = PARTPRICE.PLIST 
AND   PRICELIST.CURRENCY = PARTPRICE.CURRENCY
AND   PARTPRICE.PART = ZCLA_PARTARC.SON
AND   PRICELIST.PLIST = - 1 
AND   PARTPRICE.CURRENCY = - 1 
AND   PARTPRICE.QUANT = 1000 
AND   ZCLA_PARTARC.ZCLA_FIXID = :FIXID 
AND   ZCLA_PARTARC.USER = SQL.USER 
AND   ZCLA_PARTARC.EXTRA <> 'Y'
;
/*
Get Sundries */
:SUNDRYCREDIT = 0.0 ;
SELECT 1 + VALUE 
INTO :SUNDRYCREDIT
FROM ZCLA_CONST
WHERE NAME = 'SUNDRYCREDIT'
;
SELECT SUM(ZCLA_PARTARC.SONQUANT * PARTARC.SONQUANT *
PARTPRICE.PRICE) * (:SUNDRYCREDIT) INTO :SUNDRYSUM
FROM  ZCLA_PARTARC ,  PARTARC ,  PARTPRICE ,  PRICELIST
WHERE 0=0
AND ZCLA_PARTARC.SON = PARTARC.PART
AND PARTARC.SON = PARTPRICE.PART
AND PARTPRICE.PLIST = PRICELIST.PLIST
AND ZCLA_PARTARC.USER = SQL.USER
AND PRICELIST.CURRENCY  = PARTPRICE.CURRENCY
AND PRICELIST.PLIST = -1
AND PARTPRICE.CURRENCY = -1
AND QUANT = 1000
AND ZCLA_PARTARC.ZCLA_FIXID = :FIXID
;
/*
*/
:SUBCON = 0.0 ;
SELECT SUM(TOTPRICE) INTO :SUBCON 
FROM ZCLA_ROOMQUOTE
WHERE 0=0
AND   HOUSETYPEID = :HOUSETYPE
AND   FIXID = :FIXID
;
/*
*/
:MILEAGECOST = :TRAVEL = :UPLIFT = :ZCLA_LABOURPOINTS = 0.0 ;
SELECT ZCLA_FIXUPLIFT + ZCLA_BRUPLIFT
,   :POINTS * ( 1 + ( ( MOD_HT + MOD_ST + MOD_PL ) / 100 ) )
INTO :UPLIFT , :ZCLA_LABOURPOINTS
FROM PROJACTS
WHERE 0=0
AND ZCLA_PLOT = :ELEMENT
AND ZCLA_FIX = :FIXID
;
/*
*/
SELECT  ( ( (:ZCLA_TIMETOSITE * 2) * :TRAVELCOST) *
(:ZCLA_LABOURPOINTS
/ :FULLPOINTS ) )
,   ( ( (:ZCLA_MILESTOSITE * 2) * :MILEAGE ) * ( :ZCLA_LABOURPOINTS
/ :FULLPOINTS ) )
INTO :TRAVEL , :MILEAGECOST
FROM PROJACTS
WHERE 0=0
AND ZCLA_PLOT = :ELEMENT
AND ZCLA_FIX = :FIXID
;
/*
Select the HouseType BY ELEMENT */
:HTYPE = 0 ;
SELECT 0 + ZCLA_HOUSETYPEID
INTO :HTYPE
FROM PROJACTS
WHERE PROJACT = :ELEMENT
;
/* 
Retrieve drill bit multiplier and
monetary value */
:DBMULT = :MONVAL = 0.00;
SELECT DRILLMULTIPLIER
INTO :DBMULT
FROM ZCLA_HTCHARS HT, ZCLA_CHARPERMITVALS CP, ZCLA_UPLIFTSPERFIX UP
WHERE HT.HOUSETYPEID = :HTYPE
AND HT.VALUEID = CP.VALUEID
AND HT.CHARID = 1
AND UP.VALUEID = CP.VALUEID
AND FIXID = :FIXID
;
SELECT MONETARYVALUE
INTO :MONVAL
FROM ZCLA_PLOTELEMENT PE, ZCLA_HOUSETYPE HT
WHERE PE.EL = HT.EL
AND HT.HOUSETYPEID = :HTYPE
;
/*
*/
SELECT :CASHVALUE * (1 + ((ZCLA_FIXUPLIFT + ZCLA_BRUPLIFT) / 100))
,      :TRAVEL * (1 + ((ZCLA_FIXUPLIFT + ZCLA_BRUPLIFT) / 100))
INTO :CASHVALUE , :TRAVEL
FROM PROJACTS
WHERE 0=0
AND ZCLA_PLOT = :ELEMENT
AND ZCLA_FIX = :FIXID
;
/*
*/
SELECT :DBMULT , :MONVAL
FROM DUMMY
FORMAT ADDTO :DEBUGFILE
;
UPDATE PROJACTS
SET ZCLA_INITPOINTS = :POINTS
,    ZCLA_LABOURPOINTS = :ZCLA_LABOURPOINTS
,    ZCLA_POINTVAL = :CASHVALUE
,    ZCLA_UPLIFT = :UPLIFT
,    ZCLA_TRAVEL = :TRAVEL
,    ZCLA_SUNDRY = :SUNDRYSUM + (:DBMULT * :MONVAL)
,    ZCLA_SUBCON = :SUBCON 
,    ZCLA_PARTSUM = :PARTSUM + :SUNDRYSUM + (:DBMULT * :MONVAL)
,    ZCLA_LABTOTAL = (( :CASHVALUE * :ZCLA_LABOURPOINTS) + :TRAVEL ) 
,    ZCLA_MILEAGE = :MILEAGECOST
,    ZCLA_TOTCOST = :PARTSUM + :SUNDRYSUM + (:DBMULT * :MONVAL)
+                   ((( :CASHVALUE * :ZCLA_LABOURPOINTS) + :TRAVEL ) * :SAFETYMARGIN )
+                    :MILEAGECOST
+                   ZCLA_SUBCON
WHERE 0=0
AND ZCLA_PLOT = :ELEMENT
AND ZCLA_FIX = :FIXID ;
/*
Only update the NOPACK value 
when the contract is not locked */
GOTO 400 WHERE EXISTS (
SELECT 'x'
FROM   ZCLA_CONTRACTS
,      ZCLA_CONTRACTEL 
,      ZCLA_CONTRACTSTATUSE 
,      PROJACTS 
WHERE 0 = 0
AND   ZCLA_CONTRACTS.CONTRACT = ZCLA_CONTRACTEL.CONTRACT
AND   ZCLA_CONTRACTS.STEPSTATUS = ZCLA_CONTRACTSTATUSE.STEPSTATUS
AND   ZCLA_CONTRACTEL.EL = PROJACTS.ZCLA_EL 
AND   ZCLA_CONTRACTS.DOC = PROJACTS.DOC
AND   ZCLA_CONTRACTSTATUSE.STATLOCK = 'Y'
AND   PROJACTS.PROJACT = :ELEMENT
AND   PROJACTS.ZCLA_TOTCOST > 0
);
UPDATE PROJACTS 
SET ZCLA_NOPACK = :NOPACK + :SUNDRYSUM + (:DBMULT * :MONVAL)
+                 ((( :CASHVALUE * :ZCLA_LABOURPOINTS) + :TRAVEL ) * :SAFETYMARGIN )
+                 :MILEAGECOST
+                 ZCLA_SUBCON
WHERE 0=0
AND ZCLA_PLOT = :ELEMENT
AND ZCLA_FIX = :FIXID ;
LABEL 400 ;
/*
*/
SELECT :FIXID
,    ZCLA_INITPOINTS 
,    ZCLA_LABOURPOINTS 
,    ZCLA_POINTVAL 
,    ZCLA_UPLIFT 
,    ZCLA_TRAVEL 
,    ZCLA_SUNDRY 
,    ZCLA_SUBCON 
,    ZCLA_PARTSUM 
,    ZCLA_LABTOTAL 
,    ZCLA_MILEAGE 
,    ZCLA_TOTCOST
FROM PROJACTS
WHERE 0=0
AND   ZCLA_PLOT = :ELEMENT
AND   ZCLA_FIX = :FIXID 
AND   :DEBUG  = 1
FORMAT ADDTO :DEBUGFILE;
/*
*/
LOOP 500;
LABEL 600;
CLOSE @INIT ;
LABEL 999;

