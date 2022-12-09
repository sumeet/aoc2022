require "set"

visible_tree_indexes = Set.new

GRID = []

File.readlines("input.txt").each_with_index do |line|
  GRID << line.chomp.split("").map(&method(:Integer))
end

# width and height are the same, it's a square
GRID_WIDTH = GRID.first.length
GRID_HEIGHT = GRID_WIDTH

# iterate columns from left to right, then bottom to top
0.upto(GRID_WIDTH - 1) do |x|
  prev = -1
  0.upto(GRID_HEIGHT - 1) do |y|
    if GRID[y][x] > prev
      visible_tree_indexes << [x, y]
      prev = GRID[y][x]
    end
  end
end

# iterate columns from left to right, then top to bottom
0.upto(GRID_WIDTH - 1) do |x|
  prev = -1
  (GRID_HEIGHT - 1).downto(0) do |y|
    if GRID[y][x] > prev
      visible_tree_indexes << [x, y]
      prev = GRID[y][x]
    end
  end
end

# iterate columns from bottom to top, then left to right
0.upto(GRID_HEIGHT - 1) do |y|
  prev = -1
  0.upto(GRID_WIDTH - 1) do |x|
    if GRID[y][x] > prev
      visible_tree_indexes << [x, y]
      prev = GRID[y][x]
    end
  end
end

# iterate columns from bottom to top, then right to left
0.upto(GRID_HEIGHT - 1) do |y|
  prev = -1
  (GRID_WIDTH - 1).downto(0) do |x|
    if GRID[y][x] > prev
      visible_tree_indexes << [x, y]
      prev = GRID[y][x]
    end
  end
end

puts "part1: #{visible_tree_indexes.size}"

def scenic_score(x, y)
  num_above(x, y) * num_below(x, y) * num_right(x, y) * num_left(x, y)
end

def num_above(x, y)
  this = GRID[y][x]
  ct = 0
  (y-1).downto(0) do |ny|
    ct += 1
    break if GRID[ny][x] >= this
  end
  ct
end

def num_below(x, y)
  this = GRID[y][x]
  ct = 0
  (y+1).upto(GRID_HEIGHT - 1) do |ny|
    ct += 1
    break if GRID[ny][x] >= this
  end
  ct
end

def num_right(x, y)
  this = GRID[y][x]
  ct = 0
  (x+1).upto(GRID_WIDTH - 1) do |nx|
    ct += 1
    break if GRID[y][nx] >= this
  end
  ct
end

def num_left(x, y)
  this = GRID[y][x]
  ct = 0
  (x-1).downto(0) do |nx|
    ct += 1
    break if GRID[y][nx] >= this
  end
  ct
end


max = 0
GRID.each_with_index do |row, y|
  row.each_with_index do |height, x|
    max = [max, scenic_score(x, y)].max
  end
end

puts "part2: #{max}"
