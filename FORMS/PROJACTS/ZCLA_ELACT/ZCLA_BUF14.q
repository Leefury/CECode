/*
Create Pricelist from site/builder/plc */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_ELACT/ZCLA_BUF14'
,      :ELEMENT , :DOC
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
:PLIST = 0 ;
SELECT PLIST INTO :PLIST 
FROM DOCUMENTS
WHERE DOC = :DOC ;
/*
*/
INSERT INTO PARTPRICE ( PART 
,   PRICE 
,   CURRENCY 
,   PLDATE 
,   PLIST 
,   USER 
,   UDATE 
,   TUNIT 
,   QUANT 
,   BYMPART 
,   VATPRICE 
,   PERCENT 
)
SELECT PART 
,   PRICE 
,   CURRENCY 
,   PLDATE 
,   PLIST 
,   USER 
,   UDATE 
,   TUNIT 
,   QUANT 
,   BYMPART 
,   VATPRICE 
,   PERCENT 
FROM  PARTPRICE ORIG
WHERE 0=0
AND   PLIST = :PLIST
;