require "set"

visible_tree_indexes = Set.new

grid = []

File.readlines("input.txt").each_with_index do |line|
  grid << line.chomp.split("").map(&method(:Integer))
end

pp grid

# width and height are the same, it's a square
grid_width = grid.first.length
grid_height = grid_width

# iterate columns from left to right, then bottom to top
0.upto(grid_width - 1) do |x|
  prev = -1
  0.upto(grid_height - 1) do |y|
    if grid[y][x] > prev
      visible_tree_indexes << [x, y]
      prev = grid[y][x]
    end
  end
end

# iterate columns from left to right, then top to bottom
0.upto(grid_width - 1) do |x|
  prev = -1
  (grid_height - 1).downto(0) do |y|
    if grid[y][x] > prev
      visible_tree_indexes << [x, y]
      prev = grid[y][x]
    end
  end
end

# iterate columns from bottom to top, then left to right
0.upto(grid_height - 1) do |y|
  prev = -1
  0.upto(grid_width - 1) do |x|
    if grid[y][x] > prev
      visible_tree_indexes << [x, y]
      prev = grid[y][x]
    end
  end
end

# iterate columns from bottom to top, then right to left
0.upto(grid_height - 1) do |y|
  prev = -1
  (grid_width - 1).downto(0) do |x|
    if grid[y][x] > prev
      visible_tree_indexes << [x, y]
      prev = grid[y][x]
    end
  end
end

pp visible_tree_indexes.size