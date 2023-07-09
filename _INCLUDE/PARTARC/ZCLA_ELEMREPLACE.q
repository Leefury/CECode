/**/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'PARTARC/ZCLA_ELEMREPLACE' , :ELEMENT , SQL.USER
FROM DUMMY FORMAT ADDTO :DEBUGFILE ;
/*
*/
:ERR = '' ;
UPDATE ZCLA_PLOTCOMPONENT
SET ZCLA_MISSINGREPL = ''
WHERE 0=0
AND   PROJACT = :ELEMENT
;
UPDATE ZCLA_PLOTCUCFG
SET ZCLA_MISSINGREPL = ''
WHERE 0=0
AND   CUNITCONFIG IN (
SELECT CUNITCONFIG
FROM ZCLA_PLOTCU , ZCLA_PLOTCUCFG
WHERE 0=0
AND   ZCLA_PLOTCU.CONSUMERUNIT = ZCLA_PLOTCUCFG.CONSUMERUNIT
AND   PROJACT = :ELEMENT
);
/*
*/
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
,      EXTRA
,      EDITID
,      PACKAGE
)
SELECT SQL.USER
,    PARTARC.PART
,    PARTARC.SON
,    PARTARC.ACT
,    PARTARC.VAR
,    PARTARC.OP
,    SUM( SONQUANT * (ZCLA_PLOTCOMPONENT.TQUANT/1000) ) AS COEF
,    PARTARC.SONACT
,    PARTARC.SCRAP
,    SUM( SONQUANT * (ZCLA_PLOTCOMPONENT.TQUANT/1000) ) AS SONQUANT
,    PARTARC.ISSUEONLY
,    PARTARC.FROMDATE
,    PARTARC.TILLDATE
,    PARTARC.RVFROMDATE
,    PARTARC.RVTILLDATE
,    PARTARC.INFOONLY
,    PARTARC.SONPARTREV
,    PARTARC.SETEXPDATE
,    PARTARC.ZCLA_FIXID
,    PARTARC.ZCLA_WHITE
,    ZCLA_PLOTCOMPONENT.COL
,    ZCLA_PLOTCOMPONENT.EXTRA
,    ZCLA_PLOTCOMPONENT.EDITID
,    ZCLA_ELEDIT.PACKAGEFLAG
FROM ZCLA_FIXES
,    ZCLA_PLOTCOMPONENT
,    ZCLA_PLOTROOMS
,    PARTARC
,    PROJACTS
,    ZCLA_ELEDIT ?
WHERE  0 = 0
AND    ZCLA_PLOTCOMPONENT.EDITID = ZCLA_ELEDIT.EDITID
AND    ZCLA_PLOTCOMPONENT.PROJACT = ZCLA_PLOTROOMS.PROJACT
AND    ZCLA_PLOTCOMPONENT.ROOM = ZCLA_PLOTROOMS.ROOM
AND    ZCLA_PLOTCOMPONENT.PART = PARTARC.PART
AND    ZCLA_PLOTCOMPONENT.PROJACT = PROJACTS.ZCLA_PLOT
AND    ZCLA_FIXES.FIXID = PROJACTS.ZCLA_FIX
AND    ZCLA_FIXES.FIXID = PARTARC.ZCLA_FIXID
AND    PROJACTS.ZCLA_PLOT = :ELEMENT
AND    ZCLA_PLOTCOMPONENT.ISDELETED <> 'Y'
GROUP BY PARTARC.PART
,    PARTARC.SON
,    PARTARC.ACT
,    PARTARC.VAR
,    PARTARC.OP
,    PARTARC.SONACT
,    PARTARC.SCRAP
,    PARTARC.ISSUEONLY
,    PARTARC.FROMDATE
,    PARTARC.TILLDATE
,    PARTARC.RVFROMDATE
,    PARTARC.RVTILLDATE
,    PARTARC.INFOONLY
,    PARTARC.SONPARTREV
,    PARTARC.SETEXPDATE
,    PARTARC.ZCLA_FIXID
,    PARTARC.ZCLA_WHITE
,    ZCLA_PLOTCOMPONENT.COL
,    ZCLA_PLOTCOMPONENT.EXTRA
,    ZCLA_PLOTCOMPONENT.EDITID
,    ZCLA_ELEDIT.PACKAGEFLAG
;
#INCLUDE PARTARC/ZCLA_ELCUNITBOM
#INCLUDE PARTARC/ZCLA_SHEATHING
/*
*/
:ZCLA_FIXID = :FAMILY = :PART = :COL = 0 ;
:SON = :SONACT = :ACT = :RVFROMDATE = 0 ;
:REPLACEPART = :MANFID = :FAMILY = :WHITE = 0 ;
:DEL = :ZCLA_WHITE = '' ;
SELECT COL INTO :WHITE
FROM ZCLA_ACCYCOL
WHERE NAME = 'White'
;
#INCLUDE ZCLA_ALTMANUF/ZCLA_ELEMENT
/* Cursor generic parts
*/
DECLARE @BOM01 CURSOR FOR
SELECT DISTINCT PART
,   SON
,   ZCLA_WHITE
,   COL
FROM ZCLA_PARTARC
WHERE 0=0
AND   USER = SQL.USER
AND   SON IN (SELECT PART FROM ZCLA_GENERICMANF)
;
OPEN @BOM01;
GOTO 9 WHERE :RETVAL = 0;
LABEL 1;
FETCH @BOM01 INTO :PART , :SON , :ZCLA_WHITE , :COL ;
GOTO 8 WHERE :RETVAL = 0 ;
SELECT FAMILY INTO :FAMILY
FROM PART WHERE PART = :PART ;
/*
*/
SELECT MANFID INTO :MANFID
FROM ZCLA_PROJMANF
WHERE 0=0
AND   ALT = :ALT
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
/*
*/
SELECT 'REPLACE FAIL >>'
,      :DOC , :ALT
,      FAMILY.FAMILYNAME
,      PARENT.PARTNAME AS PARENT
,      SON.PARTNAME AS SON
,      MNFCTR.MNFNAME
,      ( :ZCLA_WHITE <> 'Y' ? :COL : :WHITE ) AS COL
FROM PART PARENT , PART SON , FAMILY , MNFCTR
WHERE 0=0
AND   PARENT.FAMILY = FAMILY.FAMILY
AND   PARENT.PART = :PART
AND   SON.PART = :SON
AND   MNFCTR.MNF = :MANFID
AND   :DEBUG = 1
AND   :REPLACEPART = 0
FORMAT ADDTO :DEBUGFILE ;
/*
*/
SELECT 'Y' INTO :ERR
FROM DUMMY
WHERE :REPLACEPART = 0
;
/*
Set the component missing flag */
UPDATE ZCLA_PLOTCOMPONENT
SET ZCLA_MISSINGREPL = (:REPLACEPART = 0 ? 'Y' : '')
WHERE 0=0
AND   PROJACT = :ELEMENT
AND   PART = :PART
AND   ZCLA_PLOTCOMPONENT.COL = :COL ;
/*
Set the consumer unit missing flag */
UPDATE ZCLA_PLOTCUCFG
SET     ZCLA_MISSINGREPL = (:REPLACEPART = 0 ? 'Y' : '')
WHERE   0=0
AND     PART = :PART
AND     CUNITCONFIG IN (
SELECT CUNITCONFIG
FROM ZCLA_PLOTCU , ZCLA_PLOTCUCFG
WHERE 0=0
AND   ZCLA_PLOTCU.CONSUMERUNIT = ZCLA_PLOTCUCFG.CONSUMERUNIT
AND   PROJACT = :ELEMENT
);
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
CLOSE @BOM01;
LABEL 9;
SELECT * FROM ZCLA_PARTARC
WHERE 0=0
AND   USER = SQL.USER
AND   :DEBUG = 1
FORMAT ADDTO :DEBUGFILE
;
#INCLUDE PARTARC/ZCLA_ELEMENT
