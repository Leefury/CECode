/* */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_ELACT/POST-UPDATE'
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
#INCLUDE ZCLA_ELACT/ZCLA_FORMVAR
GOTO 999 WHERE :EDITFLAG <> 'Y' ;
#INCLUDE ZCLA_ELACT/ZCLA_BUF4
LABEL 999 ;
