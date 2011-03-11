{-# LANGUAGE OverloadedStrings #-}

module VerDB (
    VerDB, getVerDB, lookupLatestVersion
  ) where

import Control.Applicative hiding (many)
import Control.Arrow (second)
import Data.Attoparsec.Char8
import Data.Attoparsec.Enumerator
import Data.ByteString (ByteString)
import Data.Map (Map)
import qualified Data.Map as M
import Data.Maybe
import Process

----------------------------------------------------------------

type VerInfo = (String, Maybe [Int])

data VerDB = VerDB (Map String [Int])

----------------------------------------------------------------

getVerDB :: IO VerDB
getVerDB = VerDB . M.fromList . justOnly <$> verInfos
  where
    verInfos = infoFromProcess "cabal list --installed" cabalListParser
    justOnly = map (second fromJust) . filter (isJust . snd)

----------------------------------------------------------------

lookupLatestVersion :: String -> VerDB -> Maybe [Int]
lookupLatestVersion pkgid (VerDB db) = M.lookup pkgid db

----------------------------------------------------------------

cabalListParser :: Iteratee ByteString IO [VerInfo]
cabalListParser = iterParser verinfos

verinfos :: Parser [VerInfo]
verinfos = many1 verinfo

verinfo :: Parser VerInfo
verinfo = do
    name <- string "* " *> nonEols <* endOfLine
    synpsis
    lat <- latestLabel *> latest <* endOfLine
    many skip
    endOfLine
    return (name, lat)
  where
    latestLabel = string "    Default available version: "
              <|> string "    Latest version available: "
    skip = many1 nonEols *> endOfLine
    synpsis = string "    Synopsis:" *> nonEols *> endOfLine *> more
          <|> return ()
      where
        more = () <$ many (string "     " *> nonEols *> endOfLine)
    latest = Nothing <$ (char '[' *> nonEols)
         <|> Just <$> dotted

dotted :: Parser [Int]
dotted = decimal `sepBy` char '.'

nonEols :: Parser String
nonEols = many1 $ satisfy (notInClass "\n")
