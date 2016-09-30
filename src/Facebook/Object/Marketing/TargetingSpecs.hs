{-# LANGUAGE DeriveDataTypeable, DeriveGeneric, FlexibleContexts, OverloadedStrings #-}

module Facebook.Object.Marketing.TargetingSpecs where

import Data.Text (Text, unpack, pack)
import Data.Aeson
import Data.Aeson.Types
import Data.Default
import qualified Data.HashMap.Strict as HM
import GHC.Generics (Generic)
import Facebook.Records
import Facebook.Object.Marketing.TargetingSpecs.Demographies
import Facebook.Object.Marketing.TargetingSpecs.Location
import Facebook.Object.Marketing.TargetingSpecs.Mobile
import Facebook.Object.Marketing.TargetingSpecs.Placement
import Facebook.Object.Marketing.TargetingSpecs.Interests
import qualified Data.ByteString.Lazy as BL

data TargetingSpecs = TargetingSpecs
  { --exclusions :: Maybe Value
   geo_locations :: TargetLocation
  , demo :: Maybe Demography
  --, mobile_targeting :: Maybe MobileTargeting -- ^ Please note that the fields of this record will be at the top level
  , page_types :: Maybe [PlacementOption]
  , device_platforms :: Maybe [DevicePlatform]
  , publisher_platforms :: Maybe [PublisherPlatform]
  , facebook_positions :: Maybe [FacebookPosition]
  , interests :: Maybe [Interest]
  } deriving (Show, Eq, Generic)

instance ToJSON TargetingSpecs where
    toJSON (TargetingSpecs loc demo pt dp pp fp ints) =
        let locJson = object ["geo_locations" .= toJSON loc]
            demoJson = case demo of
                        Nothing ->  Null
                        Just dem -> demoToJSON dem
            pagesJson = case pt of
                          Nothing -> Null
                          Just x -> object ["page_types" .= toJSON x]
            intsJson = case ints of
                          Nothing -> Null
                          Just ints' -> object ["interests" .= toJSON ints']
            deviceJson = case dp of
                          Nothing -> Null
                          Just x -> object ["device_platforms" .= toJSON x]
            pubsJson = case pp of
                          Nothing -> Null
                          Just x -> object ["publisher_platforms" .= toJSON x]
            posJson = case fp of
                          Nothing -> Null
                          Just x -> object ["facebook_positions" .= toJSON x]
        in foldl merge Null [locJson, demoJson, pagesJson, intsJson, deviceJson, pubsJson, posJson]

merge :: Value -> Value -> Value
merge Null v = v
merge v Null = v
merge (Object v1) (Object v2) = Object $ HM.union v1 v2

instance FromJSON TargetingSpecs where
    parseJSON val@(Object v) = genericParseJSON defaultOptions val

instance ToBS TargetingSpecs where
    toBS a = toBS $ toJSON a

instance ToBS TargetLocation where
    toBS = toBS . toJSON

instance ToBS Value where -- FIXME, move to Types.hs
    toBS = BL.toStrict . encode
