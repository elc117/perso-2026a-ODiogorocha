module Types where 
import Data.Text (Text)

-- tipos validos 
type PokemonTypesName = Text 

-- calcula e multiplica o dano recebido para um tipo dependendo do ataque

data DamageRelation = DamageRelation
{
    drType :: PokemonTypeName,
    drMultiplier :: Double,
}deriving (Show, Eq)

-- dados de um pokemon do time 
data TeamMember = TeamMember
{
    memberName : Text,
    memberType :: [PokemonTypeName], -- podem ser dois
}deriving (Show, Eq)

-- resultado da analise de fraquezas
data WeaknessReport = WeaknessReport
{
    wrMember :: TeamMember,
    wrWeaknesses :: [DamageRelation], -- multiplicadore maiores q 1.0
    wrResistances :: [DamageRelation], -- multiplicadores menores q 1.0
}deriving (Show, Eq)

-- Analisa o time
data TeamAnalysis = TeamAnalysis
{
    taMembers :: [WeaknessReport],
    taCoverageScore :: Double, --vai de 0.0 até 1.0
    taUncoveredTypes :: [PokemonTypeName], --Tipos sem resistencias no time  
}deriving (Show, Eq)

-- sugerir novo membro
data suggestion = suggestion
{
    suggestedType :: PokemonTypeName,
    suggestedNames :: [Text],
}deriving(Show, Eq)

-- todos os 18 tipos do jogo 
allTypes :: [PokemonTypeName]
allTypes = 
    [
        "normal", "fire", "water", "electric",
        "grass", "ice", "fighting", "poison",
        "ground", "flying", "psychic", "bug",
        "rock", "ghost", "dragon", "dark",
        "steel", "fairy"

    ]