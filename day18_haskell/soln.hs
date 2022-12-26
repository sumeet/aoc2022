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

choices :: [a] -> [(a, [a])]
choices (x : xs) = (x, xs) : [(y, x : ys) | (y, ys) <- choices xs]
choices [] = []

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
      if start `Set.member` structure
        then pure $ Set.singleton start
        else
          if start `exceeds` minMax
            then pure Set.empty
            else do
              let nbors = neighbors start
              nborResults <- mapM (\p -> searchStructure p minMax structure) nbors
              pure $ foldl Set.union Set.empty nborResults

main :: IO ()
main = do
  s <- readFile "sample.txt"
  let nums :: [[Int]] = map (map read . splitOn ',') $ lines s
  let cubes = map (\[x, y, z] -> Point x y z) nums
  let allFaces = concatMap faces cubes
  let facesCounts = foldl (\acc face -> Map.insertWith (+) face 1 acc) Map.empty allFaces
  putStr "part 1: "
  let facesInSurfaceArea = Map.keys $ Map.filter (== 1) facesCounts
  print $ length facesInSurfaceArea
  let allPointsInSurfaceArea = foldl Set.union Set.empty facesInSurfaceArea
  let minMax = minMaxXyzs $ Set.toList allPointsInSurfaceArea
  print minMax
  let (pointsOfStructure, _) = runState (searchStructure (fst minMax) minMax allPointsInSurfaceArea) Set.empty
  print $ length pointsOfStructure