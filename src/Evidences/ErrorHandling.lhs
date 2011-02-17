> {-# OPTIONS_GHC -F -pgmF she #-}
> {-# LANGUAGE TypeOperators, TypeSynonymInstances #-}


> module Evidences.ErrorHandling where

> import Control.Monad.Error

> import Evidences.Tm
> import Evidences.TmJig

> import Kit.NatFinVec


> data ErrorTok  =  StrMsg String
>                |  ErrorTm (Maybe EXP :>: EXP)

An error is list of error tokens:

> type ErrorItem = [ErrorTok]

Errors a reported in a stack, as failure is likely to be followed by
further failures. The top of the stack is the head of the list.

> type StackError = [ErrorItem]


> err :: String -> ErrorItem
> err s = [StrMsg s]

> errTm :: EXP -> ErrorItem
> errTm t = [ErrorTm (Nothing :>: t)]

> errTmList :: [EXP] -> ErrorItem
> errTmList = map (ErrorTm . (Nothing :>:))

> errTyTm :: EXP :>: EXP -> ErrorItem
> errTyTm (ty :>: t) = [ErrorTm (Just ty :>: t)]

> instance Error StackError where
>   strMsg s = [err s]

> instance Show ErrorTok where
>   show (StrMsg s) = s
>   show (ErrorTm (Nothing :>: t)) = ugly V0 t
>   show (ErrorTm (Just ty :>: t)) = ugly V0 t ++ " : " ++ ugly V0 ty