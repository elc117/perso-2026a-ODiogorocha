{-# LANGUAGE OverloadedStrings #-}

module Logic where

import Types
import Data.Text (Text)
import qualified Data.Text as T
import Data.List (nub)
-- import Data.Maybe (catMaybes)

-- Tabela de efetividade completa
effectivenessMap :: [(Text, Text, Double)]
effectivenessMap = 
  [ ("normal", "rock", 0.5), ("normal", "steel", 0.5), ("normal", "ghost", 0.0)
  , ("fire", "grass", 2.0), ("fire", "ice", 2.0), ("fire", "bug", 2.0)
  , ("fire", "steel", 2.0), ("fire", "fire", 0.5), ("fire", "water", 0.5)
  , ("fire", "dragon", 0.5), ("fire", "rock", 0.5)
  , ("water", "fire", 2.0), ("water", "ground", 2.0), ("water", "rock", 2.0)
  , ("water", "water", 0.5), ("water", "grass", 0.5), ("water", "dragon", 0.5)
  , ("electric", "water", 2.0), ("electric", "flying", 2.0)
  , ("electric", "electric", 0.5), ("electric", "grass", 0.5)
  , ("electric", "dragon", 0.5), ("electric", "ground", 0.0)
  , ("grass", "water", 2.0), ("grass", "ground", 2.0), ("grass", "rock", 2.0)
  , ("grass", "fire", 0.5), ("grass", "grass", 0.5), ("grass", "poison", 0.5)
  , ("grass", "flying", 0.5), ("grass", "bug", 0.5), ("grass", "dragon", 0.5)
  , ("grass", "steel", 0.5)
  , ("ice", "grass", 2.0), ("ice", "ground", 2.0), ("ice", "flying", 2.0)
  , ("ice", "dragon", 2.0), ("ice", "fire", 0.5), ("ice", "water", 0.5)
  , ("ice", "ice", 0.5), ("ice", "steel", 0.5)
  , ("fighting", "normal", 2.0), ("fighting", "ice", 2.0), ("fighting", "rock", 2.0)
  , ("fighting", "dark", 2.0), ("fighting", "steel", 2.0), ("fighting", "poison", 0.5)
  , ("fighting", "flying", 0.5), ("fighting", "psychic", 0.5), ("fighting", "bug", 0.5)
  , ("fighting", "fairy", 0.5), ("fighting", "ghost", 0.0)
  , ("poison", "grass", 2.0), ("poison", "fairy", 2.0), ("poison", "poison", 0.5)
  , ("poison", "ground", 0.5), ("poison", "rock", 0.5), ("poison", "ghost", 0.5)
  , ("poison", "steel", 0.0)
  , ("ground", "fire", 2.0), ("ground", "electric", 2.0), ("ground", "poison", 2.0)
  , ("ground", "rock", 2.0), ("ground", "steel", 2.0), ("ground", "grass", 0.5)
  , ("ground", "bug", 0.5), ("ground", "flying", 0.0)
  , ("flying", "grass", 2.0), ("flying", "fighting", 2.0), ("flying", "bug", 2.0)
  , ("flying", "electric", 0.5), ("flying", "rock", 0.5), ("flying", "steel", 0.5)
  , ("psychic", "fighting", 2.0), ("psychic", "poison", 2.0), ("psychic", "psychic", 0.5)
  , ("psychic", "steel", 0.5), ("psychic", "dark", 0.0)
  , ("bug", "grass", 2.0), ("bug", "psychic", 2.0), ("bug", "dark", 2.0)
  , ("bug", "fire", 0.5), ("bug", "fighting", 0.5), ("bug", "poison", 0.5)
  , ("bug", "flying", 0.5), ("bug", "ghost", 0.5), ("bug", "steel", 0.5)
  , ("rock", "fire", 2.0), ("rock", "ice", 2.0), ("rock", "flying", 2.0)
  , ("rock", "bug", 2.0), ("rock", "fighting", 0.5), ("rock", "ground", 0.5)
  , ("rock", "steel", 0.5)
  , ("ghost", "psychic", 2.0), ("ghost", "ghost", 2.0), ("ghost", "dark", 0.5)
  , ("ghost", "normal", 0.0)
  , ("dragon", "dragon", 2.0), ("dragon", "steel", 0.5), ("dragon", "fairy", 0.0)
  , ("dark", "psychic", 2.0), ("dark", "ghost", 2.0), ("dark", "fighting", 0.5)
  , ("dark", "dark", 0.5), ("dark", "fairy", 0.5)
  , ("steel", "ice", 2.0), ("steel", "rock", 2.0), ("steel", "fairy", 2.0)
  , ("steel", "fire", 0.5), ("steel", "water", 0.5), ("steel", "electric", 0.5)
  , ("steel", "steel", 0.5)
  , ("fairy", "fighting", 2.0), ("fairy", "dragon", 2.0), ("fairy", "dark", 2.0)
  , ("fairy", "fire", 0.5), ("fairy", "poison", 0.5), ("fairy", "steel", 0.5)
  ]

allTypes :: [Text]
allTypes = ["normal", "fire", "water", "electric", "grass", "ice"
           ,"fighting", "poison", "ground", "flying", "psychic"
           ,"bug", "rock", "ghost", "dragon", "dark", "steel", "fairy"]

-- Calcula multiplicador de dano
calculateDamageMultiplier :: Text -> [Text] -> Double
calculateDamageMultiplier attackType defenseTypes = 
  product $ map (getMultiplier attackType) defenseTypes
  where
    getMultiplier atk def = case lookup (atk, def) effectivenessMap' of
      Just mult -> mult
      Nothing -> 1.0
    effectivenessMap' = [((a,d), m) | (a,d,m) <- effectivenessMap]

-- Calcula fraquezas e resistências de um Pokémon
calculateWeaknesses :: TeamMember -> WeaknessReport
calculateWeaknesses member = 
  WeaknessReport { weaknesses = weaks, resistances = resists }
  where
    typeList = types member
    (weaks, resists) = foldr classify ([], []) allTypes
    classify t (ws, rs) =
      let mult = calculateDamageMultiplier t typeList
      in if mult > 1.0
         then (DamageRelation t mult : ws, rs)
         else if mult < 1.0 && mult > 0
              then (ws, DamageRelation t mult : rs)
              else (ws, rs)

-- Analisa time completo
analyzeTeam :: [TeamMember] -> TeamAnalysis
analyzeTeam team =
  TeamAnalysis
    { membersAnalysis = map analyzeMember team
    , coverageScore = calculateCoverage team
    , uncoveredTypes = findUncoveredTypes team
    }
  where
    analyzeMember m = MemberAnalysis m (weaknesses wr) (resistances wr)
      where wr = calculateWeaknesses m

-- Calcula score de cobertura (0-1)
calculateCoverage :: [TeamMember] -> Double
calculateCoverage team = 
  let typesUncovered = findUncoveredTypes team
      covered = length allTypes - length typesUncovered
  in fromIntegral covered / fromIntegral (length allTypes)

-- Encontra tipos não cobertos pelo time
findUncoveredTypes :: [TeamMember] -> [Text]
findUncoveredTypes team =
  let teamTypes = nub $ concatMap types team
  in filter (\t -> t `notElem` teamTypes) allTypes

-- Sugere novo membro baseado na análise
suggestNewMember :: TeamAnalysis -> Maybe Suggestion
suggestNewMember analysis = 
  if null (uncoveredTypes analysis)
  then Nothing
  else Just $
    Suggestion
      { suggestedType = head (uncoveredTypes analysis)
      , examplePokemon = getExamplePokemon (head (uncoveredTypes analysis))
      , reason = T.pack $ "Cobre tipos não cobertos: " ++ T.unpack (T.intercalate ", " (uncoveredTypes analysis))
      }

-- Sugere baseado em tipos específicos (para GET /suggest)
suggestForTypes :: [Text] -> Maybe Suggestion
suggestForTypes types =
  let fakeMember = TeamMember (T.pack "consulta") types
      report = calculateWeaknesses fakeMember
      weaknessesList = map drType (weaknesses report)
      mostNeeded = if null weaknessesList then T.pack "ground" else head weaknessesList
  in Just $
    Suggestion
      { suggestedType = mostNeeded
      , examplePokemon = getExamplePokemon mostNeeded
      , reason = T.pack $ "Cobre fraquezas contra: " ++ T.unpack (T.intercalate ", " (take 3 weaknessesList))
      }

-- Exemplos de Pokémon por tipo
getExamplePokemon :: Text -> [Text]
getExamplePokemon t
  | t == "fire" = ["Charizard", "Arcanine", "Typhlosion"]
  | t == "water" = ["Blastoise", "Gyarados", "Milotic"]
  | t == "grass" = ["Venusaur", "Sceptile", "Torterra"]
  | t == "electric" = ["Pikachu", "Jolteon", "Luxray"]
  | t == "ground" = ["Garchomp", "Excadrill", "Gliscor"]
  | t == "rock" = ["Tyranitar", "Aerodactyl", "Golem"]
  | t == "ice" = ["Lapras", "Weavile", "Glaceon"]
  | t == "fighting" = ["Machamp", "Lucario", "Infernape"]
  | t == "psychic" = ["Alakazam", "Espeon", "Gardevoir"]
  | t == "dark" = ["Umbreon", "Absol", "Weavile"]
  | t == "dragon" = ["Dragonite", "Garchomp", "Salamence"]
  | t == "fairy" = ["Togekiss", "Sylveon", "Gardevoir"]
  | t == "steel" = ["Steelix", "Metagross", "Lucario"]
  | t == "poison" = ["Venusaur", "Gengar", "Toxicroak"]
  | t == "flying" = ["Pidgeot", "Staraptor", "Braviary"]
  | t == "bug" = ["Scizor", "Heracross", "Galvantula"]
  | t == "ghost" = ["Gengar", "Mismagius", "Chandelure"]
  | otherwise = ["Garchomp", "Excadrill", "Gliscor"]