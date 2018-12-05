DECLARE @month_age DATETIME
DECLARE @month_age_timestamp NUMERIC

-- SET @month_age = DATEADD(month, -1, GETDATE())
-- SET @month_age = DATEADD(month, -2, GETDATE())
SET @month_age = DATEADD(month, -3, GETDATE())
SET @month_age_timestamp = (SELECT DATEDIFF(s, '1970-01-01 00:00:00', @month_age))


/**
  * 가장 최근에 접속 이력을 먼저 계산 함으로써,
  * one_month_ago_timestamp에서 검증이 가능하도록 한다
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
/** 
  * GROUP_BY와 JOIN을 한 쿼리에 담지 않는다
  * sUserId(휴대폰번호), sUserName(사용자이름), lastAccessTime(마지막 접속 시간)
  *   sUserId = nUserId
  */

SELECT DISTINCT sUserId, sUsername, dateadd(s, lastNDateTime, '1970-01-01 00:00:00') as lastAccessTime
FROM TB_USER as userTable
INNER JOIN USER_LAST_NOT_ACCESS_ONE_MONTH as lastTable
ON userTable.sUserId=lastTable.nUserId
WHERE lastNDateTime < @month_age_timestamp

/**
  * WHERE 조건으로 JOIN전에 WHERE문을 걸면 더 빠르지 않을까?
  *
  */


/* 이전 접속자를 모두 뽑는다. 단 현재 접속자들도 포함될 수 있다
 *  현재 접속자들을 뽑아 제거하는 것이 맞다
*/
-- ;WITH oneMonthEvent AS (
--     SELECT DISTINCT nUserID, max(DATEADD(s, nDateTime, '1970-01-01 00:00:00')) as lastAccessTime
--     FROM TB_EVENT_LOG
--     WHERE nDateTime >= @month_age_timestamp
--         AND nUserID >0 
--     GROUP BY nUserID
-- ), inValidUsers AS(
-- SELECT DISTINCT nUserIdn
-- FROM TB_USER as userTable
-- WHERE nUserIdn NOT IN (SELECT nUserID FROM oneMonthEvent)
-- )

/**
  * oneMonthUsers
  * 최근 한달간 접속 이력이 있는 사용자를 리턴
  * */
-- ;WITH oneMonthUsers AS (
--     SELECT DISTINCT nUserID
--     FROM TB_EVENT_LOG
--     WHERE nDateTime >= @month_age_timestamp
--         AND nUserID >0
-- )

-- SELECT DISTINCT nUserIdn, sUserName, max(DATEADD(s, nDateTime, '1970-01-01 00:00:00')) as lastAccessTime
-- FROM TB_USER as userTable
-- WHERE nUserIdn NOT IN (oneMonthUsers)
--     AND nUserIdn > 0
-- GROUP BY nUserIdn;

/**
  * 단일 쿼리로 작성
  */
-- SELECT DISTINCT nUserIdn, sUserName, max(DATEADD(s, nDateTime, '1970-01-01 00:00:00')) as lastAccessTime
-- FROM TB_USER as userTable
-- WHERE nUserIdn > 0
--     AND nUserIdn NOT IN ( -- 최근 기간(한달)에 접속한 사용자 목록
--         SELECT DISTINCT nUserID
--         FROM TB_EVENT_LOG
--         WHERE nDateTime >= @month_age_timestamp
--             AND nUserID > 0
--     )
-- GROUP BY nUserIdn;


/**
  * EVENT_LOG 테이블에서 최신기록만을 유저에 매핑해서 가져온다.
  * 각 유저에 대해 라스트 이벤트만 가져온다.
  *
  */
-- ;WITH USER_LAST_EVENT as (
--   SELECT nUserId, max(DATEADD(s, nDateTime, '1970-01-01 00:00:00')) as lastAccessTime
--   FROM TB_EVENT_LOG
--   WHERE nUserId > 0
--   GROUP BY nUserId
-- )

-- SELECT DISTINCT nUserIdn, sUserName, lastAccessTime
-- FROM TB_USER as userTable
-- INNER JOIN USER_LAST_EVENT as lastTable
-- ON userTable.nUserIdn=lastTable.nUserId
-- WHERE nUserIdn > 0
-- AND lastAccessTime < @month_age_timestamp;


/**
  * Valid한 사용자 정보가 출력된다.
  */
-- SELECT DISTINCT nUserIDn, sUserName, lastAccessTime
-- FROM TB_USER as userTable
-- INNER JOIN oneMonthEvent as monthTable
-- ON userTable.nUserIDn = monthTable.nUserID
-- WHERE nUserIdn IN inValidUsers


