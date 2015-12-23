{-# LANGUAGE BangPatterns #-}
module Facebook.Gen.Types
where

import Data.Text hiding (length)
import Data.Csv
import Data.Coerce
import Control.Monad

newtype Entity = Entity Text deriving (Show, Ord, Eq)
data InteractionMode =
      Reading
    | Creating
    | Updating
    | Deleting
    | Types -- Used only for Types.hs
    deriving (Show, Ord, Eq)
newtype Boolean = Boolean Bool deriving Show

data FieldInfo = FieldInfo {
      name        :: !Text
    , type_       :: !Text
    , desc        :: !Text -- TODO: Can contain enum definitions --> change CSV files?
    , required    :: Boolean
    , inResp      :: Boolean -- when response does not contain requested field
    } deriving Show

isRequired :: FieldInfo -> Bool
isRequired (FieldInfo _ _ _ (Boolean True) _) = True
isRequired _ = False

instance Eq FieldInfo where
    -- in order to find duplicate field names for a single entity
    (==) (FieldInfo n1 _ _ _ _)
         (FieldInfo n2 _ _ _ _) = n1 == n2

instance FromField Boolean where
    parseField s
        | s == "Y" || s == "y" = pure $ Boolean True
        | otherwise = pure $ Boolean False

instance FromField InteractionMode where
    parseField "Reading"  = pure Reading
    parseField "Creating" = pure Creating
    parseField "Deleting" = pure Deleting
    parseField "Updating" = pure Updating
    parseField x = error $ "Don't know what to do with InteractionMode \"" ++ show x ++ "\""
