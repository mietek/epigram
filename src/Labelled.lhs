\section{Labelled Types}

%if False

> {-# OPTIONS_GHC -F -pgmF she #-}
> {-# LANGUAGE TypeOperators, GADTs, KindSignatures,
>     TypeSynonymInstances, FlexibleInstances, ScopedTypeVariables #-}

> module Labelled where

> import -> CanConstructors where
>   Label  :: t -> t -> Can t
>   LRet   :: t -> Can t

> import -> ElimConstructors where
>   Call   :: t -> Elim t

> import -> CanPats where
>   pattern LABEL l t = C (Label l t)
>   pattern LRET t    = C (LRet t)

> import -> DisplayCanPats where
>   pattern DLABEL l t = DC (Label l t)
>   pattern DLRET t    = DC (LRet t)

> import -> CanCompile where
>   makeBody (Label l t) = makeBody t
>   makeBody (LRet t)    = makeBody t

> import -> TraverseCan where
>   traverse f (Label l t) = (| Label (f l) (f t) |)
>   traverse f (LRet t)    = (| LRet (f t) |)

> import -> TraverseElim where
>   traverse f (Call l) = (| Call (f l) |)

> import -> HalfZipCan where
>   halfZip (Label l1 t1) (Label l2 t2) = Just (Label (l1,l2) (t1,t2))
>   halfZip (LRet x) (LRet y)           = Just (LRet (x,y))

> import -> CanPretty where
>   pretty (Label l t) = brackets (pretty l <+> text ":" <+> pretty t)
>   pretty (LRet x) = parens (text "return" <+> pretty x)

> import -> ElimPretty where
>   pretty (Call l) = parens (text "call" <+> brackets (pretty l))

> import -> ElimComputation where
>   LRET t $$ Call l = t

> import -> ElimCompile where
>   makeBody (arg, Call l) = makeBody l

> import -> CanTyRules where
>   canTy chev (Set :>: Label l t) = do
>      ttv@(t :=>: tv) <- chev (SET :>: t)
>      llv@(l :=>: lv) <- chev (tv :>: l)
>      return (Label llv ttv)
>   canTy chev (Label l ty :>: LRet t) = do
>      ttv@(t :=>: tv) <- chev (ty :>: t)
>      return (LRet ttv)

> import -> ElimTyRules where
>   elimTy chev (_ :<: Label _ t) (Call l) = do
>      llv@(l :=>: lv) <- chev (t :>: l)
>      return (Call llv, t)

   canTy chev (ty :>: Call c tm) = do
      -- tytv@(ty :=>: tyv) <- chev (SET :>: ty)
      ccv@(c :=>: cv) <- chev (ty :>: c)
      tmtv@(tm :=>: tmv) <- chev (LABEL cv ty :>: tm)
      return (Call ccv tmtv)

-- > import -> OpCode where
-- >   callOp = Op
-- >     { opName = "call"
-- >     , opArity = 3
-- >     , opTy = callOpTy
-- >     , opRun = callOpRun       
-- >     , opSimp = callOpSimp
-- >     } where
-- >       callOpTy chev [ty, lbl, tm] = do
-- >            tytv@(ty :=>: tyv) <- chev (SET :>: ty)
-- >            lbltv@(lbl :=>: lblv) <- chev (tytv :>: lbl)
-- >            tmtv@(tm :=>: tmv) <- chev (LABEL lbltv tytv :>: tm)
-- >            return ([tytv, lbltv, tmtv], tyv)

-- >       callOpRun :: [VAL] -> Either NEU VAL
-- >       callOpRun [ty, lbl, LRET t] = Right t
-- >       callOpRun [ty, lbl, N t] = Left t

-- >       callOpSimp :: Alternative m => [VAL] -> Root -> m NEU
-- >       callOpSimp _ _ = empty

-- > import -> Operators where
-- >   callOp :

-- > import -> OpCompile where
-- >   ("call", [ty, l, t]) -> l

%endif
