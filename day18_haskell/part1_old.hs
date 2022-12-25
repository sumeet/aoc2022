{-# LANGUAGE ScopedTypeVariables #-}

import Data.List (nub)
import qualified Data.Map as Map
import qualified Data.Set as Set

data Point = Point Int Int Int deriving (Show, Eq, Ord)

type Face = Set.Set Point

type Counts = Map.Map Face Int

splitOn :: Char -> String -> [String]
splitOn _ [] = []
splitOn c s = let (x, xs) = break (== c) s in x : splitOn c (drop 1 xs)

faces :: Point -> [Face]
faces (Point x y z) = [topFace, bottomFace, frontFace, backFace, leftFace, rightFace]
  where
    topFace = Set.fromList [Point x y (z + 1), Point (x + 1) y (z + 1), Point (x + 1) (y + 1) (z + 1), Point x (y + 1) (z + 1)]
    bottomFace = Set.fromList [Point x y z, Point (x + 1) y z, Point (x + 1) (y + 1) z, Point x (y + 1) z]
    frontFace = Set.fromList [Point x y z, Point x y (z + 1), Point (x + 1) y (z + 1), Point (x + 1) y z]
    backFace = Set.fromList [Point x (y + 1) z, Point x (y + 1) (z + 1), Point (x + 1) (y + 1) (z + 1), Point (x + 1) (y + 1) z]
    leftFace = Set.fromList [Point x y z, Point x y (z + 1), Point x (y + 1) (z + 1), Point x (y + 1) z]
    rightFace = Set.fromList [Point (x + 1) y z, Point (x + 1) y (z + 1), Point (x + 1) (y + 1) (z + 1), Point (x + 1) (y + 1) z]

choices :: [a] -> [(a, [a])]
choices (x : xs) = (x, xs) : [(y, x : ys) | (y, ys) <- choices xs]
choices [] = []

main :: IO ()
main = do
  s <- readFile "input.txt"
  let nums :: [[Int]] = map (map read . splitOn ',') $ lines s
  let cubes = map (\[x, y, z] -> Point x y z) nums
  let allFaces = concatMap faces cubes
  let facesCounts = foldl (\acc face -> Map.insertWith (+) face 1 acc) Map.empty allFaces
  putStr "part 1: "
  print $ Map.size $ Map.filter (== 1) facesCounts