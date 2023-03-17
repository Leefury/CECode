/*
:ELEMENT = 42 ; 
UPDATE Plot Uplift : BY ELEMENT
*/
:NAME = '';
:FIXID = 0 ;
:MOD_PL = :PLUPLIFT = 0.0 ;
/*
*/
UPDATE PROJACTS
SET   MOD_PL = 1
WHERE   PROJACT = :ELEMENT
;
DECLARE @PL CURSOR FOR
SELECT PROJACTS.ZCLA_FIX 
,   ZCLA_PLOTFIXUPLIFTS.UPLIFT
,   STRCAT(ZCLA_PLOTCHARS.CHARNAME 
,   '|' 
,   ZCLA_PLOTPERMITVALS.VALUE)
FROM PROJACTS , ZCLA_PLOTATTR, ZCLA_PLOTCHARS , ZCLA_PLOTPERMITVALS , ZCLA_PLOTFIXUPLIFTS 
WHERE 0=0
AND   PROJACTS.ZCLA_PLOT = ZCLA_PLOTATTR.PROJACT
AND   ZCLA_PLOTCHARS.CHARID = ZCLA_PLOTATTR.CHARID
AND   ZCLA_PLOTATTR.CHARID = ZCLA_PLOTPERMITVALS.CHARID
AND   ZCLA_PLOTATTR.VALUEID = ZCLA_PLOTPERMITVALS.VALUEID
AND   ZCLA_PLOTPERMITVALS.VALUEID = ZCLA_PLOTFIXUPLIFTS.VALUEID
AND   PROJACTS.ZCLA_FIX = ZCLA_PLOTFIXUPLIFTS.FIXID
AND   ZCLA_PLOTFIXUPLIFTS.UPLIFT <> 0
AND   INACTIVE <> 'Y'
AND   PROJACTS.ZCLA_PLOT = :ELEMENT
;
OPEN @PL ;
GOTO 9999 WHERE :RETVAL = 0 ;
LABEL 5009;
FETCH @PL INTO :FIXID , :PLUPLIFT , :NAME ;
GOTO 6009 WHERE :RETVAL = 0;
/*
*/
SELECT MOD_PL INTO :MOD_PL
FROM PROJACTS
WHERE 0=0
AND   ZCLA_FIX = :FIXID
AND   PROJACT = :ELEMENT
;
UPDATE PROJACTS
SET MOD_PL = :MOD_PL * :PLUPLIFT
WHERE 0=0
AND   ZCLA_FIX = :FIXID
AND   PROJACT = :ELEMENT
;
/*
*/
LOOP 5009;
LABEL 6009;
CLOSE @PL ;
LABEL 9999;