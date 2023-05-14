/* ***********************
Points calc by Element
*********************** */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_ELACT/ZCLA_BUF2'
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
:MILEAGE = :FULLPOINTS = :TRAVELCOST = 0.0 ;
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
*/
DECLARE @INIT CURSOR FOR
SELECT ZCLA_PARTPOINTSPF.FIXID
,   SUM ( ( ZCLA_PARTPOINTSPF.VALUE + (ZCLA_FIXES.FIX = '3' ?
ZCLA_ACCYCOL.POINTS : 0) ) * ZCLA_PLOTCOMPONENT.TQUANT ) / 1000 AS
POINTS
,   MAX(ZCLA_FIXES.CASHVALUE / 100)
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
*/
SELECT :FIXID , :POINTS , :CASHVALUE
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
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
:TRAVEL = :UPLIFT = :ZCLA_LABOURPOINTS = 0.0 ;
SELECT ZCLA_FIXUPLIFT + ZCLA_BRUPLIFT + MOD_HT + MOD_ST + MOD_PL
,   :POINTS * ( 1 + ( ( ZCLA_FIXUPLIFT * ZCLA_BRUPLIFT + MOD_HT + MOD_ST + MOD_PL ) / 100 ) )
INTO :UPLIFT , :ZCLA_LABOURPOINTS
FROM PROJACTS
WHERE 0=0
AND ZCLA_PLOT = :ELEMENT
AND ZCLA_FIX = :FIXID
;
/*
*/
:MILEAGECOST = 0.0 ;
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
*/
SELECT     :PARTSUM
,    :SUNDRYSUM
,    :TRAVEL
,    :MILEAGECOST
,    :POINTS AS ZCLA_INITPOINTS
,    :CASHVALUE
,    :ZCLA_LABOURPOINTS AS ZCLA_LABOURPOINTS
,    :UPLIFT AS ZCLA_UPLIFT
,    :TRAVEL AS ZCLA_TRAVEL
,    :MILEAGECOST AS ZCLA_MILEAGE
,    :PARTSUM  AS ZCLA_PARTSUM
,    :SUNDRYSUM AS ZCLA_SUNDRY
,    (( :CASHVALUE * :ZCLA_LABOURPOINTS) + :TRAVEL ) AS
ZCLA_LABTOTAL
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
Select the HouseType BY ELEMENT */
:HTYPE = 0 ;
SELECT 0 + ZCLA_HOUSETYPEID
INTO :HTYPE
FROM PROJACTS
WHERE PROJACT = :ELEMENT
;
/* Retrieve drill bit multiplier and
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
UPDATE PROJACTS
SET ZCLA_INITPOINTS = :POINTS
,    ZCLA_LABOURPOINTS = :ZCLA_LABOURPOINTS
,    ZCLA_UPLIFT = :UPLIFT
,    ZCLA_TRAVEL = :TRAVEL
,    ZCLA_MILEAGE = :MILEAGECOST
,    ZCLA_PARTSUM = :PARTSUM 
,    ZCLA_SUNDRY = :SUNDRYSUM + (:DBMULT * :MONVAL)
,    ZCLA_LABTOTAL = (( :CASHVALUE * :ZCLA_LABOURPOINTS) + :TRAVEL ) * :SAFETYMARGIN
,    ZCLA_TOTCOST = ((( :CASHVALUE * :ZCLA_LABOURPOINTS) + :TRAVEL ) * :SAFETYMARGIN)
+                   (:PARTSUM )
+                    :TOTML
+                   (:SUNDRYSUM ) + (:DBMULT * :MONVAL)
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
/*
*/
/*
Update Housetype PRICE Totals */
/*
*/
SELECT SUM(ZCLA_TOTCOST) INTO :ZCLA_TOTCOST
FROM PROJACTS
WHERE   ZCLA_PLOT = :ELEMENT
;
DECLARE @PRICE CURSOR FOR
SELECT PROJACTS.ZCLA_FIX
,      :ZCLA_TOTCOST * (ZCLA_ELEMENTFIX.SPLIT/100) *
ZCLA_ELTYPE.MARKUP
FROM   ZCLA_ELTYPE , ZCLA_PLOTELEMENT  , ZCLA_ELEMENTFIX , PROJACTS
WHERE  0 = 0
AND    PROJACTS.ZCLA_PLOT = :ELEMENT
AND    ZCLA_PLOTELEMENT.EL = PROJACTS.ZCLA_EL
AND    ZCLA_ELEMENTFIX.FIXID = PROJACTS.ZCLA_FIX
AND    ZCLA_PLOTELEMENT.EL = ZCLA_ELEMENTFIX.EL
AND    ZCLA_ELTYPE.ELTYPE = ZCLA_PLOTELEMENT.ELTYPE
;
OPEN @PRICE;
GOTO 25239 WHERE :RETVAL = 0 ;
LABEL 25231 ;
:FIXACT = 0 ;
:ZCLA_TOTPRICE = 0.0 ;
FETCH @PRICE INTO :FIXACT , :ZCLA_TOTPRICE ;
GOTO 25238 WHERE :RETVAL = 0 ;
/*
*/
SELECT 'PRICE>>'
, :ELEMENT , :FIXACT , :ZCLA_TOTPRICE
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE
;
UPDATE PROJACTS
SET ZCLA_TOTPRICE = :ZCLA_TOTPRICE
WHERE 0=0
AND   ZCLA_FIX = :FIXACT
AND   ZCLA_PLOT = :ELEMENT ;
/*
*/
LOOP 25231;
LABEL 25238 ;
CLOSE @PRICE ;
LABEL 25239 ;
/*
*/
#INCLUDE ZCLA_ELACT/ZCLA_BUF6
