{-# LANGUAGE ScopedTypeVariables #-}

import Control.Monad (foldM, mapM)
import Control.Monad.State (State, get, put, runState)
import Data.List (nub)
import qualified Data.Map as Map
import qualified Data.Set as Set
import Debug.Trace (traceShowId)

data Point = Point Int Int Int deriving (Show, Eq, Ord)

type Face = Set.Set Point

type Counts = Map.Map Face Int

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

faces :: Point -> [Face]
faces (Point x y z) = [topFace, bottomFace, frontFace, backFace, leftFace, rightFace]
  where
    topFace = Set.fromList [Point x y (z + 1), Point (x + 1) y (z + 1), Point (x + 1) (y + 1) (z + 1), Point x (y + 1) (z + 1)]
    bottomFace = Set.fromList [Point x y z, Point (x + 1) y z, Point (x + 1) (y + 1) z, Point x (y + 1) z]
    frontFace = Set.fromList [Point x y z, Point x y (z + 1), Point (x + 1) y (z + 1), Point (x + 1) y z]
    backFace = Set.fromList [Point x (y + 1) z, Point x (y + 1) (z + 1), Point (x + 1) (y + 1) (z + 1), Point (x + 1) (y + 1) z]
    leftFace = Set.fromList [Point x y z, Point x y (z + 1), Point x (y + 1) (z + 1), Point x (y + 1) z]
    rightFace = Set.fromList [Point (x + 1) y z, Point (x + 1) y (z + 1), Point (x + 1) (y + 1) (z + 1), Point (x + 1) (y + 1) z]

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
  if start `Set.member` visited
    then pure Set.empty
    else do
      put $ start `Set.insert` visited
      if (start `Set.member` structure) || (start `exceeds` minMax)
        then pure Set.empty
        else -- we have outer air

          ( do
              let nbors = neighbors start
              nborResults <- mapM (\p -> searchStructure p minMax structure) nbors
              pure $ foldl Set.union (Set.singleton start) nborResults
          )

calcSurfaceArea :: [Point] -> Int
calcSurfaceArea points = length $ Map.filter (== 1) facesCounts
  where
    allFaces = concatMap faces points
    facesCounts = foldl (\acc face -> Map.insertWith (+) face 1 acc) Map.empty allFaces

main :: IO ()
main = do
  s <- readFile "input.txt"
  let nums :: [[Int]] = map (map read . splitOn ',') $ lines s
  let cubes = map (\[x, y, z] -> Point x y z) nums
  putStr "part 1: "
  let part1 = calcSurfaceArea cubes
  print part1
  let (minXyzs, maxXyzs) = minMaxXyzs cubes
  let allPointsSet = Set.fromList $ allPoints minXyzs maxXyzs
  let cubesSet = Set.fromList cubes
  let (foundPointsSet, _) = runState (searchStructure minXyzs (minXyzs, maxXyzs) cubesSet) Set.empty
  let innerAirCubes = (allPointsSet `Set.difference` cubesSet) `Set.difference` foundPointsSet
  putStr "part 2: "
  print $ part1 - calcSurfaceArea (Set.toList innerAirCubes)
