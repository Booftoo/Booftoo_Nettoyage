Config = {}

-- Position pour récupérer le balai
Config.BroomPickup = vector3(1714.12, 2525.26, 45.56)

-- Coordonnées des points Vector2 à nettoyer
Config.CleaningPoints = {
    vector2(1731.01, 2533.88),
    vector2(1723.39, 2535.43),
    vector2(1722.85, 2542.75),
    vector2(1730.28, 2545.32),
    vector2(1736.96, 2539.77),
    vector2(1740.50, 2529.84),
    vector2(1729.55, 2521.88),
}

-- Temps de nettoyage en secondes
Config.CleaningTime = 30

-- 30secondes  - 7 = 140$ sois 20$ / tâches

-- Récompense finale
Config.RewardItem = "money"
Config.RewardAmount = 140
