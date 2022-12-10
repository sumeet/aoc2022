import qualified Data.Set as Set
import Debug.Trace (traceShowId)

parseLine :: String -> (Char, Int)
parseLine (dir : ' ' : num) = (dir, read num)
parseLine line = error $ "Invalid line: " ++ line

data State = State
  { poss :: [(Int, Int)],
    tailSeen :: Set.Set (Int, Int)
  }
  deriving (Show)

moveN :: State -> (Char, Int) -> State
moveN s (dir, n) = foldl moveOne s $ replicate n dir

moveOne :: State -> Char -> State
moveOne s@(State knots tailSeen) dir =
  let existingHead = head knots
      existingTails = tail knots
      nextHead = moveHead existingHead dir
      nextTails = followTails nextHead existingTails
   in s {poss = nextHead : nextTails, tailSeen = Set.insert (last nextTails) tailSeen}

followTails :: (Int, Int) -> [(Int, Int)] -> [(Int, Int)]
followTails head tails = undefined

moveHead :: (Int, Int) -> Char -> (Int, Int)
moveHead (x, y) dir = case dir of
  'U' -> (x, y + 1)
  'D' -> (x, y - 1)
  'R' -> (x + 1, y)
  'L' -> (x - 1, y)
  _ -> error $ "Invalid direction: " ++ [dir]

followTail :: (Int, Int) -> (Int, Int) -> (Int, Int)
followTail head@(headX, headY) tail@(tailX, tailY)
  -- if they're the same then don't need to follow anything
  | head == tail = tail
  -- if head is 1 space directly above, below, left, or right of tail, then
  -- then no need to follow either
  | tail == (headX, headY + 1) = tail
  | tail == (headX, headY - 1) = tail
  | tail == (headX + 1, headY) = tail
  | tail == (headX - 1, headY) = tail
  -- if head is 1 space diagonally from tail, then no need to follow tail
  | tail == (headX + 1, headY + 1) = tail
  | tail == (headX - 1, headY + 1) = tail
  | tail == (headX + 1, headY - 1) = tail
  | tail == (headX - 1, headY - 1) = tail
  -- directly above, below, left, or right of tail, then tail follows
  | tail == (headX, headY + 2) = (tailX, tailY - 1)
  | tail == (headX, headY - 2) = (tailX, tailY + 1)
  | tail == (headX + 2, headY) = (tailX - 1, tailY)
  | tail == (headX - 2, headY) = (tailX + 1, tailY)
  -- if head is 2 spaces diagonally from tail, then tail follows
  | tail == (headX + 1, headY + 2) = (tailX - 1, tailY - 1)
  | tail == (headX - 1, headY + 2) = (tailX + 1, tailY - 1)
  | tail == (headX + 1, headY - 2) = (tailX - 1, tailY + 1)
  | tail == (headX - 1, headY - 2) = (tailX + 1, tailY + 1)
  | tail == (headX + 2, headY + 1) = (tailX - 1, tailY - 1)
  | tail == (headX - 2, headY + 1) = (tailX + 1, tailY - 1)
  | tail == (headX + 2, headY - 1) = (tailX - 1, tailY + 1)
  | tail == (headX - 2, headY - 1) = (tailX + 1, tailY + 1)
  | otherwise = error $ "Tail was too far from head: " ++ show tail ++ " " ++ show head

main :: IO ()
main = do
  let numTails = 10
  let knotPoss = replicate numTails (0, 0)
  let state = State knotPoss Set.empty
  s <- readFile "./sample.txt"
  let movess = map parseLine $ lines s
  let endingState = foldl moveN state movess
  putStrLn $ "part 2: " ++ show (length $ tailSeen endingState)