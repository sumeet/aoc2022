import qualified Data.Set as Set
import Debug.Trace (traceShowId)

parseLine :: String -> (Char, Int)
parseLine (dir : ' ' : num) = (dir, read num)
parseLine line = error $ "Invalid line: " ++ line

data State = State
  { posHead :: (Int, Int),
    posTail :: (Int, Int),
    tailPoss :: Set.Set (Int, Int)
  }
  deriving (Show)

moveN :: State -> (Char, Int) -> State
moveN s (dir, n) = foldl moveOne s $ replicate n dir

moveOne :: State -> Char -> State
moveOne s@(State head tail tailPoss) dir =
  let s' = moveHead s dir
      s'' = followTail s'
      newTail = posTail s''
   in s'' {tailPoss = Set.insert newTail tailPoss}

moveHead :: State -> Char -> State
moveHead s@(State (x, y) _ _) dir =
  case dir of
    'U' -> s {posHead = (x, y + 1)}
    'D' -> s {posHead = (x, y - 1)}
    'R' -> s {posHead = (x + 1, y)}
    'L' -> s {posHead = (x - 1, y)}
    _ -> error $ "Invalid direction: " ++ [dir]

followTail :: State -> State
followTail s@(State head@(headX, headY) tail@(tailX, tailY) _)
  -- if they're the same then don't need to follow anything
  | head == tail = s
  -- if head is 1 space directly above, below, left, or right of tail, then
  -- then no need to follow either
  | tail == (headX, headY + 1) = s
  | tail == (headX, headY - 1) = s
  | tail == (headX + 1, headY) = s
  | tail == (headX - 1, headY) = s
  -- if head is 1 space diagonally from tail, then no need to follow tail
  | tail == (headX + 1, headY + 1) = s
  | tail == (headX - 1, headY + 1) = s
  | tail == (headX + 1, headY - 1) = s
  | tail == (headX - 1, headY - 1) = s
  -- directly above, below, left, or right of tail, then tail follows
  | tail == (headX, headY + 2) = s {posTail = (tailX, tailY - 1)}
  | tail == (headX, headY - 2) = s {posTail = (tailX, tailY + 1)}
  | tail == (headX + 2, headY) = s {posTail = (tailX - 1, tailY)}
  | tail == (headX - 2, headY) = s {posTail = (tailX + 1, tailY)}
  -- if head is 2 spaces diagonally from tail, then tail follows
  | tail == (headX + 1, headY + 2) = s {posTail = (tailX - 1, tailY - 1)}
  | tail == (headX - 1, headY + 2) = s {posTail = (tailX + 1, tailY - 1)}
  | tail == (headX + 1, headY - 2) = s {posTail = (tailX - 1, tailY + 1)}
  | tail == (headX - 1, headY - 2) = s {posTail = (tailX + 1, tailY + 1)}
  | tail == (headX + 2, headY + 1) = s {posTail = (tailX - 1, tailY - 1)}
  | tail == (headX - 2, headY + 1) = s {posTail = (tailX + 1, tailY - 1)}
  | tail == (headX + 2, headY - 1) = s {posTail = (tailX - 1, tailY + 1)}
  | tail == (headX - 2, headY - 1) = s {posTail = (tailX + 1, tailY + 1)}
  | otherwise = error $ "Tail was too far from head: " ++ show tail ++ " " ++ show head

main :: IO ()
main = do
  let state = State (0, 0) (0, 0) Set.empty
  s <- readFile "./input.txt"
  let movess = map parseLine $ lines s
  let endingState = foldl moveN state movess
  putStrLn $ "part 1: " ++ show (length $ tailPoss endingState)