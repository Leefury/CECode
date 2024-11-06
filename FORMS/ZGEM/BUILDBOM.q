/*************************
Build the BOM for an element
*************************/
/*INPUT
:ELEMENT    Element (ID)    PROJACTS.PROJACT
:FIX        Fix (ID) or -99 for all fixes
:IGNORE_ROOM    0 = NO, 1 = Yes
*/
/*OUTPUT
:MISSINGREPL
There is a missing replacement part under the element
ZCLA_PROJACTTREE table WHERE USER = SQL.USER
FREECHAR2   Sundry flag
FREEREAL1   Quantity - Rounded if IGNORE_ROOM = 1
FREEREAL2   Part Cost
PART        Parent part
SONPART     Son Part
*/
/*--*/
DELETE FROM ZCLA_PROJACTTREE WHERE USER = SQL.USER;
:KLINE = 0;
:MISSINGREPL = 'N';
/*------*/
/*Site ID & Housetype ID*/
:DOC = :HID = :CUST = 0;
SELECT P.DOC, P.ZCLA_HOUSETYPEID, D.CUST
INTO :DOC, :HID, :CUST
FROM PROJACTS P, DOCUMENTS D
WHERE PROJACT = :ELEMENT
AND P.DOC = D.DOC
;
SELECT 'ZGEM_BOMROOM/BUILDBOM'
, :ELEMENT
, :FIX
, :IGNORE_ROOM
FROM DUMMY
FORMAT ADDTO :DEBUGFILE
;
/*------*/
/*--*/
:ALT = 0 ;
#INCLUDE ZCLA_ALTMANUF/ZCLA_ELEMENT
/*--*/
SELECT 'Primary/Alt Manf', :ALT, :ELEMENT
FROM DUMMY
FORMAT ADDTO :DEBUGFILE;
/*------*/
/*--*/
#INCLUDE ZGEM_BOMROOM/BOMSONPARTS
/*--*/
/*Cursor Through Replacable Parts*/
DECLARE @BOMCURSOR CURSOR FOR
SELECT DISTINCT
KLINE
,   BOM.PART
,   SONPART
,   ZCLA_ROOM
,   WHITE
,   BOM.STYLE
FROM ZCLA_PROJACTTREE BOM, ZCLA_GENERICMANF P9
WHERE USER = SQL.USER
AND P9.PART = BOM.SONPART
;
/*--*/
OPEN @BOMCURSOR;
GOTO 88003 WHERE :RETVAL <= 0;
/*--*/
LABEL 88002;
/*--*/
:ROOMID = 0;
:P9_QUANT = 0.0;
FETCH @BOMCURSOR
INTO :KLINE
, :PART
, :P9
, :ROOMID
, :ISWHITE
, :STYLE
;
GOTO 88001 WHERE :RETVAL <= 0;
/*--*/
/*Replace P9*/
#INCLUDE ZGEM_BOMROOM/REPLACEP9
/*Update ZCLA_PROJACTTREE*/
:PARTNAME = '';
SELECT PARTNAME
INTO :PARTNAME
FROM PART
WHERE PART = (:P2 = 0 ? :P9 : :P2)
;
SELECT 'REPLACE P9 >>> P2'
, :PART
, :P9
, :P2
, :PARTNAME
, :MISSREPLPART
, :KLINE
FROM DUMMY
FORMAT ADDTO :DEBUGFILE
;
UPDATE ZCLA_PROJACTTREE
SET SONPART = (:P2 = 0 ? :P9 : :P2)
, PURCHASEPRICE = :P2_UNITPRICE
, PARTNAME = :PARTNAME
WHERE USER = SQL.USER
AND KLINE = :KLINE
;
/*--*/
LOOP 88002;
LABEL 88001;
CLOSE @BOMCURSOR
;
LABEL 88003;
/*--*/
SELECT 'BOM'
,   KLINE
,   PROJACT
,   DOC
, FIXID
,   P.PART
,   RATIO
,   SONPART
,   PART.PARTNAME
,   FREEREAL1
,   SONQUANT
,   ZCLA_ROOM
,   FREEREAL2
,   WHITE
,   STYLE
, FREECHAR1
, FREECHAR2
, ISEXTRA
, ORIGIN
, FREEREAL2
, PURCHASEPRICE
FROM ZCLA_PROJACTTREE P, PART
WHERE P.USER = SQL.USER
AND P.SONPART = PART.PART
FORMAT ADDTO :DEBUGFILE;