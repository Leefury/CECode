/*
*/
#INCLUDE func/ZCLA_DEBUGUSR
LINK ZCLA_ELEDIT TO :$.PAR;
/*
*/
GOTO 999 WHERE :RETVAL <= 0;
:ELEMENT = 0;
:EDITID = 0;
:ALREADY_CLOSED = '';
SELECT EDITID, PROJACT, CLOSEFLAG
INTO :EDITID, :ELEMENT, :ALREADY_CLOSED
FROM ZCLA_ELEDIT
WHERE EDITID <> 0
;
SELECT :EDITID, :ELEMENT, :ALREADY_CLOSED
FROM DUMMY WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE
;
UNLINK ZCLA_ELEDIT;
/*
*/
#INCLUDE STATUSTYPES/ZCLA_BUF4
SELECT SQL.TMPFILE
INTO :GEN FROM DUMMY;
:USERLOGIN = '' ;
:POSTNAME = 'CLOSEDIT' ;
GOSUB 500 ;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE
,   KEY1 , TEXT1 , TEXT3 , TEXT2 , TEXT10 , CHAR1
)
SELECT SQL.LINE , '1'
,   ITOA ( ZCLA_ELACTSTAT.ELACT )
,   ZCLA_ELACTSTAT.STATDES1
,   ZCLA_ELSTATUSES.STEPSTATUSDES
,   :USERLOGIN
,   SQL.GUID
,   'Y'
FROM   ZCLA_ELACTSTAT
,      ZCLA_ELSTATUSES
WHERE  0=0
AND    ZCLA_ELACTSTAT.STEPSTATUS = ZCLA_ELSTATUSES.STEPSTATUS
AND    ZCLA_ELACTSTAT.PROJACT    = :ELEMENT
;
:LOADNAME = 'STATUSMAILZCLA_EL' ;
GOSUB 600 ;
/*
*/
UPDATE ZCLA_ELEDIT SET RECALC = 'Y' WHERE EDITID = :EDITID ;
UPDATE PROJACTS SET ZCLA_RECALC = 'Y' WHERE PROJACT = :ELEMENT ;