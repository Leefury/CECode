/*
.   Create list of valid components
*/
DELETE FROM ZCLA_VALIDCOMPNENT WHERE USER = SQL.USER ;
/* 
medatech.si. 8/5/2024 */
INSERT INTO ZCLA_VALIDCOMPNENT ( USER , PART , COL , MANFID )
SELECT DISTINCT SQL.USER 
,      PART.PART
,      0
,      0
FROM   PART childPart
,      PARTARC
,      PART
,      ZCLA_PARTTYPE
WHERE  0=0
AND    PART.ZCLA_PARTTYPE     = ZCLA_PARTTYPE.TYPEID
AND    PARTARC.PART           = PART.PART
AND    childPart.PART         = PARTARC.SON
AND    ZCLA_PARTTYPE.TYPENAME = 'C'
AND    childPart.PARTNAME     NOT LIKE 'P9%'
GROUP BY PART.PART
; 
/* 
medatech.si. 9/5/2024 */
INSERT INTO ZCLA_VALIDCOMPNENT ( USER , PART , COL , MANFID )
SELECT DISTINCT SQL.USER 
,      PART.PART
,      ZCLA_PROJMANF.COL
,      ZCLA_PROJMANF.MANFID
FROM   ZCLA_PROJMANF
,      PART childPart
,      PARTARC
,      PART
,      ZCLA_PARTTYPE
WHERE  0=0
AND    PART.ZCLA_PARTTYPE     = ZCLA_PARTTYPE.TYPEID
AND    PARTARC.PART           = PART.PART
AND    childPart.PART         = PARTARC.SON
AND    ZCLA_PROJMANF.FAMILY   = PART.FAMILY
AND    ZCLA_PARTTYPE.TYPENAME = 'C'
AND    childPart.PARTNAME     LIKE 'P9%'
AND    ZCLA_PROJMANF.DOC      = 187
AND    ZCLA_PROJMANF.ALT      = 1
GROUP BY PART.PART, ZCLA_PROJMANF.COL, ZCLA_PROJMANF.MANFID
HAVING        (ZCLA_PROJMANF.MANFID > 0)
; 

