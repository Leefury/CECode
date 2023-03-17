/* Copy FROM site TO site
*/
:DOC = 0 ;
:DOCNO = '' ;
SELECT DOC , DOCNO INTO :DOC , :DOCNO
FROM DOCUMENTS
WHERE 0=0
AND   DOCNO = :$.PR1
AND   TYPE = 'p'
;
/* Check exists
*/
SELECT :$.NAM , :DOCNO
INTO :PAR1, :PAR2
FROM DUMMY ;
ERRMSG 800 WHERE EXISTS (
SELECT 'x'
FROM ZCLA_HOUSETYPE
WHERE 0=0
AND   DOC = :DOC
AND   TYPENAME = :$.NAM
);
SELECT :DOC , :$.HS
FROM DUMMY
FORMAT ADDTO '../ZCLA_COPYHOUSE.txt'
;
SELECT SQL.TMPFILE
INTO :GEN FROM DUMMY;
LINK GENERALLOAD TO :GEN;
ERRMSG 1 WHERE :RETVAL = 0
;
/*
*/
:LN = 0 ;
/* insert Proj line */
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, KEY1)
SELECT :LN , '1' , ITOA(:DOC)
FROM DUMMY
;
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD ;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, INT1, INT2, INT3, INT4 ,
CHAR1 , CHAR2 , TEXT1, TEXT2 , CHAR3)
SELECT :LN
,   '6'
,   :DOC
,   EL
,   HOUSETYPEID
,   COL
,   '¬'
,   :$.LNK
,   :$.NAM
,   :$.DES
,   'Y'
FROM ZCLA_HOUSETYPE
WHERE 0=0
AND   HOUSETYPEID  = :$.HS
;
DELETE FROM ERRMSGS
WHERE 0=0
AND   USER = SQL.USER
AND   TYPE = 'i'
;
EXECUTE INTERFACE 'ZCLA_LOADPLOT', SQL.TMPFILE, '-L', :GEN
;
:i_LOGGEDBY = 'ZCLA_COPYHOUSE';
#INCLUDE func/ZEMG_ERRMSGLOG
SELECT LINE, RECORDTYPE , KEY1 , LOADED , INT1, INT2, INT3, INT4 ,
CHAR1 , CHAR2 , TEXT1, TEXT2
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
