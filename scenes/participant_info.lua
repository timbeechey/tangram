local participant_info_scene = {}


function participant_info_scene.load()
    participant_id = {text = ""}
    player = {text = ""}
    group = {text = ""}
    random_seed = {text = ""}
end


function participant_info_scene.update(dt)
    suit.Label("Participant ID", 80, 100, 100, 30)
    suit.Input(participant_id, 200,100,200,30)
    suit.Label("Player Number", 80, 150, 100, 30)
    suit.Input(player, 200,150,200,30)
    suit.Label("Group", 80, 200, 100, 30)
    suit.Input(group, 200,200,200,30)
    suit.Label("Random seed", 80, 250, 100, 30)
    suit.Input(random_seed, 200,250,200,30)
    if suit.Button("Start", 200,300, 200,30).hit then
        SSM.remove("participant_info") -- clear info screen
        SSM.add("puzzle") -- show a puzzle
    end
end


-- forward keyboard events to the GUI
function love.textinput(t)
    suit.textinput(t)
end


function love.keypressed(key)
    suit.keypressed(key)
end


function participant_info_scene.draw()
    suit.draw()
end


return participant_info_scene