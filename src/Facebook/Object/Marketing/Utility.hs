module Facebook.Object.Marketing.Utility where

import Data.Aeson
import Data.Aeson.Types
import Data.List
import GHC.Generics
import Data.ByteString
import Data.Char
import qualified Data.Aeson.Encode as AE (fromValue)
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Encoding as TE
import qualified Data.Text.Lazy.Builder as TLB
import qualified Network.HTTP.Conduit as MPFD

dropString :: String -> String -> String
dropString pre s = case stripPrefix pre s of
  Nothing      -> s
  Just dropped -> dropped

dropOption pre = defaultOptions
  { fieldLabelModifier = dropString pre
  , omitNothingFields = True
  }
parseJSONWithPrefix pre = genericParseJSON (dropOption pre)
toJSONWithPrefix pre = genericToJSON (dropOption pre)

toBS :: Value -> ByteString
toBS = TE.encodeUtf8 . TL.toStrict . TLB.toLazyText . AE.fromValue

data WithJSON a = WithJSON { withJsonValue :: Value,
                             unWithJson :: a }deriving Show

instance FromJSON a => FromJSON (WithJSON a) where
  parseJSON v = do
    x <- parseJSON v
    return $ WithJSON v x
