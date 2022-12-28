{-# LANGUAGE ScopedTypeVariables #-}

import Control.Monad (mapM)
import Control.Monad.State (State, get, put, runState)
import qualified Data.Set as Set

data Point = Point Int Int Int deriving (Show, Eq, Ord)

allPoints :: Point -> Point -> [Point]
allPoints (Point minX minY minZ) (Point maxX maxY maxZ) =
  [Point x y z | x <- [minX .. maxX], y <- [minY .. maxY], z <- [minZ .. maxZ]]

minMaxXyzs :: [Point] -> (Point, Point)
minMaxXyzs points = (Point minX minY minZ, Point maxX maxY maxZ)
  where
    minX = minimum $ map (\(Point x _ _) -> x) points
    minY = minimum $ map (\(Point _ y _) -> y) points
    minZ = minimum $ map (\(Point _ _ z) -> z) points
    maxX = maximum $ map (\(Point x _ _) -> x) points
    maxY = maximum $ map (\(Point _ y _) -> y) points
    maxZ = maximum $ map (\(Point _ _ z) -> z) points

exceeds :: Point -> (Point, Point) -> Bool
exceeds (Point x y z) (Point minX minY minZ, Point maxX maxY maxZ) =
  x < minX || x > maxX || y < minY || y > maxY || z < minZ || z > maxZ

splitOn :: Char -> String -> [String]
splitOn _ [] = []
splitOn c s = let (x, xs) = break (== c) s in x : splitOn c (drop 1 xs)

neighbors :: Point -> [Point]
neighbors (Point x y z) =
  [ Point (x + 1) y z,
    Point (x - 1) y z,
    Point x (y -1) z,
    Point x (y + 1) z,
    Point x y (z -1),
    Point x y (z + 1)
  ]

searchStructure :: Point -> (Point, Point) -> Set.Set Point -> State (Set.Set Point) (Set.Set Point)
searchStructure start minMax structure = do
  visited <- get
  if start `Set.member` visited || start `Set.member` structure || start `exceeds` minMax
    then pure Set.empty
    else do
      put $ start `Set.insert` visited
      let nbors = neighbors start
      foldl Set.union (Set.singleton start) <$> mapM (\p -> searchStructure p minMax structure) nbors

calcSurfaceArea :: Set.Set Point -> Int
calcSurfaceArea cubes = length $ filter (`Set.notMember` cubes) $ concatMap neighbors (Set.toList cubes)

main :: IO ()
main = do
  s <- readFile "input.txt"
  let nums :: [[Int]] = map (map read . splitOn ',') $ lines s
  let cubes = Set.fromList $ map (\[x, y, z] -> Point x y z) nums

  putStr "part 1: "
  let part1 = calcSurfaceArea cubes
  print part1

  putStr "part 2: "
  let (minXyzs, maxXyzs) = minMaxXyzs (Set.toList cubes)
  let allPointsSet = Set.fromList $ allPoints minXyzs maxXyzs
  let (foundPointsSet, _) = runState (searchStructure minXyzs (minXyzs, maxXyzs) cubes) Set.empty
  let innerAirCubes = allPointsSet `Set.difference` cubes `Set.difference` foundPointsSet
  print $ part1 - calcSurfaceArea innerAirCubes