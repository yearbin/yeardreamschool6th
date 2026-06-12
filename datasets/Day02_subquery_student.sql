/* =====================================================================
   5장 서브쿼리 — 실습 문제 모음 (답지 포함)
   - 강의자료 순서 준수:
       01 단일 행 서브쿼리   (WHERE 절 + 비교 연산자 =, >, <, ...)
       02 다중 행 서브쿼리   (IN / NOT IN, 그리고 ANY/ALL의 SQLite 대체)
       03 위치에 따른 분류   (스칼라(SELECT절) / FROM절 파생테이블 / EXISTS·상관)
   - 사용 DB: SQLite Tutorial 샘플 데이터베이스 (chinook)
     주요 테이블: artists, albums, tracks, genres,
                  invoices, invoice_items, customers, employees
   - 관계 요약:
       artists.ArtistId      <-> albums.ArtistId
       albums.AlbumId        <-> tracks.AlbumId
       genres.GenreId        <-> tracks.GenreId
       invoices.CustomerId   <-> customers.CustomerId
       invoice_items.TrackId <-> tracks.TrackId
       customers.SupportRepId<-> employees.EmployeeId
   - ⚠️ SQLite는 ANY / ALL 연산자를 지원하지 않음 → MIN / MAX 로 대체
   ===================================================================== */


/* ===============  01. 단일 행 서브쿼리 (WHERE, 비교 연산자)  =========== */

-- 문제 1.
-- 'Balls to the Wall' 트랙보다 재생시간(Milliseconds)이 긴 트랙의
-- 이름과 재생시간을 조회하세요. (단일 행, > 연산자)
-- 메인쿼리 : 이름과 재생시간 조회
-- 서브쿼리 : 'Balls to the Wall'의 재생시간 조회

-- 메인쿼리
SELECT Name, Milliseconds
FROM tracks
WHERE Milliseconds
;
-- 서브쿼리
SELECT Milliseconds FROM tracks where Name = 'Balls to the Wall';


-- 메인쿼리 + 서브쿼리
SELECT Name, Milliseconds
FROM tracks
WHERE Milliseconds > (
    SELECT Milliseconds 
    FROM tracks 
    where Name = 'Balls to the Wall')
;

-- 문제 2.
-- 전체 트랙의 평균 재생시간보다 긴 트랙의 이름과 재생시간을 조회하세요.
-- 힌트: 서브쿼리에서 AVG를 쓰면 한 값만 반환 = 단일 행.

-- 메인쿼리 : 트랙이름과 재생시간 조회
select Name, Milliseconds
from tracks 
where Milliseconds; > (

-- 서브쿼리 : 전체트랙의 평균 재생시간
select avg(Milliseconds)
from tracks) ;

select Name, Milliseconds
from tracks 
where Milliseconds > (
    select avg(Milliseconds) from tracks) ;


-- 문제 3.
-- 단가(UnitPrice)가 가장 비싼 트랙과 '같은' 단가를 가진 트랙의
-- 이름과 단가를 조회하세요. (= 연산자, MAX)

-- 메인쿼리 : 이름 단가 조회
select name, UnitPrice from tracks
where UnitPrice ;

-- 서브쿼리 : 단가가 가장 비싼 트랙
select max(UnitPrice) from tracks
where UnitPrice

select name, UnitPrice from tracks
where UnitPrice = (select max(UnitPrice) from tracks) ;


-- 문제 4.
-- 앨범 'Let There Be Rock'에 수록된 트랙의 이름을 조회하세요.
-- 힌트: 앨범 1개의 AlbumId는 단일 행 → = 연산자 사용.
-- 메인 : 트랙의 이름조회, 서브 : 'let~~이 수록된 트랙'

select name from tracks
where albumID = (
    select name, 'Let There Be Rock' from tracks
);

