
module Kucipong.Handler.Admin where

import Kucipong.Prelude

import Control.Lens ( (^.) )
import Control.Monad.Time ( MonadTime(..) )
import Data.HVect ( HVect(..) )
import Database.Persist ( Entity(..) )
import Network.HTTP.Types ( forbidden403 )
import Web.Spock
    ( ActionCtxT, Path, SpockCtxT, (<//>), get, getContext, html, prehook, root
    , redirect, renderRoute, runSpock, setStatus, spockT, text, var )

import Kucipong.Db ( Admin, AdminId, AdminLoginToken, Key(..), LoginTokenExpirationTime(..), adminLoginTokenExpirationTime )
import Kucipong.LoginToken ( LoginToken )
import Kucipong.Monad ( MonadKucipongCookie, MonadKucipongDb(..), MonadKucipongSendEmail )
import Kucipong.Spock ( getAdminCookie, setAdminCookie )
import Kucipong.Session ( Admin, Session )
import Kucipong.Util ( fromMaybeM )

-- | Login an admin.  Take the admin's 'LoginToken', and send them a session
-- cookie.
login
    :: forall ctx m
     . ( MonadIO m
       , MonadKucipongCookie m
       , MonadKucipongDb m
       , MonadTime m
       )
    => LoginToken -> ActionCtxT ctx m ()
login loginToken = do
    maybeAdminLoginTokenEntity <- dbFindAdminLoginToken loginToken
    (Entity (AdminLoginTokenKey (AdminKey adminEmail)) adminLoginToken) <-
        fromMaybeM noAdminLoginTokenError maybeAdminLoginTokenEntity
    -- check date on admin login token
    now <- currentTime
    let (LoginTokenExpirationTime expirationTime) =
            adminLoginToken ^. adminLoginTokenExpirationTime
    when (now > expirationTime) tokenExpiredError
    setAdminCookie adminEmail
    redirect $ renderRoute root
  where
    -- TODO: What should actually be returned for these two error cases?
    noAdminLoginTokenError :: ActionCtxT ctx m a
    noAdminLoginTokenError = do
        setStatus forbidden403
        html "<p>loginToken incorrect</p>"

    tokenExpiredError :: ActionCtxT ctx m a
    tokenExpiredError = do
        setStatus forbidden403
        html "<p>token expired error</p>"

-- | Return the store create page for an admin.
storeCreate
    :: forall ctx m
     . ( MonadIO m
       )
    => ActionCtxT ctx m ()
storeCreate = undefined

adminAuthHook
    :: ( MonadIO m
       , MonadKucipongCookie m
       )
    => ActionCtxT (HVect xs) m (HVect ((Session Kucipong.Session.Admin) ': xs))
adminAuthHook = do
    maybeAdminSession <- getAdminCookie
    case maybeAdminSession of
        Nothing -> undefined
        Just adminSession -> do
            oldCtx <- getContext
            return $ adminSession :&: oldCtx

adminComponent
    :: forall m xs
     . ( MonadIO m
       , MonadKucipongCookie m
       , MonadKucipongDb m
       , MonadKucipongSendEmail m
       , MonadTime m
       )
    => SpockCtxT (HVect xs) m ()
adminComponent = do
    get ("login" <//> var) login
    prehook adminAuthHook $
        get ("store" <//> "create") storeCreate
