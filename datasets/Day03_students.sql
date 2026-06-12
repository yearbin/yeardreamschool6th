-- ============================================================
--  Day 03 학생 실습 SQL (student copy)
--  주제: 집합 연산자 / 집계 함수 / 서브쿼리 / 계층형 질의
--  데이터베이스: SQLite Chinook DB
--  참고: https://www.sqlitetutorial.net/sqlite-sample-database/
--        https://www.sqlitetutorial.net/sqlite-union/
--        https://www.sqlitetutorial.net/sqlite-except/
--        https://www.sqlitetutorial.net/sqlite-intersect/
--        https://www.sqlitetutorial.net/sqlite-aggregate-functions/
--        https://www.sqlitetutorial.net/sqlite-subquery/
--        https://www.sqlitetutorial.net/sqlite-exists/
-- ============================================================
--
--  Chinook DB 테이블 (11개)
--  ┌─────────────────┬──────────────────────────────────────┐
--  │ 테이블           │ 설명                                  │
--  ├─────────────────┼──────────────────────────────────────┤
--  │ employees       │ 직원 (ReportsTo → 계층형 구조)         │
--  │ customers       │ 고객 (SupportRepId → employees FK)    │
--  │ invoices        │ 청구서 헤더                            │
--  │ invoice_items   │ 청구서 라인 아이템                      │
--  │ artists         │ 아티스트                               │
--  │ albums          │ 앨범 (ArtistId FK)                    │
--  │ tracks          │ 트랙 (AlbumId / GenreId / MediaTypeId)│
--  │ genres          │ 장르                                  │
--  │ media_types     │ 미디어 타입                            │
--  │ playlists       │ 플레이리스트                           │
--  │ playlist_track  │ 플레이리스트-트랙 (M:N 중간 테이블)     │
--  └─────────────────┴──────────────────────────────────────┘
-- ============================================================


-- ============================================================
-- PART 1. 집계 함수 (Aggregate Functions)
-- ============================================================
-- 집계 함수는 여러 행(row)을 입력받아 단일 값을 반환한다
-- GROUP BY, HAVING 절과 함께 자주 사용
--
-- SQLite 제공 집계 함수
--   COUNT()        : 행 수
--   SUM()          : 합계
--   AVG()          : 평균
--   MAX()          : 최댓값
--   MIN()          : 최솟값
--   GROUP_CONCAT() : 문자열 연결 (separator 지정 가능)
--
-- 문법: aggregate_function([DISTINCT | ALL] expression)
--   DISTINCT → 중복 제외 후 집계
--   ALL      → 중복 포함 집계 (기본값)
-- ============================================================

-- ──────────────────────────────────────────────────────────
-- 1-1. COUNT() - 행 수 반환
-- ──────────────────────────────────────────────────────────

-- (a) 전체 트랙 수
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/

-- (b) 앨범별 트랙 수 (내림차순)


-- (c) 국가별 고객 수

-- (d) DISTINCT - 중복 제거 후 COUNT
--     실제 청구서가 발생한 고유 고객 수

SELECT count(DISTINCT CustomerID) as 실제구매고객수
FROM invoices;



-- ──────────────────────────────────────────────────────────
-- 1-2. SUM() - 합계
-- ──────────────────────────────────────────────────────────

-- (a) 앨범별 총 재생 시간 (분 단위)
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/

-- (b) 연도별 총 매출

SELECT
    strftime('%Y', InvoiceDate) as 연도
    , round (SUM(Total), 1) as 연매출
FROM invoices
group by 연도
;

-- (c) 장르별 총 트랙 용량 (MB)


-- ──────────────────────────────────────────────────────────
-- 1-3. AVG() - 평균
-- ──────────────────────────────────────────────────────────

-- (a) 앨범별 평균 트랙 길이 (분)
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/

-- (b) 고객 1인당 평균 청구 금액

-- (c) 미디어 타입별 평균 단가


