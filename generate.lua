-- math.randomseed(os.time())
math.randomseed(tonumber(random_seed.text))

function list_contains(lst, x)
  local isin = false
  for i, v in ipairs(lst) do
    if v == x then
      isin = true
    end
  end
  return isin
end


function make_path()
  -- Retry making path from this point if it gets stuck.
  ::redo::
  -- start with an empty grid
  local grid = {}
  -- fill the grid with 0s
  for i = 1, 6 do
    grid[i] = {0,0,0,0,0,0}
  end

  -- set the starting row and column
  local row = 1
  local column = 1
  -- start path in start cell
  grid[row][column] = 1
  -- count completed moves
  local n = 2
  -- store each move as "left", "right", "up", or "down"
  local completed_moves = {}
  -- store the grid coordinates of the end point of each move
  local path_coords = {{1,1}}
  -- work towards the bottom right of the grid (cell 6,6)
  while row ~=6 or column ~= 6 do
    -- gather set of possible moves available from the current cell
    local mvs = {}
    -- available cell to the right
    if column < 6 and grid[row][column+1] == 0 then
        table.insert(mvs, "right")
    end
    -- available cell to the left
    if column > 1 and grid[row][column-1] == 0 then
      table.insert(mvs, "left")
    end
    -- available cell below
    if row < 6 and grid[row+1][column] == 0 then
      table.insert(mvs, "down")
    end
    -- available cell above
    if row > 1 and grid[row-1][column] == 0 then
      table.insert(mvs, "up")
    end

    if #mvs == 0 then -- no possible moves
      goto redo
    else -- at least one possible available
      -- randomly choose one of the available moves
      local move = mvs[math.random(1, #mvs)]
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
      -- mark the path with the number of the current move
      grid[row][column] = n
      -- save the coordinates and direction of the move
      table.insert(path_coords, {row, column})
      table.insert(completed_moves, move)
      n = n + 1 -- add to move count

      if (row == 6 and column == 6) and (n < 19) then
        goto redo
      end

    end
  end
  return {grid = grid, moves = completed_moves, path_coords = path_coords}
end

-- TODO: randomly select a set of tangrams

function fill_path(p)
  local attempts = 0
  ::redo_fill_path::

  -- create empty colour_map and image_map tables
  local colour_map = {}
  local image_map = {}

  for i = 1, 6 do
    colour_map[i] = {0,0,0,0,0,0}
    image_map[i] = {0,0,0,0,0,0}
  end

  -- count redos
  attempts = attempts + 1

  if attempts > 5 then -- stuck
    return {colour_map = colour_map, image_map = image_map, EXIT_SUCCESS = 1}
  end

  -- randomly choose colour and tangram for initial cell
  colour_map[1][1] = math.random(1, 3)
  image_map[1][1] = math.random(1, 9)

  -- randomly choose whether colour or tangram should match between 
  -- first two adjacent cells
  local match_type = math.random(1, 2)

  -- fill tangrams and colours on the path
  for i = 2, #p.path_coords do
    local current_cell = p.path_coords[i]
    local previous_cell = p.path_coords[i-1]
    local two_back_cell = p.path_coords[i-2]

    -- create set of all possible colours by usings table keys
    local all_colours = {[1] = true, [2] = true, [3] = true}

    -- create set of all possible tangrams by usings table keys
    local all_tangrams = {[1] = true,
                          [2] = true,
                          [3] = true,
                          [4] = true,
                          [5] = true,
                          [6] = true,
                          [7] = true,
                          [8] = true,
                          [9] = true}

    -- remove items from colour or tangram sets when they are
    -- in adjacent cells to the current cell
    if current_cell[1] > 1 and (current_cell[1]-1 ~= previous_cell[1] or current_cell[2] ~= previous_cell[2]) then
      all_colours[colour_map[current_cell[1]-1][current_cell[2]]] = nil
      all_tangrams[image_map[current_cell[1]-1][current_cell[2]]] = nil
    end
    if current_cell[1] < 6 and (current_cell[1]+1 ~= previous_cell[1] or current_cell[2] ~= previous_cell[2]) then
      all_colours[colour_map[current_cell[1]+1][current_cell[2]]] = nil
      all_tangrams[image_map[current_cell[1]+1][current_cell[2]]] = nil
    end
    if current_cell[2] > 1 and (current_cell[1] ~= previous_cell[1] or current_cell[2]-1 ~= previous_cell[2]) then
      all_colours[colour_map[current_cell[1]][current_cell[2]-1]] = nil
      all_tangrams[image_map[current_cell[1]][current_cell[2]-1]] = nil
    end
    if current_cell[2] < 6 and (current_cell[1] ~= previous_cell[1] or current_cell[2]+1 ~= previous_cell[2]) then
      all_colours[colour_map[current_cell[1]][current_cell[2]+1]] = nil
      all_tangrams[image_map[current_cell[1]][current_cell[2]+1]] = nil
    end

    -- construct a list of tangrams that are not used in adjacent cells
    local complimentary_tangrams = {}
    for tangram_idx = 1, 9 do
      if all_tangrams[tangram_idx] then
        table.insert(complimentary_tangrams, tangram_idx)
      end
    end

    -- construct a list of colours that are not used in adjacent cells
    local complimentary_colours = {}
    for colour_idx = 1, 3 do
      if all_colours[colour_idx] then
        table.insert(complimentary_colours, colour_idx)
      end
    end

    -- try again if all colours or tangrams are used in adjacent cells
    if #complimentary_colours == 0 then
      goto redo_fill_path
    elseif #complimentary_tangrams == 0 then
      goto redo_fill_path
    end

    -- can't match previous cell in colour or tangram due to clashes with other adj path cells
    if list_contains(complimentary_colours, colour_map[previous_cell[1]][previous_cell[2]]) == false and
       list_contains(complimentary_tangrams, image_map[previous_cell[1]][previous_cell[2]]) == false then
        goto redo_fill_path
    end

    if match_type == 1 then -- match colour
      if list_contains(complimentary_colours, colour_map[previous_cell[1]][previous_cell[2]]) then
        colour_map[current_cell[1]][current_cell[2]] = colour_map[previous_cell[1]][previous_cell[2]] -- match colour
        image_map[current_cell[1]][current_cell[2]] = complimentary_tangrams[math.random(1, #complimentary_tangrams)]
      else -- can't match colour because of clash with another adjacent cell in the path
        colour_map[current_cell[1]][current_cell[2]] = complimentary_colours[math.random(1, #complimentary_colours)]
        image_map[current_cell[1]][current_cell[2]] = image_map[previous_cell[1]][previous_cell[2]] -- match tangram
      end
    else -- match tangram
      if list_contains(complimentary_tangrams, image_map[previous_cell[1]][previous_cell[2]]) then
        colour_map[current_cell[1]][current_cell[2]] = complimentary_colours[math.random(1, #complimentary_colours)]
        image_map[current_cell[1]][current_cell[2]] = image_map[previous_cell[1]][previous_cell[2]] -- match tangram
      else -- can't match tangram because of clash with another adjacent cell in the path
        colour_map[current_cell[1]][current_cell[2]] = colour_map[previous_cell[1]][previous_cell[2]] -- match colour
        image_map[current_cell[1]][current_cell[2]] = complimentary_tangrams[math.random(1, #complimentary_tangrams)]
      end
    end

    -- don't allow adjacent cells in the path to match both colour and tangram
    if colour_map[current_cell[1]][current_cell[2]] == colour_map[previous_cell[1]][previous_cell[2]] and
       image_map[current_cell[1]][current_cell[2]] == image_map[previous_cell[1]][previous_cell[2]] then
      goto redo_fill_path
    end

    -- don't allows runs of three cells of the same colour within the path
    if two_back_cell ~= nil and 
       colour_map[current_cell[1]][current_cell[2]] == colour_map[previous_cell[1]][previous_cell[2]] and
       colour_map[current_cell[1]][current_cell[2]] == colour_map[two_back_cell[1]][two_back_cell[2]] then
      goto redo_fill_path
    end

    -- don't allows runs of three cells of the same tangram within the path
    if two_back_cell ~= nil and 
       image_map[current_cell[1]][current_cell[2]] == image_map[previous_cell[1]][previous_cell[2]] and
       image_map[current_cell[1]][current_cell[2]] == image_map[two_back_cell[1]][two_back_cell[2]] then
      goto redo_fill_path
    end

    -- alternate match type at each step of the path
    if match_type == 1 then
      match_type = 2
    else
      match_type = 1
    end
  end
  return {colour_map = colour_map, image_map = image_map, EXIT_SUCCESS = 0}
end

-- pass the output of fill_path()
function pad_path(p)
  -- Add colours and tangrams to each cell adjacent to the path.
  -- These cells form a barrier around the path by ensuring that
  -- neither colours nor tangrams match in cells that can be
  -- moved to from the path.

  local attempts = 0

  ::redo_pad_path::

  local colour_map = {}
  local image_map = {}

  attempts = attempts + 1

  if attempts > 9 then
    return {colour_map = colour_map, image_map = image_map, EXIT_SUCCESS = 1}
  end

  for i = 1, 6 do
    colour_map[i] = {0,0,0,0,0,0}
    image_map[i] = {0,0,0,0,0,0}
  end

  for i = 1,6 do
    for j = 1,6 do
      if p.colour_map[i][j] == 0 then -- find cells not on the path
        -- find cells adjacent to path
        if ((i > 1) and (p.colour_map[i-1][j] ~= 0)) or -- cell above on path
           ((i < 6) and (p.colour_map[i+1][j] ~= 0)) or -- cell below on path
           ((j > 1) and (p.colour_map[i][j-1] ~= 0)) or -- cell to left on path
           ((j < 6) and (p.colour_map[i][j+1] ~= 0)) then -- cell to right on path
            -- construct set of colours and tangrams in adjacent cells on path
            -- create set of all colours and tangrams
            -- create set of all possible colours by usings table keys
            local possible_colours = {}
            for _,v in ipairs({1,2,3}) do
              possible_colours[v] = true
            end

            -- create set of all possible tangrams by usings table keys
            local possible_tangrams = {}
            for _,v in ipairs({1,2,3,4,5,6,7,8,9}) do
              possible_tangrams[v] = true
            end

            -- don't use colour or tangram from cell above
            if i > 1 and p.colour_map[i-1][j] ~= 0 then
              possible_colours[p.colour_map[i-1][j]] = nil
              possible_tangrams[p.image_map[i-1][j]] = nil
            end

            -- don't use colour or tangram from cell below
            if i < 6 and p.colour_map[i+1][j] ~= 0 then
              possible_colours[p.colour_map[i+1][j]] = nil
              possible_tangrams[p.image_map[i+1][j]] = nil
            end

            -- don't use colour or tangram from cell to left
            if j > 1 and p.colour_map[i][j-1] ~= 0 then
              possible_colours[p.colour_map[i][j-1]] = nil
              possible_tangrams[p.image_map[i][j-1]] = nil
            end

            -- don't use colour or tangram from cell to right
            if j < 6 and p.colour_map[i][j+1] ~= 0 then
              possible_colours[p.colour_map[i][j+1]] = nil
              possible_tangrams[p.image_map[i][j+1]] = nil
            end

            -- construct a list of tangrams that are not used in adjacent cells
            local complimentary_tangrams = {}
            for x = 1,9 do
              if possible_tangrams[x] then
                table.insert(complimentary_tangrams, x)
              end
            end

            -- construct a list of colours that are not used in adjacent cells
            local complimentary_colours = {}
            for y = 1,3 do
              if possible_colours[y] then
                table.insert(complimentary_colours, y)
              end
            end

            -- no colour or tangram options left
            if #complimentary_colours == 0 then
              goto redo_pad_path
            elseif #complimentary_tangrams == 0 then
              goto redo_pad_path
            end

            -- fill in cells adjacent to path
            colour_map[i][j] = complimentary_colours[math.random(1, #complimentary_colours)]
            image_map[i][j] = complimentary_tangrams[math.random(1, #complimentary_tangrams)]
          else
            -- fill in the rest of the blank cells
            colour_map[i][j] = math.random(1, 3)
            image_map[i][j] = math.random(1, 9)
          end
      end
    end
  end
  return {colour_map = colour_map, image_map = image_map, EXIT_SUCCESS = 0}
end

function make_maps()
  ::redo::
  local path = make_path()
  local filled_path = fill_path(path)
  if filled_path.EXIT_SUCCESS == 1 then
    goto redo
  end
  local padded_path = pad_path(filled_path)
  if padded_path.EXIT_SUCCESS == 1 then
    goto redo
  end

  local colour_map = {}
  local image_map = {}
  for i = 1, 6 do
    colour_map[i] = {0,0,0,0,0,0}
    image_map[i] = {0,0,0,0,0,0}
  end
  for x = 1, 6 do
    for y = 1, 6 do
      if filled_path.colour_map[x][y] ~= 0 then
        colour_map[x][y] = filled_path.colour_map[x][y]
      elseif padded_path.colour_map[x][y] ~= 0 then
        colour_map[x][y] = padded_path.colour_map[x][y]
      end

      if filled_path.image_map[x][y] ~= 0 then
        image_map[x][y] = filled_path.image_map[x][y]
      elseif padded_path.image_map[x][y] ~= 0 then
        image_map[x][y] = padded_path.image_map[x][y]
      end
    end
  end

  return {path = path.grid,
          moves = path.moves,
          path_coords = path.path_coords,
          image_map = image_map,
          colour_map = colour_map}
end
