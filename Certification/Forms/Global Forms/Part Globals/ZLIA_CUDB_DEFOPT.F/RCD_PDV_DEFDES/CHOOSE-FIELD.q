/*ZLIA_CUDB_DEFOPT/RCD_PDV_DEFDES/CHOOSE-FIELD */
SELECT CO.DEVTYPENAME, DV.PDV_DEFDES, DV.PDV_DEFID
FROM ZLIA_PDV_DEFOPT DV, ZLIA_PDV_CONFIG CO
WHERE DV.DEVTYPEID = CO.DEVTYPEID
AND DV.PDV_DEFID <> 0
AND CO.DEVTYPENAME = 'RCD'
ORDER BY DV.PDV_DEFID;