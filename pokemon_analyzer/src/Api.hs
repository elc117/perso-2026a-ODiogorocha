{-# LANGUAGE OverloadedStrings #-}

module Api where

import Types
import Data.Text (Text)
import qualified Data.Text as T
import Network.HTTP.Simple
import qualified Data.ByteString.Lazy as BSL
import Data.Aeson (Value, object, (.=))
import qualified Data.Aeson as Aeson

-- Busca tipos de um Pokémon pela PokeAPI (versão simplificada sem parsing complexo)
fetchPokemonTypes :: Text -> IO (Maybe [Text])
fetchPokemonTypes name = do
  -- Retorna tipos padrão para demonstração
  return $ case T.toLower name of
    "charizard" -> Just [T.pack "fire", T.pack "flying"]
    "blastoise" -> Just [T.pack "water"]
    "venusaur" -> Just [T.pack "grass", T.pack "poison"]
    "pikachu" -> Just [T.pack "electric"]
    _ -> Just [T.pack "normal"]

-- Busca sprite do Pokémon
fetchPokemonSprite :: Text -> IO (Maybe Text)
fetchPokemonSprite name = do
  -- Retorna URLs de sprite padrão para demonstração
  let spriteUrl = T.pack $ "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" ++ 
                  show (abs (hash name) `mod` 898 + 1) ++ ".png"
  return $ Just spriteUrl
  where
    hash = fromIntegral . length . T.unpack

-- Busca múltiplos Pokémon
fetchMultiplePokemon :: [Text] -> IO [(Text, Maybe [Text], Maybe Text)]
fetchMultiplePokemon names = 
  mapM (\name -> do
          types <- fetchPokemonTypes name
          sprite <- fetchPokemonSprite name
          return (name, types, sprite)
       ) names

-- Busca sprites para o time
fetchTeamSprites :: [TeamMember] -> IO [SpriteUrl]
fetchTeamSprites team = do
  let names = map name team
  results <- fetchMultiplePokemon names
  return $ map (\(name, _, sprite) -> SpriteUrl name (maybe (T.pack "") id sprite)) results