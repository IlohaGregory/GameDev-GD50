--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class { __includes = BaseState }

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:init()
    self.goldCup = love.graphics.newImage('download.png')
    self.quad = GeneratesQuads(self.goldCup)
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    FromPause = false
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
    GAP_HEIGHT = 150
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(mediumFont)
    if self.score < 10 then
        love.graphics.printf('Score : ' .. tostring(self.score) .. '\tyou get Bronze', 0, 100, 400, 'center')
        love.graphics.draw(self.goldCup, self.quad[3], 300, 100, 0, 0.3, 0.3)
    elseif self.score < 20 and self.score > 10 then
        love.graphics.printf('Score : ' .. tostring(self.score) .. '\tyou get Silver', 0, 100, 400, 'center')
        love.graphics.draw(self.goldCup, self.quad[2], 300, 100, 0, 0.3, 0.3)
    else
        love.graphics.printf('Score : ' .. tostring(self.score) .. '\tyou get Gold', 0, 100, 400, 'center')
        love.graphics.draw(self.goldCup, self.quad[1], 300, 100, 0, 0.3, 0.3)
    end
    love.graphics.printf('Press Enter to Play Again!', 0, 200, VIRTUAL_WIDTH, 'center')
end

function GeneratesQuads(atlas)
    local tileHeight = 100
    local tileWidth = 106
    local quads = {}
    for x = 0, 2 do
        quads[x + 1] = love.graphics.newQuad(x * tileWidth, 30, tileWidth, tileHeight, atlas:getDimensions())
    end
    return quads
end
