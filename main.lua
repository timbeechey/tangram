function love.load()

    icon = love.graphics.newImage("icon.png")

    socket = require("socket") -- for milisecond precision time
    -- get baseline start time in ms for logging results
    gameTimeMs = socket.gettime()
    -- get start time and date for results filename
    gameTimeS = os.date('%Y%m%d_%H%M%S')
    fname = "results_" .. gameTimeS .. ".txt"

    love.graphics.setBackgroundColor(1,1,1)

    --[[
    1: orange
    2: blue
    3: green
    --]]
    colourMap = {
        {1,1,2,3,1,2},
        {2,3,2,1,2,3},
        {2,1,3,3,1,1},
        {3,2,1,2,2,2},
        {2,3,3,1,3,3},
        {2,1,2,2,1,2}
    }

    --[[
    1: swan
    2: giraffe
    3: running man
    4: kangeroo
    5: tall ship
    6: rooster
    7: man riding horse
    8: depressed man
    9: low ship
    --]]
    
    cellSize = 120
    
    tangrams = love.graphics.newImage("set02.png")
    local image_width = tangrams:getWidth()
    local image_height = tangrams:getHeight()

    imageFrames = {}
    local image_frame_width = cellSize
    local image_frame_height = cellSize

    for i=0,9 do
        table.insert(imageFrames, love.graphics.newQuad(i * image_frame_width, 0, image_frame_width, image_frame_height, image_width, image_height))
    end

    letters = love.graphics.newImage("letters.png")
    local letters_width = letters:getWidth()
    local letters_height = letters:getHeight()

    letterFrames = {}
    local letter_frame_width = cellSize
    local letter_frame_height = cellSize

    for i=0,5 do
        table.insert(letterFrames, love.graphics.newQuad(i * letter_frame_width, 0, letter_frame_width, letter_frame_height, letters_width, letters_height))
    end

    numbers = love.graphics.newImage("numbers.png")
    local numbers_width = numbers:getWidth()
    local numbers_height = numbers:getHeight()

    numberFrames = {}
    local number_frame_width = cellSize
    local number_frame_height = cellSize

    for i = 0, 5 do
        table.insert(numberFrames, love.graphics.newQuad(i * number_frame_width, 0, number_frame_width, number_frame_height, numbers_width, numbers_height))
    end

    imageMap = {
        {1,2,2,3,3,6},
        {4,4,5,5,5,6},
        {3,9,4,9,5,4},
        {3,1,7,7,2,4},
        {8,8,7,5,6,1},
        {9,9,9,6,6,1}
    }

    colours = {
        {246/255, 156/255, 51/255},  -- orange
        {133/255, 136/255, 255/255}, -- blue
        {1/255, 144/255, 67/255},    -- green
        {1,1,1}                      -- white
    }
    
    currentRow = 1
    currentCol = 1

    currentX = cellSize + (cellSize / 2)
    currentY = cellSize + (cellSize / 2)

    moves = {}

    success, errormsg = love.filesystem.append(fname, "player" .. "time," .. "direction," .. "x," .. "y" .. "\n")
    
    player = 1
    
    -- blank out every other colour and tangram
    -- alternately for player 1 and player 2
    for i, row in ipairs(colourMap) do
        for j, col in ipairs(row) do
            if player == 1 then
                if i % 2 == 1 then -- odd row
                    if j % 2 == 1 then -- odd column
                        colourMap[i][j] = 4
                    elseif j % 2 == 0 then -- odd row, even column
                        imageMap[i][j] = 10
                    end
                elseif j % 2 == 0 then -- even row, even column
                    colourMap[i][j] = 4
                elseif i % 2 == 0 then -- even row, odd column
                    imageMap[i][j] = 10
                end
            elseif player == 2 then
              
              if i % 2 == 1 then -- odd row
                    if j % 2 == 0 then -- even column
                        colourMap[i][j] = 4
                    elseif j % 2 == 1 then
                        imageMap[i][j] = 10
                    end
                elseif j % 2 == 1 then
                    colourMap[i][j] = 4
                elseif i % 2 == 0 then
                    imageMap[i][j] = 10
                end
              
            end
        end
    end
    
end

