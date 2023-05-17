/* */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_ADDPLOT' FROM DUMMY
FORMAT ADDTO :DEBUGFILE ;
/* vars
*/
:P = :PLOT = :LN = 0 ;
:HOUSETYPEID = :DOC = :EL = 0 ;
:ISHOUSE = :CORE = '' ;
/* Get housetype
*/
LINK ZCLA_HOUSETYPE TO :$.PAR;
ERRMSG 1 WHERE :RETVAL <= 0;
/*
*/
SELECT HOUSETYPEID , DOC , EL , CORE
INTO :HOUSETYPEID , :DOC , :EL , :CORE
FROM ZCLA_HOUSETYPE
WHERE HOUSETYPEID <> 0 ;
SELECT :HOUSETYPEID , :DOC , :EL , :CORE
FROM ZCLA_HOUSETYPE
FORMAT ADDTO :DEBUGFILE ;
UNLINK ZCLA_HOUSETYPE ;
/* Initialise vars
*/
SELECT ISHOUSE INTO :ISHOUSE
FROM ZCLA_PLOTELEMENT
WHERE EL = :EL ;
/*
*/
SELECT 'Adding plots', PLOT
FROM ZCLA_USERADDPLOT
WHERE 0=0
AND   :DEBUG = 1
AND   USER = SQL.USER
FORMAT ADDTO :DEBUGFILE ;
/* Start Cursor
*/
DECLARE E97 CURSOR FOR
SELECT PLOT FROM ZCLA_USERADDPLOT
WHERE 0=0
AND   PLOT > 0
AND   USER = SQL.USER
;
OPEN E97 ;
GOTO 403239 WHERE :RETVAL = 0 ;
LABEL 403231 ;
FETCH E97 INTO :PLOT ;
GOTO 403238 WHERE :RETVAL = 0 ;
/* Link General load table
*/
:LN = 0 ;
SELECT SQL.TMPFILE
INTO :GEN FROM DUMMY;
LINK GENERALLOAD TO :GEN;
ERRMSG 1 WHERE :RETVAL = 0 ;
/* insert Proj line
*/
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD ;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, KEY1)
SELECT :LN , '1' , ITOA(:DOC)
FROM DUMMY ;
/* insert Projact line
*/
SELECT MAX(PROJACTUID) + 1 INTO :P FROM PROJACTS ;
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD ;
GOTO 50 WHERE EXISTS (
SELECT 'x'
FROM PROJACTS
WHERE 0=0
AND   DOC = :DOC
AND   LEVEL = 1
AND   WBS = ITOA(:PLOT)
);
/* Create New plot
*/
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, TEXT1, TEXT2 , INT1 ,
INT2, INT3)
SELECT :LN
,    '2'
,    STRCAT('Plot ' , ITOA(:PLOT))
,    ITOA(:PLOT)
,    :P
,    -1
,    (:ISHOUSE = 'Y' ? :HOUSETYPEID : 0)
FROM DUMMY
;
SELECT :P + 1 INTO :P FROM DUMMY ;
GOTO 99 ;
LABEL 50 ;
/* Use existing plot
*/
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD ;
GOTO 80 WHERE :ISHOUSE = 'Y' ;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, KEY1 )
SELECT :LN
,    '2'
,    ITOA( PROJACT )
FROM PROJACTS
WHERE 0=0
AND   DOC = :DOC
AND   WBS = ITOA(:PLOT)
;
GOTO 90 ;
LABEL 80 ;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, KEY1 , INT3)
SELECT :LN
,    '2'
,    ITOA( PROJACT )
,    :HOUSETYPEID
FROM PROJACTS
WHERE 0=0
AND   DOC = :DOC
AND   WBS = ITOA(:PLOT)
;
LABEL 90;
LABEL 99 ;
/*
ATTACHMENTS FROM HOUSETYPE
*/
/* Find latest attachment for each category */
DECLARE CATCURSOR CURSOR FOR
SELECT DISTINCT ZCLA_FILECATEGORY
FROM EXTFILES, ZCLA_FILECATEGORIES Z
WHERE IV = :HOUSETYPEID
AND EXTFILES.ZCLA_FILECATEGORY = Z.FILECATEGORY
AND   TYPE = '¬'
AND   Z.INTERNALCOPY = 'Y'
;
OPEN CATCURSOR;
GOTO 8081 WHERE :RETVAL = 0;
LABEL 111;
:CAT = 0;
FETCH CATCURSOR INTO :CAT;
GOTO 8080 WHERE :RETVAL = 0;
/* Insert attachments */
:EXTFILENUM = :CURDATE = 0;
:EXTFILEDES = :EXTFILENAME = :CATEGORYNAME = '';
SELECT EXTFILENUM, EXTFILEDES, EXTFILENAME, CATEGORYNAME, CURDATE
INTO :EXTFILENUM, :EXTFILEDES, :EXTFILENAME, :CATEGORYNAME, :CURDATE
FROM ZCLA_FILECATEGORIES, EXTFILES
WHERE TYPE = '¬'
AND   IV = :HOUSETYPEID
AND   ZCLA_FILECATEGORIES.FILECATEGORY = EXTFILES.ZCLA_FILECATEGORY
AND   EXTFILES.ZCLA_FILECATEGORY = :CAT
ORDER BY CURDATE DESC
OFFSET 0 FETCH NEXT 1 ROWS ONLY
;
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD;
INSERT INTO GENERALLOAD(LINE, RECORDTYPE, INT1, TEXT1, TEXT2, TEXT3,
DATE1)
VALUES(:LN + 1, '7', :EXTFILENUM, :EXTFILEDES, :EXTFILENAME,
:CATEGORYNAME, :CURDATE)
;
LOOP 111;
LABEL 8080;
CLOSE CATCURSOR;
LABEL 8081;
SELECT :LN + 1 INTO :LN FROM DUMMY;
/* Check exists
*/
GOSUB 1000 WHERE EXISTS (
SELECT 'x'
FROM PROJACTS
WHERE 0=0
AND   DOC = :DOC
AND   WBS = STRCAT(ITOA(:PLOT) , '.' , ITOA(:EL))
);
/*
Get Status */
SELECT * FROM ZCLA_ELSTATUSES
FORMAT ADDTO :DEBUGFILE
;
:STATUS = 0 ;
:STEPSTATUSDES = '' ;
SELECT STEPSTATUS , STEPSTATUSDES INTO :STATUS, :STEPSTATUSDES
FROM ZCLA_ELSTATUSES WHERE INITFLAG = 'Y' 
;
SELECT :STATUS, :STEPSTATUSDES
FROM DUMMY
FORMAT ADDTO :DEBUGFILE
;
/*
 insert Element line */
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD ;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, INT1, INT2, INT3, INT4,
INT5 , INT6 , INT7, TEXT2)
SELECT :LN
,   '3'
,   EL
,   HOUSETYPEID
,   COL
,   -1
,   :P
,   ALT
,   :STATUS
,   :STEPSTATUSDES
FROM ZCLA_HOUSETYPE
WHERE HOUSETYPEID = :HOUSETYPEID
;
/*
*/
/* Loading
*/
#INCLUDE func/ZCLA_RESETERR
EXECUTE INTERFACE 'ZCLA_LOADPLOT', SQL.TMPFILE, '-L', :GEN ;
:i_LOGGEDBY = 'ZCLA_LOADPLOT';
#INCLUDE func/ZEMG_ERRMSGLOG
/* Log to file
*/
SELECT LINE , RECORDTYPE, LOADED, INT1, INT2, INT3, INT4
,      INT5 , INT6 , INT7, TEXT2
FROM GENERALLOAD
FORMAT ADDTO :DEBUGFILE ;
#INCLUDE func/ZCLA_ERRMSG
UNLINK AND REMOVE GENERALLOAD ;
/*
*/
LOOP 403231 ;
LABEL 403238 ;
CLOSE E97 ;
LABEL 403239 ;
/* Error Handler
*/
SUB 1000 ;
SELECT STRCAT('Plot ' , ITOA(:PLOT)) INTO :PAR1
FROM DUMMY ;
SELECT ELDES INTO :PAR2
FROM ZCLA_PLOTELEMENT
WHERE 0=0
AND   EL = :EL ;
ERRMSG 500 ;
RETURN ;
