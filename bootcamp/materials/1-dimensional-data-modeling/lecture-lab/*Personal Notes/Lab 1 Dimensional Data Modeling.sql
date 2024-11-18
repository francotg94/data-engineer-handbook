-- SELECT * FROM player_seasons;
-- CREATE TYPE season_stats AS (
--                         season INTEGER,
--                         gp INTEGER,
--                         pts REAL,
--                         reb REAL,
--                         ast REAL
--                             )

-- CREATE TYPE scoring_class AS ENUM ('star', 'good', 'average', 'bad');
--
-- CREATE TABLE players (
--     player_name TEXT,
--     height TEXT,
--     college TEXT,
--     country TEXT,
--     draft_year TEXT,
--     draft_round TEXT,
--     draft_number TEXT,
--     season_stats season_stats[],
--     scoring_class scoring_class,
--     years_since_last_season INTEGER,
--     current_season INTEGER,
--     PRIMARY KEY(player_name, current_season)
-- );

--Query run earlier in lab
--SELECT MIN(season) FROM player_seasons;

--Query run about half way through lab
-- INSERT INTO players

-- DROP TABLE players;
--
INSERT INTO players (
    player_name,
    height,
    college,
    country,
    draft_year,
    draft_round,
    draft_number,
    season_stats,
    scoring_class,
    years_since_last_season,
    current_season
)
WITH yesterday AS (
    SELECT * FROM players
    WHERE current_season = 1996
),
today AS (
    SELECT * FROM player_seasons
    WHERE season = 1997
)
SELECT
    COALESCE(t.player_name, y.player_name) AS player_name,
    COALESCE(t.height, y.height) AS height,
    COALESCE(t.college, y.college) AS college,
    COALESCE(t.country, y.country) AS country,
    COALESCE(t.draft_year, y.draft_year) AS draft_year,
    COALESCE(t.draft_round, y.draft_round) AS draft_round,
    COALESCE(t.draft_number, y.draft_number) AS draft_number,
    CASE
        WHEN y.season_stats IS NULL THEN ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats
        ]
        WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats
        ]
        ELSE y.season_stats
    END AS season_stats,
    CASE
        WHEN t.season IS NOT NULL THEN
            CASE
                WHEN t.pts > 20 THEN 'star'
                WHEN t.pts > 15 THEN 'good'
                WHEN t.pts > 10 THEN 'average'
                ELSE 'bad'
            END::scoring_class
        ELSE y.scoring_class
    END AS scoring_class,
    CASE
        WHEN t.season IS NOT NULL THEN 0
        ELSE y.years_since_last_season + 1
    END AS years_since_last_season,
    COALESCE(t.season, y.current_season + 1) AS current_season
FROM today t
FULL OUTER JOIN yesterday y
    ON t.player_name = y.player_name
ON CONFLICT (player_name, current_season) DO NOTHING;

SELECT * FROM players
WHERE current_season = 1997;
-- AND player_name = 'Michael Jordan';

-- WITH unnested AS (
-- SELECT player_name,
--        UNNEST(season_stats) :: season_stats AS season_stats
--         FROM players
-- WHERE current_season = 2001
-- AND player_name = 'Michael Jordan'
-- )
-- SELECT player_name,
--        (season_stats::season_stats).*
-- FROM unnested