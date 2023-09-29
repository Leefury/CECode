UPDATE ZCLA_FIXACTSTAT
SET LASTSTAT = :$1.STATDES
WHERE 0=0
AND   PROJACT = :$.PROJACT
AND   EXISTS (
SELECT 'x'
FROM ZCLA_FIXACTSTAT , ZCLA_FIXSTATUSES
WHERE 0=0
AND   ZCLA_FIXACTSTAT.STEPSTATUS = ZCLA_FIXSTATUSES.STEPSTATUS
AND   HOLD = 'Y'
AND   STEPSTATUSDES = :$.STATDES
);
UPDATE ZCLA_FIXACTSTAT
SET LASTSTAT = ''
WHERE 0=0
AND   PROJACT = :$.PROJACT
AND EXISTS (
SELECT 'x'
FROM ZCLA_FIXACTSTAT , ZCLA_FIXSTATUSES
WHERE 0=0
AND   ZCLA_FIXACTSTAT.STEPSTATUS = ZCLA_FIXSTATUSES.STEPSTATUS
AND   HOLD = 'Y'
AND   STEPSTATUSDES = :$1.STATDES
);