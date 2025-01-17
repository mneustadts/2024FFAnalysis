WITH Consolidated_Projections AS (
    SELECT 
        e.Player AS Player,
        e.ProjPts AS ESPN_pp,
        n.ProjPts AS NFL_pp,
        r.ProjPts AS ROTO_pp,
        (
            COALESCE(e.ProjPts, 0) + 
            COALESCE(n.ProjPts, 0) + 
            COALESCE(r.ProjPts, 0)
        ) / 
        (
            CASE 
                WHEN e.ProjPts IS NOT NULL THEN 1 ELSE 0 END +
            CASE 
                WHEN n.ProjPts IS NOT NULL THEN 1 ELSE 0 END +
            CASE 
                WHEN r.ProjPts IS NOT NULL THEN 1 ELSE 0 END
        ) AS Consensus_pp
    FROM 
        ESPN_Data e
    FULL OUTER JOIN 
        NFL_Data n ON e.Player = n.Player
    FULL OUTER JOIN 
        Roto_Data r ON COALESCE(e.Player, n.Player) = r.Player
)
SELECT 
    Player,
    ESPN_pp,
    NFL_pp,
    ROTO_pp,
    Consensus_pp
FROM 
    Consolidated_Projections;
