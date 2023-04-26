/* 
Check if all the PLOTS in this SITE
are closed/cancelled. */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'PROJACT/ZCLA_POST-FORM'
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/* 
Skip where open PLOTS */
GOTO 99 WHERE EXISTS (
SELECT 'x'
FROM PROJACTS , STEPSTATUSES
WHERE 0=0
AND   PROJACTS.STEPSTATUS = STEPSTATUSES.STEPSTATUS 
AND   CANCELFLAG <> 'Y'
AND   CLOSEFLAG <> 'Y'
AND   PROJACTS.DOC = :$$.DOC
AND   LEVEL = 1
);
:LN = 0 ;
SELECT SQL.TMPFILE
INTO :GEN FROM DUMMY;
LINK GENERALLOAD TO :GEN;
ERRMSG 1 WHERE :RETVAL = 0 ;
/*
Get the closing statusdes for the SITE */
:STATDES = '' ;
SELECT NEXTSTAT.STATDES INTO :STATDES
FROM   DOCSTATS NEXTSTAT 
,      DOCUMENTSA 
,      DOCSTATS 
WHERE 0=0
AND   DOCUMENTSA.ASSEMBLYSTATUS = DOCSTATS.DOCSTAT
AND   NEXTSTAT.DOCSTAT = DOCSTATS.FINALSTAT
AND   DOCUMENTSA.DOC = :$$.DOC
;
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, KEY1 , TEXT1)
SELECT :LN + 0, '1' , ITOA(:$$.DOC) , :STATDES
FROM DUMMY ;
/*
*/
#INCLUDE func/ZCLA_RESETERR
EXECUTE INTERFACE 'ZCLA_UPDSTAT', SQL.TMPFILE, '-L', :GEN ;
:i_LOGGEDBY = 'ZCLA_UPDSTAT' ;
#INCLUDE func/ZEMG_ERRMSGLOG
SELECT LINE, RECORDTYPE , LOADED , KEY1 , TEXT1
FROM GENERALLOAD
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
#INCLUDE func/ZCLA_ERRMSG
UNLINK AND REMOVE GENERALLOAD ;
#INCLUDE func/ZCLA_THROWERR
LABEL 99 ;

