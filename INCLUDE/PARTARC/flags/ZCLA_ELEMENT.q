/* Set ELEMENT Missing flag */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'PARTARC/ZCLA_ELEMENT' , :ELEMENT , SQL.USER
FROM DUMMY FORMAT ADDTO :DEBUGFILE ;
/*
Clear Room Flag */
UPDATE  ZCLA_PLOTROOMS
SET     ZCLA_MISSINGREPL = ''
WHERE   ROOM IN (
SELECT  ROOM
FROM    ZCLA_PLOTROOMS
WHERE   0=0
AND   PROJACT = :ELEMENT
);
/*
Update rooms missing part flag */
UPDATE ZCLA_PLOTROOMS
SET     ZCLA_MISSINGREPL = 'Y'
WHERE 0=0
AND   PROJACT = :ELEMENT
AND   ROOM IN (
SELECT ZCLA_PLOTROOMS.ROOM
FROM   ZCLA_PLOTCOMPONENT , ZCLA_PLOTROOMS
WHERE  0=0
AND    ZCLA_PLOTROOMS.PROJACT = :ELEMENT
AND    ZCLA_PLOTCOMPONENT.ROOM = ZCLA_PLOTROOMS.ROOM
AND    ZCLA_PLOTCOMPONENT.ZCLA_MISSINGREPL = 'Y'
);
SELECT 'missing room', ZCLA_PLOTROOMS.ROOM
FROM   ZCLA_PLOTCOMPONENT , ZCLA_PLOTROOMS
WHERE  0=0
AND    ZCLA_PLOTROOMS.PROJACT = :ELEMENT
AND    ZCLA_PLOTCOMPONENT.ROOM = ZCLA_PLOTROOMS.ROOM
AND    ZCLA_PLOTCOMPONENT.ZCLA_MISSINGREPL = 'Y'
AND    :DEBUG = 1 
FORMAT ADDTO :DEBUGFILE ;
/*
Clear House Flag */
UPDATE  PROJACTS
SET     ZCLA_MISSINGREPL = ''
WHERE   0=0
AND     PROJACT = :ELEMENT
;
/*
Update Element missing part flag */
GOTO 799 WHERE NOT EXISTS (
SELECT  'x' FROM ZCLA_PLOTROOMS
WHERE   0=0
AND     ZCLA_MISSINGREPL = 'Y'
AND     PROJACT = :ELEMENT
);
UPDATE  PROJACTS
SET     ZCLA_MISSINGREPL = 'Y'
WHERE   0=0
AND     PROJACT = :ELEMENT
;
LABEL 799 ;
/* 
Get the plot PROJACT */
:PLOT = 0 ;
SELECT PROJACT INTO :PLOT
FROM PROJACTS
WHERE 0=0
AND   PROJACT IN (
SELECT ZCLA_PLOT FROM PROJACTS
WHERE 0=0
AND   PROJACT = :ELEMENT
);
/*
Clear Plot flag */
UPDATE PROJACTS SET ZCLA_MISSINGREPL = ''
WHERE 0=0
AND   PROJACT = :PLOT ;
/* */
SELECT WBS , :PLOT , ZCLA_MISSINGREPL
FROM PROJACTS 
WHERE 0=0
AND   PROJACT = :PLOT 
AND   :DEBUG = 1
FORMAT ADDTO :DEBUGFILE;
/*
Set Plot Flag */
GOTO 899 WHERE NOT EXISTS(
SELECT 'x'
FROM PROJACTS
WHERE 0=0
AND   ZCLA_PLOT = :PLOT
AND   ZCLA_MISSINGREPL = 'Y'
);
SELECT 'Set plot missing', :PLOT
FROM DUMMY 
WHERE 0=0
AND   :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
UPDATE PROJACTS SET ZCLA_MISSINGREPL = 'Y'
WHERE 0=0
AND   PROJACT = :PLOT ;
/*
*/
LABEL 899 ;