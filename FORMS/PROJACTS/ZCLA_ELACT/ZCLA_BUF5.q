/* 
Add Consumer units */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_ELACT/ZCLA_BUF5'
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/* */
:HOUSETYPE = 0 ;
SELECT ZCLA_HOUSETYPEID INTO :HOUSETYPE
FROM PROJACTS WHERE PROJACT = :ELEMENT ;
/* 
Declare CUNIT cursor */
DECLARE @CUCURSOR CURSOR FOR
SELECT CU.CONSUMERUNIT
FROM ZCLA_CONSUMERUNITS CU
WHERE 0=0
AND CU.HOUSETYPEID = :HOUSETYPE
;
OPEN @CUCURSOR;
GOTO 9898 WHERE :RETVAL <= 0 ;
LABEL 1212 ;
:CONSUMERUNIT = 0 ;
FETCH @CUCURSOR INTO :CONSUMERUNIT ;
GOTO 9898 WHERE :RETVAL <= 0 ;
/*
*/
:ROOM = :PART = 0 ;
SELECT    PART , ROOM INTO :PART , :ROOM
FROM ZCLA_CONSUMERUNITS 
WHERE CONSUMERUNIT = :CONSUMERUNIT 
;
/*
Does the part exist ? */
GOTO 91 WHERE EXISTS (
SELECT 'x' FROM ZCLA_PLOTCU
WHERE 0=0
AND   PROJACT = :ELEMENT
AND   PART = :PART
);
INSERT INTO ZCLA_PLOTCU( PROJACT , PART , ROOM)
SELECT :ELEMENT , :PART , :ROOM
FROM DUMMY ;
/*
*/
LABEL 91 ;
UPDATE ZCLA_PLOTCU
SET    ROOM = :ROOM
WHERE 0=0
AND   PROJACT = :ELEMENT
AND   PART = :PART
;
/*
*/
:NEWCU = 0;
SELECT CONSUMERUNIT INTO :NEWCU
FROM ZCLA_PLOTCU
WHERE 0=0
AND   PROJACT = :ELEMENT
AND   PART = :PART ;
/*
*/
INSERT INTO ZCLA_PLOTCUCFG ( CONSUMERUNIT
,   RCD
,   KLINE
,   PART
,   DEVICE
,   WAYNO
)
SELECT :NEWCU 
,   ZCLA_CUNITCONFIG.RCD
,   ZCLA_CUNITCONFIG.KLINE
,   PART.PART
,   ZCLA_CUCONFIG_OPT.DEVICE
,   ZCLA_CUNITCONFIG.WAYNO
FROM  ZLIA_CAB_CONFIG  , ZLIA_PDV_CONFIG  , ZLIA_PDV_DEFOPT  
,     PART  , ZCLA_CUCONFIG_OPT  , ZCLA_CUNITCONFIG   
WHERE 0=0
AND   ZCLA_CUNITCONFIG.DEVICE = ZCLA_CUCONFIG_OPT.DEVICE
AND   PART.ZLIA_PDV_DEFID = ZLIA_PDV_DEFOPT.PDV_DEFID
AND   ZLIA_PDV_DEFOPT.DEVTYPEID = ZLIA_PDV_CONFIG.DEVTYPEID
AND   PART.ZLIA_CIRCCAB_DEFID = ZLIA_CAB_CONFIG.CABLEID
AND   ZCLA_CUNITCONFIG.PART = PART.PART 
AND   ZCLA_CUNITCONFIG.CONSUMERUNIT = 0 + :CONSUMERUNIT 
;
LABEL 99 ;
/*
*/
LOOP 1212;
LABEL 9898;
CLOSE @CUCURSOR;
LABEL 9999 ;
/*
*/

