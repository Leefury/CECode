/*
Run Calculation if refresh flagged */
GOTO 030423 WHERE NOT EXISTS (
SELECT 'x' FROM ZCLA_HOUSETYPE
WHERE  0=0
AND    HOUSETYPEID = :$.HOUSETYPEID
AND    DOREFRESH = 'Y'
);
UPDATE ZCLA_HOUSETYPE 
SET    DOREFRESH = ''
WHERE  HOUSETYPEID = :$.HOUSETYPEID ;
#INCLUDE ZCLA_HOUSETYPE/ZCLA_BUF2
LABEL 030423 ;