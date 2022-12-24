{-# LANGUAGE ScopedTypeVariables #-}

import qualified Data.Set as Set

data Point = Point Int Int Int deriving (Show, Eq, Ord)

type Face = Set.Set Point

splitOn :: Char -> String -> [String]
splitOn _ [] = []
splitOn c s = let (x, xs) = break (== c) s in x : splitOn c (drop 1 xs)

faces :: Point -> [Face]
faces (Point x y z) =
  [ Set.fromList [Point x y z, Point (x + 1) y z, Point x (y + 1) z, Point x y (z + 1)],
    Set.fromList [Point x y z, Point (x + 1) y z, Point (x + 1) (y + 1) z, Point x (y + 1) z],
    Set.fromList [Point x y z, Point (x + 1) y z, Point (x + 1) y (z + 1), Point x y (z + 1)],
    Set.fromList [Point x y z, Point x (y + 1) z, Point x (y + 1) (z + 1), Point x y (z + 1)],
    Set.fromList [Point x y z, Point x (y + 1) z, Point (x + 1) (y + 1) z, Point (x + 1) y z],
    Set.fromList [Point x y z, Point x y (z + 1), Point (x + 1) y (z + 1), Point (x + 1) y z]
  ]

choices :: [a] -> [(a, [a])]
choices (x : xs) = (x, xs) : [(y, x : ys) | (y, ys) <- choices xs]
choices [] = []

main :: IO ()
main = do
  s <- readFile "sample.txt"
  let nums :: [[Int]] = map (map read . splitOn ',') $ lines s
  let cubes = map (\[x, y, z] -> Point x y z) nums
  let f = length $ concat $ [filter (\face -> face `notElem` concatMap faces otherCubes) (faces thisCube) | (thisCube, otherCubes) <- choices cubes]
  print f