function make_frames(m)
    local cellSize = 120

    local colours = m.colour_map
    local images = m.image_map

    local tangrams = love.graphics.newImage("set02.png")
    local image_width = tangrams:getWidth()
    local image_height = tangrams:getHeight()

    local imageFrames = {}
    local image_frame_width = cellSize
    local image_frame_height = cellSize

    for i=0, 9 do
        table.insert(imageFrames, love.graphics.newQuad(i * image_frame_width, 0, image_frame_width, image_frame_height, image_width, image_height))
    end

    local letters = love.graphics.newImage("letters.png")
    local letters_width = letters:getWidth()
    local letters_height = letters:getHeight()

    local letterFrames = {}
    local letter_frame_width = cellSize
    local letter_frame_height = cellSize

    for i=0,5 do
        table.insert(letterFrames, love.graphics.newQuad(i * letter_frame_width, 0, letter_frame_width, letter_frame_height, letters_width, letters_height))
    end

    local numbers = love.graphics.newImage("numbers.png")
    local numbers_width = numbers:getWidth()
    local numbers_height = numbers:getHeight()

    local numberFrames = {}
    local number_frame_width = cellSize
    local number_frame_height = cellSize

    for i = 0, 5 do
        table.insert(numberFrames, love.graphics.newQuad(i * number_frame_width, 0, number_frame_width, number_frame_height, numbers_width, numbers_height))
    end

    finished = false
    
    player = 0
    
    -- blank out every other colour and tangram
    -- alternately for player 1 and player 2
    for i, row in ipairs(colours) do
        for j, col in ipairs(row) do
            if player == 1 then
                if i % 2 == 1 then -- odd row
                    if j % 2 == 1 then -- odd column
                        colours[i][j] = 4
                    elseif j % 2 == 0 then -- odd row, even column
                        images[i][j] = 10
                    end
                elseif j % 2 == 0 then -- even row, even column
                    colours[i][j] = 4
                elseif i % 2 == 0 then -- even row, odd column
                    images[i][j] = 10
                end
            elseif player == 2 then
              
              if i % 2 == 1 then -- odd row
                    if j % 2 == 0 then -- even column
                        colours[i][j] = 4
                    elseif j % 2 == 1 then
                        images[i][j] = 10
                    end
                elseif j % 2 == 1 then
                    colours[i][j] = 4
                elseif i % 2 == 0 then
                    images[i][j] = 10
                end
              
            end
        end
    end
    return {image_map = images, colour_map = colours, 
            imageFrames = imageFrames, numberFrames = numberFrames, 
            letterFrames = letterFrames,
            letters = letters, numbers = numbers, tangrams = tangrams}
end

function love.load()
    require("generate")

    icon = love.graphics.newImage("icon.png")

    socket = require("socket") -- for milisecond precision time
    -- get baseline start time in ms for logging results
    gameTimeMs = socket.gettime()
    -- get start time and date for results filename
    gameTimeS = os.date('%Y%m%d_%H%M%S')
    fname = "results_" .. gameTimeS .. ".txt"

    love.graphics.setBackgroundColor(1, 1, 1)

    cellSize = 120

    colours = {
        {246/255, 156/255, 51/255},  -- orange
        {133/255, 136/255, 255/255}, -- blue
        {1/255, 144/255, 67/255},    -- green
        {1, 1, 1}                    -- white
    }

    mps = make_maps()
    frms = make_frames(mps)

    colourMap = frms.colour_map
    imageMap = frms.image_map
    imageFrames = frms.imageFrames
    numberFrames = frms.numberFrames
    letterFrames = frms.letterFrames
    letters = frms.letters
    numbers = frms.numbers
    tangrams = frms.tangrams

    finished = false

    -- start in the top left cell
    currentRow = 1
    currentCol = 1
    
    -- initial coordinate is the middle of the first cell
    currentX = (currentRow * cellSize) + ((currentRow * cellSize) / 2)
    currentY = (currentRow * cellSize) + ((currentRow * cellSize) / 2)
    
    moves = {}
    
    success, errormsg = love.filesystem.append(fname, "player" .. "time," .. "direction," .. "x," .. "y" .. "\n")
        
end

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
    if finished == true then
        mps = make_maps()
        frms = make_frames(mps)

        colourMap = frms.colour_map
        imageMap = frms.image_map
        imageFrames = frms.imageFrames
        numberFrames = frms.numberFrames
        letterFrames = frms.letterFrames
        letters = frms.letters
        numbers = frms.numbers
        tangrams = frms.tangrams

        -- start in the top left cell
        currentRow = 1
        currentCol = 1
        
        -- initial coordinate is the middle of the first cell
        currentX = (currentRow * cellSize) + ((currentRow * cellSize) / 2)
        currentY = (currentRow * cellSize) + ((currentRow * cellSize) / 2)
        
        moves = {}
    end
end

function love.draw()
    -- add column labels and highlight current column
    for i = 1, 6 do
        if i == currentCol then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1, 0.3)
        end
        love.graphics.draw(letters, letterFrames[i], cellSize + ((i - 1) * cellSize), 0)
    end

    -- add row labels and highlight current row
    for i = 1, 6 do
        if i == currentRow then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1, 0.3)
        end
        love.graphics.draw(numbers, numberFrames[i], 0, cellSize + ((i - 1) * cellSize))
    end

    for i, row in ipairs(colourMap) do
        for j, tile in ipairs(row) do
            love.graphics.setColor(colours[tile])
            love.graphics.rectangle("fill", j*cellSize, i*cellSize, cellSize, cellSize) -- draw colours
            love.graphics.setColor(0, 0, 0)  -- black for lines
            love.graphics.rectangle("line", j*cellSize, i*cellSize, cellSize, cellSize) -- draw lines
            love.graphics.setColor(1, 1, 1)  -- white for images
            love.graphics.draw(tangrams, imageFrames[imageMap[i][j]], j*cellSize, i*cellSize) -- draw tangrams
        end
    end
    if currentRow == 6 and currentCol == 6 then
        love.graphics.setColor(0, 1, 0) -- final cell
        love.graphics.setLineWidth(7) -- highlight final square
    else
        love.graphics.setColor(0, 0, 0)
        love.graphics.setLineWidth(5) -- highlight current square
    end
    love.graphics.rectangle("line", currentCol*cellSize, currentRow*cellSize, cellSize, cellSize)
    love.graphics.setLineWidth(7)
    love.graphics.setColor(0, 0, 0, 0.5)
    for i,move in ipairs(moves) do
        love.graphics.line(move.x1, move.y1, move.x2, move.y2) -- trace moves
    end
    love.graphics.setLineWidth(1)

    if currentRow == 6 and currentCol == 6 then
        finished = true
    end
end
