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
),
PositionInfo AS (
    SELECT 
        f.Player AS Player,
        p.Position AS Position,
        f.PPRpts AS PPRpts
    FROM 
        FD_Actuals_ppr f
    JOIN 
        PlayerInfo p ON f.Player = p.Player
),
RankedPositions AS (
    SELECT 
        Player,
        Position,
        PPRpts,
        Position || CAST(ROW_NUMBER() OVER (PARTITION BY Position ORDER BY PPRpts DESC) AS TEXT) AS Act_Rankings
    FROM 
        PositionInfo
),
Consolidated_ADP AS (
    SELECT 
        e.Player AS Player,
        e.ADP AS ESPN_ADP,
        n.ADP AS NFL_ADP,
        r.ADP AS ROTO_ADP,
        (e.ADP + n.ADP + r.ADP) / 3.0 AS Consensus_ADP
    FROM 
        ESPN_Data e
    LEFT JOIN 
        NFL_Data n ON e.Player = n.Player
    LEFT JOIN 
        Roto_Data r ON e.Player = r.Player
),
Consensus_Rankings AS (
    SELECT 
        c.Player AS Player,
        p.Position || CAST(ROW_NUMBER() OVER (PARTITION BY p.Position ORDER BY c.Consensus_ADP) AS TEXT) AS Consensus_PosRank
    FROM 
        Consolidated_ADP c
    JOIN 
        PlayerInfo p ON c.Player = p.Player
)
SELECT 
    c.Player AS Player,
    c.ESPN_ADP,
    c.NFL_ADP,
    c.ROTO_ADP,
    c.Consensus_ADP,
    er.ESPN_PosRank,
    nr.NFL_PosRank,
    rr.ROTO_PosRank,
    cr.Consensus_PosRank,
    rp.Act_Rankings
FROM 
    Consolidated_ADP c
LEFT JOIN 
    ESPN_Rankings er ON c.Player = er.Player
LEFT JOIN 
    NFL_Rankings nr ON c.Player = nr.Player
LEFT JOIN 
    Roto_Rankings rr ON c.Player = rr.Player
LEFT JOIN 
    RankedPositions rp ON c.Player = rp.Player
LEFT JOIN 
    Consensus_Rankings cr ON c.Player = cr.Player;