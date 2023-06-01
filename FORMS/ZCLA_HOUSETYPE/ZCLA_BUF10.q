/*
Get Split and Markup */
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_HOUSETYPE/ZCLA_BUF10' , :HOUSETYPE
FROM DUMMY
WHERE :DEBUG = 2
FORMAT ADDTO :DEBUGFILE ;
/*
Use the default or housetype split ? */
:HTSPLIT = 0 ;
SELECT (SUM ( ZCLA_SITEELFIX.SPLIT ) = 100 ? 1 : 0)
INTO :HTSPLIT
FROM ZCLA_SITEELFIX , ZCLA_HOUSETYPE
WHERE 0=0
AND   ZCLA_HOUSETYPE.EL = ZCLA_SITEELFIX.EL
AND   HOUSETYPEID = :HOUSETYPE
;
INSERT INTO ZCLA_SPLIT (FIXID , SPLIT)
SELECT  ZCLA_ELEMENTFIX.FIXID      
,       0.0 + (:HTSPLIT = 1 
?       ( ZCLA_SITEELFIX.SPLIT > 0 ? ( ZCLA_SITEELFIX.SPLIT / 100 ) : 0 )
:       ( ZCLA_ELEMENTFIX.SPLIT > 0 ? ( ZCLA_ELEMENTFIX.SPLIT / 100 ) : 0 )
)
FROM   ZCLA_SITEELFIX ? 
,      ZCLA_HOUSETYPE 
,      ZCLA_ELEMENTFIX 
WHERE 0=0
AND   ZCLA_HOUSETYPE.EL = ZCLA_ELEMENTFIX.EL 
AND   ZCLA_SITEELFIX.FIXID = ZCLA_ELEMENTFIX.FIXID 
AND   ZCLA_SITEELFIX.EL = ZCLA_ELEMENTFIX.EL
AND   ZCLA_HOUSETYPE.HOUSETYPEID = :HOUSETYPE
;
/*
*/
SELECT * FROM ZCLA_SPLIT
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
*/
:MARKUP = 0.0 ;
SELECT  1.0 + ((ZCLA_SITEELSPLIT.MARKUP > 0 ? 
ZCLA_SITEELSPLIT.MARKUP : ZCLA_PLOTELEMENT.MARKUP) / 100)
INTO    :MARKUP
FROM    ZCLA_SITEELSPLIT ?
,       ZCLA_HOUSETYPE 
,       ZCLA_PLOTELEMENT 
WHERE 0=0
AND   ZCLA_HOUSETYPE.EL = ZCLA_PLOTELEMENT.EL 
AND   ZCLA_SITEELSPLIT.DOC = ZCLA_HOUSETYPE.DOC 
AND   ZCLA_SITEELSPLIT.ELTYPE = ZCLA_HOUSETYPE.EL
AND   ZCLA_HOUSETYPE.HOUSETYPEID = :HOUSETYPE
;
/*
*/
SELECT :MARKUP FROM DUMMY
WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE
;