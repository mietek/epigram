\section{Rooty}

%if False

> {-# OPTIONS_GHC -F -pgmF she #-}
> {-# LANGUAGE TypeOperators, GADTs, KindSignatures, RankNTypes,
>     TypeSynonymInstances, FlexibleInstances, ScopedTypeVariables,
>     MultiParamTypeClasses #-}

> module NameSupply.Rooty where

> import Control.Applicative
> import Control.Monad.Error
> import Control.Monad.Reader

> import Kit.MissingLibrary

> import NameSupply.Root

> import Evidences.Tm


%endif

The |Rooty| type-class aims at giving the ability to some structures
to use the Root in a safe way. There is trade-off here, between ease
of implementation and safety. As it stands now, this version offers a
moderate safety but is easy to use, by having not required a lot of
changes in the code base. Ideally, we would like that most of the code
uses |Rooty| instead of manipulating the Root explicitly.

So, what does |Rooty| offer? First, |freshRef| enables the safe
creation of fresh names inside the structure: it is provided with an
informative name, the variable type, and a \emph{body} consuming that
free variable. It returns the body with the free variable filled in,
while maintaining the coherency of the namespace.

Similarly, |forkRoot| is a safe wrapper around |room| and |roos|:
|forkRoot subname child dad| runs the |child| with the current
namespace extended with |subname|. Then, |dad| gets the result of
|child|'s work and can go ahead with a fresh variable index.

Finally, we have a |root| operation, to \emph{read} the current
Root. This was a difficult choice: we give up the read-only access to
the Root, allowing the code to use it in potentially nasty ways. This
operation has been motivated by |equal| that calls into
|exQuote|. |exQuote| on a paramater uses and abuses some invariants of
the name fabric, hence needs direct access to the |Root| structure.

Because of the presence of |root|, we have here a kind of Reader monad
on steroid. This might be true forever, we can hope to replace |root|
by a finer grained mechanism.

> class (Applicative m, Monad m) => Rooty m where
>     freshRef :: (String :<: TY) -> (REF -> m t) -> m t
>     forkRoot :: String -> m s -> (s -> m t) -> m t
>     root :: m Root

Sometimes you want a fresh value rather than a reference:

> fresh :: Rooty m => (String :<: TY) -> (VAL -> m t) -> m t
> fresh xty f = freshRef xty (f . pval)


\subsection{|(->) Root| is Rooty}

To illustrate the implementation of |Rooty|, we implement on the
|Root| Reader monad:

> instance Rooty ((->) Root) where
>     freshRef (x :<: ty) f r = f (name r x := DECL :<: ty) (roos r)
>     forkRoot s child dad root = (dad . child) (room root s) (roos root)
>     root r = r


\subsection{|ReaderT Root| is Rooty}

Once we have |Rooty| for the |Root| Reader monad, we can actually get
it for any |ReaderT Root|. This is as simple as:

> instance (Monad m, Applicative m) => Rooty (ReaderT Root m) where
>     freshRef st body = do
>         r <- ask
>         lift $ freshRef st (runReaderT . body) r
>     forkRoot s child dad = do
>         root <- ask
>         c <- local (flip room s) child
>         d <- local roos (dad c)
>         return d
>     root = ask

\subsection{|Root -> Either StackError a| is Rooty}

One such example is the |Check| monad:

> type Check = ReaderT Root (Either StackError)

That is, a Reader of |Root| on top of an Error of
|StackError|. Running a type-checking process is therefore is simple
|runReader| operation:

> typeCheck :: Check a -> Root -> Either StackError a
> typeCheck = runReaderT
