SELECT 
    e.Player AS Player,
    e.ADP AS ESPN_ADP,
    n.ADP AS NFL_ADP,
    r.ADP AS ROTO_ADP,
    (e.ADP + n.ADP + r.ADP) / 3.0 AS Cons_ADP
FROM 
    ESPN_Data e
LEFT JOIN 
    NFL_Data n ON e.Player = n.Player
LEFT JOIN 
    Roto_Data r ON e.Player = r.Player;

	
WITH ESPN_Rankings AS (
    SELECT 
        Player,
        Position || CAST(ROW_NUMBER() OVER (PARTITION BY Position ORDER BY ADP) AS TEXT) AS ESPN_PosRank
    FROM ESPN_Data
),
NFL_Rankings AS (
    SELECT 
        Player,
        Position || CAST(ROW_NUMBER() OVER (PARTITION BY Position ORDER BY ADP) AS TEXT) AS NFL_PosRank
    FROM NFL_Data
),
Roto_Rankings AS (
    SELECT 
        Player,
        Position || CAST(ROW_NUMBER() OVER (PARTITION BY Position ORDER BY ADP) AS TEXT) AS ROTO_PosRank
    FROM Roto_Data
)
SELECT 
    e.Player AS Player,
    e.ESPN_PosRank,
    n.NFL_PosRank,
    r.ROTO_PosRank
FROM 
    ESPN_Rankings e
LEFT JOIN 
    NFL_Rankings n ON e.Player = n.Player
LEFT JOIN 
    Roto_Rankings r ON e.Player = r.Player;