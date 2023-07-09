:SONQUANT = :PROJACT = :KLINE = :SON = :ROOM = :PART = 0 ;
:COL = :WHITE = :MANFID = 0 ;
:ERR = :ISWHITE = '' ;
/*
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'PARTARC/ZCLA_TREEREPLACE' , :KITFLAG , :IGNOREROOM
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
SELECT :FIXACT
,      :DOC
,      :HOUSETYPEID
,      :ELACT
,      :FIX
,      :KITFLAG
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE 
;
/*
Skip if Active (FREECHAR1) parts exist ? */
GOTO 180623 WHERE EXISTS (
SELECT 'x'
FROM PROJACTTREE
WHERE 0=0
AND PROJACT = :FIXACT
AND FREECHAR1 = 'Y'
);
DELETE FROM PROJACTTREE 
WHERE 0=0
AND PROJACT = :FIXACT
AND FREECHAR1 <> 'Y'
;
DELETE FROM ZCLA_PROJACTTREE
WHERE 0=0
AND   COPYUSER = SQL.USER
;
/*
*/
:ALT = :ELEMENT = 0 ;
SELECT :ELACT INTO :ELEMENT
FROM DUMMY ;
#INCLUDE ZCLA_ALTMANUF/ZCLA_ELEMENT
/*
*/
SELECT COL INTO :WHITE
FROM ZCLA_ACCYCOL
WHERE NAME = 'White'
;
SELECT SQL.TMPFILE
INTO :TREE FROM DUMMY;
LINK ZCLA_PROJACTTREE TO :TREE ;
ERRMSG 1 WHERE :RETVAL = 0 ;
/* */
INSERT INTO ZCLA_PROJACTTREE ( COPYUSER
,   PROJACT
,   KLINE
,   SONPART
,   SONQUANT
,   USER
,   UDATE
,   DUEDATE
,   RATIO
,   DOC
,   ZCLA_ROOM
,   WHITE
,   PART
,   COL
)
SELECT SQL.USER
,   PROJACTS.PROJACT 
,   SQL.LINE
,   SON.PART
,   SUM( SONQUANT * (ZCLA_PLOTCOMPONENT.TQUANT/1000) )
,   SQL.USER
,   SQL.DATE
,   PROJACTS.STARTDATE
,   SUM( SONQUANT * (ZCLA_PLOTCOMPONENT.TQUANT/1000) )
,   :DOC
,   ( :IGNOREROOM = 1 ? 0 : ZCLA_ROOMS.ROOM )
,   PARTARC.ZCLA_WHITE
,   PARTARC.PART
,   ZCLA_PLOTCOMPONENT.COL
FROM PROJACTS 
,    PART SON 
,    PARTARC  
,    PART  
,    ZCLA_PLOTROOMS 
,    ZCLA_PLOTCOMPONENT 
,    ZCLA_ROOMS 
WHERE 0=0
AND   ZCLA_PLOTROOMS.ROOM = ZCLA_PLOTCOMPONENT.ROOM 
AND   ZCLA_PLOTROOMS.PROJACT = ZCLA_PLOTCOMPONENT.PROJACT 
AND   ZCLA_PLOTROOMS.ROOM = ZCLA_ROOMS.ROOM 
AND   ZCLA_PLOTCOMPONENT.ROOM = ZCLA_ROOMS.ROOM 
AND   PART.PART = ZCLA_PLOTCOMPONENT.PART 
AND   PROJACTS.ZCLA_FIX = PARTARC.ZCLA_FIXID 
AND   PROJACTS.ZCLA_PLOT = ZCLA_PLOTCOMPONENT.PROJACT
AND   SON.PART = PARTARC.SON
AND   PARTARC.PART = PART.PART
AND   ZCLA_PLOTCOMPONENT.ISDELETED <> 'Y'
AND   PROJACTS.PROJACT = :FIXACT
GROUP BY 1,2,3,4,6,7,8,10,11,12,13,14
;
:DUEDATE = 0 ;
SELECT MAX( DUEDATE ) INTO :DUEDATE
FROM ZCLA_PROJACTTREE 
WHERE COPYUSER = SQL.USER ;
/*
*/
#INCLUDE PARTARC/ZCLA_TSHEATHING
#INCLUDE PARTARC/ZCLA_TCUNITBOM
/*
Iterate through BoM for distinct keys where the 
child part is listed in Generic Maunfacturers */
DECLARE @BOM04 CURSOR FOR
SELECT DISTINCT SONPART , WHITE , PART , COL
FROM ZCLA_PROJACTTREE
WHERE 0=0
AND   USER = SQL.USER
AND   SONPART IN (SELECT PART FROM ZCLA_GENERICMANF)
;
OPEN @BOM04;
GOTO 2502239 WHERE :RETVAL = 0;
LABEL 2502231;
FETCH @BOM04 INTO :SON , :ISWHITE , :PART , :COL;
GOTO 2502238 WHERE :RETVAL = 0
;
/*
Get the family of the parent part */
SELECT FAMILY INTO :FAMILY
FROM PART WHERE PART = :PART
;
/* find the manufacturer for the current:
Site / Alt part list / child part family 
depending on finish. :ISWHITE parts always use
the :WHITE finish. */
SELECT MANFID INTO :MANFID
FROM ZCLA_PROJMANF
WHERE 0=0
AND   ALT = :ALT
AND   DOC = :DOC
AND   ZCLA_PROJMANF.FAMILY = :FAMILY
AND   COL = ( :ISWHITE <> 'Y' ? :COL : :WHITE)
;
SELECT :DOC , :SON , :ISWHITE , :PART , :COL , :WHITE , :MANFID , :ALT
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
Find the replacement for the child part
based on manufacturer and family of child part */
:REPLACEPART = 0 ;
SELECT REPLPART INTO :REPLACEPART
FROM ZCLA_GENERICMANF , PART
WHERE 0=0
AND   ZCLA_GENERICMANF.REPLPART = PART.PART
AND   PART.FAMILY = :FAMILY
AND   MNF = :MANFID
AND   ZCLA_GENERICMANF.PART = :SON
AND   COL = ( :ZCLA_WHITE <> 'Y' ? :COL : :WHITE )
;
/* 
Save changes to matching BoM lines */
UPDATE ZCLA_PROJACTTREE
SET SONPART = :REPLACEPART
WHERE 0=0
AND   COPYUSER = SQL.USER
AND   SONPART = :SON 
AND   WHITE = :ISWHITE 
AND   PART = :PART 
AND   COL = :COL
AND   :REPLACEPART > 0
;
SELECT 'Y' INTO :ERR
FROM DUMMY
WHERE :REPLACEPART = 0
;
SELECT :REPLACEPART , :ERR
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
LOOP 2502231;
LABEL 2502238;
/*
*/
LABEL 2502239;
/*
Remove part and group */
INSERT INTO ZCLA_PROJACTTREE ORIG ( COPYUSER
,   PROJACT
,   KLINE
,   SONPART
,   SONQUANT
,   USER
,   UDATE
,   DUEDATE
,   RATIO
,   DOC
,   ZCLA_ROOM
,   WHITE
,   PART
,   COL
)
SELECT SQL.USER
,   PROJACT
,   SQL.LINE
,   SONPART
,   SUM(SONQUANT) * 1000
,   USER
,   UDATE
,   DUEDATE
,   1
,   DOC
,   ZCLA_ROOM
,   WHITE
,   0
,   COL
FROM ZCLA_PROJACTTREE
WHERE 0=0
AND   COPYUSER = SQL.USER 
AND   PROJACT = :FIXACT
GROUP BY PROJACT 
,   SONPART
,   USER
,   UDATE
,   DUEDATE
,   DOC
,   ZCLA_ROOM
,   WHITE
,   COL 
;
UNLINK ZCLA_PROJACTTREE ;
/*
*/
/*
Sundries */
:SUNDRYCREDIT = 0.0 ;
SELECT 1.0 + VALUE 
INTO :SUNDRYCREDIT
FROM ZCLA_CONST
WHERE NAME = 'SUNDRYCREDIT'
;
/*
*/
SELECT SQL.TMPFILE
INTO :STK FROM DUMMY;
LINK STACK10 TO :STK;
ERRMSG 1 WHERE :RETVAL = 0 ;
/*
*/
:LN = 0 ;
DECLARE @PAT CURSOR FOR
SELECT ZCLA_PROJACTTREE.SONPART
,      ZCLA_PROJACTTREE.SONQUANT
FROM  ZCLA_PROJACTTREE
WHERE 0=0
AND   SONPART > 0
AND   COPYUSER = SQL.USER
;
OPEN @PAT ;
GOTO 18069 WHERE :RETVAL = 0 ;
LABEL 18061;
:PART = :TQUANT = 0 ;
FETCH @PAT INTO :PART , :TQUANT  ;
GOTO 18068 WHERE :RETVAL = 0
;
/*
Inserts the sundry parts for this BoM line */
INSERT INTO STACK10 (KEY1 , KEY2 , REAL1 )
SELECT     :PART 
,          PARTARC.SON
,          SUM( ( 1000 * SONQUANT ) * REALQUANT( :TQUANT ) )
FROM PARTARC
WHERE   0=0
AND     PARTARC.PART = :PART
GROUP BY 1 , 2
;
/*
*/
LOOP 18061;
LABEL 18068;
CLOSE @PAT ;
LABEL 18069
;
SELECT KEY1 , KEY2 , REAL1 
FROM STACK10
FORMAT ADDTO :DEBUGFILE ;
/*
Remove part and group SUNDRIES */
SELECT MAX(KLINE) +1 INTO :LN 
FROM ZCLA_PROJACTTREE ;
INSERT INTO ZCLA_PROJACTTREE ( COPYUSER
,   PROJACT
,   KLINE
,   SONPART
,   SONQUANT
,   USER
,   UDATE
,   DUEDATE
,   RATIO
,   DOC
,   FREECHAR2
)
SELECT SQL.USER
,   :FIXACT
,   :LN  + SQL.LINE
,   KEY2
,   ( SUM( ROUND( REAL1 / 1000 ) * 1000 ) = 0 
?     1000 : SUM( ROUND( REAL1 / 1000 ) * 1000 ) )
,   SQL.USER
,   SQL.DATE
,   :DUEDATE
,   1000
,   :DOC
,   'Y'
FROM STACK10 
WHERE KEY2 > 0
GROUP BY KEY2 ;
/*
*/
/*
Populate the live BoM 
:KITFLAG comes from the calling status 
Once kitted, the FREECHAR1 = 'Y'
Sundries have FREECHAR2 = 'Y' */
INSERT INTO PROJACTTREE ( PROJACT 
,    KLINE 
,    SONPART 
,    USERB 
,    SONQUANT 
,    NONSTANDARD 
,    PURSOURCE 
,    PURCHASEPRICE 
,    USER 
,    UDATE 
,    FREEINT1 
,    FREEINT2 
,    FREEINT3 
,    FREEINT4 
,    FREEDATE1 
,    FREEDATE2 
,    FREEREAL1 
,    FREEREAL2 
,    FREECHAR1 
,    FREECHAR2 
,    SUP 
,    DUEDATE 
,    ICURRENCY 
,    IEXCHANGE 
,    RATIO 
,    HRFLAG 
,    DOC 
,    PURFLAG 
,    CONFFLAG 
,    PURQUANT 
,    CONFUSER 
,    FREEINT6 
,    FREEINT5 
,    CONFUDATE 
,    DONEFLAG 
,    ACTIVEFLAG )
SELECT PROJACT 
,    KLINE 
,    SONPART 
,    USERB 
,    SONQUANT * ( 1 + ( PART.ZCLA_WASTAGE / 100 ) )
,    NONSTANDARD 
,    PURSOURCE 
,    ( FREECHAR2 = 'Y' ? PARTPRICE.PRICE * :SUNDRYCREDIT : PARTPRICE.PRICE )
,    SQL.USER 
,    ZCLA_PROJACTTREE.UDATE 
,    FREEINT1 
,    FREEINT2 
,    FREEINT3 
,    FREEINT4 
,    FREEDATE1 
,    FREEDATE2 
,    FREEREAL1 
,    FREEREAL2 
,    :KITFLAG 
,    FREECHAR2 
,    SUP 
,    DUEDATE 
,    PARTPRICE.CURRENCY 
,    IEXCHANGE 
,    1
,    HRFLAG 
,    DOC 
,    PURFLAG 
,    CONFFLAG 
,    PURQUANT 
,    CONFUSER 
,    FREEINT6 
,    FREEINT5 
,    CONFUDATE 
,    DONEFLAG 
,    ACTIVEFLAG
FROM ZCLA_PROJACTTREE 
,  PARTPRICE 
,  PRICELIST 
,  PART
WHERE 0 = 0
AND   PART.PART = ZCLA_PROJACTTREE.SONPART
AND   PARTPRICE.CURRENCY = PRICELIST.CURRENCY
AND   ZCLA_PROJACTTREE.SONPART = PARTPRICE.PART 
AND   PARTPRICE.PLIST = PRICELIST.PLIST 
AND   PRICELIST.PLIST = - 1
AND   PARTPRICE.CURRENCY = - 1
AND   PARTPRICE.QUANT = 1000
AND   ZCLA_PROJACTTREE.COPYUSER = SQL.USER
;
SELECT * FROM PROJACTTREE
WHERE 0=0
AND    PROJACT = :FIXACT 
AND    :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
LABEL 180623 ;