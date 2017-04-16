{-# LANGUAGE TemplateHaskell #-}

module Kucipong.Handler.Consumer
  ( module Kucipong.Handler.Consumer
  ) where

import Kucipong.Prelude

import Control.FromSum (fromMaybeM)
import Data.Default (def)
import Database.Persist.Sql (Entity(..))
import Web.Spock (ActionCtxT, renderRoute)
import Web.Spock.Core (SpockCtxT, get)

import Kucipong.Db (Coupon(..), CouponType(..), Image(..), Key(..))
import Kucipong.Handler.Consumer.TemplatePath
import Kucipong.Handler.Consumer.Types (ConsumerError(..))
import Kucipong.Handler.Route
       (consumerCouponVarR, consumerStoreVarR, storeCouponDeleteVarR)
import Kucipong.Handler.Store.Types
       (CouponView(..), CouponViewKey(..), CouponViewTypes(..),
        CouponViewImageUrl(..), CouponViewConditions(..),
        CouponViewCouponType(..), StoreViewText(..))
import Kucipong.Handler.Types (PageViewer(..))
import Kucipong.I18n (label)
import Kucipong.Monad
       (MonadKucipongAws(..), MonadKucipongDb(..), awsImageS3Url,
        dbFindImage, dbFindPublicCouponById, dbFindStoreByStoreKey)
import Kucipong.RenderTemplate (renderTemplateFromEnv)

couponGet
  :: forall ctx m.
     (MonadIO m, MonadKucipongAws m, MonadKucipongDb m)
  => Key Coupon -> ActionCtxT ctx m ()
couponGet couponKey = do
  maybeCouponEntity <- dbFindPublicCouponById couponKey
  Entity _ coupon <-
    fromMaybeM (handleErr $ label def ConsumerErrorCouldNotFindCoupon) maybeCouponEntity
  maybeStoreEntity <- dbFindStoreByStoreKey $ couponStoreId coupon
  let maybeImageKey = couponImage . entityVal =<< maybeCouponEntity
  maybeImageEntity <- join <$> traverse dbFindImage maybeImageKey
  let maybeImageName = imageS3Name . entityVal <$> maybeImageEntity
  maybeImageUrl <- traverse awsImageS3Url maybeImageName
  let
    mdata = CouponView
      <$> maybeStoreEntity
      <*> maybeCouponEntity
      <*> pure maybeImageUrl
    aboutStore =
      maybe mempty
        (renderRoute consumerStoreVarR . entityKey)
        maybeStoreEntity
    pageViewer = PageViewerEndUser
  $(renderTemplateFromEnv templateCouponId)
  where
    handleErr :: Text -> ActionCtxT ctx m a
    handleErr errMsg = do
      let errors = [errMsg]
      $(renderTemplateFromEnv templateCategory)

consumerComponent
  :: forall m.
     (MonadIO m, MonadKucipongAws m, MonadKucipongDb m)
  => SpockCtxT () m ()
consumerComponent = get consumerCouponVarR couponGet
