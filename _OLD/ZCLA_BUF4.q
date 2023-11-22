/* ***********************
Points calc by HouseType
*********************** */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_HOUSETYPE/ZCLA_BUF4'
,      :HOUSETYPE
FROM DUMMY
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

/*
*/
SELECT '>>> BEGIN SPLIT'
FROM DUMMY FORMAT ADDTO :DEBUGFILE 
;
/*
Update Housetype PRICE Totals */
SELECT SUM(ZCLA_TOTCOST) INTO :ZCLA_TOTCOST
FROM ZCLA_HOUSETYPEFIX
WHERE   HOUSETYPEID = :HOUSETYPE
;
/*
Get Split and Markup */
SELECT SQL.TMPFILE INTO :SPLIT FROM DUMMY ;
LINK ZCLA_SPLIT TO :SPLIT;
ERRMSG 1 WHERE :RETVAL = 0 ;
#INCLUDE ZCLA_HOUSETYPE/ZCLA_BUF10
/* 
*/
DECLARE @PRICE CURSOR FOR
SELECT FIXID
,   (:ZCLA_TOTCOST * SPLIT) * :MARKUP
FROM   ZCLA_SPLIT
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
, :HOUSETYPE , :FIXACT , :ZCLA_TOTPRICE
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE 
;
UPDATE ZCLA_HOUSETYPEFIX 
SET ZCLA_TOTPRICE = :ZCLA_TOTPRICE
WHERE 0=0
AND   FIXID = :FIXACT 
AND   HOUSETYPEID = :HOUSETYPE ;
/*
*/
LOOP 25231;
LABEL 25238 ;
CLOSE @PRICE ;
LABEL 25239 ;
/*
*/
UNLINK ZCLA_SPLIT ;
/*
*/
#INCLUDE ZCLA_HOUSETYPE/ZCLA_BUF5