-- ──────────────────────────────────────────────────────────
-- 1-4. MAX() / MIN() - 최댓값·최솟값
-- ──────────────────────────────────────────────────────────

-- (a) 가장 긴 트랙의 재생 시간 (분)
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/

-- (b) 가장 짧은 트랙의 재생 시간 (분)

-- (c) 고객별 최대·최소 청구 금액


-- ──────────────────────────────────────────────────────────
-- 1-5. GROUP_CONCAT() - 문자열 연결
-- ──────────────────────────────────────────────────────────

-- (a) 앨범 ID = 1 의 트랙 이름 목록 (쉼표 구분)
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/
select GROUP_CONCAT(name) as 트랙목록
from tracks
WHERE AlbumId = 1 ;

-- (b) 구분자를 ' / ' 로 변경

select GROUP_CONCAT(name, ' / ') as 트랙목록
from tracks
WHERE AlbumId = 1 ;

-- (c) 장르별 미디어 타입 종류 나열

SELECT 
    g.Name                          as 장르
    , GROUP_CONCAT(DISTINCT m.name) as 미디어타입목록
FROM tracks t
inner join genres g on t.GenreId = g.GenreId
inner join media_types m on t.MediaTypeId = m.MediaTypeId
GROUP BY g.Name
;

-- ──────────────────────────────────────────────────────────
-- 1-6. HAVING - 집계 결과 필터링
--      WHERE 는 집계 전 개별 행 필터
--      HAVING 은 집계 후 그룹 필터
-- ──────────────────────────────────────────────────────────

-- (a) 트랙이 15개 이상인 앨범

-- (b) 총 매출이 $40 이상인 고객

-- (c) 평균 트랙 단가가 $0.99 초과인 장르


-- ============================================================
-- PART 2. 서브쿼리 (Subquery)
-- ============================================================
-- 서브쿼리(내부 쿼리/중첩 쿼리): 다른 SQL 문 안에 포함된 SELECT
-- 위치에 따른 분류
--   WHERE 절  : 조건 비교에 활용 (가장 일반적)
--   FROM  절  : 인라인 뷰(Inline View) / 파생 테이블(Derived Table)
--   SELECT 절 : 스칼라 서브쿼리 (행마다 단일값 반환)
--
-- 연관성에 따른 분류
--   비연관(Non-Correlated) : 외부 쿼리와 독립적으로 실행
--   연관(Correlated)       : 외부 쿼리의 값을 참조, 행마다 재실행
-- ============================================================

-- ──────────────────────────────────────────────────────────
-- 2-1. WHERE 절 서브쿼리 (비연관)
-- ──────────────────────────────────────────────────────────

-- (a) 가장 긴 트랙 정보 조회
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/

-- (b) 가장 짧은 트랙 정보 조회

-- (c) 평균 청구 금액보다 높은 청구서 목록
-- 테이블 invocies 메인쿼리 : InvoiceID, CustomerID, 청구금액

SELECT invoiceID, customerID, Total from invoices
WHERE Total > (SELECT avg(Total) from invoices)
ORDER BY Total desc ;

-- (d) IN 서브쿼리 - Rock 장르 트랙 조회

-- (e) NOT IN 서브쿼리 - 한 번도 판매되지 않은 트랙


-- ──────────────────────────────────────────────────────────
-- 2-2. FROM 절 서브쿼리 - 인라인 뷰 (Derived Table)
--      서브쿼리 결과를 임시 테이블처럼 사용
-- ──────────────────────────────────────────────────────────

-- (a) 고객별 총 매출 TOP 5
select *
from (인라인 뷰)
join customers on
order BY
LIMIT 5
;

-- 총매출 구하기
-- 구체적으로 고객ID, 고객이름, 총매출

select 
    sub.customerID
    , c.FirstName || '' || c.LastName as 고객명
    , sub.총매출
from(
    select customerID, sum(Total) as 총매출
    from invoices
    GROUP BY CustomerID) as sub
