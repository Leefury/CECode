/* 
Get alt from element */
:ALT = 0 ;
SELECT ZCLA_ALT INTO :ALT
FROM PROJACTS 
WHERE 0=0
AND   PROJACT = :ELEMENT
;