/* 
*    Copy update package to plots
*    Runs on status locked plots
*    See ZCLA_ELACT/ZCLA_BUF1 for 
*    bulk updates
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_ELACT/ZCLA_BUF15' 
,      :DOC , :PLOT , :ELEMENT 
,      :OPENEDIT , :HTEDIT , :HOUSETYPE
FROM DUMMY WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
Update / Insert */
DECLARE @ROOMCUR CURSOR FOR
SELECT ZCLA_COMPONENT.GUID  
,     ZCLA_COMPONENT.ROOM  
,     ZCLA_COMPONENT.PART  
,     ZCLA_COMPONENT.TQUANT  
,     ZCLA_COMPONENT.STYLE  
,     ZCLA_COMPONENT.ISDELETED  
,     ZCLA_PLOTCOMPONENT.GUID AS GUID2  
,     ZCLA_PLOTCOMPONENT.PART AS PART2  
,     ZCLA_PLOTCOMPONENT.TQUANT AS TQUANT2  
,     ZCLA_PLOTCOMPONENT.STYLE AS STYLE2  
,     ZCLA_PLOTCOMPONENT.ISDELETED
,     ZCLA_HTEDITLOG.UPDTYPE
FROM  ZCLA_ROOMS     
,     ZCLA_COMPONENT  
,     ZCLA_PLOTCOMPONENT     ?
,     PROJACTS      
,     ZCLA_HTEDIT     
,     ZCLA_HTEDITLOG 
WHERE 0 = 0
AND   ZCLA_ROOMS.ROOM = ZCLA_COMPONENT.ROOM  
AND   ZCLA_PLOTCOMPONENT.PROJACT = PROJACTS.PROJACT 
AND   ZCLA_ROOMS.HOUSETYPEID = PROJACTS.ZCLA_HOUSETYPEID 
AND   ZCLA_COMPONENT.GUID = ZCLA_PLOTCOMPONENT.GUID
AND   ZCLA_HTEDIT.HTEDIT = ZCLA_HTEDITLOG.HTEDIT 
AND   ZCLA_COMPONENT.GUID = ZCLA_HTEDITLOG.GUID
AND   ZCLA_COMPONENT.ROOM > 0  
AND   PROJACTS.PROJACT = :ELEMENT   
AND   ZCLA_HTEDIT.HTEDIT = :HTEDIT
;
/*
*/
OPEN @ROOMCUR ;
GOTO 2009 WHERE :RETVAL = 0 ;
LABEL 2001 ;
:GUID = :GUID2 = :STYLE = :STYLE2 = '' ;
:ROOM = :PART = :PART2 = :TQUANT = :TQUANT2 = 0 ;
:ISDELETED = :ISDELETED2 = :UPDTYPE = '\0' ;
/*
*/
FETCH @ROOMCUR INTO :GUID
,     :ROOM
,     :PART
,     :TQUANT
,     :STYLE
,     :ISDELETED
,     :GUID2
,     :PART2
,     :TQUANT2
,     :STYLE2
,     :ISDELETED2
,     :UPDTYPE
;
GOTO 2008 WHERE :RETVAL = 0 ;
/*
*/
SELECT :GUID
,     :ROOM
,     :PART
,     :TQUANT
,     :STYLE
,     :ISDELETED
,     :GUID2
,     :PART2
,     :TQUANT2
,     :STYLE2
,     :ISDELETED2
,     :UPDTYPE
FROM DUMMY WHERE :DEBUG = 1 
FORMAT ADDTO :DEBUGFILE ;
/*
*/
GOSUB 500 WHERE :UPDTYPE = 'I' ;
GOSUB 600 WHERE :UPDTYPE = 'U' ;
GOSUB 700 WHERE :UPDTYPE = 'D' ;
/*
*/
LOOP 2001 ; 
LABEL 2008 ;
CLOSE @ROOMCUR ;
LABEL 2009 ; 
/*
*
*
*********************************
Insert */
SUB 500 ;
SELECT 'INSERT'
,      :OPENEDIT
,      :ELEMENT 
,      :ROOM
,      :PART 
,      'INSERT'
,      ''
,      PARTNAME
,      SQL.DATE
,      SQL.USER
,      SQL.GUID
FROM PART
WHERE 0=0
AND   PART.PART = :PART 
FORMAT ADDTO :DEBUGFILE 
;
INSERT INTO ZCLA_EDITLOG ( EDITID ,   PROJACT ,   ROOM ,   COMPONENT
,   FIELD ,   OLDVALUE ,   NEWVALUE ,   UDATE ,   USER ,   GUID )
SELECT :OPENEDIT ,      :ELEMENT  ,      :ROOM ,      :PART  ,      'INSERT'
,      '' ,      PARTNAME ,      SQL.DATE ,      SQL.USER ,      SQL.GUID
FROM PART
WHERE 0=0
AND   PART.PART = :PART 
;
/*
*/
SELECT :GUID , :ELEMENT , :ROOM , :PART 
,      :TQUANT , :STYLE , 'N' , 'N'
FROM DUMMY 
FORMAT ADDTO :DEBUGFILE ;
/*
*/
INSERT INTO ZCLA_PLOTCOMPONENT( GUID , PROJACT , ROOM , PART 
,           TQUANT , STYLE , EXTRA , ISDELETED )
SELECT :GUID , :ELEMENT , :ROOM , :PART 
,      :TQUANT , :STYLE , 'N' , 'N'
FROM DUMMY 
;
RETURN ;
/*
*
*
*******************************************
Update */
SUB 600 ;
GOTO 610 WHERE :ISDELETED2 <> 'Y' ;
UPDATE ZCLA_PLOTCOMPONENT 
SET ISDELETED = '\0'
WHERE 0=0
AND   GUID = :GUID
;
INSERT INTO ZCLA_EDITLOG ( EDITID ,   PROJACT ,   ROOM ,   COMPONENT
,   FIELD ,   OLDVALUE ,   NEWVALUE ,   UDATE ,   USER ,   GUID
)
SELECT :OPENEDIT ,      :ELEMENT  ,      :ROOM ,      :PART  ,      'INSERT'
,      '' ,      PARTNAME ,      SQL.DATE ,      SQL.USER ,      SQL.GUID
FROM PART
WHERE 0=0
AND   PART.PART = :PART 
;
LABEL 610 ;
/*
*/
:OLDVALUE = :NEWVALUE = '' ;
SELECT PARTNAME INTO :OLDVALUE
FROM PART WHERE PART = :PART2 ;
SELECT PARTNAME INTO :NEWVALUE
FROM PART WHERE PART = :PART ;
/*
Update Part */
SELECT 'UPDATE' , :OPENEDIT , :ELEMENT , :ROOM 
,      :GUID , 'PART' , :OLDVALUE , :NEWVALUE
FROM DUMMY
WHERE 0=0
AND   :PART <> :PART2
AND   :OPENEDIT > 0
FORMAT ADDTO :DEBUGFILE 
;
INSERT INTO ZCLA_EDITLOG ( EDITID , PROJACT , ROOM 
,      GUID , FIELD , OLDVALUE , NEWVALUE )
SELECT :OPENEDIT , :ELEMENT , :ROOM 
,      :GUID , 'PART' , :OLDVALUE , :NEWVALUE
FROM DUMMY
WHERE 0=0
AND   :PART <> :PART2
AND   :OPENEDIT > 0
;
UPDATE ZCLA_PLOTCOMPONENT
SET PART = :PART
WHERE 0=0
AND   GUID = :GUID 
AND   :PART <> :PART2
AND   PROJACT = :ELEMENT
AND   ROOM = :ROOM
;
/*
Update Quantity */
SELECT 'UPDATE' , :OPENEDIT , :ELEMENT , :ROOM 
,      :GUID , 'QUANTITY' , ITOA(:TQUANT2) , ITOA(:TQUANT)
FROM DUMMY
WHERE 0=0
AND   :TQUANT <> :TQUANT2
AND   :OPENEDIT > 0
FORMAT ADDTO :DEBUGFILE 
;
INSERT INTO ZCLA_EDITLOG ( EDITID , PROJACT , ROOM 
,           GUID , FIELD , OLDVALUE , NEWVALUE )
SELECT :OPENEDIT , :ELEMENT , :ROOM , :GUID , 'QUANTITY' 
,      ITOA( :TQUANT2 / 1000 )
,      ITOA( :TQUANT / 1000 )
FROM DUMMY
WHERE 0=0
AND   :TQUANT <> :TQUANT2
AND   :OPENEDIT > 0
;
/**/
UPDATE ZCLA_PLOTCOMPONENT
SET TQUANT = :TQUANT
WHERE 0=0
AND   GUID = :GUID 
AND   :TQUANT <> :TQUANT2
AND   PROJACT = :ELEMENT
AND   ROOM = :ROOM
;
/*
Update Style */
SELECT STYLE INTO :OLDVALUE
FROM ZCLA_PLOTCOMPONENT WHERE GUID = :GUID ;
SELECT STYLE INTO :NEWVALUE
FROM ZCLA_COMPONENT WHERE GUID = :GUID ;
/*
*/
SELECT 'UPDATE' , :OPENEDIT , :ELEMENT , :ROOM 
,      :GUID , 'STYLE' , :OLDVALUE , :NEWVALUE
FROM DUMMY
WHERE 0=0
AND   :STYLE <> :STYLE2
AND   :OPENEDIT > 0
FORMAT ADDTO :DEBUGFILE
;
INSERT INTO ZCLA_EDITLOG ( EDITID , PROJACT , ROOM 
,           GUID , FIELD , OLDVALUE , NEWVALUE )
SELECT :OPENEDIT , :ELEMENT , :ROOM 
,      :GUID , 'STYLE' , :OLDVALUE , :NEWVALUE
FROM DUMMY
WHERE 0=0
AND   :STYLE <> :STYLE2
AND   :OPENEDIT > 0
;
UPDATE ZCLA_PLOTCOMPONENT
SET STYLE = :STYLE
WHERE 0=0
AND   GUID = :GUID 
AND   :STYLE <> :STYLE2
AND   PROJACT = :ELEMENT
AND   ROOM = :ROOM
;
RETURN ;
/*
*
*
*******************************************
Delete */
SUB 700 ;
SELECT 'DELETE'
,      :OPENEDIT
,      :ELEMENT 
,      :ROOM
,      :PART 
,      'DELETE'
,      PARTNAME
,      ''
,      SQL.DATE
,      SQL.USER
,      SQL.GUID
FROM PART
WHERE 0=0
AND   PART.PART = :PART
FORMAT ADDTO :DEBUGFILE
;
INSERT INTO ZCLA_EDITLOG ( EDITID
,   PROJACT
,   ROOM
,   COMPONENT
,   FIELD
,   OLDVALUE
,   NEWVALUE
,   UDATE
,   USER
,   GUID
)
SELECT :OPENEDIT
,      :ELEMENT 
,      :ROOM
,      :PART 
,      'DELETE'
,      PARTNAME
,      ''
,      SQL.DATE
,      SQL.USER
,      SQL.GUID
FROM PART
WHERE 0=0
AND   PART.PART = :PART
;
UPDATE ZCLA_PLOTCOMPONENT
SET ISDELETED = 'Y'
,   TQUANT = 0
WHERE 0=0
AND   PROJACT = :ELEMENT
AND   ROOM = :ROOM
AND   GUID = :GUID
;
RETURN ;