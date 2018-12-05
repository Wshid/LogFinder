/**
  * 전체 사용자의 최근 접속 로그를 확인한다.
  */

;WITH VALID_USERS as(
  -- SELECT DISTINCT nUserIdn FROM TB_USER
  SELECT DISTINCT sUserId FROM TB_USER
)
,USER_LAST_EVENT as(
  SELECT DISTINCT nUserId, max(nDateTime) as lastNDateTime
  FROM TB_EVENT_LOG
  WHERE nUserId IN (SELECT sUserId FROM VALID_USERS)
  GROUP BY nUserId
)
SELECT DISTINCT sUserId, sUsername, dateadd(s, lastNDateTime, '1970-01-01 00:00:00') as lastAccessTime
FROM TB_USER as userTable
INNER JOIN USER_LAST_NOT_ACCESS_ONE_MONTH as lastTable
ON userTable.sUserId=lastTable.nUserId
-- WHERE lastNDateTime < @month_age_timestamp