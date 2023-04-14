/* Create / Update fix status.
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_ELACT/ZCLA_BUF8'
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE;
#INCLUDE func/ZCLA_LNKGEN
SELECT MAX(LINE) + 1 INTO :LN FROM GENERALLOAD;
/*
*/
GOTO 10 WHERE EXISTS (
SELECT PROJACT
FROM ZCLA_ELACTSTAT
WHERE 0=0
AND   PROJACT = :$.PROJACT
);
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, INT1 , INT2 , TEXT1 )
SELECT :LN , '1' , :$.PROJACT , :$.USER1 , :$.STEPSTATUSDES
FROM DUMMY ;
GOTO 20 ;
/*
*/
LABEL 10 ;
:KEY1 = '' ;
SELECT ITOA(ELACT) INTO :KEY1
FROM ZCLA_ELACTSTAT
WHERE PROJACT = :$.PROJACT ;
INSERT INTO GENERALLOAD (LINE , RECORDTYPE, KEY1 , INT2, TEXT1 )
SELECT :LN , '1' , :KEY1 ,  :$.USER1 , :$.STEPSTATUSDES
FROM DUMMY ;
/*
*/
LABEL 20 ;
#INCLUDE func/ZCLA_RESETERR
EXECUTE INTERFACE 'ZCLA_CHELSTAT', SQL.TMPFILE, '-L', :GEN ;
:i_LOGGEDBY = 'ZCLA_CHELSTAT' ;
#INCLUDE func/ZEMG_ERRMSGLOG
SELECT LINE, RECORDTYPE , LOADED , KEY1 , INT1 , INT2 , TEXT1
FROM GENERALLOAD
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
#INCLUDE func/ZCLA_ERRMSG
UNLINK AND REMOVE GENERALLOAD ;
#INCLUDE func/ZCLA_THROWERR