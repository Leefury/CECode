/**/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'STEPSTATUSDES/CHECK-FIELD' , SQL.USER
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE;
/*
Changed? */
GOTO 99 WHERE EXISTS(
SELECT 'x'
FROM DUMMY
WHERE :$.STEPSTATUSDES = :$1.STEPSTATUSDES
);
/*
Is new status Valid */
:PAR1 = '' ;
SELECT :$.@ INTO :PAR1 FROM DUMMY ;
ERRMSG 899 WHERE :$.@ NOT IN (
SELECT STATDES FROM ZCLA_NEXTFIXSTAT
WHERE FIXACT = :$.PROJACT
);
/*
*/
#INCLUDE ZCLA_FIXACT/ZCLA_BUF2
#INCLUDE func/ZCLA_THROWERR
LABEL 99 ;