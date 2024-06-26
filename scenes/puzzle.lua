local puzzle_scene = {}

font = love.graphics.newFont(20)

-- Global parameters
Puzzle_number = 1 -- keep track of how many puzzles have been completed
CellSize = 120    -- size of squares that make up the puzzle grid


local function make_frames(m)
    local image_sets = {"set01.png", "set02.png", "set03.png", "set04.png"}
    local image_set_idx = math.random(1, #image_sets) -- choose 1 set of tangrams
    local colours = m.colour_map
    local images = m.image_map
    local tangrams = love.graphics.newImage(image_sets[image_set_idx])
    local image_width = tangrams:getWidth()
    local image_height = tangrams:getHeight()
    local imageFrames = {}
    local image_frame_width = CellSize
    local image_frame_height = CellSize

    for i = 0, 9 do
        table.insert(imageFrames, love.graphics.newQuad(i * image_frame_width, 0, image_frame_width, image_frame_height, image_width, image_height))
    end

    local letters = love.graphics.newImage("letters.png")
    local letters_width = letters:getWidth()
    local letters_height = letters:getHeight()
    local letterFrames = {}
    local letter_frame_width = CellSize
    local letter_frame_height = CellSize

    for i = 0, 5 do
        table.insert(letterFrames, love.graphics.newQuad(i * letter_frame_width, 0, letter_frame_width, letter_frame_height, letters_width, letters_height))
    end

    local numbers = love.graphics.newImage("numbers.png")
    local numbers_width = numbers:getWidth()
    local numbers_height = numbers:getHeight()
    local numberFrames = {}
    local number_frame_width = CellSize
    local number_frame_height = CellSize

    for i = 0, 5 do
        table.insert(numberFrames, love.graphics.newQuad(i * number_frame_width, 0, number_frame_width, number_frame_height, numbers_width, numbers_height))
    end

    -- blank out every other colour and tangram
    -- alternately for player 1 and player 2
    for i, row in ipairs(colours) do
        for j = 1, #row do
            if player.text == "1" then
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
            elseif player.text == "2" then
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


function puzzle_scene.load()
    require("generate")
    -- system icon for compiled application
    local icon = love.graphics.newImage("icon.png")
    -- use cocket library for milisecond precision time
    Socket = require("socket")
    -- get baseline start time in ms for logging results
    GameTimeMs = Socket.gettime()
    -- get start time and date for results filename
    GameTimeS = os.date('%Y%m%d_%H%M%S')
    Fname = "results_" .. GameTimeS .. ".csv"

    -- window background colour
    love.graphics.setBackgroundColor(1, 1, 1) -- white

    Colours = {
        {0, 115/255, 194/255},       -- blue
        {239/255, 192/255, 0},       -- yellow
        {134/255, 134/255, 134/255}, -- grey
        {1, 1, 1}                    -- white
    }

    local mps = MakeMaps()
    local frms = make_frames(mps)

    ColourMap = frms.colour_map
    ImageMap = frms.image_map
    ImageFrames = frms.imageFrames
    NumberFrames = frms.numberFrames
    LetterFrames = frms.letterFrames
    Letters = frms.letters
    Numbers = frms.numbers
    Tangrams = frms.tangrams

    -- start in the top left cell
    CurrentRow = 1
    CurrentCol = 1

    -- initial coordinate is the middle of the first cell
    CurrentX = (CurrentRow * CellSize) + ((CurrentRow * CellSize) / 2)
    CurrentY = (CurrentRow * CellSize) + ((CurrentRow * CellSize) / 2)
    -- empty moves table
    Moves = {}

    Success, ErrorMsg = love.filesystem.append(Fname, "time_since_epoch," .. "participant_id," .. "group," .. "puzzle_number," .. "time_since_puzzle_start," .. "move_direction," .. "x_coord," .. "y_cord," .. "row_num," .. "col_num\n")
end


function love.mousepressed(x, y, button, istouch, presses)
    -- calculate the column that corresponds to x and
    -- the row that corresponds to y
    local x_col = math.ceil((x-CellSize) / CellSize)
    local y_row = math.ceil((y-CellSize) / CellSize)
    -- check for double tap and that tap was within 1 row xor 1 col or current cell
    if presses == 2 and ((math.abs(x_col - CurrentCol) == 1 and y_row == CurrentRow) or (math.abs(y_row - CurrentRow) == 1 and x_col == CurrentCol)) then
        local newCol = x_col
        local newRow = y_row
        if newCol == CurrentCol + 1 and newRow == CurrentRow and CurrentCol < 6 then
            table.insert(Moves, {x1=CurrentX, y1=CurrentY, x2=x, y2=y})
            CurrentCol = CurrentCol + 1
            local dat = Socket.gettime() .. "," .. participant_id.text .. "," .. group.text .. "," .. Puzzle_number .. "," .. Socket.gettime() - GameTimeMs .. "," .. "right," .. x .. "," .. y .. "," .. CurrentRow .. "," .. CurrentCol .. "\n"
            Success, ErrorMsg = love.filesystem.append(Fname, dat)
        elseif newCol == CurrentCol - 1 and newRow == CurrentRow and CurrentCol > 1 then
            table.insert(Moves, {x1=CurrentX, y1=CurrentY, x2=x, y2=y})
            CurrentCol = CurrentCol - 1
            local dat = Socket.gettime() .. "," .. participant_id.text .. "," .. group.text .. "," .. Puzzle_number .. "," .. Socket.gettime() - GameTimeMs .. "," .. "left," .. x .. "," .. y .. "," .. CurrentRow .. "," .. CurrentCol .. "\n"
            Success, ErrorMsg = love.filesystem.append(Fname, dat)
        elseif newRow == CurrentRow + 1 and newCol == CurrentCol and CurrentRow < 6 then
            table.insert(Moves, {x1=CurrentX, y1=CurrentY, x2=x, y2=y})
            CurrentRow = CurrentRow + 1
            local dat = Socket.gettime() .. "," .. participant_id.text .. "," .. group.text .. "," .. Puzzle_number .. "," .. Socket.gettime() - GameTimeMs .. "," .. "down," .. x .. "," .. y .. "," .. CurrentRow .. "," .. CurrentCol .. "\n"
            Success, Errormsg = love.filesystem.append(Fname, dat)
        elseif newRow == CurrentRow - 1 and newCol == CurrentCol and CurrentRow > 1 then
            table.insert(Moves, {x1=CurrentX, y1=CurrentY, x2=x, y2=y})
            CurrentRow = CurrentRow - 1
            local dat = Socket.gettime() .. "," .. participant_id.text .. "," .. group.text .. "," .. Puzzle_number .. "," .. Socket.gettime() - GameTimeMs .. "," .. "up," .. x .. "," .. y .. "," .. CurrentRow .. "," .. CurrentCol .. "\n"
            Success, Errormsg = love.filesystem.append(Fname, dat)
        end
        CurrentX = x
        CurrentY = y
    end
    if CurrentRow == 6 and CurrentCol == 6 then
        love.graphics.captureScreenshot("image" .. GameTimeS .. "_" .. Puzzle_number .. ".png")
    end
end


function puzzle_scene.update(dt)
    -- next puzzle button
    if suit.Button("Next", 900, 200, 200, 50).hit then
        Puzzle_number = Puzzle_number + 1
        -- set up a new puzzle
        local mps = MakeMaps()
        local frms = make_frames(mps)

        ColourMap = frms.colour_map
        ImageMap = frms.image_map
        ImageFrames = frms.imageFrames
        NumberFrames = frms.numberFrames
        LetterFrames = frms.letterFrames
        Letters = frms.letters
        Numbers = frms.numbers
        Tangrams = frms.tangrams

        -- start in the top left cell
        CurrentRow = 1
        CurrentCol = 1

        -- initial coordinate is the middle of the first cell
        CurrentX = (CurrentRow * CellSize) + ((CurrentRow * CellSize) / 2)
        CurrentY = (CurrentRow * CellSize) + ((CurrentRow * CellSize) / 2)

        Moves = {}
        -- restart timer
        GameTimeMs = Socket.gettime()

    end

    -- end game button
    if suit.Button("Exit", 900, 280, 200, 50).hit then
        love.event.quit()
    end
end


function puzzle_scene.draw()
    -- add exit and next puzzle buttons
    suit.draw()
    -- add column labels and highlight current column
    for i = 1, 6 do
        if i == CurrentCol then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1, 0.3)
        end
        love.graphics.draw(Letters, LetterFrames[i], CellSize + ((i - 1) * CellSize), 0)
    end

    -- add row labels and highlight current row
    for i = 1, 6 do
        if i == CurrentRow then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1, 0.3)
        end
        love.graphics.draw(Numbers, NumberFrames[i], 0, CellSize + ((i - 1) * CellSize))
    end

    for i, row in ipairs(ColourMap) do
        for j, tile in ipairs(row) do
            love.graphics.setColor(Colours[tile])
            love.graphics.rectangle("fill", j*CellSize, i*CellSize, CellSize, CellSize) -- draw colours
            love.graphics.setColor(0, 0, 0)  -- black for lines
            love.graphics.rectangle("line", j*CellSize, i*CellSize, CellSize, CellSize) -- draw lines
            love.graphics.setColor(1, 1, 1)  -- white for images
            love.graphics.draw(Tangrams, ImageFrames[ImageMap[i][j]], j*CellSize, i*CellSize) -- draw tangrams
        end
    end
    if CurrentRow == 6 and CurrentCol == 6 then
        love.graphics.setColor(0, 1, 0) -- border final cell green
        love.graphics.setLineWidth(7) -- highlight final cell
    else
        love.graphics.setColor(1, 0, 0) -- red
        love.graphics.setLineWidth(7) -- highlight current square
    end
    love.graphics.rectangle("line", CurrentCol * CellSize, CurrentRow * CellSize, CellSize, CellSize)
    love.graphics.setLineWidth(7)
    love.graphics.setColor(1, 0, 0, 0.7) -- red line colour
    for _, move in ipairs(Moves) do
        love.graphics.line(move.x1, move.y1, move.x2, move.y2) -- trace moves
    end
    love.graphics.setColor(0, 0, 0) -- back to black
    love.graphics.setLineWidth(1)

    love.graphics.print("Puzzle number: " .. tostring(Puzzle_number), font, 900, 650)
end


return puzzle_scene
