:ERR = '' ;
DELETE FROM ZCLA_PARTARC
WHERE 0=0
AND   USER = SQL.USER;
INSERT INTO ZCLA_PARTARC ( USER
,      PART
,      SON
,      ACT
,      VAR
,      OP
,      COEF
,      SONACT
,      SCRAP
,      SONQUANT
,      ISSUEONLY
,      FROMDATE
,      TILLDATE
,      RVFROMDATE
,      RVTILLDATE
,      INFOONLY
,      SONPARTREV
,      SETEXPDATE
,      ZCLA_FIXID
,      ZCLA_WHITE
,      COL
)
SELECT        SQL.USER
,     PARTARC.PART
,     PARTARC.SON
,     PARTARC.ACT
,     PARTARC.VAR
,     PARTARC.OP
,     SUM( PARTARC.SONQUANT) AS COEF
,     PARTARC.SONACT
,     PARTARC.SCRAP
,     SUM( PARTARC.SONQUANT) AS SONQUANT
,     PARTARC.ISSUEONLY
,     PARTARC.FROMDATE
,     PARTARC.TILLDATE
,     PARTARC.RVFROMDATE
,     PARTARC.RVTILLDATE
,     PARTARC.INFOONLY
,     PARTARC.SONPARTREV
,     PARTARC.SETEXPDATE
,     PARTARC.ZCLA_FIXID
,     PARTARC.ZCLA_WHITE
,     ZCLA_PLOTROOMS.COL
FROM  ZCLA_FIXES , PROJACTS , ZCLA_PLOTROOMS, PARTARC,
ZCLA_PLOTCOMPONENT
WHERE 0 = 0
AND   ZCLA_PLOTROOMS.PROJACT =  ZCLA_PLOTCOMPONENT.PROJACT
AND   ZCLA_PLOTROOMS.ROOM =  ZCLA_PLOTCOMPONENT.ROOM
AND   ZCLA_PLOTCOMPONENT.PART =  PARTARC.PART
AND   PROJACTS.ZCLA_PLOT =  ZCLA_PLOTCOMPONENT.PROJACT
AND   ZCLA_FIXES.FIXID =  PROJACTS.ZCLA_FIX
AND   ZCLA_FIXES.FIXID =  PARTARC.ZCLA_FIXID
AND   PROJACTS.ZCLA_PLOT = :ELEMENT
GROUP BY  PARTARC.PART
,     PARTARC.SON
,     PARTARC.ACT
,     PARTARC.VAR
,     PARTARC.OP
,     PARTARC.SONACT
,     PARTARC.SCRAP
,     PARTARC.ISSUEONLY
,     PARTARC.FROMDATE
,     PARTARC.TILLDATE
,     PARTARC.RVFROMDATE
,     PARTARC.RVTILLDATE
,     PARTARC.INFOONLY
,     PARTARC.SONPARTREV
,     PARTARC.SETEXPDATE
,     PARTARC.ZCLA_FIXID
,     PARTARC.ZCLA_WHITE
,     ZCLA_PLOTROOMS.COL
;
:ZCLA_FIXID = :FAMILY = :PART = :COL = 0 ;
:SON = :SONACT = :ACT = :RVFROMDATE = 0 ;
:REPLACEPART = :MANFID = :FAMILY = :WHITE = 0 ;
:DEL = :ZCLA_WHITE = '' ;
SELECT COL INTO :WHITE
FROM ZCLA_ACCYCOL
WHERE NAME = 'White'
;
/* Cursor generic parts
*/
DECLARE @E2 CURSOR FOR
SELECT DISTINCT PART
,   SON
,   ZCLA_WHITE
,   COL
FROM ZCLA_PARTARC
WHERE 0=0
AND   USER = SQL.USER
AND   SON IN (SELECT PART FROM ZCLA_GENERICMANF)
;
OPEN @E2;
GOTO 9 WHERE :RETVAL = 0;
LABEL 1;
FETCH @E2 INTO :PART , :SON , :ZCLA_WHITE , :COL ;
GOTO 8 WHERE :RETVAL = 0 ;
SELECT FAMILY INTO :FAMILY
FROM PART WHERE PART = :PART ;
/*
*/
SELECT MANFID INTO :MANFID
FROM ZCLA_PROJMANF
WHERE 0=0
AND   DOC = :DOC
AND   ZCLA_PROJMANF.FAMILY = :FAMILY
AND   COL = ( :ZCLA_WHITE <> 'Y' ? :COL : :WHITE)
;
/*
*/
:REPLACEPART = 0 ;
SELECT REPLPART INTO :REPLACEPART
FROM ZCLA_GENERICMANF
,    PART
WHERE 0=0
AND   ZCLA_GENERICMANF.REPLPART = PART.PART
AND   PART.FAMILY = :FAMILY
AND   MNF = :MANFID
AND   ZCLA_GENERICMANF.PART = :SON
AND   COL = ( :ZCLA_WHITE <> 'Y'? :COL : :WHITE )
;
SELECT 'Y' INTO :ERR
FROM DUMMY
WHERE :REPLACEPART = 0
;
/*
*/
UPDATE ZCLA_PARTARC
SET SON = :REPLACEPART
WHERE 0=0
AND   USER = SQL.USER
AND   PART = :PART  
AND   SON = :SON 
AND   ZCLA_WHITE = :ZCLA_WHITE 
AND   COL = :COL
AND   :REPLACEPART > 0
;
LOOP 1;
LABEL 8;
CLOSE @E2;
LABEL 9;
