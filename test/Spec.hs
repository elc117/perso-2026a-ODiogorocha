module Main where

import Test.HUnit
import System.Exit (exitFailure, exitSuccess)
import Types
import Logic
import qualified Data.Text as T
import Data.Maybe (isJust)

main :: IO ()
main = do
  putStrLn "\n=========================================="
  putStrLn "  Pokemon Analyzer — Testes Unitários"
  putStrLn "==========================================\n"
  
  let tests = TestList
        [ -- Multiplicadores básicos
          TestLabel "[Logic] fire > grass 2x" $ TestCase testFireVsGrass
        , TestLabel "[Logic] water > fire 2x" $ TestCase testWaterVsFire
        , TestLabel "[Logic] electric > water 2x" $ TestCase testElectricVsWater
        , TestLabel "[Logic] ghost vs normal 0x" $ TestCase testGhostVsNormal
        , TestLabel "[Logic] fire vs water 0.5x" $ TestCase testFireVsWater
        , TestLabel "[Logic] electric vs ground 0x" $ TestCase testElectricVsGround
        , TestLabel "[Logic] fighting vs ghost 0x" $ TestCase testFightingVsGhost
        , TestLabel "[Logic] Multiple types combination (rock vs fire/flying) 4x" $ TestCase testMultipleTypes
        
          -- Fraquezas e resistências
        , TestLabel "[Logic] Charizard weaknesses" $ TestCase testCharizardWeaknesses
        , TestLabel "[Logic] Charizard resistances" $ TestCase testCharizardResistances
        , TestLabel "[Logic] Water type resistances" $ TestCase testWaterResistances
        
          -- Cobertura e tipos descobertos
        , TestLabel "[Logic] Team coverage score (Charizard/Blastoise/Venusaur)" $ TestCase testCoverageScore
        , TestLabel "[Logic] Find uncovered types with partial team" $ TestCase testUncoveredTypes
        , TestLabel "[Logic] Coverage with duplicate types" $ TestCase testCoverageWithDuplicateTypes
        
          -- Sugestões
        , TestLabel "[Logic] Suggest new member for weak team" $ TestCase testSuggestion
        , TestLabel "[Logic] Suggest for fire/flying types" $ TestCase testSuggestForTypes
        , TestLabel "[Logic] Suggestion example pokemon not empty" $ TestCase testSuggestionExamplePokemon
        
          -- Casos extremos
        , TestLabel "[Logic] Calculate coverage empty team" $ TestCase testEmptyTeamCoverage
        ]
  
  counts <- runTestTT tests
  putStrLn $ "\n=========================================="
  putStrLn $ "Resultado: " ++ show (cases counts) ++ " testes"
  putStrLn $ "✅ OK: " ++ show (cases counts - errors counts - failures counts)
  putStrLn $ "❌ Falhas: " ++ show (failures counts)
  putStrLn $ "⚠️  Erros: " ++ show (errors counts)
  putStrLn "=========================================="
  
  if errors counts + failures counts == 0
    then exitSuccess
    else exitFailure

-- ============================================
-- Multiplicadores básicos
-- ============================================

testFireVsGrass :: Assertion
testFireVsGrass = 
  let mult = calculateDamageMultiplier (T.pack "fire") [T.pack "grass"]
  in assertEqual "Fire vs Grass deve ser 2.0" 2.0 mult

testWaterVsFire :: Assertion
testWaterVsFire = 
  let mult = calculateDamageMultiplier (T.pack "water") [T.pack "fire"]
  in assertEqual "Water vs Fire deve ser 2.0" 2.0 mult

testElectricVsWater :: Assertion
testElectricVsWater = 
  let mult = calculateDamageMultiplier (T.pack "electric") [T.pack "water"]
  in assertEqual "Electric vs Water deve ser 2.0" 2.0 mult

testGhostVsNormal :: Assertion
testGhostVsNormal = 
  let mult = calculateDamageMultiplier (T.pack "ghost") [T.pack "normal"]
  in assertEqual "Ghost vs Normal deve ser 0.0" 0.0 mult

testFireVsWater :: Assertion
testFireVsWater = 
  let mult = calculateDamageMultiplier (T.pack "fire") [T.pack "water"]
  in assertEqual "Fire vs Water deve ser 0.5" 0.5 mult

testElectricVsGround :: Assertion
testElectricVsGround = 
  let mult = calculateDamageMultiplier (T.pack "electric") [T.pack "ground"]
  in assertEqual "Electric vs Ground deve ser 0.0" 0.0 mult

testFightingVsGhost :: Assertion
testFightingVsGhost = 
  let mult = calculateDamageMultiplier (T.pack "fighting") [T.pack "ghost"]
  in assertEqual "Fighting vs Ghost deve ser 0.0" 0.0 mult

