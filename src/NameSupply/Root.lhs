\section{Root}

%if False

> {-# OPTIONS_GHC -F -pgmF she #-}
> {-# LANGUAGE TypeOperators #-}

> module NameSupply.Root where

> import Kit.BwdFwd

%endif

The |Root| is the name generator used throughout Epigram. It is
inspired by the \emph{hierarchical names}~\cite{mcbride:free_variable}
used in Epigram the First. The aim of this structure is to,
conveniently, provide unique free variable names.

A |Root| is composed by a backward list of |(String, Int)| and an
|Int|. This corresponds to a hierarchical namespace and a free name in
that namespace. The structure of the namespace stack is justified as
follow. The |String| component is simply here for readability
purposes, while the |Int| uniquely identifies the namespace.

> type Root = (Bwd (String, Int), Int)

Therefore, creating a fresh name in a given namespace simply consists
in incrementing the name counter:

> roos :: Root -> Root
> roos (sis, i) = (sis, i + 1)

Whereas creating a fresh namespace involves stacking up a new name
|s|, uniquely identified by |i|, and initializing the per-namespace
counter to |0|:

> room :: Root -> String -> Root
> room (sis, i) s = (sis :< (s,i), 0)

Intuitively, the function |name| computes a fresh name out of a given
name generator, decorating it with the human-readable label
|s|. Technically, |Name| is defined as
a list of |(String, Int)|. Hence, on that structure, the effect of
|trail| is to flatten the backward namespace into a (unique) |Name|.

> type Name = [(String, Int)]
>
> name :: Root -> String -> Name
> name (sis, i) s = trail (sis :< (s, i))
