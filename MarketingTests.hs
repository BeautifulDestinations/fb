{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}

import System.Environment
import Network.HTTP.Conduit
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Facebook hiding (Id)
import qualified Facebook as FB
import Facebook.Records
import           Control.Monad.Trans.Resource
import Data.Time
import Control.Monad.Trans
import Facebook.Object.Marketing.AdAccount
import Facebook.Object.Marketing.Types
import Facebook.Object.Marketing.AdCampaign
import qualified Facebook.Object.Marketing.AdCampaign as AdC
--import Facebook.Object.Marketing.AdLabel
import Facebook.Object.Marketing.AdSet
import Facebook.Object.Marketing.AdImage
import Facebook.Object.Marketing.Utility hiding (toBS)
import Facebook.Object.Marketing.Insights
import Prelude hiding (id)

main = do
  appId <- getEnv "FB_APP_ID"
  appSecret <- getEnv "FB_APP_SECRET"
  tokenBody <- getEnv "FB_ACCESS_TOKEN"
  fbUid <- getEnv "FB_USER_ID"
  man <- newManager conduitManagerSettings
  now <- getCurrentTime
  let creds = Credentials "bdpromo" (T.pack appId) (T.pack appSecret)
      fbuser = FB.Id (T.pack fbUid)
      tokExpires = addUTCTime 1000 now
      tok = UserAccessToken fbuser (T.pack tokenBody) now
  runResourceT $ runFacebookT creds man $ do
    u <- getUser "me" [] (Just tok)
    liftIO $ print u
    Pager adaccids _ _ <- getAdAccountId $ Just tok
    liftIO $ print adaccids
    adAcc <- getAdAccount (id $ head adaccids)
                (Balance ::: AmountSpent ::: Age ::: Nil)
                (Just tok)
    liftIO $ print adAcc
    Pager adCamps _ _ <- getAdCampaign (id $ head adaccids) (Name ::: Nil) tok
    liftIO $ print adCamps
    Pager adSets _ _ <- getAdSet (id $ head adCamps) (ConfiguredStatus ::: EffectiveStatus ::: DailyBudget ::: Nil) tok
    liftIO $ print adSets
    let (Id_ idText) = id $ head adSets
    Pager insights _ _ <- getInsights (FB.Id idText) [] tok
    liftIO $ print (insights:: [WithJSON Insights])
    Pager images _ _ <- getAdImage (id $ head adaccids)
            (Id ::: Name ::: Nil) tok
    liftIO $ print $ (id $ head adaccids)
    liftIO $ print $ length images
    let rec = (Filename, Filename_ "/home/alex/code/fb/bridge.jpg") :*: Nil
    adImg <- setAdImage (id $ head adaccids) rec tok
    liftIO $ print adImg
    Pager images' _ _ <- getAdImage (id $ head adaccids)
        (Id ::: Nil) tok
    liftIO $ print $ length images'
    delRet <- delAdImage (id $ head adaccids) ((Hash, Hash_ "5f73a7d1df0252ac7f012224dde315d0") :*: Nil) tok
    liftIO $ print delRet
    Pager images'' _ _ <- getAdImage (id $ head adaccids)
        (Id ::: Nil) tok
    liftIO $ print $ length images''
    --let campaign = (Name, Name_ "Test Campaign") :*: (Objective, Objective_ OBJ_LINK_CLICKS) :*: (AdC.Status, AdC.Status_ PAUSED_) :*: Nil
    --ret <- setAdCampaign (id $ head adaccids) campaign tok
    --liftIO $ print ret
    --adset <- setAdSet (id $ head adaccids) campaign tok
    --liftIO $ print adset
    --let delId = (Id, Id_ $ campaignId ret) :*: Nil
    --delCampaign <- delAdCampaign ret delId tok -- (id $ head adaccids) delId tok
    --liftIO $ print delCampaign
    -- TODO: create Ad; test here; then beautilitics
    return ()
