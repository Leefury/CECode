/*
:ELEMENT = 42 ;
Update fix uplift by ELEMENT
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'DOCUMENTS_p/ZCLA_ELEMENT' , :ELEMENT
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
:PROJACT = 0 ;
:UPLIFT = :POINTS = :FIXUPLIFT = 0.0 ;
UPDATE PROJACTS
SET   ZCLA_NEGPOINT = 0
,     ZCLA_BRUPLIFT = 0
WHERE PROJACTS.ZCLA_PLOT = :ELEMENT ;
/*
*/
DECLARE @FIX96 CURSOR FOR
SELECT  PROJACTS.PROJACT
,   ZCLA_PROJBRANCHFIX.UPLIFT
,   ZCLA_BRANCHFIX.POINTS
,   ZCLA_PROJNEGFIX.FIXUPLIFT
FROM DOCUMENTS , ZCLA_FIXES , PROJACTS , ZCLA_BRANCHFIX ? ,
ZCLA_PROJBRANCHFIX ? , ZCLA_PROJNEGFIX ?
WHERE 0=0
AND   ZCLA_FIXES.FIXID = PROJACTS.ZCLA_FIX
AND   DOCUMENTS.DOC = PROJACTS.DOC
AND   ZCLA_PROJNEGFIX.FIX = ZCLA_FIXES.FIXID
AND   ZCLA_PROJNEGFIX.PROJ = PROJACTS.DOC
AND   ZCLA_PROJBRANCHFIX.FIXID = ZCLA_FIXES.FIXID
AND   ZCLA_PROJBRANCHFIX.FIXID = PROJACTS.ZCLA_FIX
AND   ZCLA_PROJBRANCHFIX.PROJ = PROJACTS.DOC
AND   ZCLA_BRANCHFIX.BRANCH = DOCUMENTS.ZCLA_BRANCH
AND   ZCLA_BRANCHFIX.FIXID = ZCLA_FIXES.FIXID
AND   PROJACTS.ZCLA_PLOT = :ELEMENT
;
OPEN @FIX96 ;
GOTO 9999 WHERE :RETVAL = 0 ;
LABEL 5009;
FETCH @FIX96 INTO :PROJACT , :UPLIFT , :POINTS , :FIXUPLIFT ;
GOTO 6009 WHERE :RETVAL = 0 ;
/*
*/
SELECT :PROJACT , :UPLIFT , :POINTS , :FIXUPLIFT
FROM DUMMY 
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
UPDATE PROJACTS
SET   ZCLA_NEGPOINT = :FIXUPLIFT
,     ZCLA_BRUPLIFT = :POINTS + :UPLIFT
WHERE PROJACT = :PROJACT ;
/*
*/
LOOP 5009 ;
LABEL 6009 ;
CLOSE @FIX96 ;
LABEL 9999 ;
