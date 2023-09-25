/* 
*   Bulk update plot parts
*   Only runs on non status locked plots
*   See ZCLA_ELACT/ZCLA_BUF15 for 
*   package updates
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_ELACT/ZCLA_BUF1' , :PLOT , :DOC
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
Delete unused rooms */
SELECT 'delete rooms' , PROJACT , ROOM
FROM ZCLA_PLOTROOMS
WHERE 0=0
AND   PROJACT = :ELEMENT
AND   ROOM NOT IN (
SELECT ZCLA_ROOMS.ROOM
FROM PROJACTS EL , ZCLA_ROOMS
WHERE 0=0
AND   ZCLA_ROOMS.HOUSETYPEID = EL.ZCLA_HOUSETYPEID
AND   EL.PROJACT = :ELEMENT
)
AND :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
DELETE FROM ZCLA_PLOTROOMS
WHERE 0=0
AND   PROJACT = :ELEMENT
AND   ROOM NOT IN (
SELECT ZCLA_ROOMS.ROOM
FROM PROJACTS EL , ZCLA_ROOMS
WHERE 0=0
AND   ZCLA_ROOMS.HOUSETYPEID = EL.ZCLA_HOUSETYPEID
AND   EL.PROJACT = :ELEMENT
);
/*
Insert New Rooms */
SELECT 'add rooms' , :ELEMENT , ROOM , COL
FROM PROJACTS EL , ZCLA_ROOMS
WHERE 0=0
AND   ZCLA_ROOMS.HOUSETYPEID = EL.ZCLA_HOUSETYPEID
AND   EL.PROJACT = :ELEMENT
AND   ROOM NOT IN (
SELECT ZCLA_PLOTROOMS.ROOM
FROM PROJACTS EL , ZCLA_PLOTROOMS
WHERE 0=0
AND   ZCLA_PLOTROOMS.PROJACT = EL.PROJACT
AND   EL.PROJACT = :ELEMENT
)
AND :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
INSERT INTO ZCLA_PLOTROOMS(PROJACT , ROOM , COL)
SELECT :ELEMENT , ROOM , COL
FROM PROJACTS EL , ZCLA_ROOMS
WHERE 0=0
AND   ZCLA_ROOMS.HOUSETYPEID = EL.ZCLA_HOUSETYPEID
AND   EL.PROJACT = :ELEMENT
AND   ROOM NOT IN (
SELECT ZCLA_PLOTROOMS.ROOM
FROM PROJACTS EL , ZCLA_PLOTROOMS
WHERE 0=0
AND   ZCLA_PLOTROOMS.PROJACT = EL.PROJACT
AND   EL.PROJACT = :ELEMENT
);
/*
Remove deleted */
DELETE FROM ZCLA_PLOTCOMPONENT
WHERE GUID IN (
SELECT  ZCLA_PLOTCOMPONENT.GUID
FROM    ZCLA_PLOTCOMPONENT ?
,       ZCLA_COMPONENT  
WHERE   0=0
AND     ZCLA_PLOTCOMPONENT.GUID = ZCLA_COMPONENT.GUID
AND     ZCLA_PLOTCOMPONENT.PROJACT = :ELEMENT 
AND     ZCLA_PLOTCOMPONENT.EXTRA <> 'Y'
AND     ZCLA_PLOTCOMPONENT.ISDELETED <> 'Y'
AND     ZCLA_PLOTCOMPONENT.PLOTCOMPONENT > 0
AND     ZCLA_PLOTCOMPONENT.GUID NOT IN
(SELECT        ZCLA_COMPONENT.GUID
FROM           PROJACTS 
,              ZCLA_COMPONENT 
,              ZCLA_ROOMS 
WHERE   0=0
AND     PROJACTS.ZCLA_HOUSETYPEID = ZCLA_ROOMS.HOUSETYPEID
AND     ZCLA_COMPONENT.ROOM = ZCLA_ROOMS.ROOM
AND     ZCLA_COMPONENT.ROOM > 0 
AND     PROJACTS.PROJACT = :ELEMENT
));
/*
Update / Insert */
:GUID = :GUID2 = :STYLE = :STYLE2 = '' ;
:ROOM = :PART = :PART2 = :TQUANT = :TQUANT2 = 0 ;
/*
*/
DECLARE @ROOMCUR CURSOR FOR
SELECT ZCLA_COMPONENT.GUID
,      ZCLA_COMPONENT.ROOM
,      ZCLA_COMPONENT.PART
,      ZCLA_COMPONENT.TQUANT
,      ZCLA_COMPONENT.STYLE
,      ZCLA_PLOTCOMPONENT.GUID AS GUID2
,      ZCLA_PLOTCOMPONENT.PART AS PART2
,      ZCLA_PLOTCOMPONENT.TQUANT AS TQUANT2
,      ZCLA_PLOTCOMPONENT.STYLE AS STYLE2
FROM   ZCLA_PLOTCOMPONENT ?
,      PROJACTS 
,      ZCLA_COMPONENT 
,      ZCLA_ROOMS 
WHERE  0=0
AND    ZCLA_COMPONENT.ROOM > 0
AND    PROJACTS.PROJACT = :ELEMENT 
AND    ZCLA_PLOTCOMPONENT.PROJACT = PROJACTS.PROJACT 
AND    ZCLA_COMPONENT.ROOM = ZCLA_ROOMS.ROOM 
AND    PROJACTS.ZCLA_HOUSETYPEID = ZCLA_ROOMS.HOUSETYPEID 
AND    ZCLA_PLOTCOMPONENT.GUID = ZCLA_COMPONENT.GUID
;
/*
*/
OPEN @ROOMCUR;
GOTO 2009 WHERE :RETVAL = 0 ;
LABEL 2001 ;
FETCH @ROOMCUR INTO :GUID
,     :ROOM
,     :PART
,     :TQUANT
,     :STYLE
,     :GUID2
,     :PART2
,     :TQUANT2
,     :STYLE2
;
GOTO 2008 WHERE :RETVAL = 0 ;
/*
*
No Change */
LOOP 2001 
WHERE :TQUANT = :TQUANT2 
AND   :STYLE  = :STYLE2 
AND   :PART   = :PART2
;
/*
*/
SELECT :GUID
,     :ROOM
,     :PART
,     :TQUANT
,     :STYLE
,     :GUID2
,     :PART2
,     :TQUANT2
,     :STYLE2
FROM DUMMY WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*
IS new ? */
GOTO 1999 WHERE :GUID2 <> '' ;
INSERT INTO ZCLA_PLOTCOMPONENT( GUID , PROJACT , ROOM , PART 
,           TQUANT , STYLE , EXTRA , ISDELETED
)
SELECT :GUID , :ELEMENT , :ROOM , :PART 
,      :TQUANT , :STYLE , 'N' , 'N'
FROM DUMMY ;
LOOP 2001 ;
LABEL 1999;
/*
*
Update Part */
UPDATE ZCLA_PLOTCOMPONENT
SET TQUANT = :PART
WHERE 0=0
AND   GUID = :GUID 
AND   :PART <> :PART2
;
/*
Update Quantity */
UPDATE ZCLA_PLOTCOMPONENT
SET TQUANT = :TQUANT
WHERE 0=0
AND   GUID = :GUID 
AND   :TQUANT <> :TQUANT2
;
/*
Update Style */
UPDATE ZCLA_PLOTCOMPONENT
SET STYLE = :STYLE
WHERE 0=0
AND   GUID = :GUID 
AND   :STYLE <> :STYLE2
;
LOOP 2001;
LABEL 2008;
CLOSE @ROOMCUR;
LABEL 2009 ; 