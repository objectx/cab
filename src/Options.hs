module Options (optionDB, getOptDB) where

import Distribution.Cab
import System.Console.GetOpt

import Types

----------------------------------------------------------------

getOptDB :: GetOptDB
getOptDB = [
    Option ['n'] ["dry-run"]
      (NoArg OptNoharm)
      "Run without destructive operations"
  , Option ['r'] ["recursive"]
      (NoArg OptRecursive)
      "Follow dependencies recursively"
  , Option ['a'] ["all"]
      (NoArg OptAll)
      "Show global packages in addition to user packages"
  , Option ['i'] ["info"]
      (NoArg OptInfo)
      "Show license and author information"
  , Option ['f'] ["flags"]
      (ReqArg OptFlag "<flags>")
      "Specify flags"
  , Option ['t'] ["test"]
      (NoArg OptTest)
      "Enable test"
  , Option ['b'] ["bench"]
      (NoArg OptBench)
      "Enable benchmark"
  , Option ['h'] ["help"]
      (NoArg OptHelp)
      "Show help message"
  ]

optionDB :: OptionDB
optionDB = zip [SwNoharm,SwRecursive,SwAll,SwInfo,SwFlag,SwTest,SwBench] getOptDB