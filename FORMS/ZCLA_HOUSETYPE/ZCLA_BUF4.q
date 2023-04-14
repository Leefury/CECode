/* ***********************
Points calc by HouseType
*********************** */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_HOUSETYPE/ZCLA_BUF4' FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
Reset Modifiers */
UPDATE ZCLA_HOUSETYPEFIX
SET ZCLA_INITPOINTS = 0
,   ZCLA_TRAVEL = 0
,   ZCLA_MILEAGE = 0
,   ZCLA_PARTSUM = 0
,   ZCLA_SUNDRY = 0
WHERE 0=0
AND   HOUSETYPEID = :HOUSETYPE ;
/*
*/
:FIXID = 0 ;
:CASHVALUE = :POINTS = 0.0 ;
/*
Get Travel Constants */
:SAFETYMARGIN = :FULLPOINTS = :TRAVELCOST = 0.0 ;
#INCLUDE ZCLA_TRAVELCONST/ZCLA_BUF1
SELECT :SAFETYMARGIN , :ZCLA_MILESTOSITE , :ZCLA_TIMETOSITE
, :MILEAGE , :TRAVELCOST , :FULLPOINTS
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
Build the BoM */
#INCLUDE PARTARC/ZCLA_HTREPLACE
/*
*/
DECLARE @INIT CURSOR FOR
SELECT ZCLA_PARTPOINTSPF.FIXID
,      SUM ( ( ZCLA_PARTPOINTSPF.VALUE + (ZCLA_FIXES.FIX = '3' ?
ZCLA_ACCYCOL.POINTS : 0) ) * ZCLA_COMPONENT.TQUANT ) / 1000 AS
POINTS
,   MIN(ZCLA_FIXES.CASHVALUE / 100)
FROM  ZCLA_ACCYCOL , ZCLA_PARTPOINTSPF , ZCLA_ROOMS , ZCLA_COMPONENT
, ZCLA_HOUSETYPE , ZCLA_FIXES
WHERE 0=0
AND   ZCLA_FIXES.FIXID = ZCLA_PARTPOINTSPF.FIXID
AND   ZCLA_ROOMS.ROOM = ZCLA_COMPONENT.ROOM
AND   ZCLA_ROOMS.HOUSETYPEID = ZCLA_HOUSETYPE.HOUSETYPEID
AND   ZCLA_PARTPOINTSPF.PART = ZCLA_COMPONENT.PART
AND   ZCLA_ACCYCOL.COL = ZCLA_COMPONENT.COL
AND   ZCLA_HOUSETYPE.HOUSETYPEID = :HOUSETYPE
GROUP BY ZCLA_PARTPOINTSPF.FIXID
;
OPEN @INIT ;
GOTO 2203239 WHERE :RETVAL = 0 ;
LABEL 2203235;
FETCH @INIT INTO :FIXID , :POINTS , :CASHVALUE ;
GOTO 2203236 WHERE :RETVAL = 0;
/*
Update Fix */
SELECT :FIXID , :POINTS , :CASHVALUE FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
:SUNDRYSUM = :PARTSUM = 0.0 ;
/*
*/
SELECT SUM(SONQUANT * PRICE) INTO :PARTSUM
FROM ZCLA_PARTARC , PRICELIST , PARTPRICE
WHERE 0=0
AND   ZCLA_PARTARC.USER = SQL.USER
AND   ZCLA_PARTARC.SON = PARTPRICE.PART
AND   PRICELIST.PLIST = PARTPRICE.PLIST
AND   PRICELIST.CURRENCY  = PARTPRICE.CURRENCY
AND   PRICELIST.PLIST = -1
AND   PARTPRICE.CURRENCY = -1
AND   QUANT = 1000
AND   ZCLA_PARTARC.ZCLA_FIXID = :FIXID
;
/*
*/
SELECT SUM(ZCLA_PARTARC.SONQUANT * PARTARC.SONQUANT *
PARTPRICE.PRICE) INTO :SUNDRYSUM
FROM  ZCLA_PARTARC ,  PARTARC ,  PARTPRICE ,  PRICELIST
WHERE 0=0
AND   ZCLA_PARTARC.SON = PARTARC.PART
AND   PARTARC.SON = PARTPRICE.PART
AND   PARTPRICE.PLIST = PRICELIST.PLIST
AND   ZCLA_PARTARC.USER = SQL.USER
AND   PRICELIST.CURRENCY  = PARTPRICE.CURRENCY
AND   PRICELIST.PLIST = -1
AND   PARTPRICE.CURRENCY = -1
AND   QUANT = 1000
AND   ZCLA_PARTARC.ZCLA_FIXID = :FIXID
;
/*
*/
:TOTML = :TRAVEL = :UPLIFT = :ZCLA_LABOURPOINTS = 0.0 ;
SELECT  ZCLA_FIXUPLIFT , ZCLA_BRUPLIFT  ,  MOD_HT , MOD_ST
FROM ZCLA_HOUSETYPEFIX
WHERE 0=0
AND   HOUSETYPEID = :HOUSETYPE
AND   FIXID = :FIXID 
AND   :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
SELECT 1 * ZCLA_FIXUPLIFT * ZCLA_BRUPLIFT  *  MOD_HT * MOD_ST
,   :POINTS * ZCLA_FIXUPLIFT * ZCLA_BRUPLIFT  *  MOD_HT * MOD_ST
INTO :UPLIFT , :ZCLA_LABOURPOINTS 
FROM ZCLA_HOUSETYPEFIX
WHERE 0=0
AND   HOUSETYPEID = :HOUSETYPE
AND   FIXID = :FIXID ;
/*
*/
SELECT ( ( (:ZCLA_TIMETOSITE * 2) * :TRAVELCOST) * (:ZCLA_LABOURPOINTS
/ :FULLPOINTS ) )
,   ( ( (:ZCLA_MILESTOSITE * 2) * :MILEAGE ) * ( :ZCLA_LABOURPOINTS
/ :FULLPOINTS ) )
INTO :TRAVEL , :TOTML
FROM ZCLA_HOUSETYPEFIX
WHERE 0=0
AND   HOUSETYPEID = :HOUSETYPE
AND   FIXID = :FIXID ;
/*
*/
SELECT     :PARTSUM
,    :SUNDRYSUM
,    :TRAVEL
,    :MILEAGE
,    :POINTS AS ZCLA_INITPOINTS
,    :CASHVALUE
,    :ZCLA_LABOURPOINTS AS ZCLA_LABOURPOINTS
,    :UPLIFT AS ZCLA_UPLIFT
,    :TRAVEL AS ZCLA_TRAVEL
,    :TOTML AS ZCLA_MILEAGE
,    :PARTSUM  *  :SAFETYMARGIN AS ZCLA_PARTSUM
,    :SUNDRYSUM *  :SAFETYMARGIN AS ZCLA_SUNDRY
,    (( :CASHVALUE * :ZCLA_LABOURPOINTS) + :TRAVEL ) AS
ZCLA_LABTOTAL
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
/* Retrieve drill bit multiplier and
monetary value */
:DBMULT = :MONVAL = 0.00;
SELECT DRILLMULTIPLIER
INTO :DBMULT
FROM ZCLA_HTCHARS HT, ZCLA_CHARPERMITVALS CP, ZCLA_UPLIFTSPERFIX UP
WHERE HOUSETYPEID = :HOUSETYPE
AND HT.VALUEID = CP.VALUEID
AND HT.CHARID = 1
AND UP.VALUEID = CP.VALUEID
AND FIXID = :FIXID
;
SELECT MONETARYVALUE
INTO :MONVAL
FROM ZCLA_PLOTELEMENT PE, ZCLA_HOUSETYPE HT
WHERE PE.EL = HT.EL
AND HT.HOUSETYPEID = :HOUSETYPE
;
/*
*/
UPDATE ZCLA_HOUSETYPEFIX
SET ZCLA_INITPOINTS = :POINTS
,    ZCLA_LABOURPOINTS = :ZCLA_LABOURPOINTS
,    ZCLA_UPLIFT = :UPLIFT
,    ZCLA_TRAVEL = :TRAVEL
,    ZCLA_MILEAGE = :TOTML
,    ZCLA_PARTSUM = :PARTSUM  *  :SAFETYMARGIN
,    ZCLA_SUNDRY = (:SUNDRYSUM *  :SAFETYMARGIN) + (:DBMULT *
:MONVAL)
,    ZCLA_LABTOTAL = (( :CASHVALUE * :ZCLA_LABOURPOINTS) + :TRAVEL )
WHERE 0=0
AND   HOUSETYPEID = :HOUSETYPE
AND   FIXID = :FIXID ;
/*
*/
LOOP 2203235 ;
LABEL 2203236 ;
CLOSE @INIT ;
LABEL 2203239 ;
/*
*/
#INCLUDE ZCLA_HOUSETYPE/ZCLA_BUF5