/* Skip if interface
*/
GOTO 999 WHERE :FORM_INTERFACE = 1;
#INCLUDE ZCLA_ELACT/ZCLA_BUF3
/*
Update screen values */
SELECT 'Y'
INTO :$$.CHANGEFLAG
FROM DUMMY
;
LABEL 999 ;
