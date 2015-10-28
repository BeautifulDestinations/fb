
{-# LANGUAGE DeriveDataTypeable, DeriveGeneric, FlexibleContexts, OverloadedStrings #-}

module Facebook.Object.Marketing.Types where

import Data.Text (Text, pack, unpack)
import Data.Typeable (Typeable)
import GHC.Generics
import Data.Aeson
import Data.Aeson.Types
import Control.Applicative
import Control.Monad
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BSL
import qualified Data.Text.Encoding as TE
import Facebook.Object.Marketing.Utility

newtype Money = Money {getMoneyInPennies :: Integer} deriving (Eq, Ord, Show, Read, Typeable, Generic)

instance FromJSON Money where
  parseJSON (String val) =
    case (decode $ textToBSL val) of
      Just x -> return $ Money x
      Nothing -> mzero
    where
      textToBSL :: Text -> BSL.ByteString
      textToBSL = BSL.fromStrict . TE.encodeUtf8
  parseJSON _ = mzero

instance ToJSON Money where
  toJSON (Money cents) = String $ pack $ show cents

data FbNumeric = FbStringNumeric Text
               | FbIntegerNumeric Int
              deriving (Show, Read, Generic)

instance FromJSON FbNumeric where

instance ToJSON FbNumeric

data FBMObjectCreated = FBMObjectCreated
  { oc_id :: Text
  , oc_success :: Bool
  } deriving (Show, Generic)

instance FromJSON FBMObjectCreated where
  parseJSON = parseJSONWithPrefix "oc_"

class ToFbText a where
  toFbText :: a -> Text