--[[
function love.keypressed(key)
    -- save events to file
    -- the file is located in the game's save directory
    -- on macos this is ~/Libary/Application Support/LOVE/tangram
    -- on windows ... appdata\roaming\LOVE\tangram
    local dat = socket.gettime() - gameTimeMs .. "," .. key .. "\n"
    success, errormsg = love.filesystem.append(fname, dat)

    if key == "right" and currentCol < 6 then
        currentCol = currentCol + 1
    elseif key == "left" and currentCol > 1 then
        currentCol = currentCol - 1
    elseif key == "up" and currentRow > 1 then
        currentRow = currentRow - 1
    elseif key == "down" and currentRow < 6 then
        currentRow = currentRow + 1
    end
end
--]]


function love.mousepressed(x, y, button, istouch, presses)
    -- calculate the column that corresponds to x and
    -- the row that corresponds to y
    local x_col = math.ceil((x-cellSize) / cellSize)
    local y_row = math.ceil((y-cellSize) / cellSize)
    -- check for double tap and that tap was within 1 row xor 1 col or current cell
    if presses == 2 and ((math.abs(x_col - currentCol) == 1 and y_row == currentRow) or (math.abs(y_row - currentRow) == 1 and x_col == currentCol)) then
        local newCol = x_col
        local newRow = y_row
        if newCol == currentCol + 1 and newRow == currentRow and currentCol < 6 then
            table.insert(moves, {x1=currentX, y1=currentY, x2=x, y2=y})
            currentCol = currentCol + 1
            local dat = player .. "," .. socket.gettime() - gameTimeMs .. "," .. "right," .. x .. "," .. y .. "\n"
            success, errormsg = love.filesystem.append(fname, dat)
        elseif newCol == currentCol - 1 and newRow == currentRow and currentCol > 1 then
            table.insert(moves, {x1=currentX, y1=currentY, x2=x, y2=y})
            currentCol = currentCol - 1
            local dat = player .. "," .. socket.gettime() - gameTimeMs .. "," .. "left," .. x .. "," .. y .. "\n"
            success, errormsg = love.filesystem.append(fname, dat)
        elseif newRow == currentRow + 1 and newCol == currentCol and currentRow < 6 then
            table.insert(moves, {x1=currentX, y1=currentY, x2=x, y2=y})
            currentRow = currentRow + 1
            local dat = player .. "," .. socket.gettime() - gameTimeMs .. "," .. "down," .. x .. "," .. y .. "\n"
            success, errormsg = love.filesystem.append(fname, dat)
        elseif newRow == currentRow - 1 and newCol == currentCol and currentRow > 1 then
            table.insert(moves, {x1=currentX, y1=currentY, x2=x, y2=y})
            currentRow = currentRow - 1
            local dat = player .. "," .. socket.gettime() - gameTimeMs .. "," .. "up," .. x .. "," .. y .. "\n"
            success, errormsg = love.filesystem.append(fname, dat)
        end
        currentX = x
        currentY = y
    end
end

function love.update(dt)

end

function love.draw()
    -- add column labels and highlight current column
    for i = 1,6 do
        if i == currentCol then
            love.graphics.setColor(1,1,1)
        else
            love.graphics.setColor(1,1,1,0.3)
        end
        love.graphics.draw(letters, letterFrames[i], cellSize + ((i-1) * cellSize), 0)
    end

    -- add row labels and highlight current row
    for i = 1,6 do
        if i == currentRow then
            love.graphics.setColor(1,1,1)
        else
            love.graphics.setColor(1,1,1,0.3)
        end
        love.graphics.draw(numbers, numberFrames[i], 0, cellSize + ((i-1) * cellSize))
    end

    for i, row in ipairs(colourMap) do
        for j, tile in ipairs(row) do
            love.graphics.setColor(colours[tile])
            love.graphics.rectangle("fill", j*cellSize, i*cellSize, cellSize, cellSize) -- draw colours
            love.graphics.setColor(0,0,0)                       -- black for lines
            love.graphics.rectangle("line", j*cellSize, i*cellSize, cellSize, cellSize) -- draw lines
            love.graphics.setColor(1,1,1)                       -- white for images
            love.graphics.draw(tangrams, imageFrames[imageMap[i][j]], j*cellSize, i*cellSize) -- draw tangrams
        end
    end
    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(3) -- highlight current square
    love.graphics.rectangle("line", currentCol*cellSize, currentRow*cellSize, cellSize, cellSize)
    love.graphics.setLineWidth(4)
    love.graphics.setColor(0,0,0,0.5)
    for i,move in ipairs(moves) do
        love.graphics.line(move.x1, move.y1, move.x2, move.y2) -- trace moves
    end
    love.graphics.setLineWidth(1)
end
