module Logic where 

import Data.List (sortBy, nub, maximumBy)
import Data.Ord (comparing, Down(..))
import Data.Text (Text)
import qualified Data.Text as T
import Types 

--retorna o multplicador de dano 
--tabela pega do site bubagarden
typeEffectiveness :: PokemonTypeName -> PokemonTypeName -> Double
typeEffectiveness attacker defender = case (attacker, defender) of
    -- Fogo
    ("fire",     "grass")    -> 2.0
    ("fire",     "ice")      -> 2.0
    ("fire",     "bug")      -> 2.0
    ("fire",     "steel")    -> 2.0
    ("fire",     "water")    -> 0.5
    ("fire",     "fire")     -> 0.5
    ("fire",     "rock")     -> 0.5
    ("fire",     "dragon")   -> 0.5
    -- Água
    ("water",    "fire")     -> 2.0
    ("water",    "ground")   -> 2.0
    ("water",    "rock")     -> 2.0
    ("water",    "water")    -> 0.5
    ("water",    "grass")    -> 0.5
    ("water",    "dragon")   -> 0.5
    -- Elétrico
    ("electric", "water")    -> 2.0
    ("electric", "flying")   -> 2.0
    ("electric", "electric") -> 0.5
    ("electric", "grass")    -> 0.5
    ("electric", "dragon")   -> 0.5
    ("electric", "ground")   -> 0.0
    -- Grama
    ("grass",    "water")    -> 2.0
    ("grass",    "ground")   -> 2.0
    ("grass",    "rock")     -> 2.0
    ("grass",    "fire")     -> 0.5
    ("grass",    "grass")    -> 0.5
    ("grass",    "poison")   -> 0.5
    ("grass",    "flying")   -> 0.5
    ("grass",    "bug")      -> 0.5
    ("grass",    "dragon")   -> 0.5
    ("grass",    "steel")    -> 0.5
    -- Gelo
    ("ice",      "grass")    -> 2.0
    ("ice",      "ground")   -> 2.0
    ("ice",      "flying")   -> 2.0
    ("ice",      "dragon")   -> 2.0
    ("ice",      "fire")     -> 0.5
    ("ice",      "water")    -> 0.5
    ("ice",      "ice")      -> 0.5
    ("ice",      "steel")    -> 0.5
    -- Luta
    ("fighting", "normal")   -> 2.0
    ("fighting", "ice")      -> 2.0
    ("fighting", "rock")     -> 2.0
    ("fighting", "dark")     -> 2.0
    ("fighting", "steel")    -> 2.0
    ("fighting", "poison")   -> 0.5
    ("fighting", "flying")   -> 0.5
    ("fighting", "psychic")  -> 0.5
    ("fighting", "bug")      -> 0.5
    ("fighting", "fairy")    -> 0.5
    ("fighting", "ghost")    -> 0.0
    -- Veneno
    ("poison",   "grass")    -> 2.0
    ("poison",   "fairy")    -> 2.0
    ("poison",   "poison")   -> 0.5
    ("poison",   "ground")   -> 0.5
    ("poison",   "rock")     -> 0.5
    ("poison",   "ghost")    -> 0.5
    ("poison",   "steel")    -> 0.0
    -- Terra
    ("ground",   "fire")     -> 2.0
    ("ground",   "electric") -> 2.0
    ("ground",   "poison")   -> 2.0
    ("ground",   "rock")     -> 2.0
    ("ground",   "steel")    -> 2.0
    ("ground",   "grass")    -> 0.5
    ("ground",   "bug")      -> 0.5
    ("ground",   "flying")   -> 0.0
    -- Voador
    ("flying",   "grass")    -> 2.0
    ("flying",   "fighting") -> 2.0
    ("flying",   "bug")      -> 2.0
    ("flying",   "electric") -> 0.5
    ("flying",   "rock")     -> 0.5
    ("flying",   "steel")    -> 0.5
    -- Psíquico
    ("psychic",  "fighting") -> 2.0
    ("psychic",  "poison")   -> 2.0
    ("psychic",  "psychic")  -> 0.5
    ("psychic",  "steel")    -> 0.5
    ("psychic",  "dark")     -> 0.0
    -- Bug
    ("bug",      "grass")    -> 2.0
    ("bug",      "psychic")  -> 2.0
    ("bug",      "dark")     -> 2.0
    ("bug",      "fire")     -> 0.5
    ("bug",      "fighting") -> 0.5
    ("bug",      "poison")   -> 0.5
    ("bug",      "flying")   -> 0.5
    ("bug",      "ghost")    -> 0.5
    ("bug",      "steel")    -> 0.5
    ("bug",      "fairy")    -> 0.5
    -- Pedra
    ("rock",     "fire")     -> 2.0
    ("rock",     "ice")      -> 2.0
    ("rock",     "flying")   -> 2.0
    ("rock",     "bug")      -> 2.0
    ("rock",     "fighting") -> 0.5
    ("rock",     "ground")   -> 0.5
    ("rock",     "steel")    -> 0.5
    -- Fantasma
    ("ghost",    "ghost")    -> 2.0
    ("ghost",    "psychic")  -> 2.0
    ("ghost",    "normal")   -> 0.0
    ("ghost",    "dark")     -> 0.5
    -- Dragão
    ("dragon",   "dragon")   -> 2.0
    ("dragon",   "steel")    -> 0.5
    ("dragon",   "fairy")    -> 0.0
    -- Sombrio
    ("dark",     "ghost")    -> 2.0
    ("dark",     "psychic")  -> 2.0
    ("dark",     "fighting") -> 0.5
    ("dark",     "dark")     -> 0.5
    ("dark",     "fairy")    -> 0.5
    -- Metálico
    ("steel",    "ice")      -> 2.0
    ("steel",    "rock")     -> 2.0
    ("steel",    "fairy")    -> 2.0
    ("steel",    "fire")     -> 0.5
    ("steel",    "water")    -> 0.5
    ("steel",    "electric") -> 0.5
    ("steel",    "steel")    -> 0.5
    -- Fada
    ("fairy",    "fighting") -> 2.0
    ("fairy",    "dragon")   -> 2.0
    ("fairy",    "dark")     -> 2.0
    ("fairy",    "fire")     -> 0.5
    ("fairy",    "poison")   -> 0.5
    ("fairy",    "steel")    -> 0.5
    -- Normal: não é super efetivo contra nada, fraco contra luta
    ("normal",   "rock")     -> 0.5
    ("normal",   "steel")    -> 0.5
    ("normal",   "ghost")    -> 0.0
    -- padrão
    _                        -> 1.0

