/*LABEL : 8881*/
/*--*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ADDNOTE'
FROM DUMMY
FORMAT :DEBUGFILE
;
LINK ZCLA_CONTRACTS TO :$.PAR;
GOTO 8881 WHERE :RETVAL <= 0;
SELECT DOC
FROM ZCLA_CONTRACTS
WHERE DOC > 0
FORMAT ADDTO :DEBUGFILE
;
/*--*/
SELECT CONTRACT
INTO :CONTRACT
FROM ZCLA_CONTRACTS
WHERE CONTRACT > 0
;
/*--*/
GOTO 8882 WHERE EXISTS (
SELECT 'X'
FROM ZCLA_CONTRACTTEXT2
WHERE CONTRACT = 0 -:CONTRACT
AND TEXTLINE > 0
)
;
WRNMSG 8882;
GOTO 8881;
LABEL 8882;
/*--*/
SELECT TEXT
FROM ZCLA_CONTRACTTEXT2
WHERE CONTRACT = 0 - :CONTRACT
FORMAT ADDTO :DEBUGFILE
;
/*--*/
SELECT MAX(TEXTLINE) - 3
INTO :LAST3
FROM ZCLA_CONTRACTTEXT2
WHERE CONTRACT = 0 - :CONTRACT
;
/*--*/
SELECT 1
INTO :HRLINE
FROM ZCLA_CONTRACTTEXT2
WHERE CONTRACT = 0 - :CONTRACT
AND TEXTLINE >= :LAST3
AND TEXT LIKE '%<hr%'
;
/*--ADD TO LOG*/
:MAXLINE = 0;
:MAXORD = 0;
SELECT MAX(TEXTLINE) + 1
INTO :MAXLINE
FROM ZCLA_CONTRACTTEXT2
WHERE CONTRACT = 0 - :CONTRACT
;
SELECT MAX(TEXTORD) + 1
INTO :MAXORD
FROM ZCLA_CONTRACTTEXT2
WHERE CONTRACT = 0 - :CONTRACT
;
/*--*/
INSERT INTO ZCLA_CONTRACTTEXT2  (CONTRACT, TEXT, TEXTLINE, TEXTORD)
SELECT 0 - :CONTRACT, '<hr ss="">', :MAXLINE, :MAXORD
FROM DUMMY
WHERE :HRLINE <> 1
;
/*--*/
/*LABELS: 1111, 1112, 1113, 188, 18889 */
/*First line*/
SELECT SUBSTR(TEXT, STRINDEX(TEXT, '</style>', 1) + 8, 35)
INTO :FIRSTLINE
FROM ZCLA_CONTRACTTEXT2
WHERE CONTRACT = 0 - :CONTRACT
AND TEXTLINE = 3
;
/*Calculating The Num of rows that will be inserted*/
SELECT COUNT(*) + 7 /*+ 6 For the Email Label*/
INTO :EXTRALINES
FROM ZCLA_CONTRACTTEXT2
WHERE CONTRACT = 0 - :CONTRACT
AND TEXTLINE > 3
;
:EXTRALINES = (:FIRSTLINE = '<p >' ? :EXTRALINES :
(:FIRSTLINE = '' ? :EXTRALINES : :EXTRALINES + 1));
/*--*/
/*If the form is empty, add the html lines and skip to the Email
Label*/
GOTO 1111 WHERE EXISTS (
SELECT 'X'
FROM ZCLA_CONTRACTTEXT
WHERE CONTRACT = 0 - :CONTRACT
)
;
SELECT 'ZCLA_CONTRACTTEXT EMPTY'
FROM DUMMY
FORMAT ADDTO :DEBUGFILE;
/*Insert the html style lines*/
INSERT INTO ZCLA_CONTRACTTEXT (CONTRACT, TEXT, TEXTLINE, TEXTORD,
ZGEM_NOTE)
VALUES (0 - :CONTRACT, '<style> p,div,li', 1, 1, 'Y');
INSERT INTO ZCLA_CONTRACTTEXT (CONTRACT, TEXT, TEXTLINE, TEXTORD,
ZGEM_NOTE)
VALUES (0 - :CONTRACT
,
'{margin:0cm;font-size:10pt;font-family:\'Verdana\';}li > font >p'
, 2, 2, 'Y');
INSERT INTO ZCLA_CONTRACTTEXT (CONTRACT, TEXT, TEXTLINE, TEXTORD,
ZGEM_NOTE)
VALUES (0 - :CONTRACT, '{display: inline-block;}</style>', 3, 3,
'Y');
GOTO 1112;
LABEL 1111;
/*update the TEXTLINE to fit the text in*/
DECLARE TEXTC CURSOR FOR
SELECT CONTRACT, TEXTLINE, TEXTORD
FROM ZCLA_CONTRACTTEXT
WHERE CONTRACT = 0 - :CONTRACT
AND TEXTLINE > 3
ORDER BY TEXTLINE DESC
;
/*--*/
OPEN TEXTC;
GOTO 18889 WHERE :RETVAL <= 0;
LABEL 188;
FETCH TEXTC
INTO :TCONTRACT, :TTEXTLINE, :TTEXTORD;
GOTO 18889 WHERE :RETVAL <= 0;
/*--*/
/*Indrement the TEXTLINE and TEXTORD*/
UPDATE ZCLA_CONTRACTTEXT
SET TEXTLINE = :TTEXTLINE + :EXTRALINES
, TEXTORD = :TTEXTORD + :EXTRALINES
WHERE CONTRACT = :TCONTRACT
AND TEXTLINE = :TTEXTLINE
;
/*--*/
LOOP 188;
LABEL 18889;
CLOSE TEXTC;
/*--*/
LABEL 1112;
/*--*/
SELECT *
FROM ZCLA_CONTRACTTEXT
WHERE CONTRACT = 0 - :CONTRACT
FORMAT ADDTO :DEBUGFILE;
/*Emial Label ------------------------*/
SELECT STRCAT(
DTOA(SQL.DATE, 'DD/MM/YY'),' ',DTOA(SQL.DATE,'hh:mm'),
'</p>')
INTO :DATECHAR
FROM DUMMY
;
/*--*/
SELECT STRCAT(USERLOGIN, '<p>')
INTO :USERLOGIN
FROM USERS
WHERE USER = SQL.USER
;
/*--*/
INSERT INTO ZCLA_CONTRACTTEXT (CONTRACT, TEXT, TEXTLINE, TEXTORD,
ZGEM_NOTE)
VALUES (0 - :CONTRACT, '<p>Note recorded on ', 4, 4, 'Y');
INSERT INTO ZCLA_CONTRACTTEXT (CONTRACT, TEXT, TEXTLINE, TEXTORD,
ZGEM_NOTE)
VALUES (0 - :CONTRACT, :DATECHAR, 5, 5, 'Y');
INSERT INTO ZCLA_CONTRACTTEXT (CONTRACT, TEXT, TEXTLINE, TEXTORD,
ZGEM_NOTE)
VALUES (0 - :CONTRACT,
'<p style = "margin-bottom: 10px">Recordedby: '
, 6, 6, 'Y');
INSERT INTO ZCLA_CONTRACTTEXT (CONTRACT, TEXT, TEXTLINE, TEXTORD,
ZGEM_NOTE)
VALUES (0 - :CONTRACT, :USERLOGIN, 7, 7, 'Y');
/*Emial Label ------------------------*/
/*Actual message*/
:LINETOINSERT = 7;
GOTO 1113 WHERE :FIRSTLINE = '<p >' OR :FIRSTLINE = '';
:LINETOINSERT = :LINETOINSERT + 1;
INSERT INTO ZCLA_CONTRACTTEXT (CONTRACT, TEXT, TEXTLINE, TEXTORD,
ZGEM_NOTE)
VALUES (0 - :CONTRACT, :FIRSTLINE, :LINETOINSERT, :LINETOINSERT,
'Y');
LABEL 1113;
:LINETOINSERT = :LINETOINSERT + 1;
INSERT INTO ZCLA_CONTRACTTEXT (CONTRACT, TEXT, TEXTLINE, TEXTORD,
ZGEM_NOTE)
SELECT CONTRACT, TEXT, SQL.LINE + :LINETOINSERT, SQL.LINE +
:LINETOINSERT, 'Y'
FROM ZCLA_CONTRACTTEXT2
WHERE CONTRACT = 0 - :CONTRACT
AND TEXTLINE > 3
;
/*Actual message*/
DELETE FROM ZCLA_CONTRACTTEXT2
WHERE CONTRACT = 0 - :CONTRACT
;
UPDATE ZCLA_CONTRACTS
SET ZGEM_EMAILFLAG = 1
WHERE CONTRACT = :CONTRACT
;
SELECT ZGEM_EMAILFLAG, :CONTRACT
FROM ZCLA_CONTRACTS
WHERE CONTRACT = :CONTRACT
FORMAT ADDTO :DEBUGFILE;
WRNMSG 8881;
LABEL 8881;
