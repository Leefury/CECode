/* Update fix sale PRICE.
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_ELACT/ZCLA_BUF9'
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE;
/*
*/
DECLARE @PRICE CURSOR FOR
SELECT FIXACT.PROJACT
,      ELACT.ZCLA_PARTCOST * (ZCLA_ELEMENTFIX.SPLIT / 100) * ZCLA_ELTYPE.MARKUP 
,      ELACT.ZCLA_LABCOST * (ZCLA_ELEMENTFIX.SPLIT / 100)  * ZCLA_ELTYPE.MARKUP 
,      ELACT.ZCLA_MILEAGECOST * (ZCLA_ELEMENTFIX.SPLIT / 100) * ZCLA_ELTYPE.MARKUP
FROM   ZCLA_PLOTELEMENT 
,      ZCLA_ELTYPE 
,      PROJACTS ELACT 
,      PROJACTS FIXACT 
,      ZCLA_ELEMENTFIX 
WHERE 0=0
AND   ELACT.PROJACT = :ELEMENT
AND   FIXACT.ZCLA_FIX = ZCLA_ELEMENTFIX.FIXID 
AND   ELACT.PROJACT = FIXACT.ZCLA_PLOT 
AND   ZCLA_PLOTELEMENT.EL = ELACT.ZCLA_EL 
AND   ZCLA_PLOTELEMENT.EL =ZCLA_ELEMENTFIX.EL
AND   ZCLA_PLOTELEMENT.ELTYPE =ZCLA_ELTYPE.ELTYPE 
;
OPEN @PRICE;
GOTO 25239 WHERE :RETVAL = 0 ;
LABEL 25231 ;
:FIXACT = 0 ;
:PARTPRICE = :LABOURPRICE = :MILEPRICE = 0.0 ;
FETCH @PRICE INTO :FIXACT , :PARTPRICE , :LABOURPRICE , :MILEPRICE ;
GOTO 25238 WHERE :RETVAL = 0 ;
/*
*/
SELECT 'ZCLA_ELACT/ZCLA_BUF9' , :FIXACT , :PARTPRICE 
,      :LABOURPRICE , :MILEPRICE
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE 
;
UPDATE PROJACTS 
SET ZCLA_PARTPRICE = :PARTPRICE
,   ZCLA_LABPRICE = :LABOURPRICE 
,   ZCLA_MILEPRICE = :MILEPRICE 
,   ZCLA_TOTPRICE = :PARTPRICE + :LABOURPRICE + :MILEPRICE
WHERE PROJACT = :FIXACT ;
/*
*/
LOOP 25231;
LABEL 25238 ;
CLOSE @PRICE ;
LABEL 25239 ;