-- -------------------------------------------------------------------------
-- Funções de teste e analise (testaveis sem o scotty, nao esquece diogo) --
-- -------------------------------------------------------------------------

-- calcular o multiplicador total de um tipo atacante 
combinedEffectiveness :: PokemonTypeName -> [PokemonTypeName] -> Double
combinedEffectiveness attacker defenderTypes = product [typeEffectiveness attacker pokemon | pokemon <- defenderTypes]

-- ver a relação de dano 
calcWeakness :: [PokemonTypeName] -> [DamageRelation]
calcWeakness = defenderTypes = 
    [
        DamageRelation attacker mult | attacker <- allTypes,
        let mult = combinedEffectiveness attacker defenderTypes 
    ]

-- filtra fraquezas com mult > 1.0
filterWeaknesses :: [DamageRelation] ->  [DamageRelation]
filterWeaknesses = filter (\damage -> damageMultiplier damage > 1.0)

-- filtra resistencia com mult < 1.0
filterResistances :: [DamageRelation] -> [DamageRelation]
filterResistances = filter (\resistence -> resistenceMultiplier resistence < 1.0)

-- relata as fraquezas para um membro do time 
buildWeaknessReport :: TeamMember -> WeaknessReport
buildWeaknessReport member = 
    let allRelations = calcWeakness (memberTypes member) in WeaknessReport
    {
        wrMember = member,
        wrWeaknesses = sortBy (comparing (Dow . damageMultiplier)) (filterWeaknesses allRelations),
        wrResistance = sortBy (comparing resistenceMultiplier) (filterResistances allRelations)
    }

