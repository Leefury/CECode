/*Skip update of PDV_DEFDES when Device Type is not MCB or RCBO*/
GOTO 999 WHERE :$.DEVTYPENAME = 'SPD';
GOTO 999 WHERE :$.DEVTYPENAME = 'RCD';
GOTO 999 WHERE :$.DEVTYPENAME = 'Spare';
GOTO 999 WHERE :$.DEVTYPENAME = 'SPARE';
GOTO 850 WHERE :$.MAXPFCKA = '10';
/*MAXPFCKA = 6*/
GOTO 840 WHERE :$.OC_TYPEOPT_NAME = 'B';
/* Update PDV_DEFDES when MAXPFCKA = 6 and OC_TYPEOPT_NAME <> 'B'*/
UPDATE ZLIA_PDV_DEFOPT 
SET PDV_DEFDES = STRCAT(:$.OC_RATEOPT_NAME, 'A ', :$.DEVTYPENAME, 
' (Type ', :$.OC_TYPEOPT_NAME, ')')
WHERE PDV_DEFID = :$.PDV_DEFID;
GOTO 999;
/* Update PDV_DEFDES when MAXPFCKA = 6 and OC_TYPEOPT_NAME = 'B' */
LABEL 840;
UPDATE ZLIA_PDV_DEFOPT 
SET PDV_DEFDES = STRCAT(:$.OC_RATEOPT_NAME, 'A ', :$.DEVTYPENAME)
WHERE PDV_DEFID = :$.PDV_DEFID;
GOTO 999;
/*MAXPFCKA = 10*/
LABEL 850;
GOTO 860 WHERE :$.OC_TYPEOPT_NAME = 'B';
/* Update PDV_DEFDES when MAXPFCKA = 10 and OC_TYPEOPT_NAME <> 'B'*/
UPDATE ZLIA_PDV_DEFOPT 
SET PDV_DEFDES = STRCAT(:$.OC_RATEOPT_NAME, 'A* ', :$.DEVTYPENAME, 
' (Type ', :$.OC_TYPEOPT_NAME, ')')
WHERE PDV_DEFID = :$.PDV_DEFID;
GOTO 999;
/* Update PDV_DEFDES when MAXPFCKA = 10 and OC_TYPEOPT_NAME = 'B'*/
LABEL 860;
UPDATE ZLIA_PDV_DEFOPT 
SET PDV_DEFDES = STRCAT(:$.OC_RATEOPT_NAME, 'A* ', :$.DEVTYPENAME)
WHERE PDV_DEFID = :$.PDV_DEFID;
LABEL 999;