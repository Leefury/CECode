GOTO 99 WHERE :FORM_INTERFACE = 1 ;
DELETE FROM ZCLA_USERLOCK
WHERE USER = SQL.USER ;
/*
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'COLNAME/PRE-FIELD' , :$.PROJACT , :$.DOC
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE;
/*
*/
:ELEMENT = :ALT = 0 ;
SELECT :$.PROJACT INTO :ELEMENT FROM DUMMY ;
DELETE FROM ZCLA_USRCOLSEL WHERE USER = SQL.USER ;
#INCLUDE ZCLA_ALTMANUF/ZCLA_ELEMENT
INSERT INTO ZCLA_USRCOLSEL (USER , COL)
SELECT DISTINCT SQL.USER, ZCLA_ACCYCOL.COL
FROM ZCLA_PROJMANF , ZCLA_ACCYCOL
WHERE 0=0
AND   ZCLA_ACCYCOL.COL = ZCLA_PROJMANF.COL
AND   ALT = :ALT
AND   DOC = :$.DOC
;
#INCLUDE ZCLA_ELACT/ZCLA_BUF7
LABEL 99 ;
