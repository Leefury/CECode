/* ***********************
Points calc by Element
*********************** */
/*
Reset Modifiers */
UPDATE PROJACTS
SET ZCLA_INITPOINTS = 0
,   ZCLA_TRAVEL = 0
,   ZCLA_MILEAGE = 0
,   ZCLA_PARTSUM = 0
,   ZCLA_SUNDRY = 0
WHERE 0=0
AND PROJACT = :ELEMENT ;
/*
*/
:ZCLA_TIMETOSITE = :FIXID = 0 ;
:CASHVALUE = :SAFETYMARGIN = :POINTS = :ZCLA_MILESTOSITE =
:MILEAGE = :FULLPOINTS = :TRAVELCOST =
0.0 ;
SELECT ZCLA_MILESTOSITE , ZCLA_TIMETOSITE
INTO :ZCLA_MILESTOSITE , :ZCLA_TIMETOSITE
FROM DOCUMENTS
WHERE 0=0
AND DOCUMENTS.DOC = :DOC ;
/*
Get Travel Constants */
#INCLUDE ZCLA_TRAVELCONST/ZCLA_BUF1
/*
*/
DECLARE @INIT CURSOR FOR
SELECT ZCLA_PARTPOINTSPF.FIXID
,   SUM ( ( ZCLA_PARTPOINTSPF.VALUE + (ZCLA_FIXES.FIX = '3' ?
ZCLA_ACCYCOL.POINTS : 0) ) * ZCLA_PLOTCOMPONENT.TQUANT ) / 1000 AS
POINTS
,   ZCLA_FIXES.CASHVALUE
FROM  ZCLA_FIXES , PROJACTS , ZCLA_PARTPOINTSPF , ZCLA_ACCYCOL  
,     ZCLA_PLOTROOMS  ,  ZCLA_PLOTCOMPONENT
WHERE 0 = 0
AND   ZCLA_PLOTROOMS.ROOM = ZCLA_PLOTCOMPONENT.ROOM
AND   ZCLA_PLOTROOMS.PROJACT = ZCLA_PLOTCOMPONENT.PROJACT
AND   PROJACTS.ZCLA_FIX = ZCLA_FIXES.FIXID
AND   ZCLA_PLOTROOMS.PROJACT = PROJACTS.ZCLA_PLOT
AND   ZCLA_ACCYCOL.COL = ZCLA_PLOTROOMS.COL
AND   ZCLA_PARTPOINTSPF.PART = ZCLA_PLOTCOMPONENT.PART
AND   ZCLA_PARTPOINTSPF.FIXID = ZCLA_FIXES.FIXID
AND   PROJACTS.ZCLA_PLOT = :ELEMENT
GROUP BY 1 , 3
;
OPEN @INIT ;
GOTO 999 WHERE :RETVAL = 0 ;
LABEL 500;
FETCH @INIT INTO :FIXID , :POINTS, :CASHVALUE ;
GOTO 600 WHERE :RETVAL = 0;
/*
Build the BoM */
#INCLUDE PARTARC/ZCLA_ELEMREPLACE
:SUNDRYSUM = :PARTSUM = 0.0 ;
/*
*/
SELECT SUM(SONQUANT * PRICE) INTO :PARTSUM
FROM ZCLA_PARTARC , PRICELIST , PARTPRICE
WHERE 0=0
AND ZCLA_PARTARC.USER = SQL.USER
AND ZCLA_PARTARC.SON = PARTPRICE.PART
AND PRICELIST.PLIST = PARTPRICE.PLIST
AND PRICELIST.CURRENCY  = PARTPRICE.CURRENCY
AND PRICELIST.PLIST = -1
AND PARTPRICE.CURRENCY = -1
AND QUANT = 1000
AND ZCLA_PARTARC.ZCLA_FIXID = :FIXID
;
/*
*/
SELECT SUM(ZCLA_PARTARC.SONQUANT * PARTARC.SONQUANT *
PARTPRICE.PRICE) INTO :SUNDRYSUM
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
:TRAVEL = :MILEAGE = :UPLIFT = :ZCLA_LABOURPOINTS = 0.0 ;
SELECT 1 * ZCLA_FIXUPLIFT * ZCLA_BRUPLIFT  * ZCLA_UPLIFT * MOD_HT *
MOD_ST  * MOD_PL
,   :POINTS * ZCLA_FIXUPLIFT * ZCLA_BRUPLIFT  * ZCLA_UPLIFT * MOD_HT
* MOD_ST  * MOD_PL
,   ( ( (:ZCLA_TIMETOSITE * 2) * :TRAVELCOST) * (:ZCLA_LABOURPOINTS
/ :FULLPOINTS ) )
,   ( ( (:ZCLA_MILESTOSITE * 2) * :MILEAGE ) * ( :ZCLA_LABOURPOINTS
/ :FULLPOINTS ) )
INTO :UPLIFT , :ZCLA_LABOURPOINTS , :TRAVEL , :MILEAGE
FROM PROJACTS
WHERE 0=0
AND ZCLA_PLOT = :ELEMENT
AND ZCLA_FIX = :FIXID
;
/*
*/
UPDATE PROJACTS
SET ZCLA_INITPOINTS = :POINTS
,    ZCLA_LABOURPOINTS = :ZCLA_LABOURPOINTS
,    ZCLA_UPLIFT = :UPLIFT
,    ZCLA_TRAVEL = :TRAVEL
,    ZCLA_MILEAGE = :MILEAGE
,    ZCLA_PARTSUM = :PARTSUM  *  :SAFETYMARGIN
,    ZCLA_SUNDRY = :SUNDRYSUM *  :SAFETYMARGIN
,    ZCLA_LABTOTAL = (( :CASHVALUE * :ZCLA_LABOURPOINTS) + :TRAVEL )
WHERE 0=0
AND ZCLA_PLOT = :ELEMENT
AND ZCLA_FIX = :FIXID
;
/*
*/
LOOP 500;
LABEL 600;
CLOSE @INIT ;
LABEL 999;
