PauseState = Class { __includes = BaseState }

function PauseState:update(dt)
    FromPause = true
    if love.keyboard.wasPressed('p') == true then
        gStateMachine:change('countdown')
    end
end

function PauseState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Press p to resume', 0, 64, VIRTUAL_WIDTH, 'center')
end