inner join customers c on sub.customerID = c.customerID
ORDER BY 3 desc
limit 5
;



-- (b) 앨범별 트랙 수 평균보다 많은 앨범 조회
-- join ()

-- (c) 용량이 10MB 미만인 앨범 조회
-- ref: sqlitetutorial.net 서브쿼리 예제 패턴
-- 메인 쿼리 : 앨범 조회 albumID, Title
select albumID, Title from albums;
where 10000000
select * from tracks;




-- ──────────────────────────────────────────────────────────
-- 2-3. SELECT 절 서브쿼리 - 스칼라 서브쿼리
--      행마다 단일 값을 반환 (연관 서브쿼리)
-- ──────────────────────────────────────────────────────────

-- (a) 앨범별 트랙 수를 SELECT 절에서 계산
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/

-- (b) 고객별 최근 청구 날짜를 SELECT 절에서 계산

-- (c) 트랙 이름과 해당 장르 이름을 스칼라 서브쿼리로 조회


-- ──────────────────────────────────────────────────────────
-- 2-4. 연관 서브쿼리 (Correlated Subquery)
--      외부 쿼리의 값을 참조 → 행마다 서브쿼리 재실행
--      ※ 대용량 데이터에서는 성능 주의
-- ──────────────────────────────────────────────────────────

-- (a) 자신이 속한 장르의 평균 단가보다 비싼 트랙

-- (b) 평균 트랙 수보다 많은 트랙을 가진 앨범


-- ──────────────────────────────────────────────────────────
-- 2-5. EXISTS / NOT EXISTS
--      서브쿼리가 행을 반환하면 TRUE, 없으면 FALSE
--      ※ 결과 집합이 클 때 IN 보다 빠른 경향
-- ──────────────────────────────────────────────────────────

-- (a) 청구서가 있는 고객 조회 (EXISTS)
-- ref: https://www.sqlitetutorial.net/sqlite-exists/

-- (b) 앨범이 없는 아티스트 조회 (NOT EXISTS)
-- ref: https://www.sqlitetutorial.net/sqlite-exists/

-- (c) 한 번도 판매된 적 없는 트랙 조회 (NOT EXISTS)


-- ──────────────────────────────────────────────────────────
-- 2-6. 서브쿼리 활용 종합 예제
-- ──────────────────────────────────────────────────────────

-- (a) 각 고객의 총 구매액이 전체 고객 평균 이상인 VIP 고객

-- (b) 가장 많이 팔린 장르 TOP 3

-- (c) 각 아티스트의 앨범 수 + 총 트랙 수 (서브쿼리 in FROM)


-- ============================================================
-- PART 3. 집합 연산자 (Set Operators)
-- ============================================================
--  연산자      | 중복제거 | 정렬발생 | 역할
--  ------------|----------|----------|-----------
--  UNION       |    O     |    O     | 합집합
--  UNION ALL   |    X     |    X     | 합집합(빠름)
--  INTERSECT   |    O     |    O     | 교집합
--  EXCEPT      |    O     |    O     | 차집합
--
--  공통 규칙
--   1) SELECT 컬럼 수가 동일해야 한다
--   2) 대응 컬럼의 데이터 타입이 호환되어야 한다
--   3) 첫 번째 쿼리의 컬럼명이 최종 결과셋 컬럼명
--   4) ORDER BY 는 최종 결합 결과에만 적용
-- ============================================================

-- ──────────────────────────────────────────────────────────
-- 3-1. UNION - 합집합 (중복 제거)
-- ──────────────────────────────────────────────────────────

-- (a) 직원 이름 + 고객 이름 통합 목록
-- ref: https://www.sqlitetutorial.net/sqlite-union/
select FirstName, LastName, 'employee' as Type
from employees

union

select FirstName, LastName, 'customer'
from customers

ORDER BY FirstName, LastName
;

