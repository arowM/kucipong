module Kucipong.Handler.Admin.Types
  ( AdminError(..)
  , AdminMsg(..)
  , CreateStoreText(..)
  , DeleteStoreText(..)
  ) where

import Kucipong.Prelude
import Kucipong.View.Class (ToName(..))

data AdminError
  = AdminErrorCouldNotSendEmail
  | AdminErrorNoAdminEmail
  | AdminErrorNoAdminLoginToken
  | AdminErrorNoAdminSession
  | AdminErrorNoStoreEmail
  | AdminErrorStoreWithSameEmailExists
  | AdminErrorStoreCreateDbProblem
  | AdminErrorSendEmailFailure
  | AdminErrorTokenExpired
  deriving (Show, Eq, Ord, Read, Enum, Bounded)

data AdminMsg
  = AdminMsgSentVerificationEmail
  deriving (Show, Eq, Ord, Read, Enum, Bounded)

-- ------
--  View
-- ------

data CreateStoreText
  = CreateStoreEmail

instance ToName CreateStoreText where
  toName CreateStoreEmail = "storeEmail"

data DeleteStoreText
  = DeleteStoreEmail

instance ToName DeleteStoreText where
  toName DeleteStoreEmail = "storeEmail"

