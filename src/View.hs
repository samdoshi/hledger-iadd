{-# LANGUAGE LambdaCase, OverloadedStrings #-}

module View where

import           Brick
import           Brick.Widgets.List
import           Brick.Widgets.WrappedText
import           Data.Monoid
import           Data.Text (Text)
import qualified Data.Text as T
import           Data.Time hiding (parseTime)
import qualified Hledger as HL

import           Model

viewState :: Step -> Widget n
viewState DateQuestion = txt " "
viewState (DescriptionQuestion date) = str $
  formatTime defaultTimeLocale "%Y/%m/%d" date
viewState (AccountQuestion trans) = str $
  HL.showTransaction trans
viewState (AmountQuestion acc trans) = str $
  HL.showTransaction trans ++ "  " ++ T.unpack acc
viewState (FinalQuestion trans) = str $
  HL.showTransaction trans

viewQuestion :: Step -> Widget n
viewQuestion DateQuestion = txt "Date"
viewQuestion (DescriptionQuestion _) = txt "Description"
viewQuestion (AccountQuestion trans) = str $
  "Account " ++ show (numPostings trans + 1)
viewQuestion (AmountQuestion _ trans) = str $
  "Amount " ++ show (numPostings trans + 1)
viewQuestion (FinalQuestion _) = txt $
  "Add this transaction to the journal? Y/n"

viewContext :: (Ord n, Show n) => List n Text -> Widget n
viewContext = renderList renderItem True

viewSuggestion :: Maybe Text -> Widget n
viewSuggestion Nothing = txt ""
viewSuggestion (Just t) = txt $ " (" <> t <> ")"

renderItem :: Bool -> Text -> Widget n
renderItem True = withAttr listSelectedAttr . txt
renderItem False = txt

numPostings :: HL.Transaction -> Int
numPostings = length . HL.tpostings

-- TODO Adding " " to an empty message isn't required for vty >= 5.14
--      => Remove this, once 5.14 becomes lower bound
viewMessage :: Text -> Widget n
viewMessage msg = wrappedText (if T.null msg then " " else msg)
