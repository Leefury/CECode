SELECT STEPSTATUS INTO :$.STEPSTATUS
FROM ZCLA_FIXSTATUSES
WHERE STEPSTATUSDES = :$.@ ;
