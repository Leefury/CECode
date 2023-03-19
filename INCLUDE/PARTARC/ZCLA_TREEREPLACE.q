:SONQUANT = :PROJACT = :KLINE = :SON = :ROOM = :PART = 0 ;
:COL = :WHITE = :MANFID = 0 ;
:ERR = :ISWHITE = '' ;
/*
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'PARTARC/ZCLA_TREEREPLACE'
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
SELECT :DEBUG
, :FIXACT
, :DOC
, :HOUSETYPEID
, :ELACT
, :FIX
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
DELETE FROM ZCLA_PROJACTTREE
WHERE 0=0
AND   COPYUSER = SQL.USER
;
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
,   :FIXACT
,   SQL.LINE
,   SON.PART
,   SUM( SONQUANT * (ZCLA_PLOTCOMPONENT.TQUANT/1000) )
,   SQL.USER
,   SQL.DATE
,   SQL.DATE
,   SUM( SONQUANT * (ZCLA_PLOTCOMPONENT.TQUANT/1000) )
,   :DOC
,   ( :IGNOREROOM = 1 ? 0 : ZCLA_ROOMS.ROOM )
,   PARTARC.ZCLA_WHITE
,   0
,   ZCLA_PLOTCOMPONENT.COL
FROM  ZCLA_ROOMS , ZCLA_PLOTCOMPONENT  , PART , PARTARC , PART SON ,
ZCLA_PLOTROOMS
WHERE 0=0
AND   ZCLA_PLOTCOMPONENT .ROOM = ZCLA_PLOTROOMS.ROOM
AND   ZCLA_PLOTCOMPONENT.PROJACT = ZCLA_PLOTCOMPONENT.PROJACT
AND   ZCLA_PLOTROOMS.PROJACT = ZCLA_PLOTCOMPONENT.PROJACT
AND   ZCLA_PLOTROOMS.ROOM = ZCLA_ROOMS.ROOM
AND   SON.PART = PARTARC.SON
AND   PARTARC.PART = PART.PART
AND   ZCLA_ROOMS.ROOM = ZCLA_PLOTCOMPONENT.ROOM
AND   PART.PART = ZCLA_PLOTCOMPONENT .PART
AND   HOUSETYPEID = :HOUSETYPEID
AND   PARTARC.ZCLA_FIXID = :FIX
AND   ZCLA_PLOTROOMS.PROJACT = :ELACT
GROUP BY 1,2,3,4,6,7,8,10,11,12,13,14
;
#INCLUDE PARTARC/ZCLA_TSHEATHING
SELECT * FROM ZCLA_PROJACTTREE
WHERE 0=0
AND   :DEBUG = 1
AND   COPYUSER = SQL.USER
FORMAT ADDTO :DEBUGFILE ;
/*
*/
SELECT COL INTO :WHITE
FROM ZCLA_ACCYCOL
WHERE NAME = 'White'
;
DECLARE @E2 CURSOR FOR
SELECT PROJACT , KLINE , SONPART , ZCLA_ROOM , WHITE , PART , COL
FROM ZCLA_PROJACTTREE
WHERE 0=0
AND   USER = SQL.USER
AND   SONPART IN (SELECT PART FROM ZCLA_GENERICMANF)
;
OPEN @E2;
GOTO 2502239 WHERE :RETVAL = 0;
LABEL 2502231;
FETCH @E2 INTO :PROJACT , :KLINE , :SON , :ROOM , :ISWHITE , :PART ,
:COL;
GOTO 2502238 WHERE :RETVAL = 0
;
SELECT FAMILY INTO :FAMILY
FROM PART WHERE PART = :PART
;
SELECT MANFID INTO :MANFID
FROM ZCLA_PROJMANF
WHERE 0=0
AND   DOC = :DOC
AND   ZCLA_PROJMANF.FAMILY = :FAMILY
AND   COL = ( :ZCLA_WHITE <> 'Y' ? :COL : :WHITE)
;
SELECT :PROJACT , :KLINE , :SON , :ROOM , :ISWHITE , :PART ,
:COL , :FAMILY , :MANFID
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
:REPLACEPART = 0 ;
SELECT REPLPART INTO :REPLACEPART
FROM ZCLA_GENERICMANF , PART
WHERE 0=0
AND   ZCLA_GENERICMANF.REPLPART = PART.PART
AND   PART.FAMILY = :FAMILY
AND   MNF = :MANFID
AND   ZCLA_GENERICMANF.PART = :SON
AND   COL = ( :ZCLA_WHITE <> 'Y'? :COL : :WHITE )
;
UPDATE ZCLA_PROJACTTREE
SET SONPART = :REPLACEPART
WHERE 0=0
AND   COPYUSER = SQL.USER
AND   KLINE = :KLINE
AND   PROJACT = :PROJACT
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
