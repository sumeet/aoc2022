{-# LANGUAGE ScopedTypeVariables #-}

import Data.Array (Array, array, (!), (//))
import Data.IORef (IORef, modifyIORef, readIORef)
import Data.List (elemIndex, insert, nub)
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Maybe (fromJust)
import qualified Data.Set as Set
import Debug.Trace (traceShowId)
import GHC.IORef (newIORef)
import System.IO.Unsafe (unsafePerformIO)

data Point = Point Int Int Int deriving (Show, Eq, Ord)

minMaxXyzs :: [Point] -> (Point, Point)
minMaxXyzs points = (Point minX minY minZ, Point maxX maxY maxZ)
  where
    minX = minimum $ map (\(Point x _ _) -> x) points
    minY = minimum $ map (\(Point _ y _) -> y) points
    minZ = minimum $ map (\(Point _ _ z) -> z) points
    maxX = maximum $ map (\(Point x _ _) -> x) points
    maxY = maximum $ map (\(Point _ y _) -> y) points
    maxZ = maximum $ map (\(Point _ _ z) -> z) points

isOutside :: Point -> [Point] -> Bool
isOutside (Point x y z) allFaces = x < minX || x > maxX || y < minY || y > maxY || z < minZ || z > maxZ
  where
    (Point minX minY minZ, Point maxX maxY maxZ) = minMaxXyzs allFaces

data SparseRepr = SparseRepr
  { xy_z :: Map (Int, Int) [Int],
    xz_y :: Map (Int, Int) [Int],
    yz_x :: Map (Int, Int) [Int]
  }
  deriving (Show)

----- (x,y) -> sorted [z1..2..zEnd]
----- (x,z) -> sorted [y1..2..yEnd]
----- (y,z) -> sorted [x1..5..xEnd]

pointTouchingOutside :: [Int] -> Int -> Bool
pointTouchingOutside sorted n = case elemIndex n sorted of
  (Just index) -> index == 0 || index == length sorted - 1
  Nothing -> False

faceTouchingOutside :: SparseRepr -> Point -> Bool
faceTouchingOutside (SparseRepr xy_z xz_y yz_x) (Point x y z) =
  let zs = Map.lookup (x, y) xy_z
      ys = Map.lookup (x, z) xz_y
      xs = Map.lookup (y, z) yz_x
   in case (xs, ys, zs) of
        (Just xs, Just ys, Just zs) -> pointTouchingOutside xs x || pointTouchingOutside ys y || pointTouchingOutside zs z
        _ -> False

initSparse :: SparseRepr
initSparse = SparseRepr Map.empty Map.empty Map.empty

insertMany :: [Int] -> [Int] -> [Int]
insertMany sorted ns = nub $ foldl (flip insert) sorted ns

addCube :: SparseRepr -> Point -> SparseRepr
addCube (SparseRepr xy_z xz_y yz_x) (Point x y z) =
  SparseRepr
    (Map.insertWith insertMany (x, y) [z] xy_z)
    (Map.insertWith insertMany (x, z) [y] xz_y)
    (Map.insertWith insertMany (y, z) [x] yz_x)

splitOn :: Char -> String -> [String]
splitOn _ [] = []
splitOn c s = let (x, xs) = break (== c) s in x : splitOn c (drop 1 xs)

globalVisited :: IORef (Set.Set Point)
{-# NOINLINE globalVisited #-}
globalVisited = unsafePerformIO $ newIORef Set.empty

searchTrapped :: Point -> Set.Set Point -> IO (Set.Set Point)
searchTrapped pt allFaces = do
  visited <- readIORef globalVisited
  if isOutside (pt) (Set.toList allFaces)
    then pure Set.empty
    else
      if (pt) `Set.member` visited
        then pure Set.empty
        else do
          modifyIORef globalVisited (Set.insert pt)
          let nexts = faces pt
          pure $
            if Set.fromList nexts `Set.isSubsetOf` Set.union visited allFaces
              then Set.singleton pt
              else foldl Set.union Set.empty $ map (\nextPt -> unsafePerformIO $ searchTrapped nextPt allFaces) nexts

main :: IO ()
main = do
  s <- readFile "sample.txt"
  let nums :: [[Int]] = map (map read . splitOn ',') $ lines s
  let cubes = map (\[x, y, z] -> Point x y z) nums
  -- i found while playing around with my soln for part 2, that this also gives the right answer for
  -- part1, not sure why. but it's removing shit tons of code. see part1_old.hs for my original soln
  putStr "part 1: "
  let cubeSet = Set.fromList cubes
  let allFaces = filter (`Set.notMember` cubeSet) $ concatMap faces cubes
  print $ length allFaces
  putStrLn $ unlines $ map (\(Point x y z) -> show x ++ "," ++ show y ++ "," ++ show z) allFaces

  putStr "part 2: "
  let trapped :: Set.Set Point = Set.fromList []
  let allFacesSet = Set.fromList allFaces
  let part2 = foldl Set.union Set.empty $ map (\nextPt -> unsafePerformIO $ searchTrapped nextPt allFacesSet) allFaces
  putStrLn $ unlines $ map (\(Point x y z) -> show x ++ "," ++ show y ++ "," ++ show z) (Set.toList part2)
  pure ()

--pure ()

--   let sparse = foldl addCube initSparse allFaces
--   let touchingOutside = Set.fromList $ filter (faceTouchingOutside sparse) allFaces
--   print $ length $ Set.intersection touchingOutside (Set.fromList $ faces (Point 2 2 5))

--print $ faceTouchingOutside sparse (Point 2 2 5)

faces :: Point -> [Point]
faces (Point x y z) =
  [ Point (x + 1) y z,
    Point (x - 1) y z,
    Point x (y -1) z,
    Point x (y + 1) z,
    Point x y (z -1),
    Point x y (z + 1)
  ]