testMultipleTypes :: Assertion
testMultipleTypes =
  let mult = calculateDamageMultiplier (T.pack "rock") [T.pack "fire", T.pack "flying"]
  in assertEqual "Rock vs Fire/Flying deve ser 4.0" 4.0 mult

-- ============================================
-- Fraquezas e resistências
-- ============================================

testCharizardWeaknesses :: Assertion
testCharizardWeaknesses = 
  let charizard = TeamMember (T.pack "Charizard") [T.pack "fire", T.pack "flying"]
      report = calculateWeaknesses charizard
      weaknessTypes = map drType (weaknesses report)
  in do
    assertBool "Charizard deve ser fraco a Rock" (T.pack "rock" `elem` weaknessTypes)
    assertBool "Charizard deve ser fraco a Electric" (T.pack "electric" `elem` weaknessTypes)
    assertBool "Charizard deve ser fraco a Water" (T.pack "water" `elem` weaknessTypes)

testCharizardResistances :: Assertion
testCharizardResistances =
  let charizard = TeamMember (T.pack "Charizard") [T.pack "fire", T.pack "flying"]
      report = calculateWeaknesses charizard
      resistanceTypes = map drType (resistances report)
  in do
    assertBool "Charizard deve resistir a Fire" (T.pack "fire" `elem` resistanceTypes)
    assertBool "Charizard deve resistir a Grass" (T.pack "grass" `elem` resistanceTypes)
    assertBool "Charizard deve resistir a Bug" (T.pack "bug" `elem` resistanceTypes)

testWaterResistances :: Assertion
testWaterResistances =
  let water = TeamMember (T.pack "Water") [T.pack "water"]
      report = calculateWeaknesses water
      resistanceTypes = map drType (resistances report)
  in assertBool "Water deve resistir a Fire" (T.pack "fire" `elem` resistanceTypes)

-- ============================================
-- Cobertura e tipos descobertos
-- ============================================

testCoverageScore :: Assertion
testCoverageScore = 
  let team = [ TeamMember (T.pack "Charizard") [T.pack "fire", T.pack "flying"]
             , TeamMember (T.pack "Blastoise") [T.pack "water"]
             , TeamMember (T.pack "Venusaur") [T.pack "grass", T.pack "poison"]
             ]
      score = calculateCoverage team
  -- O valor real é aproximadamente 0.2778 (5/18 tipos cobertos? Verifique: fire, flying, water, grass, poison = 5/18 = 0.2777)
  in assertBool "Coverage score deve ser > 0.2" (score > 0.2)

testUncoveredTypes :: Assertion
testUncoveredTypes =
  let team = [ TeamMember (T.pack "Charizard") [T.pack "fire"] ]
      uncovered = findUncoveredTypes team
  in do
    assertBool "Deve haver tipos não cobertos" (not (null uncovered))
    -- Verifica que 'electric' está descoberto (exemplo)
    assertBool "Electric deve estar descoberto" (T.pack "electric" `elem` uncovered)

testCoverageWithDuplicateTypes :: Assertion
testCoverageWithDuplicateTypes =
  let team = [ TeamMember (T.pack "Charizard") [T.pack "fire"]
             , TeamMember (T.pack "Flareon") [T.pack "fire"]
             ]
      score = calculateCoverage team
  in assertEqual "Time com tipos duplicados deve ter cobertura 1/18 ≈ 0.0556" 0.05555555555555555 score

-- ============================================
-- Sugestões
-- ============================================

testSuggestion :: Assertion
testSuggestion = 
  let team = [ TeamMember (T.pack "Charizard") [T.pack "fire", T.pack "flying"] ]
      analysis = analyzeTeam team
      suggestion = suggestNewMember analysis
  in assertBool "Deve sugerir um novo membro" (isJust suggestion)

testSuggestForTypes :: Assertion
testSuggestForTypes =
  let suggestion = suggestForTypes [T.pack "fire", T.pack "flying"]
  in assertBool "Deve sugerir tipo para cobrir fraquezas" (isJust suggestion)

testSuggestionExamplePokemon :: Assertion
testSuggestionExamplePokemon =
  let suggestion = suggestForTypes [T.pack "fire", T.pack "flying"]
  in case suggestion of
       Nothing -> assertFailure "Sugestão não gerada"
       Just s -> assertBool "Exemplos de Pokémon não devem ser vazios" (not (null (examplePokemon s)))

-- ============================================
-- Casos extremos
-- ============================================

testEmptyTeamCoverage :: Assertion
testEmptyTeamCoverage =
  let score = calculateCoverage []
  in assertEqual "Time vazio deve ter score 0" 0.0 score