SELECT Name
FROM tracks
WHERE AlbumId = (
    SELECT AlbumId FROM albums WHERE Title = 'Let There Be Rock'


-- 문제 5.
-- 인보이스 총액(Total)이 전체 평균 총액보다 '작은'(<) 인보이스의
-- InvoiceId와 Total을 조회하세요.
--메인 : 인보이스의 invoiceID 와 total 조회
--서브 : 인보이스 총액이 전체 평균

SELECT InvoiceId, Total
FROM invoices
WHERE Total < (
    SELECT AVG(Total) FROM invoices
);


/* ===================  02. 다중 행 서브쿼리 (IN / NOT IN)  ============== */

-- 문제 6.
-- 'AC/DC'가 발매한 앨범에 속한 모든 트랙의 이름을 조회하세요.
-- 힌트: 아티스트→여러 앨범(다중 행)이므로 IN. (서브쿼리 중첩)
-- 메인 쿼리 : 트랙의 이름 조회
-- 서브 쿼리 : 트랙의 이름 조회
-- 서브 쿼리 : 'AC/DC가 발매한 앨범
---- 서브 쿼리의 메인 쿼리 : AlbumID From Albums
SELECT Name FROM tracks;

-- 서브쿼리 : 'AC/DC'가 발매한 앨범ID
---- 서브쿼리의 메인쿼리 : AlbumID FROM Albums
SELECT AlbumId FROM albums;
---- 서브쿼리의 서브쿼리 : AC/DC의 ArtistID조회
SELECT ArtistId FROM artists WHERE Name = 'AC/DC';

-- 서브쿼리 합치기
SELECT AlbumId FROM albums
WHERE ArtistId = (
    SELECT ArtistId FROM artists WHERE Name = 'AC/DC'
);
-- 메인쿼리 : 트랙의 이름 조회
SELECT Name FROM tracks 
WHERE AlbumID IN (
    SELECT AlbumId FROM albums
    WHERE ArtistId = (SELECT ArtistId FROM artists WHERE Name = 'AC/DC')
);

-- 문제 7.
-- 담당 직원(SupportRepId)이 캐나다(Country = 'Canada')에 근무하는
-- 고객의 이름(FirstName, LastName)을 조회하세요. (IN)
-- 테이블명 : customers, employees

-- 메인 고객의 FristName, LastName 조회
-- 서브 캐나다에서 근무 하는 담당 직원
select FirstName, LastName From customers where SupportRepId in
    (select employeeID from employees where country = 'Canada')
    ;


-- 문제 8.
-- 한 번이라도 구매된 적이 있는(invoice_items에 등장한) 트랙의 이름을
-- 조회하세요. (IN)
-- 테이블명 : tracks, invoice_items
-- 메인 트랙의 이름 조회, 
-- 서브 invoice_items에서 trackID 조회

select Name from tracks
where trackID in (
select TrackID From invoice_items);


-- 문제 9.
-- 한 번도 구매되지 않은 트랙의 이름을 조회하세요. (NOT IN)
-- 주의: 서브쿼리 결과에 NULL이 섞이면 NOT IN은 아무 것도 반환하지 않을 수
--       있음 → 문제 19의 NOT EXISTS 방식이 더 안전.

select Name from tracks
where trackID not in (
select TrackID From invoice_items);

-- 문제 10.
-- 'Rock' 장르의 트랙이 한 곡이라도 포함된 앨범의 제목을 조회하세요. (IN)
-- 테이블 명 : albums, tracks, genres

-- 메인쿼리 : tracks의 앨범ID
-- 서브쿼리 : 'Rock' 장르ID

SELECT Title
FROM albums
WHERE AlbumId IN (
    SELECT AlbumId FROM tracks
    WHERE GenreId = (SELECT GenreId FROM genres WHERE Name = 'Rock')
);


/* ----  [SQLite 보강] 강의자료의 ANY / ALL → SQLite에서는 MIN / MAX  ---- */

-- 문제 11.  (강의자료의 ALL 개념)
-- 'Rock' 장르의 '모든' 트랙보다 재생시간이 긴 트랙의 이름을 조회하세요.
-- ❌ SQLite 미지원: WHERE Milliseconds > ALL (SELECT Milliseconds ...)
-- ✅ 대체: ALL → MAX (모든 값보다 크다 = 최댓값보다 크다)
-- 메인쿼리 : Name, Milliseconds

-- 
select name Milliseconds
from tracks
where Milliseconds > 
;
-- 서브쿼리 :
-- Rock 장르와 관련된 것은 Genre 테이블, GenreID 추출 
select max(Milliseconds) from tracks
where GenreID = ();

select GenreID from Genres where name = 'Rock';

select * from Genres;
-- 최종
SELECT Name, Milliseconds
FROM tracks
WHERE Milliseconds > (
    SELECT MAX(Milliseconds) FROM tracks
    WHERE GenreId = (SELECT GenreId FROM genres WHERE Name = 'Rock')
);


-- 문제 12.  (강의자료의 ANY 개념)
-- 'Jazz' 장르 트랙 중 '하나라도'보다 재생시간이 긴 트랙의 이름을 조회하세요.
-- ❌ SQLite 미지원: WHERE Milliseconds > ANY (...)
-- ✅ 대체: ANY → MIN (하나라도보다 크다 = 최솟값보다 크다)
-- 메인

SELECT Name, Milliseconds
FROM tracks
WHERE Milliseconds > (
    SELECT MIN(Milliseconds) FROM tracks
    WHERE GenreId = (SELECT GenreId FROM genres WHERE Name = 'Jazz')
);


/* ============  03. 위치에 따른 분류 — 스칼라 서브쿼리 (SELECT 절)  ===== */

-- 문제 13.
-- 각 앨범의 제목과, 그 앨범에 속한 트랙 수를 스칼라 서브쿼리로 함께
-- 조회하세요. (상관 서브쿼리: 바깥의 a.AlbumId 참조)
-- 메인 쿼리 : 앨범의 제목. 서브쿼리 : 앨범에 속한 트랙 수
select
    a.Title
    , (select count(*) from tracks t where t.albumID = a.albumID) as track_cnt
from albums a;

-- 문제 14.
-- 각 고객의 이름과, 그 고객의 총 결제 금액(SUM(Total))을 스칼라 서브쿼리로
-- 조회하세요. 테이블명 customers, invoices
-- 메인 고객의 이름을 구한다.  서브 : 총 결제 금액 구하기 (고객ID 매칭)
select * from invoices;
select
    c.FirstName
    , c.LastName
    , (select sum(i.total) from invoices i where i.CustomerId = i.CustomerId) as customer_cnt
from customers c;

-- 문제 15.
-- 각 트랙의 이름과, 그 트랙이 속한 앨범 제목을 스칼라 서브쿼리로 조회하세요.
-- (강의자료 포인트: 스칼라 서브쿼리는 JOIN과 같은 결과)
--
select
    t.name
    , (select al.Title from albums al where al.albumID = t.albumID) as album_title
from tracks t
;

-- 문제 15-1.  (참고) 위 문제 15를 JOIN으로 바꾼 동일 결과


/* -------------  [보강] FROM 절 서브쿼리 (파생 테이블, 별칭 필수)  ------- */

-- 문제 16.
-- 앨범별 트랙 수를 먼저 구한 뒤, 그 트랙 수의 '전체 평균'을 구하세요.
-- 힌트: FROM 절 서브쿼리에는 반드시 별칭(AS ...)을 붙입니다.



-- 문제 17.
-- 국가별 매출 합계를 구한 파생 테이블에서, 매출이 높은 상위 5개 국가를
-- 조회하세요.
-- select * from (서브쿼리) group by / order by
-- 메인 쿼리 : 매출이 높은 국가 출력
-- invoices
select BillingCountry from (
select BillingCountry, sum(Total) 
from invoices 
GROUP BY BillingCountry 
order BY 2 desc 
limit 5)
;



/* ----------------  [보강] EXISTS / 상관 서브쿼리  -------------------- */

-- 문제 18.
-- 트랙이 한 곡이라도 존재하는 앨범의 제목을 EXISTS로 조회하세요.

-- 문제 19.
-- 한 번도 구매된 적이 없는 트랙의 이름을 NOT EXISTS로 조회하세요.
-- (문제 9의 NOT IN보다 NULL 안전한 방식)

-- 문제 20.  (종합)
-- 각 직원에 대해 그 직원이 담당하는 고객 수를 스칼라 서브쿼리로 구하되,
-- 담당 고객이 한 명 이상인 직원만 조회하세요.
-- (스칼라 서브쿼리 + WHERE 절 다중 행 서브쿼리 동시 사용)


/* =====================================================================
   개념 Quiz 10제  (정답·해설은 파일 맨 아래)
   ===================================================================== */

-- Quiz 1. 서브쿼리에 대한 설명으로 옳은 것은?
--   (A) 메인 쿼리와 완전히 독립적인 별개의 쿼리이다
--   (B) 하나의 쿼리 안에 포함된 또 하나의 쿼리이다
--   (C) 두 테이블을 가로로 합치는 명령이다
--   (D) 항상 메인 쿼리 다음에 실행된다

-- Quiz 2. 서브쿼리 사용 시 규칙으로 '틀린' 것은?
--   (A) 서브쿼리는 괄호로 감싸야 한다
--   (B) 비교 연산자의 오른쪽에 위치한다
--   (C) 서브쿼리 내부는 SELECT 문이어야 한다
--   (D) 서브쿼리는 SELECT 문 안에서만 쓸 수 있고 DELETE에는 못 쓴다

-- Quiz 3. 단일 행 서브쿼리에 사용할 수 '없는' 연산자는?
--   (A) =     (B) >=     (C) IN     (D) <>

-- Quiz 4. SQLite에서 '지원하지 않는' 다중 행 연산자끼리 묶인 것은?
--   (A) IN, NOT IN     (B) ANY, ALL     (C) EXISTS, IN     (D) =, <>

-- Quiz 5. 강의자료의  10 < ANY (1, 2, 3, 4)  의 결과는?
--   (A) 참(목록 중 하나라도 10보다 큰 값이 있으므로)
--   (B) 거짓(10보다 큰 값이 목록에 없으므로)
--   (C) 에러
--   (D) NULL

-- Quiz 6. SQLite에서  "Rock 장르 모든 트랙보다 긴 트랙"  을 구할 때
--         ALL 대신 사용해야 하는 집계 함수는?
--   (A) MIN     (B) MAX     (C) AVG     (D) COUNT

-- Quiz 7. NOT IN 서브쿼리의 결과에 NULL이 섞여 있을 때 일어나는 일은?
--   (A) NULL은 무시되고 정상 동작한다
--   (B) 자동으로 NOT EXISTS로 바뀐다
--   (C) 결과가 비어버릴(아무 행도 안 나올) 수 있다
--   (D) 문법 에러가 발생한다

-- Quiz 8. 스칼라 서브쿼리에 대한 설명으로 옳은 것은?
--   (A) FROM 절에서만 쓸 수 있다
--   (B) SELECT 절에서 쓰며 한 행(한 값)만 반환한다
--   (C) 항상 두 개 이상의 값을 반환한다
--   (D) JOIN으로는 절대 같은 결과를 낼 수 없다

-- Quiz 9. FROM 절 서브쿼리(파생 테이블)에서 반드시 필요한 것은?
--   (A) ORDER BY     (B) 별칭(alias)     (C) HAVING     (D) DISTINCT

-- Quiz 10. 바깥 쿼리의 컬럼 값을 참조하여 행마다 다시 실행되는 서브쿼리는?
--   (A) 스칼라 서브쿼리     (B) 파생 테이블
--   (C) 상관(correlated) 서브쿼리     (D) 단일 행 서브쿼리
