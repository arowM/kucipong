{-# LANGUAGE TemplateHaskell #-}

module Kucipong.Handler where

import Kucipong.Prelude

import Data.HVect ( HVect(HNil) )
import Web.Routing.Combinators ( PathState(Open) )
import Web.Spock
    ( ActionCtxT, Path, (<//>), getContext, html
    , root, redirect, renderRoute, runSpock, setStatus, text, var )
import Web.Spock.Core ( SpockCtxT, spockT, get, post, prehook, subcomponent )

import Kucipong.Config ( Config )
import Kucipong.Handler.Admin ( adminComponent, adminUrlPrefix )
import Kucipong.Handler.Store ( storeComponent, storeUrlPrefix )
import Kucipong.Handler.Static ( staticComponent' )
import Kucipong.Host ( HasPort(..) )
import Kucipong.Monad ( KucipongM, runKucipongM )

-- TODO: Remove this:
import Kucipong.Email
import Mail.Hailgun
import "emailaddress" Text.Email.Validate (emailAddress)

runKucipongMHandleErrors :: Config -> KucipongM a -> IO a
runKucipongMHandleErrors config = either throwIO pure <=< runKucipongM config

baseHook :: Monad m => ActionCtxT () m (HVect '[])
baseHook = pure HNil

app :: Config -> IO ()
app config = runSpock (getPort config) $
    spockT (runKucipongMHandleErrors config) $ do
        subcomponent "static" $(staticComponent')
        prehook baseHook $ do
            subcomponent adminUrlPrefix adminComponent
            subcomponent storeUrlPrefix storeComponent
        get root $ do
            html "<p>hello world</p>"