-- (b) 구매 이력 유무별 고객 분류
-- 테이블명 : customers, invoices
-- 출력 : customerID, FirestName, LastName 고객명 as 고객명,
--                  'Has Invoice' / 'No Invoice'
-- 힌트 : WHERE 정 Customers ID 활용해서 서브쿼리

select customerID, FirstName ||''|| LastName as 고객명
    , 'Has Invoice'
from customers
where customerID Not IN (select DISTINCT customerID from invoices)
;

-- ──────────────────────────────────────────────────────────
-- 3-2. UNION ALL - 합집합 (중복 포함, 더 빠름)
-- ──────────────────────────────────────────────────────────

-- (a) 연도별 매출 + 전체 합계 리포트 (소계 패턴)
select
    strftime('%Y', InvoiceDate) as 연도
    , ROUND(SUM(Total), 2) AS 매출합계
from invoices
GROUP BY 연도

union ALL

select '------전체합계'
        , ROUND(SUM(Total), 1)
from invoices
;

-- (b) 장르별 트랙 수 + 전체 합계

select 
    g.name                         as 장르명
    , COUNT(t.TrackID)             as 트랙수
from Genres g
Left join tracks t on g.GenreID = t.GenreID
GROUP by g.Name

union ALL

select '------전체합계'
        , count(DISTINCT InvoiceID)
        , SUM(Quantity)
        , round(sum(UnitPrice * Quantity), 2)
from invoices
;

-- ──────────────────────────────────────────────────────────
-- 3-3. INTERSECT - 교집합
-- ──────────────────────────────────────────────────────────

-- (a) 청구서가 있는 고객 (INTERSECT 방식)
-- ref: https://www.sqlitetutorial.net/sqlite-intersect/

-- 현재 문제점.. Customers 59명 Invoices 59명 모두 구매를 함
-- 차집합을 하거나 할때, 차이점이 존재하지 않음


-- (b) 2009년과 2010년 모두 구매한 고객 ID
-- 2009년에 구매한 고객ID, 
select CustomerID
FROM invoices
WHERE strftime('%Y', invoiceDate) = '2009'
intersect
select CustomerID
FROM invoices
WHERE strftime('%Y', invoiceDate) = '2010'
;

-- (c) (b)에서 구매한 고객 아이디와 FirstName, LastName
select c.CustomerID, FirstName, LastName
from Customers c
inner join (

    select CustomerID
    FROM invoices
    WHERE strftime('%Y', invoiceDate) = '2009'
    intersect
    select CustomerID
    FROM invoices
    WHERE strftime('%Y', invoiceDate) = '2010'
) y
on y.CustomerID = c.CustomerID
;


-- ──────────────────────────────────────────────────────────
-- 3-4. EXCEPT - 차집합
-- ──────────────────────────────────────────────────────────

-- (a) 청구서 없는 고객 (전체 - 청구서 있는 고객)
-- ref: https://www.sqlitetutorial.net/sqlite-except/


-- (b) 2009년 구매 고객 중 2010년에 구매 안 한 고객
select CustomerID
FROM invoices
WHERE strftime('%Y', invoiceDate) = '2009'

EXCEPT

select CustomerID 
FROM invoices
WHERE strftime('%Y', invoiceDate) = '2010'
;

-- (c) (b)에서 구매한 고객 아이디와 FirstName, LastName
select c.CustomerID, FirstName, LastName
from Customers c
inner join (

    select CustomerID
    FROM invoices
    WHERE strftime('%Y', invoiceDate) = '2009'
    EXCEPT
    select CustomerID
    FROM invoices
    WHERE strftime('%Y', invoiceDate) = '2010'
) y
on y.CustomerID = c.CustomerID
;


-- (c) 플레이리스트에 없는 트랙 (미포함 트랙)


-- ============================================================
-- PART 4. 집계 함수 + 서브쿼리 + 집합 연산자 복합 활용
-- ============================================================

