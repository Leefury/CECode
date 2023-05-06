/* Add missing fixes to the plot.
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_FIXACT/ZCLA_BUF1'
FROM DUMMY 
WHERE :DEBUG = 1 
FORMAT ADDTO :DEBUGFILE;
#INCLUDE ZCLA_FIXACT/ZCLA_FORMVAR
/*
*/
GOTO 999 
WHERE EXISTS (
SELECT 'x'
FROM ZCLA_USERLOCK
WHERE USER = SQL.USER
); 
/*
Set User lock */
INSERT INTO ZCLA_USERLOCK (USER)
SELECT SQL.USER FROM DUMMY ;
:LN = 0 ;
SELECT SQL.TMPFILE
INTO :GEN FROM DUMMY;
LINK GENERALLOAD TO :GEN;
ERRMSG 1 WHERE :RETVAL = 0 ;
/* Insert Project Line
*/
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, KEY1)
SELECT :LN , '1' , ITOA(:DOC)
FROM DUMMY ;
/* 
insert Projact line */
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, KEY1)
SELECT :LN
,    '2'
,    ITOA(:PLOT)
FROM DUMMY
;
/* 
insert Element line */
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, KEY1)
SELECT :LN
,    '3'
,    ITOA(:ELEMENT)
FROM DUMMY
;
/* 
Find fixes used by child parts of components. */
:FIX = 0 ;
DECLARE @E4 CURSOR FOR
SELECT DISTINCT PARTARC.ZCLA_FIXID
FROM  ZCLA_ROOMS , ZCLA_COMPONENT , PART , PARTARC , PART SON
WHERE 0=0
AND   SON.PART = PARTARC.SON
AND   PARTARC.PART = PART.PART
AND   ZCLA_ROOMS.ROOM = ZCLA_COMPONENT.ROOM
AND   PART.PART = ZCLA_COMPONENT.PART
AND   HOUSETYPEID = :HOUSETYPE
AND   PARTARC.ZCLA_FIXID > 0
AND   PARTARC.ZCLA_FIXID NOT IN (
SELECT ZCLA_FIX
FROM PROJACTS
WHERE 0=0
AND   ZCLA_PLOT = :ELEMENT
);
OPEN @E4 ;
GOTO 9 WHERE :RETVAL = 0 ;
LABEL 1;
FETCH @E4 INTO :FIX ;
GOTO 8 WHERE :RETVAL = 0;
/* 
insert fix line */
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, INT1 )
SELECT :LN
,    '4'
,    :FIX
FROM DUMMY ;
LOOP 1;
LABEL 8;
CLOSE @E4 ;
LABEL 9;
GOTO 998 WHERE NOT EXISTS (
SELECT 'x'
FROM GENERALLOAD WHERE RECORDTYPE = '4'
);
/*
*/
#INCLUDE func/ZCLA_RESETERR
EXECUTE INTERFACE 'ZCLA_LOADPLOT', SQL.TMPFILE, '-L', :GEN ;
:i_LOGGEDBY = 'ZCLA_FIXACT-BUF1';
#INCLUDE func/ZEMG_ERRMSGLOG
SELECT 'ZCLA_FIXACT/ZCLA_BUF1' , LINE, RECORDTYPE , KEY1 , LOADED , TEXT1 ,  INT1 , INT2
FROM GENERALLOAD
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
#INCLUDE func/ZCLA_ERRMSG
UNLINK GENERALLOAD ;
LABEL 998 ;
/*
Remove Lock */
DELETE FROM ZCLA_USERLOCK
WHERE USER = SQL.USER ;
LABEL 999 ;
