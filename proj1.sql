DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching -- replace this line
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast,birthyear
  FROM people
  WHERE weight > 300 -- replace this line
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people WHERE namefirst LIKE '% %' -- replace this line
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, avg(height) as avgheight, count(*) as count
  FROM people -- replace this line
  GROUP BY birthyear
  ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, avg(height) as avgheight, count(*) as count
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear ASC -- replace this line
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, h.playerid, h.yearid
  FROM people as p, halloffame as h
  WHERE p.playerid = h.playerid AND h.inducted = 'Y'
  ORDER BY h.yearid DESC -- replace this line
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.namefirst, p.namelast, h.playerid, s.schoolid, h.yearid
  FROM people as p, halloffame as h, collegeplaying as c, schools as s
  WHERE p.playerid = h.playerid AND c.playerid = h.playerid AND s.schoolid = c.schoolid
  AND h.inducted = 'Y' AND s.schoolstate = 'CA'
  ORDER BY h.yearid DESC, s.schoolid, h.playerid ASC-- replace this line
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT h.playerid, p.namefirst, p.namelast, s.schoolid
  FROM people as p
  INNER JOIN halloffame as h ON p.playerid = h.playerid
  LEFT JOIN collegeplaying as c ON c.playerid = h.playerid
  LEFT JOIN schools as s ON s.schoolid = c.schoolid
  WHERE h.inducted = 'Y'
  ORDER BY p.playerid DESC, s.schoolid ASC;-- replace this line

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, b.yearid, (b.h - b.h2b - b.h3b - b.hr + 2*b.h2b + 3*b.h3b + 4*b.hr)/(cast(b.ab as  real)) AS slg
  FROM people as p
  INNER JOIN batting as b ON b.playerid = p.playerid
  WHERE b.ab > 50
  ORDER BY slg DESC, b.yearid, p.playerid ASC
  LIMIT 10 -- replace this line
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, sum(b.h - b.h2b - b.h3b - b.hr + 2*b.h2b + 3*b.h3b + 4*b.hr)/(cast(sum(b.ab) as  real)) AS lslg
  FROM people as p
  INNER JOIN batting as b ON b.playerid = p.playerid
  GROUP BY p.playerid
  HAVING sum(b.ab) > 50
  ORDER BY lslg DESC, p.playerid ASC
  LIMIT 10;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH T AS
  (SELECT p.playerid, p.namefirst, p.namelast,
  sum(b.h - b.h2b - b.h3b - b.hr + 2 * b.h2b + 3 * b.h3b + 4 * b.hr)
  /cast(sum(b.ab) as real) as lslg
  FROM people as p
  INNER JOIN batting as b on b.playerid = p.playerid
  WHERE b.ab > 0
  GROUP BY p.playerid
  HAVING sum(b.ab) > 50)
  SELECT namefirst, namelast, lslg FROM T
  WHERE T.lslg > (SELECT T.lslg FROM T WHERE T.playerid = 'mayswi01')
  ORDER BY namefirst;
 -- replace this line
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, min(salary) as min, max(salary) as max, avg(salary) as avg, stddev(salary) as stddev
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid ASC -- replace this line
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH X AS (SELECT MIN(salary), MAX(salary) FROM salaries WHERE yearid = '2016'),
  Y AS (SELECT i AS binid, i * (X.max - X.min) / 10.0 + X.min AS low, (i+1)*(X.max - X.min)/10.0 + X.min AS high
        From generate_series(0,9) AS i, X)
  SELECT binid, low, high, COUNT(*)
  FROM Y INNER JOIN salaries AS s ON s.salary >= Y.low AND (s.salary < Y.high OR binid = 9 AND s.salary <= Y.high)
  AND yearid = '2016'
  GROUP BY binid, low, high
  ORDER BY binid ASC
-- replace this line
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH R AS
   (SELECT yearid, min(salary) as min, max(salary) as max, avg(salary) as avg
   FROM salaries
   GROUP BY yearid)
   SELECT R.yearid,
   R.min - R2.min as mindiff,
   R.max - R2.max as maxdiff,
   R.avg - R2.avg as avgdiff
   FROM R
   INNER JOIN R as R2 ON R.yearid = R2.yearid +1
   ORDER BY R.yearid-- replace this line
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH T AS (SELECT max(s.salary) as max, s.yearid
  FROM salaries as s
  GROUP BY s.yearid
  HAVING s.yearid = 2001 or s.yearid = 2000)
  SELECT p.playerid, p.namefirst, p.namelast, t.max as salary, t.yearid
  FROM people as p
  INNER JOIN salaries as s2 ON p.playerid = s2.playerid
  INNER JOIN T as t ON t.yearid = s2.yearid and t.max = s2.salary -- replace this line
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, max(s.salary) - min(s.salary) as diffAvg
  FROM allstarfull as a
  INNER JOIN salaries as s ON s.playerid = a.playerid
  GROUP BY s.yearid, a.yearid, a.teamid
  HAVING s.yearid = 2016 and a.yearid = 2016
  ORDER BY a.teamid ASC -- replace this line
;
