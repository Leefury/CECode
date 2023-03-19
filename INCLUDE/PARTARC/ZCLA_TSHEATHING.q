/* */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'PARTARC/ZCLA_TSHEATHING' 
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
:PARENTPROJACT = :PARENTKLINE = 0
;
SELECT PROJACT , KLINE
INTO :PARENTPROJACT , :PARENTKLINE
FROM ZCLA_PROJACTTREE , PART
WHERE 0=0
AND   ZCLA_PROJACTTREE.SONPART = PART.PART
AND   PART.ZCLA_THICKNESS > 0 
AND   ZCLA_PROJACTTREE.COPYUSER = SQL.USER ;
/*
*/
:MM25QUANT = :MM38QUANT = 0.0;
SELECT SUM(SONQUANT) * 0.05
INTO :MM25QUANT
FROM ZCLA_PROJACTTREE , PART
WHERE 0=0
AND   ZCLA_PROJACTTREE.SONPART = PART.PART
AND   PART.ZCLA_THICKNESS > 0 
AND   ZCLA_PROJACTTREE.COPYUSER = SQL.USER ;
/*
*/
SELECT SUM(SONQUANT) * 0.05 + 1
INTO :MM38QUANT
FROM ZCLA_PROJACTTREE , PART
WHERE 0=0
AND   ZCLA_PROJACTTREE.SONPART = PART.PART
AND   PART.ZCLA_THICKNESS = 2.5
AND   ZCLA_PROJACTTREE.COPYUSER = SQL.USER ;
/*
*/
SELECT :MM25QUANT , :MM38QUANT
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
#INCLUDE PART/ZCLA_BUF1
SELECT :MM25PART , :MM38PART
FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
:LN = 0 ;
SELECT MAX (KLINE)  + 1 INTO :LN
FROM ZCLA_PROJACTTREE
WHERE COPYUSER = SQL.USER 
;
/* Insert into ZCLA_PROJACTTREE for 25mm sheathing*/
INSERT INTO ZCLA_PROJACTTREE ( COPYUSER
,   PROJACT
,   KLINE
,   SONPART
,   SONQUANT
,   USER
,   UDATE
,   DUEDATE
,   RATIO
,   DOC
,   ZCLA_ROOM
,   WHITE
,   COL
)
SELECT SQL.USER
,   PROJACT
,   :LN
,   :MM25PART 
,   :MM25QUANT 
,   SQL.USER
,   SQL.DATE
,   SQL.DATE
,   :MM25QUANT
,   DOC
,   ( :IGNOREROOM = 1 ? 0 : ZCLA_ROOM )
,   WHITE
,   COL
FROM ZCLA_PROJACTTREE
WHERE 0=0
AND   PROJACT = :PARENTPROJACT 
AND   KLINE =   :PARENTKLINE
;
/* Insert into ZCLA_PROJACTTREE for 38mm sheathing*/
SELECT MAX (KLINE)  + 1 INTO :LN
FROM ZCLA_PROJACTTREE
WHERE COPYUSER = SQL.USER 
;
INSERT INTO ZCLA_PROJACTTREE ( COPYUSER
,   PROJACT
,   KLINE
,   SONPART
,   SONQUANT
,   USER
,   UDATE
,   DUEDATE
,   RATIO
,   DOC
,   ZCLA_ROOM
,   WHITE
,   COL
)
SELECT SQL.USER
,   PROJACT
,   :LN
,   :MM38PART 
,   :MM38QUANT 
,   SQL.USER
,   SQL.DATE
,   SQL.DATE
,   :MM25QUANT
,   DOC
,   ( :IGNOREROOM = 1 ? 0 : ZCLA_ROOM )
,   WHITE
,   COL
FROM ZCLA_PROJACTTREE
WHERE 0=0
AND   PROJACT = :PARENTPROJACT 
AND   KLINE =   :PARENTKLINE
;