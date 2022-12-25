{-# LANGUAGE ScopedTypeVariables #-}

import Data.Array (Array, array, (!), (//))
import Data.List (nub)
import Data.Map (Map)
import qualified Data.Map as Map
import qualified Data.Set as Set

data Point = Point Int Int Int deriving (Show, Eq, Ord)

data SparseRepr = SparseRepr { xy :: Map (Int, Int) (List Int)),
                               xz :: Map (Int, Int) (List Int)),
                               yz :: Map (Int, Int) (List Int))
                             }
type SparseCube = Array Int (Array Int (Array Int Bool))

-- we actually need 3 sparse datastructures, one for each dimension
-- for example,
-- xy: [(x,y) => [z1->zlast]]
-- xz: [(x,z) => [y1->ylast]]
-- yz: [(y,z) => [x1->xlast]]

initSparse :: Int -> Int -> SparseCube
initSparse min max = array (min, max) [(i, inner1) | i <- [min .. max]]
  where
    inner1 = array (min, max) [(i, inner2) | i <- [min .. max]]
    inner2 = array (min, max) [(i, False) | i <- [min .. max]]

addCube :: SparseCube -> Point -> SparseCube
addCube cube (Point x y z) = cube // [(x, inner1 // [(y, inner2 // [(z, True)])])]
  where
    inner1 = cube ! x
    inner2 = inner1 ! y

splitOn :: Char -> String -> [String]
splitOn _ [] = []
splitOn c s = let (x, xs) = break (== c) s in x : splitOn c (drop 1 xs)

main :: IO ()
main = do
  s <- readFile "sample.txt"
  let nums :: [[Int]] = map (map read . splitOn ',') $ lines s
  let cubes = map (\[x, y, z] -> Point x y z) nums
  -- i found while playing around with my soln for part 2, that this also gives the right answer for
  -- part1, not sure why. but it's removing shit tons of code. see part1_old.hs for my original soln
  putStr "part 1: "
  let cubeSet = Set.fromList cubes
  let maybeTrappedCubes = filter (`Set.notMember` cubeSet) $ concatMap trappers cubes
  print $ length maybeTrappedCubes

--   putStr "part 2: "
--   let min = minimum $ concat nums
--   let max = maximum $ concat nums
--   print $ cubes
--   let sparseCube = foldl addCube (initSparse min max) cubes
--   print sparseCube
--   pure ()

trappers :: Point -> [Point]
trappers (Point x y z) =
  [ Point (x + 1) y z,
    Point (x - 1) y z,
    Point x (y -1) z,
    Point x (y + 1) z,
    Point x y (z -1),
    Point x y (z + 1)
  ]