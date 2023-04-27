/*
Integer Change*/
:EDITID = 0 ;
SELECT EDITID INTO :EDITID
FROM ZCLA_ELEDIT
WHERE 0=0
AND   PROJACT = :$.PROJACT
AND   CLOSEFLAG <> 'Y'
;
ERRMSG 801 WHERE :EDITID = 0
;
SELECT 'Y' INTO :$.CHANGEFLAG
FROM DUMMY ;
INSERT INTO ZCLA_EDITLOG ( EDITID
,   PROJACT
,   ROOM
,   COMPONENT
,   FIELD
,   OLDVALUE
,   NEWVALUE
,   OLDCOST
,   NEWCOST
,   UDATE
,   USER
,   GUID
)
SELECT :EDITID
,      :$.PROJACT
,      :$.ROOM
,      :$.PLOTCOMPONENT
,      :FNAME
,      ITOA(:$1.@ / 1000 )
,      ITOA(:$.@ / 1000 )
,      0
,      0
,      SQL.DATE
,      SQL.USER
,      SQL.GUID
FROM DUMMY ;
