{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty
import Network.HTTP.Types.Status (status400)
import Network.Wai.Middleware.Cors (cors, simpleCorsResourcePolicy)
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Encoding as TLEnc
import qualified Data.Text as T
import Data.Aeson (object, (.=), eitherDecode)
import Control.Monad.IO.Class (liftIO)
import qualified Data.ByteString.Lazy.Char8 as BSL
import Types
import Logic
import Api

main :: IO ()
main = do
  putStrLn "=========================================="
  putStrLn "  Pokemon Analyzer Server v0.1.0"
  putStrLn "  Running on http://localhost:3000"
  putStrLn "  Acesse http://localhost:3000"
  putStrLn "=========================================="
  scotty 3000 $ do
    middleware $ cors (const $ Just simpleCorsResourcePolicy)
    
    get "/" $ do
      fileContent <- liftIO $ BSL.readFile "frontend.html"
      let htmlContent = TLEnc.decodeUtf8 fileContent
      html htmlContent
    
    get "/health" $ do
      json $ object [ "status" .= ("ok" :: String)
                    , "service" .= ("pokemon-analyzer" :: String)
                    , "version" .= ("0.1.0" :: String)
                    ]
    
    post "/analyze" $ do
      bodyBS <- body
      case eitherDecode bodyBS :: Either String TeamRequest of
        Left err -> do
          status status400
          json $ object [ "error" .= ("Erro no JSON: " ++ err) ]
        Right (TeamRequest teamMembers) -> do
          let analysis = analyzeTeam teamMembers
              suggestion = suggestNewMember analysis
          sprites <- liftIO $ fetchTeamSprites teamMembers
          json $ FullResponse analysis suggestion sprites
    
    get "/suggest" $ do
      typesParam <- param "types"
      let typeList = map T.pack $ splitOnComma (TL.unpack typesParam)
          fakeMember = TeamMember (T.pack "consulta") typeList
          report = calculateWeaknesses fakeMember
          suggestion = suggestForTypes typeList
      json $ object
        [ "queried_types" .= typeList
        , "weaknesses" .= weaknesses report
        , "resistances" .= resistances report
        , "suggestion" .= suggestion
        ]
  where
    splitOnComma [] = []
    splitOnComma s = 
      let (first, rest) = break (== ',') s
      in first : if null rest then [] else splitOnComma (tail rest)