-- ──────────────────────────────────────────────────────────
-- 4-1. 집계 + 서브쿼리 + UNION ALL
--      장르별 매출 통계 리포트 (합계 행 포함)
-- ──────────────────────────────────────────────────────────
-- 테이블명 : invoice_items, tracks, genres
-- 집합연산자 : union ALL

select 
    g.name
    , COUNT(DISTINCT ii.InvoiceID)
    , sum(ii.Quantity)
    , round(SUM(ii.UnitPrice * ii.Quantity), 2)
from invoice_items ii
inner join tracks t on ii.trackID = t.trackID
inner join genres g on t.GenreID = g.GenreID
GROUP BY g.Name
;

-- ──────────────────────────────────────────────────────────
-- 4-3. 집계 + HAVING + EXISTS 조합
--      앨범이 2개 이상이면서 총 트랙이 30개 이상인 아티스트
-- ──────────────────────────────────────────────────────────


-- ============================================================
-- PART 5. 계층형 질의 (Hierarchical Query)
-- ============================================================
-- SQLite 방식: WITH RECURSIVE CTE
-- 대상 테이블: employees
--   EmployeeId : PK
--   ReportsTo  : 상위 관리자 FK (NULL = 최상위 Root)
-- ============================================================

-- ──────────────────────────────────────────────────────────
-- 5-1. 기본 계층형 질의 - 보고 체계 전체 조회
-- ──────────────────────────────────────────────────────────
-- Anchor: 최상위 직원 (Root)
-- Recursive: 직속 부하 반복 탐색

WITH RECURSIVE emp_hierarchy(
    EmployeeId, FirstName, LastName, Title, ReportsTo, lvl
) AS (
    -- Anchor: 최상위 직원
    SELECT EmployeeId, FirstName, LastName, Title, ReportsTo, 0 AS lvl
    FROM employees
    WHERE ReportsTo IS NULL

    UNION ALL

    -- Recursive : 직속 부하 반복 탐색 
    SELECT e.EmployeeId, e.FirstName, e.LastName, e.Title, e.ReportsTo, h.lvl + 1
    FROM employees e
    INNER JOIN emp_hierarchy h ON e.ReportsTo = h.EmployeeId
)
SELECT 
    lvl                                     AS 계층레벨
    , EmployeeId                            AS 직원ID
    , SUBSTR('          ', 1, lvl * 4) || FirstName || ' ' || LastName AS 직원명
    , Title                                 AS 직책
    , ReportsTo                             AS 관리자ID
FROM emp_hierarchy
ORDER BY lvl, EmployeeId
;
-- ──────────────────────────────────────────────────────────
-- 5-2. 계층형 + 집계 - 직원별 담당 고객 수 포함 조회
-- ──────────────────────────────────────────────────────────


-- ──────────────────────────────────────────────────────────
-- 5-3. 경로(PATH) + 리프(Leaf) 노드 판별
-- ──────────────────────────────────────────────────────────


-- ──────────────────────────────────────────────────────────
-- 5-4. 계층형 + UNION ALL - 레벨별 인원 + 전체 합계
-- ──────────────────────────────────────────────────────────


-- ============================================================
-- [참고] Oracle 계층형 질의 구문 (SQLite 미지원 - 비교용)
-- ============================================================
/*
SELECT LEVEL,
       LPAD(' ', 4*(LEVEL-1)) || EmployeeId         AS 직원ID,
       FirstName || ' ' || LastName                 AS 직원명,
       Title,
       ReportsTo,
       CONNECT_BY_ROOT  FirstName || ' ' || LastName AS 루트직원,
       CONNECT_BY_ISLEAF                             AS 리프여부,
       SYS_CONNECT_BY_PATH(LastName, '/')            AS 경로
FROM   employees
START  WITH ReportsTo IS NULL
CONNECT BY  PRIOR EmployeeId = ReportsTo
ORDER  SIBLINGS BY LastName;
*/

-- ============================================================
-- End of Day03_students_copy.sql
-- ============================================================
