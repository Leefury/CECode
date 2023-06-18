/* Build the BoM
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'STEPSTATUSDES/ZCLA_POST-FIELD' , SQL.USER
FROM DUMMY FORMAT ADDTO :DEBUGFILE ;
:ERR = '' ;
:DOC = :$$$.DOC ;
:FIXACT = :$.PROJACT ;
:ELACT = :$$.PROJACT ;
:PLOT = :$$$.PROJACT ;
:HOUSETYPEID = :$$.ZCLA_HOUSETYPEID ;
:FIX = :$.ZCLA_FIX ;
/* Changed ?
*/
GOTO 99 WHERE :$1.STEPSTATUSDES = :$.STEPSTATUSDES ;
/* In kit BoM state ?
*/
:KITFLAG = '' ;
SELECT ( ZCLA_KITFLAG = 'Y' ? 'Y' : 'N' ) INTO :KITFLAG
FROM ZCLA_FIXSTATUSES 
WHERE STEPSTATUSDES = :$.STEPSTATUSDES
;
/*
*/
SELECT :FIXACT
,  :DOC
,  :HOUSETYPEID
,  :FIX
,  :ELACT
,  :KITFLAG
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
:IGNOREROOM = 0 ;
#INCLUDE PARTARC/ZCLA_TREEREPLACE
WRNMSG 800 WHERE :ERR = 'Y' ;
/*
*/
LABEL 99;
/*
Update Part use */
#INCLUDE PART/ZCLA_BUF2
