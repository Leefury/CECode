/*
** Add annual Holiday Extras for this User/Year
** 19/09/24 @Si- Added to allow for extra holidays to be added to
the holiday table
*/
#INCLUDE func/ZCLA_DEBUGUSR
SELECT 'ZCLA_PAYCODES/BUF2', :i_USER FROM DUMMY
WHERE 0=0
AND :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
** Get Default Days Holiday in case needed
*/
:i_HOLIDAYSDAYS = :i_HOLBASIC = :o_DAYS = 0.0; 
:i_CPYNAME = '';
:i_CPYNAME = 'DEFHOLDAYS';
#INCLUDE func/ZEMG_CPYCONST
:i_HOLBASIC = :o_RCPYVALUE;
/*
** Processing each user, zero current values
*/
#INCLUDE ZCLA_PAYCODES/ZCLA_BUF1
SELECT :i_HOLBASIC + :o_DAYS INTO :i_HOLIDAYSDAYS
FROM DUMMY
;
SELECT :i_USER, USERLOGIN, :i_HOLIDAYSDAYS
FROM USERS 
WHERE 0=0
AND USER = :i_USER
AND :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/**/
INSERT INTO ZEMG_HOLIDAY (USER, HYEAR)
VALUES (:i_USER, ATOI(DTOA(SQL.DATE,'YYYY')));
/**/
UPDATE ZEMG_HOLIDAY
SET EXTRAHOLIDAYDAYS = 0.0,
HOLIDAYUSEDDAYS = 0.0,
HOLIDAYCFWDDAYS = 0.0,
HOLIDAYLEFTDAYS = :i_HOLIDAYSDAYS,
YHOLIDAYDAYS = :i_HOLIDAYSDAYS,
HOLIDAYDAYS = :i_HOLIDAYSDAYS
WHERE USER = :i_USER
AND HYEAR = ATOI(DTOA(SQL.DATE,'YYYY'));N
/*
** Declare Cursor for all holiday entries this year
*/
DECLARE @HOL_CUR CURSOR FOR
SELECT AC.FROMDATE, AC.FROMTIME, AC.TODATE, AC.TOTIME, ZC.EXCBREAK,
AB.ZEMG_HOLIDAY, AB.ZEMG_EXTRAHOLIDAY
FROM ABSENTCHART AC, ZEMG_ABSENTCHART ZC ?, ABSENTCODES AB
WHERE AC.USER = :i_USER
AND YEAR(AC.FROMDATE) = ATOI(DTOA(SQL.DATE,'YYYY'))
AND ZC.USER = AC.USER
AND ZC.TODATE = AC.TODATE
AND AB.ABSENTC = AC.ABSENTC
ORDER BY AC.FROMDATE, AC.FROMTIME;  /* Just for neatness */
/* Open cursor */
OPEN @HOL_CUR;
GOTO 853 WHERE :RETVAL <= 0; /* Treat as if no records found */
/*
** Start of cursor loop
*/
LABEL 850;
/* Initialise variables */
:i_FROMDATE = :i_TODATE = 01/01/1988;
:i_FROMTIME = :i_TOTIME = 00:00;
:i_EXCBREAK = :l_HOLIDAY = :l_EXTRA = '\0';
/* Get next record from cursor */
FETCH @HOL_CUR INTO :i_FROMDATE, :i_FROMTIME, :i_TODATE, :i_TOTIME,
:i_EXCBREAK, :l_HOLIDAY, :l_EXTRA;
GOTO 852 WHERE :RETVAL <= 0;
/*
** Processing each line
*/
SELECT :i_FROMDATE, :i_FROMTIME, :i_TODATE, :i_TOTIME,
:i_EXCBREAK, :l_HOLIDAY, :l_EXTRA
FROM DUMMY WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
** Calculate Days for this Entry
*/
#INCLUDE func/ZEMG_HOLDATERANGE
/**/
SELECT :o_HOLIDAYDAYS
FROM DUMMY WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
** Insert/Update Days Leave on all Absences
*/
UPDATE ZEMG_ABSENTCHART
SET DAYS = :o_HOLIDAYDAYS
WHERE USER = :i_USER
AND TODATE = :i_TODATE;
GOTO 851 WHERE :RETVAL > 0; /* Create extension if not found */
/**/
INSERT INTO ZEMG_ABSENTCHART
(USER, TODATE, DAYS)
VALUES
(:i_USER, :i_TODATE, :o_HOLIDAYDAYS);
/**/
LABEL 851;
/**/
SELECT 'ZC', :o_HOLIDAYDAYS, :RETVAL
FROM DUMMY WHERE :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
** Skip if Not a Holiday Type
*/
LOOP 850 WHERE :l_HOLIDAY <> 'Y' AND :l_EXTRA <> 'Y';
/*
** Update Extra holiday
*/
UPDATE ZEMG_HOLIDAY
SET EXTRAHOLIDAYDAYS = EXTRAHOLIDAYDAYS + :o_HOLIDAYDAYS
WHERE USER = :i_USER
AND HYEAR = YEAR(:i_FROMDATE)
AND :l_EXTRA = 'Y';
/*
** Update Holiday taken
*/
UPDATE ZEMG_HOLIDAY
SET HOLIDAYUSEDDAYS = HOLIDAYUSEDDAYS + :o_HOLIDAYDAYS
WHERE USER = :i_USER
AND HYEAR = YEAR(:i_FROMDATE)
AND :l_HOLIDAY = 'Y';
/*
** End of cursor loop
*/
LOOP 850;
/*
** Clean up
*/
LABEL 852;
CLOSE @HOL_CUR;
LABEL 853;
/*
** End Processing lines
*/
:l_EXTRADAYS = 0.0;
SELECT SUM(EXTRAHOLIDAYDAYS)
INTO :l_EXTRADAYS
FROM ZEMG_HOLIDAY_EXTRAS
WHERE USER = :i_USER
AND HYEAR = ATOI(DTOA(SQL.DATE,'YYYY'))
AND ONEOFF <> 'Y';
/**/
UPDATE ZEMG_HOLIDAY
SET EXTRAHOLIDAYDAYS = EXTRAHOLIDAYDAYS + :l_EXTRADAYS
WHERE USER = :i_USER
AND HYEAR = ATOI(DTOA(SQL.DATE,'YYYY'))
AND :l_EXTRADAYS > 0.0;
/**/
:l_ONEOFFDAYS = 0.0;
SELECT SUM(EXTRAHOLIDAYDAYS)
INTO :l_ONEOFFDAYS
FROM ZEMG_HOLIDAY_EXTRAS
WHERE USER = :i_USER
AND HYEAR = ATOI(DTOA(SQL.DATE,'YYYY'))
AND ONEOFF = 'Y';
/**/
UPDATE ZEMG_HOLIDAY
SET ONEOFFEXTRAS = :l_ONEOFFDAYS
WHERE USER = :i_USER
AND HYEAR = ATOI(DTOA(SQL.DATE,'YYYY'))
AND :l_ONEOFFDAYS > 0.0;
/**/
SELECT 'N' AS 'ONEOFF', :l_EXTRADAYS, :l_ONEOFFDAYS
FROM  USERS WHERE 0=0
AND   USER = :i_USER
AND   :DEBUG = 1
FORMAT ADDTO :DEBUGFILE ;
/*
** Update holiday left
*/
UPDATE ZEMG_HOLIDAY
SET HOLIDAYLEFTDAYS =
HOLIDAYDAYS + EXTRAHOLIDAYDAYS - HOLIDAYCFWDDAYS - HOLIDAYUSEDDAYS
WHERE USER = :i_USER
AND HYEAR = ATOI(DTOA(SQL.DATE,'YYYY'));