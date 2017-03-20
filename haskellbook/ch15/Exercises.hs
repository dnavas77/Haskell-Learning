module Exercises where

import Test.QuickCheck (Gen, Arbitrary, arbitrary, quickCheck, elements)
import Data.Semigroup (Semigroup, (<>))

semigroupAssoc :: (Eq m, Semigroup m) => m -> m -> m -> Bool
semigroupAssoc a b c = (a <> (b <> c)) == ((a <> b) <> c)

-- ~~~~~ 1 ~~~~~~~~~~~~~~
data Trivial = Trivial deriving (Eq, Show)

instance Semigroup Trivial where
  Trivial <> Trivial = Trivial

instance Arbitrary Trivial where
  arbitrary = return Trivial

type TrivialAssoc = Trivial -> Trivial -> Trivial -> Bool

-- ~~~~~ 2 ~~~~~~~~~~~~~~
newtype Identity a = Identity a deriving (Eq, Show)

instance Semigroup a => Semigroup (Identity a) where
  Identity a <> Identity a' = Identity $ a <> a'

instance Arbitrary a => Arbitrary (Identity a) where
  arbitrary = go where
    go :: Arbitrary a => Gen (Identity a)
    go = do
      a <- arbitrary
      return (Identity a)

type IdentityAssoc = Identity String -> Identity String -> Identity String -> Bool

-- ~~~~~ 3 ~~~~~~~~~~~~~~
data Two a b = Two a b deriving (Eq, Show)

instance (Semigroup a, Semigroup b) => Semigroup (Two a b) where
  (Two a b) <> (Two a' b') = Two (a <> a') (b <> b')

type TwoAssoc = Two String String -> Two String String -> Two String String -> Bool

instance (Arbitrary a, Arbitrary b) => Arbitrary (Two a b) where
  arbitrary = go where
    go :: (Arbitrary a, Arbitrary b) => Gen (Two a b)
    go = do
      a <- arbitrary
      b <- arbitrary
      return (Two a b)

-- ~~~~~ 6 ~~~~~~~~~~~~~~
newtype BoolConj = BoolConj Bool deriving (Eq, Show)

instance Semigroup BoolConj where
  BoolConj True <> BoolConj True = BoolConj True
  BoolConj True <> BoolConj False = BoolConj False
  BoolConj False <> BoolConj True = BoolConj False
  BoolConj False <> BoolConj False = BoolConj False

type BoolConjAssoc = BoolConj -> BoolConj -> BoolConj -> Bool

instance Arbitrary BoolConj where
  arbitrary = do
    a <- arbitrary
    return $ BoolConj a

-- ~~~~~ 7 ~~~~~~~~~~~~~~
newtype BoolDisj = BoolDisj Bool deriving (Eq, Show)

instance Semigroup BoolDisj where
  BoolDisj True <> BoolDisj True = BoolDisj True
  BoolDisj True <> BoolDisj False = BoolDisj True
  BoolDisj False <> BoolDisj True = BoolDisj True
  BoolDisj False <> BoolDisj False = BoolDisj False

type BoolDisjAssoc = BoolDisj -> BoolDisj -> BoolDisj -> Bool

instance Arbitrary BoolDisj where
  arbitrary = do
    a <- arbitrary
    elements [BoolDisj a, BoolDisj a]

-- ~~~~~ 8 ~~~~~~~~~~~~~~
data Or a b = Fst a | Snd b deriving (Eq, Show)

instance Semigroup (Or a b) where
  Fst _ <> Fst a = Fst a
  Snd a <> _ = Snd a
  _ <> Snd a = Snd a

instance (Arbitrary a, Arbitrary b) => Arbitrary (Or a b) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    elements [Fst a, Snd b]

type OrAssoc = Or String Ordering -> Or String Ordering -> Or String Ordering -> Bool

main :: IO ()
main = do
  quickCheck (semigroupAssoc :: TrivialAssoc)
  quickCheck (semigroupAssoc :: IdentityAssoc)
  quickCheck (semigroupAssoc :: TwoAssoc)
  quickCheck (semigroupAssoc :: BoolConjAssoc)
  quickCheck (semigroupAssoc :: BoolDisjAssoc)
  quickCheck (semigroupAssoc :: OrAssoc)