-- calcula os ataques que o time resiste ( pelo menos um membro)
coveredTypes :: [WeaknessReport] -> [PokemonTypeName]
coveredTypes reports = 
    nub [
        resistenceType re | report <- reports,
        re <- wrResistance
    ]

-- calcula a pontuação de cobertura do time 0.0 ate 1.0
scoreCoverage :: [WeaknessReport] -> Double
scoreCoverage reports = 
    let covered = length (coveredTypes reports)
        total = length allTypes
    in fromIntegral covered / fromIntegral total

-- ve os tipos mais problematicos para o time 
uncoveredWeakTypes :: [WeaknessReport] -> [PokemonTypeName]
uncoveredWeakTypes reports = 
    let covered = coveredTypes reports 
        -- afeta pelo menos um membro do time 
        weakFor = nub [
            drType dr | report <- reports,
            dr <- wrWeaknesses
        ]
    in filter (`notElem` covered) weakFor

-- sugere um tipo para cobrir a fraqueza
suggestionBestType :: [WeaknessReport] -> Maybe PokemonTypeName
suggestionBestType reports =
    let uncovered = uncoveredWeakTypes reports in 
        if null uncovered
            then Nothing 
        else 
            let score t = length [
                 u | u <- uncovered,
                 combinedEffectiveness u [t] < 1.0
                ]
                candidates = filter (\t -> score t > 0) allTypes
        in 
            if null candidates
                then Nothing 
            else
                just $ maximumBy (comparing score) candidates 
-- exemplo de pokemons conhecidos pelo tipo  
examplesByType :: PokemonTypeName -> [Text]
examplesByType t = case t of
  "fire"     -> ["Charizard", "Arcanine", "Heatran"]
  "water"    -> ["Gyarados", "Starmie", "Swampert"]
  "electric" -> ["Raichu", "Jolteon", "Magnezone"]
  "grass"    -> ["Venusaur", "Roserade", "Ferrothorn"]
  "ice"      -> ["Lapras", "Mamoswine", "Weavile"]
  "fighting" -> ["Lucario", "Machamp", "Conkeldurr"]
  "poison"   -> ["Gengar", "Toxapex", "Nidoking"]
  "ground"   -> ["Garchomp", "Excadrill", "Gliscor"]
  "flying"   -> ["Togekiss", "Skarmory", "Landorus"]
  "psychic"  -> ["Alakazam", "Gardevoir", "Espeon"]
  "bug"      -> ["Scizor", "Volcarona", "Heracross"]
  "rock"     -> ["Tyranitar", "Aerodactyl", "Rhyperior"]
  "ghost"    -> ["Gengar", "Chandelure", "Mimikyu"]
  "dragon"   -> ["Dragonite", "Salamence", "Garchomp"]
  "dark"     -> ["Umbreon", "Hydreigon", "Weavile"]
  "steel"    -> ["Metagross", "Skarmory", "Ferrothorn"]
  "fairy"    -> ["Clefable", "Togekiss", "Sylveon"]
  "normal"   -> ["Snorlax", "Porygon-Z", "Blissey"]
  _          -> []

-- monsta a sugestao completa baseada no time 
buildSuggestion :: [WeaknessReport] -> Maybe Suggestion 
buildSuggestion reports = do 
    bestType <- suggestionBestType reports 
    let uncovered = uncoveredWeakTypes reports
        reason = "cobre fraquezas a: "<> T.intercalate ", " (take 4 uncovered)
    return $ Suggestion
    {
        suggesType = bestType,
        suggestedNames = examplesByType bestType,
        suggetionReason = reason
    }

-- ponto de entrada da analise completa do time ( sem I\O)
analyzeTeam :: [TeamMember] -> TeamAnalysis
analyzeTeam members = 
    let reports = map buildWeaknessReport members 
    in TeamAnalysis 
    {
        taMember = reports,
        taCoverageScore = scoreCoverage reports,
        taUncoveredTypes = uncoveredWeakTypes reports
    }