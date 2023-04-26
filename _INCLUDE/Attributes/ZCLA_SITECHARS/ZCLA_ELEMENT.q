/* :ELEMENT = 42 ; 
UPDATE SITE Uplift : BY ELEMENT
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_SITECHARS/ZCLA_ELEMENT' , :ELEMENT
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
:NAME = '';
:FIXID = 0 ;
:MOD_HT = :STUPLIFT = 0.0 ;
/*
*/
UPDATE PROJACTS
SET   MOD_ST = 1
WHERE   PROJACT = :ELEMENT
;
/* Cursor
*/
DECLARE @ST CURSOR FOR
SELECT ZCLA_SITEFIXUPLIFTS.UPLIFT
,   ZCLA_SITEFIXUPLIFTS.FIXID
,   STRCAT(ZCLA_SITECHARS.CHARNAME 
,   '|' , ZCLA_SITEPERMITVALS.VALUE
)
FROM PROJACTS , ZCLA_SITEFIXUPLIFTS ,ZCLA_SITEATTRIB , ZCLA_SITECHARS , ZCLA_SITEPERMITVALS 
WHERE 0=0
AND   ZCLA_SITECHARS.CHARID = ZCLA_SITEPERMITVALS.CHARID
AND   ZCLA_SITEATTRIB.VALUEID = ZCLA_SITEPERMITVALS.VALUEID
AND   PROJACTS.ZCLA_FIX = ZCLA_SITEFIXUPLIFTS.FIXID
AND   PROJACTS.DOC = ZCLA_SITEATTRIB.DOC 
AND   ZCLA_SITEFIXUPLIFTS.VALUEID = ZCLA_SITEPERMITVALS.VALUEID
AND   ZCLA_SITEATTRIB.CHARID = ZCLA_SITECHARS.CHARID
AND   ZCLA_SITEATTRIB.CHARID = ZCLA_SITEPERMITVALS.CHARID
AND   PROJACTS.ZCLA_PLOT = :ELEMENT
AND   ZCLA_SITEFIXUPLIFTS.UPLIFT <> 0
AND   INACTIVE <> 'Y'
;
OPEN @ST ;
GOTO 999 WHERE :RETVAL = 0 ;
LABEL 500;
FETCH @ST INTO :STUPLIFT , :FIXID , :NAME ;
GOTO 600 WHERE :RETVAL = 0;
/*
*/
SELECT :STUPLIFT , :FIXID , :NAME 
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
SELECT MOD_ST INTO :MOD_ST
FROM ZCLA_SITEFIX
WHERE 0=0
AND   FIXID = :FIXID
AND   DOC = :DOC
;
UPDATE PROJACTS
SET MOD_ST = :MOD_ST * :STUPLIFT
WHERE 0=0
AND   FIXID = :FIXID
AND   ZCLA_PLOT = :ELEMENT
;
/*
*/
LOOP 500;
LABEL 600;
CLOSE @ST ;
LABEL 999;