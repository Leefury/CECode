:PAR1 = '' ;
SELECT :$.@ INTO :PAR1 FROM DUMMY ;
ERRMSG 899 WHERE :$.@ NOT IN (
SELECT STATDES FROM ZCLA_NEXTFIXSTAT
WHERE FIXACT = :$.PROJACT
);
/**/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'STEPSTATUSDES/CHECK-FIELD' , SQL.USER
FROM DUMMY FORMAT ADDTO :DEBUGFILE ;
/*
*/
SELECT SQL.TMPFILE
INTO :GEN FROM DUMMY;
LINK GENERALLOAD TO :GEN;
ERRMSG 1 WHERE :RETVAL = 0 ;
/*
*/
:LN = 0 ;
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD;
/*
*/
GOTO 10 WHERE EXISTS (
SELECT PROJACT
FROM ZCLA_FIXACTSTAT
WHERE 0=0
AND   PROJACT = :$.PROJACT
);
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, INT1 , INT2 , TEXT1 )
SELECT :LN , '1' , :$.PROJACT , SQL.USER , :$.@
FROM DUMMY ;
GOTO 20 ;
/*
*/
LABEL 10 ;
:KEY1 = '' ;
SELECT ITOA(FIXACT) INTO :KEY1
FROM ZCLA_FIXACTSTAT
WHERE PROJACT = :$.PROJACT ;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, KEY1 , INT2, TEXT1 )
SELECT :LN , '1' , :KEY1 ,  SQL.USER , :$.@
FROM DUMMY ;
/*
*/
LABEL 20 ;
#INCLUDE func/ZCLA_RESETERR
EXECUTE INTERFACE 'ZCLA_CHFIXSTAT', SQL.TMPFILE, '-L', :GEN ;
:i_LOGGEDBY = 'ZCLA_CHFIXSTAT' ;
#INCLUDE func/ZEMG_ERRMSGLOG
SELECT LINE, RECORDTYPE , LOADED , KEY1 , INT1 , INT2 , TEXT1
FROM GENERALLOAD
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
#INCLUDE func/ZCLA_ERRMSG
UNLINK AND REMOVE GENERALLOAD ;
#INCLUDE func/ZCLA_THROWERR
