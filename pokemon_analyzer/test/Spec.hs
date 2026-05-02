module Main where

import Test.HUnit
import System.Exit (exitFailure, exitSuccess)
import Types
import Logic
import qualified Data.Text as T

main :: IO ()
main = do
  putStrLn "\n=========================================="
  putStrLn "  Pokemon Analyzer — Testes Unitários"
  putStrLn "==========================================\n"
  
  let tests = TestList
        [ TestLabel "[Logic] fire > grass 2x" $ TestCase testFireVsGrass
        , TestLabel "[Logic] water > fire 2x" $ TestCase testWaterVsFire
        , TestLabel "[Logic] electric > water 2x" $ TestCase testElectricVsWater
        , TestLabel "[Logic] ghost vs normal 0x" $ TestCase testGhostVsNormal
        , TestLabel "[Logic] Multiple types combination" $ TestCase testMultipleTypes
        , TestLabel "[Logic] Charizard weaknesses" $ TestCase testCharizardWeaknesses
        , TestLabel "[Logic] Team coverage score" $ TestCase testCoverageScore
        , TestLabel "[Logic] Find uncovered types" $ TestCase testUncoveredTypes
        , TestLabel "[Logic] Suggest new member" $ TestCase testSuggestion
        , TestLabel "[Logic] Suggest for fire/flying" $ TestCase testSuggestForTypes
        , TestLabel "[Logic] Calculate coverage empty team" $ TestCase testEmptyTeamCoverage
        , TestLabel "[Logic] Water type resistances" $ TestCase testWaterResistances
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

-- Testa multiplicador Fire vs Grass
testFireVsGrass :: Assertion
testFireVsGrass = 
  let mult = calculateDamageMultiplier (T.pack "fire") [T.pack "grass"]
  in assertEqual "Fire vs Grass deve ser 2.0" 2.0 mult

-- Testa multiplicador Water vs Fire
testWaterVsFire :: Assertion
testWaterVsFire = 
  let mult = calculateDamageMultiplier (T.pack "water") [T.pack "fire"]
  in assertEqual "Water vs Fire deve ser 2.0" 2.0 mult

-- Testa multiplicador Electric vs Water
testElectricVsWater :: Assertion
testElectricVsWater = 
  let mult = calculateDamageMultiplier (T.pack "electric") [T.pack "water"]
  in assertEqual "Electric vs Water deve ser 2.0" 2.0 mult

-- Testa imunidade Ghost vs Normal
testGhostVsNormal :: Assertion
testGhostVsNormal = 
  let mult = calculateDamageMultiplier (T.pack "ghost") [T.pack "normal"]
  in assertEqual "Ghost vs Normal deve ser 0.0" 0.0 mult

-- Testa tipos múltiplos (ex: Charizard Fire/Flying)
testMultipleTypes :: Assertion
testMultipleTypes =
  let mult = calculateDamageMultiplier (T.pack "rock") [T.pack "fire", T.pack "flying"]
  in assertEqual "Rock vs Fire/Flying deve ser 4.0" 4.0 mult

-- Testa fraquezas do Charizard
testCharizardWeaknesses :: Assertion
testCharizardWeaknesses = 
  let charizard = TeamMember (T.pack "Charizard") [T.pack "fire", T.pack "flying"]
      report = calculateWeaknesses charizard
      weaknessTypes = map drType (weaknesses report)
  in do
    assertBool "Charizard deve ser fraco a Rock" (T.pack "rock" `elem` weaknessTypes)
    assertBool "Charizard deve ser fraco a Electric" (T.pack "electric" `elem` weaknessTypes)
    assertBool "Charizard deve ser fraco a Water" (T.pack "water" `elem` weaknessTypes)

-- Testa score de cobertura do time
testCoverageScore :: Assertion
testCoverageScore = 
  let team = [ TeamMember (T.pack "Charizard") [T.pack "fire", T.pack "flying"]
             , TeamMember (T.pack "Blastoise") [T.pack "water"]
             , TeamMember (T.pack "Venusaur") [T.pack "grass", T.pack "poison"]
             ]
      score = calculateCoverage team
  in assertBool "Coverage score deve ser > 0.5" (score > 0.5)

-- Testa tipos não cobertos
testUncoveredTypes :: Assertion
testUncoveredTypes =
  let team = [ TeamMember (T.pack "Charizard") [T.pack "fire"] ]
      uncovered = findUncoveredTypes team
  in assertBool "Deve ter tipos não cobertos" (not (null uncovered))

-- Testa sugestão de novo membro
testSuggestion :: Assertion
testSuggestion = 
  let team = [ TeamMember (T.pack "Charizard") [T.pack "fire", T.pack "flying"] ]
      analysis = analyzeTeam team
      suggestion = suggestNewMember analysis
  in assertBool "Deve sugerir algo" (isJust suggestion)
  where
    isJust Nothing = False
    isJust (Just _) = True

-- Testa sugestão para tipos específicos
testSuggestForTypes :: Assertion
testSuggestForTypes =
  let suggestion = suggestForTypes [T.pack "fire", T.pack "flying"]
  in assertBool "Deve sugerir tipo para cobrir fraquezas" (isJust suggestion)

-- Testa cobertura de time vazio
testEmptyTeamCoverage :: Assertion
testEmptyTeamCoverage =
  let score = calculateCoverage []
  in assertEqual "Time vazio deve ter score 0" 0.0 score

-- Testa resistências de Water
testWaterResistances :: Assertion
testWaterResistances =
  let water = TeamMember (T.pack "Water") [T.pack "water"]
      report = calculateWeaknesses water
      resistanceTypes = map drType (resistances report)
  in assertBool "Water deve resistir a Fire" (T.pack "fire" `elem` resistanceTypes)