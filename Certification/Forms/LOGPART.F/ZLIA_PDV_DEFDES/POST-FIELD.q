/*LOGPART/ZLIA_PDV_DEFDES/POST-FIELD */
SELECT PDV_DEFID INTO :$.ZLIA_PDV_DEFID
FROM ZLIA_PDV_DEFOPT
WHERE 0=0
AND PDV_DEFDES = :$.@;