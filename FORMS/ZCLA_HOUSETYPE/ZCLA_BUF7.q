/* ZCLA_HOUSETYPE POST UPDATE/INSERT 
*/
:DOC = :CUST = :HOUSETYPE = :HOUSETYPEID = :COPIEDFROMTYPE = 0 ;
:ZCLA_COPY = :TYPE = '' ;
SELECT :$.HOUSETYPEID 
,   :$.COPIEDFROMTYPE 
,   :$.HOUSETYPEID 
,   :$.ZCLA_COPY
,   :$$.TYPE
,   :$$.DOC
,   :$$.CUST
INTO :HOUSETYPEID 
,   :COPIEDFROMTYPE 
,   :HOUSETYPE 
,   :ZCLA_COPY
,   :TYPE
,   :DOC 
,   :CUST 
FROM DUMMY ;
SELECT :HOUSETYPEID , :COPIEDFROMTYPE , :ZCLA_COPY
,   :TYPE
,   :DOC 
,   :CUST 
FROM DUMMY FORMAT ADDTO :DEBUGFILE ;