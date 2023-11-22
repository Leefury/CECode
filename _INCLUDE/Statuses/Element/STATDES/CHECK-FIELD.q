/**/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'STEPSTATUSDES/CHECK-FIELD' , SQL.USER
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE;
/*
Is new status Valid */
:PAR1 = '' ;
SELECT :$.@ INTO :PAR1 FROM DUMMY ;
ERRMSG 899 WHERE :$.@ NOT IN (
SELECT STATDES FROM ZCLA_NEXTELSTAT
WHERE ELACT = :$.PROJACT
);
/*
The plot is on hold? */
ERRMSG 898 WHERE EXISTS (
SELECT 'x'
FROM PROJACTS , STEPSTATUSES
WHERE 0=0
AND   PROJACTS.STEPSTATUS = STEPSTATUSES.STEPSTATUS
AND   STEPSTATUSES.ZCLA_HOLD = 'Y'
AND   PROJACT = (
SELECT ZCLA_PLOT
FROM PROJACTS
WHERE PROJACT = :$.PROJACT
)
AND NOT EXISTS ( /* CAN EDIT */
SELECT 'x' FROM ZCLA_ELSTATUSES
WHERE 0=0
AND   STEPSTATUSDES = :$.@
AND   EDITFLAG = 'Y'
));
/*
Has an open package? */
ERRMSG 897 WHERE EXISTS (
SELECT 'x'
FROM ZCLA_ELEDIT
WHERE 0=0
AND   PROJACT = :$.PROJACT
AND   PACKAGEFLAG = 'Y'
AND   CLOSEFLAG <> 'Y'
AND   ( PACKAGENAME = '' OR PACKAGEPRICE = 0 )
);
/*
Has Missing */
ERRMSG 896 WHERE EXISTS (
SELECT 'x'
FROM PROJACTS
WHERE 0=0
AND   PROJACT = :$.PROJACT
AND   ZCLA_MISSINGREPL = 'Y'
AND NOT EXISTS ( /* CAN EDIT */
SELECT 'x' FROM ZCLA_ELSTATUSES
WHERE 0=0
AND   STEPSTATUSDES = :$.@
AND   EDITFLAG = 'Y'
));