GOTO 999 WHERE :FORM_INTERFACE = 1 ;
UPDATE PROJACTS
SET ZCLA_DOREFRESH = 'Y'
WHERE PROJACT = :$$$.PROJACT ;
/* */
:DOC = :ELEMENT = 0 ;
SELECT :$$$$$.DOC , :$$$.PROJACT
INTO :DOC , :ELEMENT
FROM DUMMY ;
#INCLUDE PARTARC/ZCLA_ELEMENT
LABEL 999 ;