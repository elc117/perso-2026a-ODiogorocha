{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Types where

import Data.Text (Text)
import Data.Aeson (ToJSON, FromJSON)
import GHC.Generics (Generic)

data TeamMember = TeamMember
  { name  :: Text
  , types :: [Text]
  } deriving (Show, Eq, Generic)

instance ToJSON TeamMember
instance FromJSON TeamMember

data TeamRequest = TeamRequest
  { team :: [TeamMember]
  } deriving (Show, Eq, Generic)

instance ToJSON TeamRequest
instance FromJSON TeamRequest

data DamageRelation = DamageRelation
  { drType       :: Text
  , drMultiplier :: Double
  } deriving (Show, Eq, Generic)

instance ToJSON DamageRelation

data WeaknessReport = WeaknessReport
  { weaknesses  :: [DamageRelation]
  , resistances :: [DamageRelation]
  } deriving (Show, Eq, Generic)

instance ToJSON WeaknessReport

data TeamAnalysis = TeamAnalysis
  { membersAnalysis :: [MemberAnalysis]
  , coverageScore   :: Double
  , uncoveredTypes  :: [Text]
  } deriving (Show, Eq, Generic)

instance ToJSON TeamAnalysis

data MemberAnalysis = MemberAnalysis
  { maPokemon      :: TeamMember
  , maWeaknesses   :: [DamageRelation]
  , maResistances  :: [DamageRelation]
  } deriving (Show, Eq, Generic)

instance ToJSON MemberAnalysis

data Suggestion = Suggestion
  { suggestedType  :: Text
  , examplePokemon :: [Text]
  , reason         :: Text
  } deriving (Show, Eq, Generic)

instance ToJSON Suggestion

data SpriteUrl = SpriteUrl
  { suName :: Text
  , suUrl  :: Text
  } deriving (Show, Eq, Generic)

instance ToJSON SpriteUrl

data FullResponse = FullResponse
  { frAnalysis   :: TeamAnalysis
  , frSuggestion :: Maybe Suggestion
  , frSprites    :: [SpriteUrl]
  } deriving (Show, Eq, Generic)

instance ToJSON FullResponse