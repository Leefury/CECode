/* Update the core type from a project
*/
:LN = :DOC = :UPD = 0 ;
SELECT DOCUMENTS.CUST INTO :DOC
FROM ZCLA_HOUSETYPE , DOCUMENTS
WHERE 0=0
AND   ZCLA_HOUSETYPE.DOC = DOCUMENTS.DOC
AND   ZCLA_HOUSETYPE.HOUSETYPEID = :$.HS ;
/*
*/
SELECT SQL.TMPFILE
INTO :GEN FROM DUMMY;
LINK GENERALLOAD TO :GEN;
ERRMSG 1 WHERE :RETVAL = 0
;
/* insert Proj line
*/
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, KEY1)
SELECT :LN , '1' , ITOA(:DOC)
FROM DUMMY
;
SELECT HOUSETYPEID INTO :UPD
FROM ZCLA_HOUSETYPE
WHERE 0=0
AND   DOC = :DOC
AND   TYPENAME = :$.TYP
;
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD ;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE , KEY1 , INT10 , DATE1 , CHAR3 )
SELECT :LN
,   '2'
,   ITOA( :UPD )
,   :$.HS
,   SQL.DATE
,   'Y'
FROM DUMMY
;
DELETE FROM ERRMSGS
WHERE 0=0
AND   USER = SQL.USER
AND   TYPE = 'i'
;
EXECUTE INTERFACE 'ZCLA_COPYTOCORE', SQL.TMPFILE, '-L', :GEN
;
:i_LOGGEDBY = 'ZCLA_COPYHOUSE';
#INCLUDE func/ZEMG_ERRMSGLOG
SELECT LINE, RECORDTYPE , KEY1 , LOADED , INT1, INT2, INT3, INT4 ,
CHAR1 , CHAR2 , TEXT1, TEXT2 , DATE1
FROM GENERALLOAD
FORMAT ADDTO '../ZCLA_COPYHOUSE.txt'
;
SELECT * FROM ERRMSGS
WHERE 0=0
AND   USER = SQL.USER
AND   TYPE = 'i'
FORMAT ADDTO '../ZCLA_COPYHOUSE.txt'
;
UNLINK GENERALLOAD ;
