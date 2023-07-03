function make_path()
  ::redo::
  grid = {}

  for i = 1, 6 do
    grid[i] = {0,0,0,0,0,0}
  end

  row = 1
  column = 1

  -- start path in row 1, column 1
  grid[row][column] = 1

  n = 2

  completed_moves = {}

  while row ~=6 or column ~= 6 do
    -- gather set of possible moves
    mvs = {}
    if column < 6 and grid[row][column+1] == 0 then
        table.insert(mvs, "right")
    end
    if column > 1 and grid[row][column-1] == 0 then
      table.insert(mvs, "left")
    end
    if row < 6 and grid[row+1][column] == 0 then
      table.insert(mvs, "down")
    end
    if row > 1 and grid[row-1][column] == 0 then
      table.insert(mvs, "up")
    end
    
    if #mvs == 0 then -- no possible moves, try again
      goto redo
    elseif n >= 17 and (row ~=6 or column ~= 6) then -- too many moves, try again
      goto redo
    else -- at least one possible move
      -- randomly choose one of the possible moves
      move = mvs[math.random(1, #mvs)]
      -- make the move
      if move == "right" then
        column = column + 1
      elseif move == "left" then
        column = column - 1
      elseif move == "down" then
        row = row + 1
      elseif move == "up" then
        row = row - 1
      end
      grid[row][column] = n
      table.insert(completed_moves, move)
      n = n + 1
    end
  end
  return {grid = grid, moves = completed_moves}
end

function print_path(x)
  for i = 1, 6  do
    for j = 1, 6 do
      if x.grid[i][j] ~= 0 and x.grid[i][j] > 9 then
        io.write(x.grid[i][j], " ")
      elseif x.grid[i][j] ~= 0 then
        io.write(0 .. x.grid[i][j], " ")
      elseif x.grid[i][j] == 0 then
        io.write("--", " ")
      end
    end
    io.write("\n")
  end
  io.write("\n")
end

z = make_path()

print_path(z)
