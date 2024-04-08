SSM = require "libs.StackingSceneMgr".newManager() -- scene manager
suit = require 'libs.suit'                         -- GUI

-- folder containing scene files
SSM.setPath("scenes/")


function love.load()
    SSM.add("participant_info")
end


function love.update(dt)
    SSM.update(dt)
end


function love.draw()
    SSM.draw()
end
