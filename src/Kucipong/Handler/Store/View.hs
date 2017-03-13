module Kucipong.Handler.Store.View
  ( CouponView(CouponView)
  , View
  ) where

import Kucipong.Prelude

data CouponView = CouponView
  { store :: Entity Store
  , coupon :: Entity Coupon
  , imageUrl :: Maybe Text
  }
  deriving (Show, Eq, Ord, Read)

-- Helper functions

storeKey :: CouponView -> Key Store
storeKey = entityKey . store

store :: CouponView -> Store
store = entityVal . store

couponKey :: CouponView -> Key Coupon
couponKey = entityKey . coupon

coupon :: CouponView -> Coupon
coupon = entityVal . coupon

data CouponViewTypes
  = StoreName
  | StoreAddress
  | ImageUrl
  | Title
  | ValidFrom
  | ValidUntil
  | DiscountPercent
  | GiftContent
  | GiftMinimumPrice
  | GiftReferencePrice
  | SetContent
  | SetPrice
  | SetReferencePrice
  | OtherContent

class View o t where
  format :: t -> o -> Text

instance View CouponView CouponViewTypes where
  format StoreName = fromMaybe "(no title)" . storeName . store
  format StoreAddress = fromMaybe mempty . storeAddress . store
  format ImageUrl = fromMaybe mempty . imageUrl
  format Title = couponTitle . coupon
  format ValidFrom = maybe mempty formatValidFrom . couponValidFrom . coupon
  format ValidUntil = maybe mempty formatValidUntil . couponValidFrom . coupon
  format DiscountPercent = maybe mempty . formatDiscountPercent . couponDiscountPercent . coupon
  format GiftContent = maybe mempty tsho . couponGiftContent . coupon
  format GiftMinimumPrice = maybe mempty formatCurrency . couponGiftMinimumPrice . coupon
  format GiftReferencePrice = maybe mempty formatCurrency . couponGiftReferencePrice . coupon
  format SetContent = maybe mempty tshow . couponSetContent . coupon
  format SetPrice = maybe mempty . formatCurrency . coupon
  format SetReferencePrice = maybe mempty . formatCurrency . coupon
  format OtherContent = maybe mempty tshow . couponOtherContent . coupon

-- couponType
-- DiscountOtherConditions
-- OtherConditions
-- SetOtherConditions
-- "maybeStoreAddress" [| storeAddress' store |]

formatValidFrom :: Day -> Text
formatValidFrom day = "From " <> tshow day
formatValidUntil :: Day -> Text
formatValidUntil day = "To " <> tshow day
